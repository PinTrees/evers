import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/dialog/dialog_itemInventory.dart';
import 'package:evers/helper/dialog.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/ux.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../Customer.dart';
import '../contract.dart';
import '../revenue.dart';
import '../system.dart';
import '../widget/excel.dart';
import '../widget/list.dart';
import '../widget/text.dart';
import 'item.dart';




/// 품목 거래 이동 입출 현황 기록 클래스
///
/// @Create YM
/// @Update YM 23.04.10
/// @Version 1.1.0
class ProcessItem {
  var id = '';
  var state = '';
  var type = '';          /// 동결, 건조, 가공 분류코드 - END = 완료

  var amount = 0.0;       /// 입고량
  var usedAmount = 0.0;

  /// dev
  var prUid = '';         /// 부모 상속값
  var itUid = '';         /// 품목 고유번호
  var rpUid = '';         /// 매입매출번호
  var ctUid = '';         /// 입고계약
  var csUid = '';         /// 거래처

  var date = 0;           /// 작업 시작일
  var endAt = 0;

  var writer = '';        /// 작성자
  var updateAt = 0;       /// 문서 변경시각

  var isUsed = false;
  var isDone = false;
  var isOutput = false;

  var filesMap = {};      /// 첨부파일
  var memo = "";

  ProcessItem.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';
    type = json['type'] ?? '';

    csUid = json['csUid'] ?? '';
    ctUid = json['ctUid'] ?? '';

    writer = json['writer'] ?? '';

    prUid = json['prUid'] ?? '';
    rpUid = json['rpUid'] ?? '';
    itUid = json['itUid'] ?? '';

    amount = json['amount'] ?? 0;
    usedAmount = json['usedAmount'] ?? 0;

    isUsed = json['isUsed'] ?? false;
    isDone = json['isDone'] ?? false;
    isOutput = json['isOutput'] ?? false;

    date = json['date'] ?? 0;
    endAt = json['endAt'] ?? 0;
    updateAt = json['updateAt'] ?? 0;
    filesMap = (json['filesMap'] != null) ? json['filesMap'] as Map : {};

