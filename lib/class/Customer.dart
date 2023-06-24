
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import 'transaction.dart';

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
  
  dynamic update({ Map<String, Uint8List>? files }) async {
    var create = false, result = false;

    if(id == "") {
      id = DatabaseM.generateRandomString(16);
      create = true;
    }
    if(id == "") return false;

    try {
      if (files != null) {
        for (int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if (filesMap[k] != null) continue;
          var url = await DatabaseM.updateCsFile(id, f, k);

          if (url == null) continue;
          filesMap[k] = url;
        }
      }
    } catch (e) {}

    var searchText = getSearchText();

    await FireStoreHub.docUpdate('meta/customer', 'CS.PATCH', { 'search\.${id}': searchText, 'updateAt': DateTime.now().microsecondsSinceEpoch,},
        setJson: { 'search': { searchText}, 'updateAt': DateTime.now().microsecondsSinceEpoch,});

    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("customer").doc(id);
    /// 검색 기록 문서 경로로
    final searchRef = db.collection('meta/search/name').doc('customer');

    await db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);
      final searchSn = await transaction.get(searchRef);

      /// 매입문서 기조 저장경로
      if(docRefSn.exists) {
        transaction.update(docRef, toJson());
      } else {
        transaction.set(docRef, toJson());
      }

      if(searchSn.exists) {
        transaction.update(searchRef, { id: businessName, },);
      } else {
        transaction.set(searchRef, { id : businessName },);
      }
    }).then((value) {
      print("DocumentSnapshot successfully updated!");
      result = true;
    },
      onError: (e) { print("Error updatePurchase() $e");
      result = false;
      },
    );

    return result;
  }


  dynamic getContractList() async {
    List<Contract>? data = await DatabaseM.getCtWithCs(id);
    return data;
  }

  dynamic getPurchase() async {
    List<Purchase> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection('customer/${id}/cs-dateH-purchase');
    await coll.limit(50).get().then((value) {
      //print('get &: customer/${id}/cs-dateH-purchase &: limit:10 &: length:${value.docs?.length}');
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

  /**
   * 현재 거래처의 전체 또는 선택기간의 거래 기록문서목록을
   * 데이터베이스로부터 요청하는 함수
   *
   * 삭제된 문서에 대한 요청 기능 없음
   *
   * @ params none
   * @ return 거래문서 목록
   */
  dynamic getTransaction() async {
    List<TS> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection('customer/${id}/cs-dateH-transaction');
    await coll.limit(20).get().then((value) {
      print('get &: customer/${id}/cs-dateH-transaction &: limit:20 &: length:${value.docs?.length}');
      if(value.docs == null) return false;

      for(var a in value.docs) {
        if(a.data() == null) continue;
        var map = a.data() as Map;
        var listMap = map as Map;

        for(var pu in listMap.values) {
          if(pu == null) continue;

          var ts = TS.fromDatabase(pu as Map);
          if(ts.type != 'DEL') data.add(ts);
        }
      }
    });

    data.sort((a, b) => b.id.compareTo(a.id));
    return data;
  }

  // 03.08 요청사항 추가
  // 고객관리 메모 검색 요청
  String getSearchText() {
    return businessName + '&:' + manager + '&:' + representative + '&:' + phoneNumber + '&:'+ companyPhoneNumber + '&:' + memo;
  }
}
