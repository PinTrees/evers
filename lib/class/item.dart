import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../helper/firebaseCore.dart';
import 'Customer.dart';
import 'contract.dart';
import 'revenue.dart';
import 'system.dart';


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
  var state = '';
  var type = '';        /// PU/RE
  var rpUid = '';       /// 매입매출번호
  var itemType = '';
  var itemUid = '';
  var amount = 0;
  var unitPrice = 0;
  var date = 0;
  var ctUid = '';
  var csUid = '';

  ///
  var storageLC = '';   /// storage UID
  var writer = '';      /// UID

  ItemTS.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';
    itemType = json['itemType'] ?? '';
    csUid = json['csUid'] ?? '';
    ctUid = json['ctUid'] ?? '';
    type = json['type'] ?? '';
    rpUid = json['rpUid'] ?? '';
    itemUid = json['itemUid'] ?? '';
    amount = json['amount'] ?? 0;
    unitPrice = json['unitPrice'] ?? 0;
    date = json['date'] ?? 0;
  }
  ItemTS.fromRe(Revenue revenue) {
    type = 'RE';
    rpUid = revenue.id;
    itemUid = revenue.item;
    amount = revenue.count * -1;
    unitPrice = revenue.unitPrice;
    csUid = revenue.csUid;
    ctUid = revenue.ctUid;
  }
  ItemTS.fromPu(Purchase purchase) {
    type = 'PU';
    id = purchase.id;
    rpUid = purchase.id;
    itemUid = purchase.item;
    amount = purchase.count;
    unitPrice = purchase.unitPrice;
    csUid = purchase.csUid;
    ctUid = purchase.ctUid;
    date = purchase.purchaseAt;

    var item = SystemT.getItem(itemUid);
    if(item == null) return;
    itemType = item.type;
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
      'unitPrice': unitPrice,
      'date': date,
      'itemType': itemType,
      'state': state,
    };
  }


  dynamic getHistory({ int? startAt, int? lastAt }) async {

  }


  dynamic createUID() {

  }

  /// (***) 문서 업데이트시 기존 org 반드시 첨부
  /// 현재 문서의 UID 가 != ''이 아닐경우 기존 기록을 히스토리로 변경
  /// 히스토리에 기록시 문서 UID는 현재 시간의 에폭시 값으로 변경
  dynamic update({ Purchase? org }) async {
    if(id == '') return;
    if(id == '') id = DateTime.now().microsecondsSinceEpoch.toString();
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(date));

    if(org != null) {
      var itemTsOrg = ItemTS.fromPu(org);
      var orgDateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(itemTsOrg.date));

      await FireStoreHub.docUpdate('meta/date-m/transaction-item/${orgDateId}', 'ItemTS.PATCH',
          { 'list\.${itemTsOrg.id}': toJson() },
          setJson: { 'list': { itemTsOrg.id: toJson() } }
      );
    }

    await FireStoreHub.docUpdate('transaction-item/${id}', 'ItemTS.PATCH', toJson());
    await FireStoreHub.docUpdate('meta/date-m/transaction-item/${dateId}', 'ItemTS.PATCH',
      { 'list\.$id': toJson() },
      setJson: { 'list': { id: toJson() } }
    );
  }

  dynamic delete() async {

  }
}
