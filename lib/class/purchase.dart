
import 'dart:ui';

import 'package:evers/class/system.dart';
import 'package:evers/class/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import 'Customer.dart';
import 'contract.dart';

class Purchase {
  var state = '';

  var fixedVat = false;
  var fixedSup = false;

  var csUid = '';
  var ctUid = '';
  var id = '';
  var item = '';

  var count = 0;
  var unitPrice = 0;
  var supplyPrice = 0;
  var vatType = 0;        /// 0 포함, 1 미포함
  var vat = 0;
  var totalPrice = 0;
  var paymentAt = 0;
  var purchaseAt = 0;

  var isItemTs = false;

  var memo = '';
  var filesMap = {};

  Purchase.fromDatabase(Map<dynamic, dynamic> json) {
    state = json['state'] ?? '';
    id = json['id'] ?? '';
    vatType = json['vatType'] ?? 0;
    ctUid = json['ctUid'] ?? '';
    csUid = json['csUid'] ?? '';
    item = json['item'] ?? '';
    count = json['count'] ?? 0;
    unitPrice = json['unitPrice'] ?? 0;
    supplyPrice = json['supplyPrice'] ?? 0;
    //vat = json['vat'] ?? 0;
    totalPrice = json['totalPrice'] ?? 0;
    paymentAt = json['paymentAt'] ?? 0;
    purchaseAt = json['purchaseAt'] ?? 0;
    memo = json['memo'] ?? '';
    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;

    fixedVat = json['fixedVat'] ?? false;
    fixedSup = json['fixedSup'] ?? false;
    init();
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
      'vatType': vatType,
      'item': item,
      'ctUid': ctUid,
      'csUid': csUid,
      'count': count,
      'unitPrice': unitPrice,
      'supplyPrice': supplyPrice,
      //'vat': vat,
      'totalPrice': totalPrice,
      'paymentAt': paymentAt,
      'purchaseAt': purchaseAt,
      'memo': memo,
      'fixedVat': fixedVat,
      'fixedSup': fixedSup,
      'filesMap': filesMap as Map,
    };
  }

  Future<String> getSearchText() async {
    var cs = (await SystemT.getCS(csUid)) ?? Customer.fromDatabase({});
    var ct = (await SystemT.getCt(ctUid)) ?? Contract.fromDatabase({});
    var it = SystemT.getItemName(item);

    var date = '';
    try {
      date = purchaseAt.toString().substring(0, 8);
    } catch (e) {
      date = '';
    }

    // 03.08 요청사항 추후 반영
    // 거래처 대표자명 검색 텍스트에 추가 - 데이터베이스 구조 변경
    return cs.businessName + '&:' + ct.ctName + '&:' + it.toString() + '&:' + memo + '&:' + date;
  }

  int getSupplyPrice() {
    var a = count * unitPrice - vat;
    return a;
  }
  int init() {
    if(!fixedSup && !fixedVat) {
      if(vatType == 0) { totalPrice = unitPrice * count;  vat = (totalPrice / 11).round(); supplyPrice = totalPrice - vat; }
      if(vatType == 1) { vat = ((unitPrice * count) / 10).round(); totalPrice = unitPrice * count + vat;  supplyPrice = unitPrice * count; }
    }
    else if(fixedSup && fixedVat) {
      if(vatType == 0) { totalPrice = supplyPrice + vat; }
      if(vatType == 1) { totalPrice = supplyPrice + vat; }
    }
    else if(fixedVat) {
      // 부가세가 변경될 경우 데이터를 보장할 수 없음
      if(vatType == 0) { supplyPrice = unitPrice * count - vat;   totalPrice = supplyPrice + vat; }
      if(vatType == 1) { totalPrice = unitPrice * count + ((unitPrice * count) / 10).round();  supplyPrice = totalPrice - vat;   }
    } else if(fixedSup) {
      // 공급가액이 변경될 경우 데이터를 보장할 수 없음 - 공식 수정 필요
      if(vatType == 0) { vat = unitPrice * count - supplyPrice;     totalPrice = supplyPrice + vat; }
      if(vatType == 1) { vat = ((unitPrice * count) / 10).round();  totalPrice = unitPrice * count + vat;   vat = totalPrice - supplyPrice;  }
    }
    return totalPrice;
  }


  dynamic update() {

  }

  dynamic delete() {

  }
}
