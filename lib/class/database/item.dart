import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../helper/firebaseCore.dart';
import '../Customer.dart';
import '../contract.dart';
import '../revenue.dart';
import '../system.dart';

/// 품목 선언 파일 변경
///
///
/// @Update YM
/// @version 1.1.0
class Item {
  var id = '';
  var name = '';
  /// 매출, 매입, 매출매입 품목 - PU, RE
  var type = '';
  /// 품목 분류
  var group = '';
  var unit = '';
  var unitPrice = 0;
  var cost = 0;
  var memo = '';

  var display = false;

  Item.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    type = json['type'] ?? '';
    group = json['group'] ?? '';
    unit = json['unit'] ?? '';
    unitPrice = json['unitPrice'] ?? 0;
    cost = json['cost'] ?? 0;
    memo = json['memo'] ?? '';
    display = json['display'] ?? false;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'group': group,
      'unit': unit,
      'unitPrice': unitPrice,
      'cost': cost,
      'memo': memo,
      'display': display,
    };
  }
}


/// 품목 사용 및 생산 개수
/// (***) 변경 필요
class ItemFD {
  var id = '';
  var count = 0;

  ItemFD.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    count = json['count'] ?? 0;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'count': count,
    };
  }
}


/// 품목 거래 이동 입출 현황 기록 클래스
///
/// @Create YM
/// @Update YM 23.04.10
/// @Version 1.1.0
class ItemTS {
  var id = '';
  var state = '';       // D,
  var type = '';       // P 매입, R 매출, F 동결,

  var rpUid = '';       /// 매입매출번호
  var itemUid = '';     /// 품목 고유번호
  var amount = 0.0;       /// 입고량
  var storageLC = '';     /// 입고창고위치

  var ctUid = '';         /// 입고계약
  var csUid = '';         /// 거래처

  var date = 0;           /// 입고일자

  var manager = '';       /// 입고자(검수자)
  var writer = '';        /// 작성자
  var updateAt = 0;       /// 문서 변경시각

  var filesMap = {};      /// 첨부파일
  //var filesDetail = {};

