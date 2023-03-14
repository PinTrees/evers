
import 'dart:ui';

import 'package:evers/class/system.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import 'revenue.dart';
import 'transaction.dart';

class Contract {
  var state = '';
  var id = '';
  var csUid = '';
  var purchasingDepartment = '';
  var scUid='';

  var ctName = '';
  var csName = '';
  var fileName = '';
  var itemName = '';

  var workSitePlace = '';
  var manager = '';
  var managerPhoneNumber = '';
  var managerFaxNumber = '';

  var contractAt = 0;
  var deadlineAt = 0;
  var updateAt = 0;
  var paymentTerms = '';
  var vatType = 0;

  var memo = '';

  ///{
  ///   id
  ///   item,
  ///   count,
  ///   unitPrice,
  ///   supplyPrice,
  ///   vat,
  ///   totalPrice,
  ///   dueAt,
  ///}
  var contractList = [];
  List<Revenue> revenueList = [];
  late Item itemT;

  var filesMap = {};
  var filesDetail = {};

  var contractFiles = {};

  Contract.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';
    vatType = json['vatType'] ?? 0;
    csUid = json['csUid'] ?? '';
    purchasingDepartment = json['purchasingDepartment'] ?? '';
    ctName = json['ctName'] ?? '';
    csName = json['csName'] ?? '';
    scUid = json['scUid'] ?? '';

    workSitePlace = json['workSitePlace'] ?? '';
    manager = json['manager'] ?? '';
    managerPhoneNumber = json['managerPhoneNumber'] ?? '';
    managerFaxNumber = json['managerFaxNumber'] ?? '';

    contractAt = json['contractAt'] ?? 0;
    deadlineAt = json['deadlineAt'] ?? 0;
    paymentTerms = json['paymentTerms'] ?? '';

    memo = json['memo'] ?? '';
    contractList = json['contractList'] ?? [];
    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;
    filesDetail = (json['filesDetail'] == null) ? {} : json['filesDetail'] as Map;
    contractFiles = (json['contractFiles'] == null) ? {} : json['contractFiles'] as Map;

    itemName = json['itemName'] ?? '';
    fileName = json['fileName'] ?? '';
    if(fileName == '') {
      fileName = filesMap.keys.join(',') + contractFiles.keys.join(',');
    }
    if(itemName == '') {
      for (var c in contractList) {
        if(c == null) continue;
        itemName += SystemT.getItemName(c['id'] ?? '');
      }
    }
  }
  void fromJson(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';
    vatType = json['vatType'] ?? 0;
    csUid = json['csUid'] ?? '';
    purchasingDepartment = json['purchasingDepartment'] ?? '';
    ctName = json['ctName'] ?? '';
    csName = json['csName'] ?? '';
    scUid = json['scUid'] ?? '';

    workSitePlace = json['workSitePlace'] ?? '';
    manager = json['manager'] ?? '';
    managerPhoneNumber = json['managerPhoneNumber'] ?? '';
    managerFaxNumber = json['managerFaxNumber'] ?? '';

    contractAt = json['contractAt'] ?? 0;
    deadlineAt = json['deadlineAt'] ?? 0;
    paymentTerms = json['paymentTerms'] ?? '';

    memo = json['memo'] ?? '';
    contractList = json['contractList'] ?? [];
    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;
    filesDetail = (json['filesDetail'] == null) ? {} : json['filesDetail'] as Map;
    contractFiles = (json['contractFiles'] == null) ? {} : json['contractFiles'] as Map;

    itemName = json['itemName'] ?? '';
    fileName = json['fileName'] ?? '';
    if(fileName == '') {
      fileName = filesMap.keys.join(',') + contractFiles.keys.join(',');
    }
    if(itemName == '') {
      for (var c in contractList) {
        if(c == null) continue;
        itemName += SystemT.getItemName(c['id'] ?? '');
      }
    }
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
      'scUid': scUid,
      'vatType': vatType,
      'csUid': csUid,
      'purchasingDepartment': purchasingDepartment,
      'ctName': ctName,
      'csName': csName,
      'fileName': fileName,

      'workSitePlace': workSitePlace,
      'manager': manager,
      'managerPhoneNumber': managerPhoneNumber,
      'managerFaxNumber': managerFaxNumber,

      'contractAt': contractAt,
      'deadlineAt': deadlineAt,
      'paymentTerms': paymentTerms,

      'memo': memo,
      'contractList': contractList as List,
      'filesMap': filesMap as Map,
      'filesDetail': filesDetail as Map,
      'contractFiles': contractFiles as Map,
    };
  }



  String getFileName(String id) {
    var data = filesDetail[id];
    if(data == null) return id;
    else return data['name'] ?? id;
  }
  String getFileTitle(String id) {
    var data = filesDetail[id];
    if(data == null) return '제목입력';
    else return data['title'] ?? '제목입력';
  }

  dynamic update() async {
    Contract? data = await FireStoreT.getContractDoc(id);
    if(data == null) return;
    fromJson(data.toJson());

    revenueList = await FireStoreT.getRevenueOnlyContract(id);
  }
  int getItemCountRevenue(String ctIndex) {
    final cl = contractList.firstWhere((a) =>
    a['id'] == ctIndex, orElse: () {
      return null;
    });
    if(cl == null) return -1;

    final revs = revenueList.where((a) =>
    a.ctIndexId == ctIndex);

    var count = 0;
    var clCount = int.tryParse(cl['count'] ?? '') ?? -1;
    for(var re in revs) count += re.count;

    return clCount - count;
  }
  /// 품목 매출 수량 GET Function
  int getItemRevenueCount(String ctIndex) {
    final cl = contractList.firstWhere((a) =>
    a['id'] == ctIndex, orElse: () {
      return null;
    });
    if(cl == null) return -1;

    final revs = revenueList.where((a) =>
    a.ctIndexId == ctIndex);

    var count = 0;
    for(var re in revs) count += re.count;

    return  count;
  }
}

class ContractInfo {
  var id = '';
  var item = '';
  var count = '';
  var unitPrice = '';
  var supplyPrice = '';
  var vat = '';
  var totalPrice = '';
  var dueAt = '';
}