    memo = json['memo'] ?? '';
  }
  Map<String, dynamic> toJson() {
    return {
      'id' : id,
      'state' : state,       // D,
      'type' : type,       // P 매입, R 매출, F 동결,

      'prUid' : prUid,       /// 매입매출번호
      'rpUid' : rpUid,       /// 매입매출번호
      'itUid' : itUid,       /// 품목 고유번호

      'amount' : amount,       /// 입고량
      'usedAmount' : usedAmount,       /// 입고량

      'ctUid' : ctUid,         /// 입고계약
      'csUid' : csUid,         /// 거래처

      'date' : date,          /// 입고일자
      'endAt' : endAt,          /// 입고일자

      'writer' : writer,        /// 작성자
      'updateAt' : updateAt,       /// 문서 변경시각

      'isUsed': isUsed,
      'isDone': isDone,
      'isOutput': isOutput,

      'filesMap' : filesMap,      /// 첨부파일
      'memo' : memo,
    };
  }

  dynamic getHistory({ int? startAt, int? lastAt }) async {  }
  
  /// 매우 엄격한 유일성 검사 중요도 낮음
  /// 무작위 16바이트 문자열
  dynamic createUID() async {
    if(id == '') {
      id = SystemT.generateRandomString(16);
    }
  }

  /// 이 함수는 해당 클래스를 직렬화 하여 데이터베이스에 기록합니다.
  ///
  /// (***) 문서 업데이트시 기존 org 반드시 첨부
  /// 현재 문서의 UID 가 != ''이 아닐경우 기존 기록을 히스토리로 변경
  /// 히스토리에 기록시 문서 UID는 현재 시간의 에폭시 값으로 변경
  dynamic update({ Map<String, Uint8List>? files, }) async {
    var create = false;
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(date));

    if(rpUid == '') return false;

    if(id == '')  { create = true; }
    if(create) await createUID();
    if(id == '') return false;

    ProcessItem? org = await DatabaseM.getItemTrans(id);
    var dateIdHarp = DateStyle.dateYearsHarp(date);
    var dateIdQuarter = DateStyle.dateYearsQuarter(date);

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;

    /// 내부 트랜잭션 다시 작성
    /// 테스트 필요
    /// 메인문서 기록
    final docRef = db.collection("purchase/$rpUid/item-process").doc(id);
    var docParentRef = null;
    if(isOutput && prUid != "") docParentRef = db.collection("purchase/$rpUid/item-process").doc(prUid);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final docRefSn = await transaction.get(docRef);
      DocumentSnapshot<Map<String, dynamic>>? docParentSn = null;
      if(docParentRef != null) docParentSn = await transaction.get(docParentRef);

      /// 트랜잭션 내부
      if(create && docRefSn.exists) return false;
      if(docRefSn.exists) transaction.update(docRef, toJson());
      else transaction.set(docRef, toJson());

      if(docParentSn != null) {
        if(docParentSn.exists) transaction.update(docParentRef, { 'endAt': date, });
        /// else 분기 오류
      }
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error update ts item() $e"); return false; }
    );
  }


  dynamic delete() async {

  }

  static Widget onTableHeader() {
    return WidgetUI.titleRowNone(['순번', '품목명', '가공공정', '상태', '작업시작 수량', '작업완료 수량', '작업중인 수량', '가공일'],
        [ 28, 200, 100, 100, 100, 100, 100, 150], background: true, lite: true);
  }
  Widget OnTableUI( { BuildContext? context,  Item? item, Function? onTap, Function? setState,
    double? usedAmount,
  } ) {
    if(isOutput) {
      return InkWell(
        onTap: () async {
          if(onTap != null) onTap();
          if(setState != null) setState();
        },
        child: Container(
          height: 28,
          child: Row(
            children: [
              ExcelT.LitGrid(text: "-", width: 28),
              ExcelT.LitGrid(text: item == null ? 'NULL' : item.name, width: 200, center: true),
              ExcelT.LitGrid(text: MetaT.processType[type] ?? 'NULL', width: 100, center: true),
              ExcelT.LitGrid(text: isDone ? "완료" : '가공중', width: 100, center: true),
              ExcelT.LitGrid(text: StyleT.krwInt((amount).toInt()), width: 200, center: true),
              ExcelT.LitGrid(text: DateStyle.dateYearMonthDayHipen(date), width: 150, center: true),
              ButtonT.IconText(
                text: "수정",
                color: Colors.transparent,
                onTap: () async {
                  if(context == null) return;

                  WidgetT.showSnackBar(context, text: '개발중');

                  if(setState != null) setState();
                },
                icon: Icons.create,
              ),
            ],
          ),
        ),
      );
    }
    else {
      var amountM = amount - ((usedAmount == null) ? 0 : usedAmount!.abs());

      return InkWell(
        onTap: () async {
          if(onTap != null) onTap();
          if(setState != null) setState();
        },
        child: Container(
          height: 28,
          child: Row(
            children: [
              ExcelT.LitGrid(text: "-", width: 28),
              ExcelT.LitGrid(text: item == null ? 'NULL' : item.name, width: 200, center: true),
              ExcelT.LitGrid(text: MetaT.processType[type] ?? 'NULL', width: 100, center: true),
              ExcelT.LitGrid(text: amountM <= 0 ? "완료" : '가공중', width: 100, center: true),
              ExcelT.LitGrid(text: StyleT.krwInt(amount.toInt()),
                  width: 100, center: true),
              ExcelT.LitGrid(text: StyleT.krwInt(((usedAmount == null) ? 0 : usedAmount!.abs()).toInt()),
                  width: 100, center: true),
              ExcelT.LitGrid(text: StyleT.krwInt((amount - ((usedAmount == null) ? 0 : usedAmount!.abs())).toInt()),
                  width: 100, center: true),

              ExcelT.LitGrid(text: DateStyle.dateYearMonthDayHipen(date), width: 150, center: true),
              ButtonT.IconText(
                text: "수정",
                color: Colors.transparent,
                onTap: () async {
                  if(context == null) return;

                  WidgetT.loadingBottomSheet(context);
                  await update();
                  Navigator.pop(context);

                  if(setState != null) setState();
                },
                icon: Icons.create,
              ),
              !isDone ? ButtonT.IconText(
                icon: Icons.done,
                text: "작업 완료하기",
                color: Colors.transparent,
                onTap: () async {
                  if(context == null) return;

                  /// 작업완료대상의 품목정보 재구성 - 가공완료수량 리밋 수정
                  var parentProcess = ProcessItem.fromDatabase(this.toJson());
                  parentProcess.amount = this.amount - ((usedAmount == null) ? 0 : usedAmount!.abs());
                  
                  var result = await DialogItemInven.createOutputItem(context, process: parentProcess);
                  if(result == null) await WidgetT.showSnackBar(context, text: "Database Error");
                  else await WidgetT.showSnackBar(context, text: "저장됨");

                  if(setState != null) setState();
                  /// 현재 작업은 완료로 변경
                  /// 작업 완료 물품을 추가
                  /// 작업완료 물품 입력폼을 추가후 해당목록을 업데이트할떄 모든 문서에대한 트랜잭션을 구현
                  /// 추후 직접 입력으로 변경
                },
              )
                  : SizedBox(),
            ],
          ),
        ),
      );
    }
  }
}