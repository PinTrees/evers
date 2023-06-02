
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/system.dart';
import 'package:evers/class/system/state.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:evers/page/window/window_ledger_revenue.dart';
import 'package:evers/ui/ux.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/aes.dart';
import '../../helper/style.dart';
import '../revenue.dart';
import '../transaction.dart';
import '../widget/excel.dart';
import 'item.dart';

class Ledger {
  var state = '';
  var id = '';
  var csUid = '';
  var ctUid = '';
  var revenueList = [];

  var writer = '';
  var fileUrl = '';
  var date = 0;

  var history = [];

  Ledger.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';
    writer = json['writer'] ?? '';
    ctUid = json['ctUid'] ?? '';
    csUid = json['csUid'] ?? '';
    revenueList = (json['revenueList'] != null) ? json['revenueList'] as List : [];
    fileUrl =  json['fileUrl'] ?? '';
    date = json['date'] ?? 0;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
      'date': date,
      'csUid': csUid,
      'ctUid': ctUid,
      'writer': writer,
      'revenueList': revenueList as List,
      'fileUrl': fileUrl,
    };
  }

  dynamic getSearchText() {
    return '';
  }

  /// LR
  /// 문서 UID 발급 함수
  /// 이 함수는 데이터베이스에서 유일한 키값 발급을 요청하고 결과를 반환합니다.
  dynamic createUid() async {
    var dateIdDay = DateStyle.dateYearMD(date);
    var dateIdMonth = DateStyle.dateYearMM(date);

    var db = FirebaseFirestore.instance;
    final refMeta = db.collection('meta/uid/dateM-ledgerRevenue').doc(dateIdMonth);

    return await db.runTransaction((transaction) async {
      final snMeta = await transaction.get(refMeta);

      /// 개수는 100% 트랜잭션을 보장할 수 없음
      /// 고유한 형식만 보장
      /// 개수가 업데이트된 후 문서 저장에 실패할 경우 예외처리 안함
      if(snMeta.exists) {
        if((snMeta.data() as Map)[dateIdDay] != null) {
          var currentRevenueCount = (snMeta.data() as Map)[dateIdDay] as int;
          currentRevenueCount++;
          id = '$dateIdDay-$currentRevenueCount';
          transaction.update(refMeta, { dateIdDay: FieldValue.increment(1)});
        }
        else {
          id = '$dateIdDay-1';
          transaction.update(refMeta, { dateIdDay: 1});
        }
      } else {
        id = '$dateIdDay-1';
        transaction.set(refMeta, { dateIdDay: 1 });
      }
    }).then(
            (value) { print("DocumentSnapshot successfully updated createUid!"); return true; },
        onError: (e) { print("Error createUid() $e"); return false; }
    );
  }


  /// 이 함수는 데이터베이스에 매출원장 생성을 요청하고 작업결과를 반환합니다.
  dynamic update(Uint8List ledgerFile) async {
    var create = false;
    if(id == '')  { create = true; }
    if(create) await createUid();
    if(id == '') return false;

    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(date));
    if(ledgerFile != null) {
      var url = await StorageHub.updateFile('ledger/revenue', 'LR', ledgerFile, id + '.pdf');
      fileUrl = url;
    }

    var org = Ledger.fromDatabase({});
    if(org != null) {
      /// create history
    }

    var dateIdHarp = DateStyle.dateYearsHarp(date);
    var dateIdQuarter = DateStyle.dateYearsQuarter(date);
    var searchText = await getSearchText();

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    Map<String, DocumentReference<Map<String, dynamic>>> revenueRef = {};
    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("ledger/revenue/article").doc(id);
    final dateRef = db.collection('meta/date-m/ledgerRevenue').doc(dateId);

    revenueList.forEach((e) { revenueRef[e] = db.collection('revenue').doc(e); });
    
    /// 거래처 분산기록 경로
    if(csUid != '') ref['cs'] = db.collection('customer').doc(csUid);
    if(csUid != '') ref['csDetail'] = db.collection('customer/${csUid}/cs-dateH-ledgerRevenue').doc(dateIdHarp);

    /// 계약 분산기록 경로
    if(ctUid != '') ref['ct'] = db.collection('contract').doc(ctUid);
    if(ctUid != '') ref['ctDetail'] = db.collection('contract/${ctUid}/ct-dateH-ledgerRevenue').doc(dateIdHarp);
    
    /// 검색문서 기록 경로
    final searchRef = db.collection('meta/search/dateQ-ledgerRevenue').doc(dateIdQuarter);

    /// 원장 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      Map<String, DocumentSnapshot<Map<String, dynamic>>> revenueSn = {};

      final  docRefSn = await transaction.get(docRef);
      final  docDateRefSn = await transaction.get(dateRef);
      final  searchSn = await transaction.get(searchRef);
      if(ref['cs'] != null) sn['cs'] = await transaction.get(ref['cs']!);
      if(ref['csDetail'] != null) sn['csDetail'] = await transaction.get(ref['csDetail']!);
      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);

      if(revenueRef.values.length > 0) {
        for(var key in revenueRef.keys) {
          var rSn = await transaction.get(revenueRef[key]!);
          revenueSn[key] = rSn;
        }
      }

      revenueSn.keys.forEach((key) {
        if(revenueSn[key]!.exists) transaction.update(revenueRef[key]!, { 'isLedger': true, });
      });

      if(org != null) {
        /// history 문서 추가 로직 작성
        //if(sn['orgSearch']!.exists && dateIdQuarter != orgDateQuarterId && orgDateQuarterId != '-')
        //  transaction.update(ref['orgSearch']!, {'list\.${org.id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});
      }

      /// 문서경로 오류
      if(create && docRefSn.exists) return false;
      /// 병합 및 덮어쓰기 분기
      if(docRefSn.exists) transaction.update(docRef, toJson());
      else transaction.set(docRef, toJson());

      /// 날짜분산기록 병합 및 덮어쓰기 분기
      if(docDateRefSn.exists) transaction.update(dateRef, { id: toJson(), });
      else transaction.set(dateRef, { id: toJson() });

      /// 거래처 문서 정보 존재시
      if(ref['cs'] != null) {
        if(create) transaction.update(ref['cs']!, {'lrCount': FieldValue.increment(1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});

        /// 거래처 분산기록 병합 및 덮어쓰기 분기
        if(sn['csDetail']!.exists) transaction.update(ref['csDetail']!, { id: toJson(), });
        else transaction.set(ref['csDetail']!, { id: toJson(), });
      }

      /// 계약 문서정보 존재시
      if(ref['ct'] != null) {
        if(create) if(sn['ct']!.exists) transaction.update(ref['ct']!, {'lrCount': FieldValue.increment(1),});

        /// 계약 분산기록 병합 및 덮어쓰기 분기
        if(sn['ctDetail']!.exists) transaction.update(ref['ctDetail']!, { id: toJson(), });
        else transaction.set(ref['ctDetail']!, { id: toJson(), });
      }
      
      /// 검색 문서정보 병합 및 덮어쓰기 분기
      if(searchSn.exists) transaction.update(searchRef, { id: searchText, },);
      else transaction.set(searchRef, { id : searchText, },);
    }).then(
            (value) { print("ledgerRevenue() updated!"); return true; },
        onError: (e) { print("Error update ledgerRevenue() $e"); return false; }
    );
  }


  /// 이 함수는 데이터베이스에서 원장기록 제거를 요청합니다.
  /// 원장파일 제거
  /// 원장과 참조중인 거래처 및 계약정보 분산기록문서 제거
  /// 원장의 생성정보 매출기록문서 원장생성여부 존재안함으로 변경
  dynamic delete() async {
    state = 'DEL';
    if(id == '')  { return false; }
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(date));
    var dateIdHarp = DateStyle.dateYearsHarp(date);
    var dateIdQuarter = DateStyle.dateYearsQuarter(date);

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    Map<String, DocumentReference<Map<String, dynamic>>> revenueDocRef = {};
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("ledger/revenue/article").doc(id);
    final dateRef = db.collection('meta/date-m/ledgerRevenue').doc(dateId);

    revenueList.forEach((e) { revenueDocRef[e] = db.collection('revenue').doc(e); });

    /// 거래처 분산기록 경로
    if(csUid != '') ref['cs'] = db.collection('customer').doc(csUid);
    if(csUid != '') ref['csDetail'] = db.collection('customer/${csUid}/cs-dateH-ledgerRevenue').doc(dateIdHarp);

    /// 계약 분산기록 경로
    if(ctUid != '') ref['ct'] = db.collection('contract').doc(ctUid);
    if(ctUid != '') ref['ctDetail'] = db.collection('contract/${ctUid}/ct-dateH-ledgerRevenue').doc(dateIdHarp);

    /// 검색문서 기록 경로
    final searchRef = db.collection('meta/search/dateQ-ledgerRevenue').doc(dateIdQuarter);

    return await db.runTransaction((transaction) async {
      /// 각 문서경로에 대한 트랜잭션 스냅샷을 설정합니다.
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      Map<String, DocumentSnapshot<Map<String, dynamic>>> revenueSn = {};
      final  docRefSn = await transaction.get(docRef);
      final  docDateRefSn = await transaction.get(dateRef);
      final  searchSn = await transaction.get(searchRef);

      if(ref['cs'] != null) sn['cs'] = await transaction.get(ref['cs']!);
      if(ref['csDetail'] != null) sn['csDetail'] = await transaction.get(ref['csDetail']!);
      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);

      if(docRefSn.exists) transaction.update(docRef, toJson());
      if(docDateRefSn.exists) transaction.update(dateRef, { id: FieldValue.delete(), });

      if(revenueDocRef.values.length > 0) {
        for(var r in revenueDocRef.keys) {
          var rSn = await transaction.get(revenueDocRef[r]!);
          revenueSn[r] = rSn;
        }
      }

      /// 여기서부터 트랜잭션 문서 업데이트 및 제거를 시작합니다.
      /// 원장을 생성한 매출기록문서의 원장생성정보를 초기화합니다.
      revenueSn.keys.forEach((key) {
        if(revenueSn[key]!.exists) transaction.update(revenueDocRef[key]!, { 'isLedger': false, });
      });

      /// 거래처 분산기록문서 제거
      if(ref['cs'] != null) {
        if(sn['cs']!.exists) transaction.update(ref['cs']!, {'lrCount': FieldValue.increment(-1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        if(sn['csDetail']!.exists) transaction.update(ref['csDetail']!, { id: FieldValue.delete(), });
      }

      /// 계약 분산기록문서 제거
      if(ref['ct'] != null) {
        if(sn['ct']!.exists) transaction.update(ref['ct']!, {'lrCount': FieldValue.increment(-1),});
        if(sn['ctDetail']!.exists) transaction.update(ref['ctDetail']!, { id: FieldValue.delete(), });
      }

      /// 검색 분산기록헤더 제거
      if(searchSn.exists) transaction.update(searchRef, { id: FieldValue.delete(), },);
    }).then(
            (value) { print("ledgerRevenue() successfully updated!"); return true; },
        onError: (e) { print("Error delete ledgerRevenue() $e"); return false; }
    );
  }


  static Widget onTableHeader() {
    return WidgetUI.titleRowNone([ '순번', '구분', '날짜', '작성자', '목록' ], [ 28, 100, 100, 100, 999], background: true, lite: true);
  }

  Widget onTableUI(BuildContext context, {
    required Function refresh,
    int? index, Function? state, Function? onEdite }) {
    return InkWell(
      onTap: () {
        UIState.OpenNewWindow(context, WindowLedgerRe(ledger: this, refresh: refresh));
      },
      child: Container(
        height: 28,
        child: Row(
          children: [
            ExcelT.LitGrid(text: '${index ?? 0 + 1}', width: 28, center: true),
            ExcelT.LitGrid(width: 100, text: id, center: true),
            ExcelT.LitGrid(width: 100, text: StyleT.dateInputFormatAtEpoch(date.toString()), center: true),
            ExcelT.Grid(width: 100, text: writer, expand: true, textSize: 10),
            ExcelT.LitGrid(width: 500, text: revenueList.join(', '), expand: true),
            ButtonT.IconText(icon: Icons.open_in_new_sharp,
              text: "원장보기",
              color: Colors.transparent,
              onTap: () async {
                var downloadUrl = fileUrl;
                PdfManager.OpenPdf(downloadUrl, "출고원장.pdf");
              }
            )
          ],
        ),
      ),
    );
  }
}