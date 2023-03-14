
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

class Customer {
  var bsType = '';
  var csType = '';
  var id = '';
  var state = '';

  var businessName = '';
  var representative = '';
  var businessRegistrationNumber = {};
  var faxNumber = {};
  var companyPhoneNumber = '';
  var phoneNumber = '';
  var email = '';

  var manager = '';
  var address = '';
  var website = '';

  var businessType = '';
  var businessItem = [];
  var account = {};

  var memo = '';

  var tsCount = 0;
  var updateAt = '';
  var files = [];
  var filesMap = {};

  Customer.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    bsType = json['bsType'] ?? '';
    csType = json['csType'] ?? '';
    tsCount = json['tsCount'] ?? 0;
    state = json['state'] ?? '';

    representative = json['representative'] ?? '';
    businessName = json['businessName'] ?? '';
    businessRegistrationNumber = (json['businessRegistrationNumber'] == null) ? {} : json['businessRegistrationNumber'] as Map;
    faxNumber = (json['faxNumber'] == null) ? {} : json['faxNumber'] as Map;
    phoneNumber = json['phoneNumber'] ?? '';
    companyPhoneNumber = json['companyPhoneNumber'] ?? '';

    manager = json['manager'] ?? '';
    email = json['email'] ?? '';
    address = json['addresses'] ?? '';
    website = json['website'] ?? '';

    businessType = json['businessType'] ?? '';
    businessItem = json['businessItem'] ?? [];

    account = (json['account'] == null) ? {} : json['account'] as Map;
    memo = json['memo'] ?? '';
    files = json['files'] ?? [];
    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;
  }
  void fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    bsType = json['bsType'] ?? '';
    csType = json['csType'] ?? '';
    tsCount = json['tsCount'] ?? 0;
    state = json['state'] ?? '';

    representative = json['representative'] ?? '';
    businessName = json['businessName'] ?? '';
    businessRegistrationNumber = (json['businessRegistrationNumber'] == null) ? {} : json['businessRegistrationNumber'] as Map;
    faxNumber = (json['faxNumber'] == null) ? {} : json['faxNumber'] as Map;
    phoneNumber = json['phoneNumber'] ?? '';
    companyPhoneNumber = json['companyPhoneNumber'] ?? '';

    manager = json['manager'] ?? '';
    email = json['email'] ?? '';
    address = json['addresses'] ?? '';
    website = json['website'] ?? '';

    businessType = json['businessType'] ?? '';
    businessItem = json['businessItem'] ?? [];

    account = (json['account'] == null) ? {} : json['account'] as Map;
    memo = json['memo'] ?? '';
    files = json['files'] ?? [];
    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;
  }

  Map<String, dynamic> toJson() {
    return {
      'bsType': bsType, 'csType': csType, 'id': id,
      'id': id, 'state': state,
      'tsCount': tsCount,

      'representative': representative,
      'manager': manager,
      'businessName': businessName,
      'businessRegistrationNumber': businessRegistrationNumber as Map,

      'phoneNumber': phoneNumber,
      'companyPhoneNumber': companyPhoneNumber,
      'faxNumber': faxNumber as Map,
      'email': email,
      'addresses': address,
      'website': website,

      'businessType': businessType,
      'businessItem': businessItem as List,
      'account': account as Map,
      'memo': memo,
      'files': files as List,
      'filesMap': filesMap as Map,
    };
  }
  dynamic update() async {
    Customer? data = await FireStoreT.getCustomerDoc(id);
    if(data != null) fromDatabase(data.toJson());
  }

  dynamic getContractList() async {
    List<Contract>? data = await FireStoreT.getCtWithCs(id);
    return data;
  }

  dynamic getPurchase() async {
    List<Purchase> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection('customer/${id}/cs-dateH-purchase');
    await coll.limit(10).get().then((value) {
      print('get &: customer/${id}/cs-dateH-purchase &: limit:10 &: length:${value.docs?.length}');
      if(value.docs == null) return false;

      for(var a in value.docs) {
        if(a.data() == null) continue;
        var map = a.data() as Map;
        var listMap = map['list'] as Map;

        for(var pu in listMap.values) {
          if(pu == null) continue;

          var ct = Purchase.fromDatabase(pu as Map);
          if(ct.state != 'DEL') data.add(ct);
        }
      }
    });

    return data;
  }
}