  ItemTS.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';
    csUid = json['csUid'] ?? '';
    ctUid = json['ctUid'] ?? '';
    type = json['type'] ?? '';
    rpUid = json['rpUid'] ?? ''; 
    itemUid = json['itemUid'] ?? '';
    amount = json['amount'] ?? 0;
    date = json['date'] ?? 0;
  }
  ItemTS.fromRe(Revenue revenue) {
    type = 'RE';
    rpUid = revenue.id;
    itemUid = revenue.item;
    amount = revenue.count * -1;
    csUid = revenue.csUid;
    ctUid = revenue.ctUid;
  }
  ItemTS.fromPu(Purchase purchase) {
    type = 'PU';
    id = purchase.id;
    rpUid = purchase.id;
    itemUid = purchase.item;
    csUid = purchase.csUid;
    ctUid = purchase.ctUid;
    date = purchase.purchaseAt;

    var item = SystemT.getItem(itemUid);
    if(item == null) return;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'csUid': csUid,
      'ctUid': ctUid,
      'type': type,
      'rpUid': rpUid,
      'itemUid': itemUid,
      'amount': amount,
      'date': date,
      'state': state,
    };
  }

  
  dynamic getHistory({ int? startAt, int? lastAt }) async {

  }
  dynamic createUID() {

  }

  /// 이 함수는 해당 클래스를 직렬화 하여 데이터베이스에 기록합니다.
  ///
  /// (***) 문서 업데이트시 기존 org 반드시 첨부
  /// 현재 문서의 UID 가 != ''이 아닐경우 기존 기록을 히스토리로 변경
  /// 히스토리에 기록시 문서 UID는 현재 시간의 에폭시 값으로 변경
  dynamic update({ ItemTS? org, Map<String, Uint8List>? files, }) async {
    var create = false;
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(date));

    // 추후 아이디 발급 형태 
    if(id == '')  { create = true; }
    if(create) await createUID();
    if(id == '') return false;
    // 현재까지 정상적으로 실행된 경우
    // id 존재

    var orgDateId = '-';
    var orgDateQuarterId = '-';
    var orgDateIdHarp = '-';
    if(org != null) {
      orgDateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(org.date));
      orgDateQuarterId = DateStyle.dateYearsQuarter(org.date);
      orgDateIdHarp = DateStyle.dateYearsHarp(org.date);
    }

    var dateIdHarp = DateStyle.dateYearsHarp(date);
    var dateIdQuarter = DateStyle.dateYearsQuarter(date);

    //var searchText = await getSearchText();

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    
    ///
    /// 
    /// 
    /// 
    /// 내부 트랜잭션 다시 작성 
    /// 테스트 필요
    /// 
    /// 
    /// 
    /// 
    /// 
    /// 메인문서 기록
    final docRef = db.collection("revenue").doc(id);
    final dateRef = db.collection('meta/date-m/revenue').doc(dateId);
    if(org != null) ref['orgDate'] = db.collection('meta/date-m/revenue').doc(orgDateId);
    if(org != null) {
      if(org.csUid != '') ref['orgCsDetail'] = db.collection('customer/${org.csUid}/cs-dateH-revenue').doc(orgDateIdHarp);
      if(org.ctUid != '') ref['orgCtDetail'] = db.collection('contract/${org.ctUid}/ct-dateH-revenue').doc(orgDateIdHarp);
    }

    if(csUid != '') ref['cs'] = db.collection('customer').doc(csUid);
    if(csUid != '') ref['csDetail'] = db.collection('customer/${csUid}/cs-dateH-revenue').doc(dateIdHarp);

    if(ctUid != '') ref['ct'] = db.collection('contract').doc(ctUid);
    if(ctUid != '') ref['ctDetail'] = db.collection('contract/${ctUid}/ct-dateH-revenue').doc(dateIdHarp);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final  docRefSn = await transaction.get(docRef);
      final  docDateRefSn = await transaction.get(dateRef);
      if(ref['orgDate'] != null) sn['orgDate'] = await transaction.get(ref['orgDate']!);
      if(ref['orgSearch'] != null) sn['orgSearch'] = await transaction.get(ref['orgSearch']!);
      if(ref['orgCsDetail'] != null) sn['orgCsDetail'] = await transaction.get(ref['orgCsDetail']!);
      if(ref['orgCtDetail'] != null) sn['orgCtDetail'] = await transaction.get(ref['orgCtDetail']!);

      if(ref['cs'] != null) sn['cs'] = await transaction.get(ref['cs']!);
      if(ref['csDetail'] != null) sn['csDetail'] = await transaction.get(ref['csDetail']!);

      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);

      if(org != null) {
        if(sn['orgDate']!.exists && dateId != orgDateId && orgDateId != '-')
          transaction.update(ref['orgDate']!, {'list\.${org.id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        if(sn['orgSearch']!.exists && dateIdQuarter != orgDateQuarterId && orgDateQuarterId != '-')
          transaction.update(ref['orgSearch']!, {'list\.${org.id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});

        if(sn['orgCsDetail'] != null) {
          if(sn['orgCsDetail']!.exists && dateIdHarp != orgDateIdHarp && orgDateIdHarp != '-') {
            transaction.update(ref['orgCsDetail']!, { org.id: FieldValue.delete(), });
          }
        }
        if(sn['orgCtDetail'] != null) {
          if(sn['orgCtDetail']!.exists && dateIdHarp != orgDateIdHarp && orgDateIdHarp != '-') {
            transaction.update(ref['orgCtDetail']!, { org.id: FieldValue.delete() });
          }
        }
      }

      /// 트랜잭션 내부

      if(create && docRefSn.exists) return false;
      if(docRefSn.exists)  transaction.update(docRef, toJson());
      else transaction.set(docRef, toJson());

      if(docDateRefSn.exists) {
        transaction.update(dateRef, { 'list\.${id}': toJson(), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
      } else {
        transaction.set(dateRef, {  'list': { id: toJson() },  'updateAt': DateTime.now().microsecondsSinceEpoch, });
      }

      // 2023.03.22 
      if(ref['cs'] != null) {
        if(create) transaction.update(ref['cs']!, {'reCount': FieldValue.increment(1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});

        if(sn['csDetail']!.exists) transaction.update(ref['csDetail']!, { id: toJson(), });
        else transaction.set(ref['csDetail']!, { id: toJson(), });
      }

      if(ref['ct'] != null) {
        if(create) if(sn['ct']!.exists) transaction.update(ref['ct']!, {'reCount': FieldValue.increment(1),});

        if(sn['ctDetail']!.exists) transaction.update(ref['ctDetail']!, { id: toJson(), });
        else transaction.set(ref['ctDetail']!, { id: toJson(), });
      }
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error updatePurchase() $e"); return false; }
    );
  }

  dynamic delete() async {

  }
}
