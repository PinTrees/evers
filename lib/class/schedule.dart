
import 'dart:ui';

import 'package:evers/helper/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import '../helper/firebaseCore.dart';

class Schedule {
  var id = '';
  var ctUid = '';
  var type = '0';
  var managers = [];
  var memo = '';
  var date = 0;

  Schedule.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    type = json['type'] ?? '0';
    ctUid = json['ctUid'] ?? '';
    memo = json['memo'] ?? '';
    date = json['date'] ?? 0;
    managers = json['managers'] ?? [];
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'ctUid': ctUid,
      'memo': memo,
      'date': date,
      'managers': managers as List,
    };
  }
  
  dynamic delete() async {
    if(id == '') return;
    await FireStoreHub.docDelete('schedule/$id', 'SCH.DELETE',);
  }

  DateTime? getDate() {
    var d = new DateTime.fromMicrosecondsSinceEpoch(date);
    return d;
  }
}

class FactoryD {
  var id = '';
  var state = '';

  var itemSvPu = {};
  var itemSvRe = {};

  var date = 0;
  var memo = '';
  var filesMap = {};

  FactoryD.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';

    memo = json['memo'] ?? '';
    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;
    date = json['date'] ?? 0;

    itemSvPu = (json['itemSvPu'] == null) ? {} : json['itemSvPu'] as Map;
    itemSvRe = (json['itemSvRe'] == null) ? {} : json['itemSvRe'] as Map;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
      'memo': memo,
      'date': date,
      'filesMap': filesMap as Map,
      'itemSvPu': itemSvPu as Map,
      'itemSvRe': itemSvRe as Map,
    };
  }
  String getID() {
    return StyleT.dateFormatBarAtEpoch(date.toString());
  }
  
  dynamic delete() async {
    if(id == '') return;
    state = 'DEL';
    await FireStoreHub.docUpdateDel('factory-daily/$id', 'FD-Date::DELETE', toJson(), fileMap: filesMap);
  }
  dynamic deleteFile(String key) async {
    if(key == '') return;
    await StorageHub.deleteFile('factory-daily/$id', 'FD-Date-File-$key::DELETE', key);
    filesMap.remove(key);
    await FireStoreT.updateFactoryDWithFile(this);
  }
}

class ProductD {
  var id = '';
  var state = '';

  var itemSvPu = {};
  var itemSvRe = {};

  var date = 0;
  var memo = '';
  var filesMap = {};

  ProductD.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';

    memo = json['memo'] ?? '';
    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;
    date = json['date'] ?? 0;

    itemSvPu = (json['itemSvPu'] == null) ? {} : json['itemSvPu'] as Map;
    itemSvRe = (json['itemSvRe'] == null) ? {} : json['itemSvRe'] as Map;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'state': state,
      'memo': memo,
      'date': date,
      'filesMap': filesMap as Map,
      'itemSvPu': itemSvPu as Map,
      'itemSvRe': itemSvRe as Map,
    };
  }
  String getID() {
    return StyleT.dateFormatBarAtEpoch(date.toString());
  }

  dynamic delete() async {
    if(id == '') return;
    state = 'DEL';
    await FireStoreHub.docUpdateDel('product-daily/$id', 'PD-Date::DELETE', toJson(), fileMap: filesMap);
  }
  dynamic deleteFile(String key) async {
    if(key == '') return;
    await StorageHub.deleteFile('product-daily/$id', 'PD-Date-File-$key::DELETE', key);
    filesMap.remove(key);
    await FireStoreT.updateProductDWithFile(this);
  }
}