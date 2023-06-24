
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/system.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/style.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import 'revenue.dart';
import 'transaction.dart';
import 'database/item.dart';

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

  dynamic updateInit() async {
    Contract? data = await DatabaseM.getContractDoc(id);
    if(data == null) return;
    fromJson(data.toJson());

    revenueList = await DatabaseM.getRevenueOnlyContract(id);
  }



  /// 이 함수는 데이터베이스에서 신규 계약정보에 대한 유일한 문서Key를 요청하고 자신의 값에 할당합니다.
  /// 해당 함수는 Update 로직 내에서만 접근하는 함수입니다.
  dynamic createUid() async {
    /// contractAt 계약일 값은 NULL 일 수 없습니다.
    var dateIdDay = DateStyle.dateYearMD(contractAt);
    var dateIdMonth = DateStyle.dateYearMM(contractAt);

    /// 이부분의 경로 값만 수정되면 됨으로 추후 함수화가 필요함
    var db = FirebaseFirestore.instance;
    final refMeta = db.collection('meta/uid/dateM-contract').doc(dateIdMonth);

    return await db.runTransaction((transaction) async {
      final snMeta = await transaction.get(refMeta);

      /// 개수는 100% 트랜잭션을 보장할 수 없음
      /// 고유한 형식만 보장
      /// 개수가 업데이트된 후 문서 저장에 실패할 경우 예외처리 안함
      if(snMeta.exists) {
        if((snMeta.data() as Map)[dateIdDay] != null) {
          var currentRevenueCount = (snMeta.data() as Map)[dateIdDay] as int;
          currentRevenueCount++;
          id = '$dateIdDay-$currentRevenueCount';
          transaction.update(refMeta, { dateIdDay: FieldValue.increment(1)});
        }
        else {
          id = '$dateIdDay-1';
          transaction.update(refMeta, { dateIdDay: 1});
        }
      } else {
        id = '$dateIdDay-1';
        transaction.set(refMeta, { dateIdDay: 1 });
      }
    }).then(
            (value) { print("meta/date-M/purchase UID successfully updated createUid!"); return true; },
        onError: (e) { print("Error createUid() $e"); return false; }
    );
  }

  dynamic update({ Map<String, Uint8List>? files, Map<String, Uint8List>? ctFiles,}) async {
    var create = false;
    var result = false;

    if(id == "") {
      create = true;
      await createUid();
    }

    /// 정상적으로 신규 키값이 할당되지 않았을 경우 로직을 종료합니다.
    if (id == '') return false;

    /// 검색 정보 시스템을 변경합니다.
    /// 계약의 상세내용에 대해 각 id 값을 추가합니다.
    for (var a in contractList) {
      if (a['id'] == null) a['id'] = DatabaseM.generateRandomString(16);
    }

    await DatabaseM.getCtMetaCountCheck();
    if (scUid == '') scUid = SystemT.searchMeta.contractCursor.toString();
    if (csName == '') csName = (await SystemT.getCS(csUid)).businessName;

    for (var a in contractList) {
      if (a['id'] == null) a['id'] = DatabaseM.generateRandomString(16);
    }

    if (files != null) {
      for(var k in files.keys) {
        var file = files[k];
        if (file == null) continue;

        var url = await DatabaseM.updateCtFile(id, file, k);
        if (url != null) filesMap[k] = url;
      }
    }
    if (ctFiles != null) {
      for(var k in ctFiles.keys) {
        var file = ctFiles[k];
        if (file == null) continue;

        var url = await DatabaseM.updateCtFile(id, file, k);
        if (url != null) contractFiles[k] = url;
      }
    }

    var searchText = csName + '&:' + ctName + '&:' + fileName + '&:' + manager + '&:' + memo;

    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("contract").doc(id);
    /// 검색 기록 문서 경로로
    final searchRef = db.collection('meta/search/contract').doc(scUid);

    await db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);
      final SearchSn = await transaction.get(searchRef);

      /// 매입문서 기조 저장경로
      if(docRefSn.exists) {
        transaction.update(docRef, toJson());
      } else {
        transaction.set(docRef, toJson());
      }

      if(SearchSn.exists) {
        transaction.update(searchRef, { 'list\.${id}': searchText, 'updateAt': DateTime.now().microsecondsSinceEpoch, },);
      } else {
        transaction.set(searchRef, { 'list' : { id : searchText },   'updateAt': DateTime.now().microsecondsSinceEpoch,  },);
      }
    }).then((value) {
      print("DocumentSnapshot successfully updated!");
      result = true;
    }, onError: (e) {
      print("Error update Contract() $e");
      result = false;
    },);

    return result;
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
    for(var re in revs) count += re.count.toInt();

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
    for(var re in revs) count += re.count.toInt();

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