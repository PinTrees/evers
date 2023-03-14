
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

    return cs.businessName + '&:' + ct.ctName + '&:' + it.toString() + '&:' + memo + '&:' + date;
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
}