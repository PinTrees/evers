
import 'dart:ui';

import 'package:evers/class/Customer.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import 'contract.dart';
import 'system.dart';
import 'transaction.dart';

class RevPur {
  var type = 0;
  Revenue? rev;
  Purchase? pur;

  int dateAt = 0;

  RevPur.fromDatabase({ Revenue? re, Purchase? pu }) {
    type = (re == null) ? 2 : 1;
    pur = pu; rev = re;

    dateAt = (re == null) ? pu!.purchaseAt : re.revenueAt;
  }
}

class Revenue {
  var selectIsTaxed = false;
  var isTaxed = false;
  var state = '';

  var csUid = '';       /// 거래처번호
  var scUid = '';       /// 거래처번호

  var ctUid = '';       /// 계약번호
  var tsUid = '';
  var id = '';          /// 고유번호

  var ctIndexId = '';
  var item = '';        /// 품목

  var vatType = 0;        /// 0 포함, 1 미포함

  var count = 0;        /// 수량
  var unitPrice = 0;    /// 단가
  var supplyPrice = 0;  /// 공급가액
  var vat = 0;          /// 부가세
  var totalPrice = 0;   /// 합계
  var paymentAt = 0;    /// 매출일
  var revenueAt = 0;    /// 매출일

  var memo = '';        /// 메모

  Revenue.fromDatabase(Map<dynamic, dynamic> json) {
    state = json['state'] ?? '';
    id = json['id'] ?? '';
    ctIndexId = json['ctIndexId'] ?? '';
    ctUid = json['ctUid'] ?? '';
    scUid = json['scUid'] ?? '';
    csUid = json['csUid'] ?? '';
    item = json['item'] ?? '';
    count = json['count'] ?? 0;
    unitPrice = json['unitPrice'] ?? 0;
    supplyPrice = json['supplyPrice'] ?? 0;
    vat = json['vat'] ?? 0;
    vatType = json['vatType'] ?? 0;
    totalPrice = json['totalPrice'] ?? 0;
    paymentAt = json['paymentAt'] ?? 0;
    revenueAt = json['revenueAt'] ?? 0;
    memo = json['memo'] ?? '';
    isTaxed = json['isTaxed'] ?? false;
    selectIsTaxed = isTaxed;
    init();
  }
  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'id': id,
      'ctIndexId': ctIndexId,
      'item': item,
      'ctUid': ctUid,
      'scUid': scUid,
      'csUid': csUid,
      'count': count,
      'unitPrice': unitPrice,
      'supplyPrice': supplyPrice,
      'vat': vat,
      'vatType': vatType,
      'totalPrice': totalPrice,
      'paymentAt': paymentAt,
      'revenueAt': revenueAt,
      'memo': memo,
      'isTaxed': isTaxed,
    };
  }
  int getSupplyPrice() {
    var a = count * unitPrice - vat;
    return a;
  }
  int init() {
    if(vatType == 0) { totalPrice = unitPrice * count;  vat = (totalPrice / 11).round(); supplyPrice = totalPrice - vat; }
    if(vatType == 1) { vat = ((unitPrice * count) / 10).round(); totalPrice = unitPrice * count + vat;  supplyPrice = unitPrice * count; }
    return totalPrice;
  }
  int getTotalPrice() {
    var a = count * unitPrice + vat;
    return a;
  }

  Future<String> getSearchText() async {
    var cs = await SystemT.getCS(csUid) ?? Customer.fromDatabase({});
    var ct = await SystemT.getCt(ctUid) ?? Contract.fromDatabase({});
    var it = SystemT.getItemName(item);

    return cs.businessName + '&:' + ct.ctName + '&:' + it + '&:' + memo;
  }

  dynamic update() async {
    await FireStoreT.updateRevenue(this);
  }
}