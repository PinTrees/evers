import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/helper/style.dart';
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




/// 품목 작업 이동 기록 데이터 클래스
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
  ProcessItem.fromItemTS(ItemTS itemTS) {
    csUid = itemTS.csUid;
    ctUid = itemTS.ctUid;
    rpUid = itemTS.rpUid;
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


    ProcessItem? parent;
    List<ProcessItem> outputList = [];
    if(isOutput) {
      parent = await DatabaseM.getProcessItemDoc(rpUid, prUid);
      outputList= await DatabaseM.getProcessItemGroupByPrUid(prUid);

      var usedAmount = 0.0;
      outputList.forEach((e) { usedAmount += e.usedAmount.abs(); });
      if(parent != null && usedAmount > 0.0) {
        parent.endAt = date;
        if(parent.amount <= usedAmount - 0.0001) parent.isDone = true;
      }
    }

    ProcessItem? org = await DatabaseM.getItemTrans(id);
    var dateIdHarp = DateStyle.dateYearsHarp(date);
    var dateIdQuarter = DateStyle.dateYearsQuarter(date);

    /// 내부 트랜잭션 다시 작성
    /// 테스트 필요
    /// 메인문서 기록
    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;

    final docRef = db.collection("purchase/$rpUid/item-process").doc(id);
    var docParentRef = null;
    if(isOutput && parent != null) docParentRef = db.collection("purchase/$rpUid/item-process").doc(prUid);
    final balanceRef = db.collection('balance/dateQ-process/${itUid}').doc(dateIdQuarter);
    final mainBalanceRef = db.collection('meta/itemInven/${itUid}').doc(dateIdQuarter);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final docRefSn = await transaction.get(docRef);
      final balanceSn = await transaction.get(balanceRef);
      final mainBalanceSn = await transaction.get(mainBalanceRef);

      DocumentSnapshot<Map<String, dynamic>>? docParentSn = null;
      if(docParentRef != null) docParentSn = await transaction.get(docParentRef);

      /// 트랜잭션 내부
      if(create && docRefSn.exists) return false;
      if(docRefSn.exists) transaction.update(docRef, toJson());
      else transaction.set(docRef, toJson());

      /// 출고품이 아닐경우 사용량 재고에서 카운트
      /// 해당 로직은 최초 가공공정 등록시에만 실행되는 로직입니다.
      if(!isOutput && !isDone) {
        if(mainBalanceSn.exists) transaction.update(mainBalanceRef, { id: amount.abs() * -1 });
        else transaction.set(mainBalanceRef, { id: amount.abs() * -1 });
      }

      /// 출고품일 경우 기초 재고 및 작업내역값에서도 적용
      if(isOutput) {
        if(mainBalanceSn.exists) {
          transaction.update(mainBalanceRef, { id: amount.abs()});
        } else {
          transaction.set(mainBalanceRef, { id: amount.abs()});
        }
      }

      if(docParentSn != null) {
        if(docParentSn.exists) transaction.update(docParentRef, parent!.toJson());
        /// else 분기 오류
      }
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error update ts item() $e"); return false; }
    );
  }

  /// 이 함수는 해당 클래스를 직렬화 하여 데이터베이스에 기록합니다.
  dynamic updateOnlyIsDone() async {
    if(rpUid == '') return false;
    if(id == '') return false;
    if(id == '') return false;

    /// 메인문서 기록
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("purchase/$rpUid/item-process").doc(id);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final docRefSn = await transaction.get(docRef);

      if(docRefSn.exists) transaction.update(docRef, { 'isDone': true });
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error update ts item() $e"); return false; }
    );
  }


  dynamic delete() async {
    if(rpUid == '') return false;
    if(id == '') return false;

    state = "DEL";
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(date));
    var dateIdHarp = DateStyle.dateYearsHarp(date);
    var dateIdQuarter = DateStyle.dateYearsQuarter(date);

    /// 내부 트랜잭션 다시 작성
    /// 테스트 필요
    /// 메인문서 기록
    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;

    final docRef = db.collection("purchase/$rpUid/item-process").doc(id);
    var docParentRef = null;
    final balanceRef = db.collection('balance/dateQ-process/${itUid}').doc(dateIdQuarter);
    final mainBalanceRef = db.collection('meta/itemInven/${itUid}').doc(dateIdQuarter);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final docRefSn = await transaction.get(docRef);
      final balanceSn = await transaction.get(balanceRef);
      final mainBalanceSn = await transaction.get(mainBalanceRef);

      DocumentSnapshot<Map<String, dynamic>>? docParentSn = null;
      if(docParentRef != null) docParentSn = await transaction.get(docParentRef);

      /// 트랜잭션 내부
      if(docRefSn.exists) transaction.update(docRef, toJson());

      /// 출고품이 아닐경우 사용량 재고에서 카운트
      /// 해당 로직은 최초 가공공정 등록시에만 실행되는 로직입니다.
      if(!isOutput && !isDone) {
        if(mainBalanceSn.exists) transaction.update(mainBalanceRef, { id: amount.abs() });
        else transaction.set(mainBalanceRef, { id: amount.abs() });
      }

      /// 출고품일 경우 기초 재고 및 작업내역값에서도 적용
      if(isOutput) {
        if(mainBalanceSn.exists) transaction.update(mainBalanceRef, { id: amount.abs() * -1 });
        else transaction.set(mainBalanceRef, { id: amount.abs() * -1 });
      }
    }).then((value) {
      print("DocumentSnapshot successfully updated!"); return true;
    }, onError: (e) {
      print("Error update ts item() $e"); return false;
    });
  }
}