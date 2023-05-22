import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/database/ledger.dart';
import 'package:evers/class/database/process.dart';
import 'package:evers/class/employee.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/style.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as en;

import '../class/Customer.dart';
import '../class/revenue.dart';
import '../class/schedule.dart';
import '../class/system.dart';
import '../class/transaction.dart';
import '../class/user.dart';
import '../class/version.dart';
import '../system/product.dart';
import 'function.dart';
import '../class/database/item.dart';

class DatabaseM {
  //static const _databaseURL = 'https://taegi-survey-default-rtdb.firebaseio.com';
  static dynamic updateEmployee(Employee data,
      { Map<String, Uint8List>? files,}) async {
    if (data.id == '') data.id = generateRandomString(16);

    try {
      if (files != null) {
        for (int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if (data.filesMap[k] != null) continue;

          var url = await updateCtFile(data.id, f, k);

          if (url == null) {
            print('contract file upload failed');
            continue;
          }

          data.filesMap[k] = url;
        }
      }

      await FireStoreHub.docUpdate(
        'employee/${data.id}', 'EM.PATCH', data.toJson(),);
    } catch (e) {
      if (files != null) {
        for (int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if (data.filesMap[k] != null) continue;

          var url = await updateCtFile(data.id, f, k);

          if (url == null) {
            print('contract file upload failed');
            continue;
          }

          data.filesMap[k] = url;
        }
      }
    }
  }

  static dynamic getReMetaCountCheck() async {
    var aaa = 0;
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta/search/revenue-meta');
    await coll.doc(SystemT.searchMeta.reCursor.toString()).get().then((value) {
      print('get search revenue meta data');
      if (!value.exists) return false;
      var aa = value.data() as Map;
      aaa = aa['count'] ?? 0;
    });
    if (aaa > SystemT.searchMeta.tsLimit) {
      SystemT.searchMeta.reCursor++;
      await updateScMeta();
    }

    return aaa;
  }

  static dynamic getReWithDate(int start, int end) async {
    Map<String, Revenue> data = {};
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'revenue');
    await coll.where('revenueAt', isGreaterThan: start).where(
        'revenueAt', isLessThan: end).orderBy('revenueAt', descending: true)
        .limit(100).get()
        .then((value) {
      print('get revenue data');
      if (value.docs == null) return;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var ct = Revenue.fromDatabase(a.data() as Map);
        if (ct.state == 'DEL') continue;
        data[ct.id] = ct;
      }
    });
    return data.values.toList();
  }

  static dynamic getResDoc(String id) async {
    Revenue? data = null;
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'revenue');
    await coll.doc(id).get().then((value) {
      print('get res doc data');
      if (!value.exists) return false;

      var rev = Revenue.fromDatabase(value.data() as Map);
      if (rev.state == 'DEL') return false;

      data = rev;
    });
    return data;
  }

  static dynamic initStreamReMeta() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta/search/dateQ-revenue');
    await coll.snapshots().listen((value) {
      print('revenue search snapshots listen data changed');
      if (value.docs == null) return;

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var searchMap = a.data() as Map;
        var headers = searchMap['list'] as Map;
        SystemT.revSearch[a.id] = headers;
      }
      FunT.setStateMain();
    });
  }

  /// (***) 매입 클래스내 내부함수로 재구현 필요
  /// 검색 메타정보 테스트 - 추후 알고리아 또는 타입신스를 통한 고도화
  static dynamic updatePurchase(Purchase data,
      { Purchase? org, Map<String, Uint8List>? files,}) async {
    var create = false;
    if (data.id == '') {
      data.id = generateRandomString(16);
      create = true;
    }
    var dateId = StyleT.dateFormatM(
        DateTime.fromMicrosecondsSinceEpoch(data.purchaseAt));

    var orgDateId = '-';
    var orgDateQuarterId = '-';
    var orgDateIdHarp = '-';
    if (org != null) {
      orgDateId = StyleT.dateFormatM(
          DateTime.fromMicrosecondsSinceEpoch(org.purchaseAt));
      orgDateQuarterId = DateStyle.dateYearsQuarter(org.purchaseAt);
      orgDateIdHarp = DateStyle.dateYearsHarp(org.purchaseAt);
    }

    var dateIdHarp = DateStyle.dateYearsHarp(data.purchaseAt);
    var dateIdQuarter = DateStyle.dateYearsQuarter(data.purchaseAt);
    var searchText = await data.getSearchText();

    /// 거래명세서 파일 업로드
    if (files != null) {
      try {
        for (int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if (data.filesMap[k] != null) continue;

          final mountainImagesRef = FirebaseStorage.instance.ref().child(
              "purchase/${data.id}/${k}");
          await mountainImagesRef.putData(f);
          var url = await mountainImagesRef.getDownloadURL();
          if (url == null) {
            print('pur file upload failed');
            continue;
          }

          data.filesMap[k] = url;
        }
      } catch (e) {
        print(e);
      }
    }
    if (data.isItemTs) {
      ItemTS itemTs = ItemTS.fromPu(data,);
      //itemTs.update(org: org);
    }

    var db = FirebaseFirestore.instance;

    /// 메인문서 기록
    final docRef = db.collection("purchase").doc(data.id);

    /// 월별 매입기록 읽기 효율화
    final dateRef = db.collection('meta/date-m/purchase').doc(dateId);
    final orgDateRef = db.collection('meta/date-m/purchase').doc(orgDateId);

    /// 거래처 총매입 개수 읽기 효율화
    final csRef = db.collection('customer').doc(data.csUid);

    /// 거래처 매입문서 읽기 효율화
    final csDetailRef = db.collection(
        'customer/${data.csUid}/cs-dateH-purchase').doc(dateIdHarp);
    final orgCsDetailRef = db.collection(
        'customer/${data.csUid}/cs-dateH-purchase').doc(orgDateIdHarp);

    /// 검색 기록 문서 경로로
    final searchRef = db.collection('meta/search/dateQ-purchase').doc(
        dateIdQuarter);
    final orgSearchRef = db.collection('meta/search/dateQ-purchase').doc(
        orgDateQuarterId);

    db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);
      final dateRefSn = await transaction.get(dateRef);
      final orgDateRefSn = await transaction.get(orgDateRef);
      final csDetailRefSn = await transaction.get(csDetailRef);
      final searchRefSn = await transaction.get(searchRef);
      final orgSearchSn = await transaction.get(orgSearchRef);
      final orgCsDetailSn = await transaction.get(orgCsDetailRef);

      if (org != null) {
        if (orgDateRefSn.exists && dateId != orgDateId && orgDateId != '-') {
          transaction.update(
              orgDateRef, {'list\.${org.id}': null, 'updateAt': DateTime
              .now()
              .microsecondsSinceEpoch,});
        }
        if (orgSearchSn.exists && dateIdQuarter != orgDateQuarterId &&
            orgDateQuarterId != '-') {
          transaction.update(
              orgSearchRef, {'list\.${org.id}': null, 'updateAt': DateTime
              .now()
              .microsecondsSinceEpoch,});
        }
        if (orgCsDetailSn.exists && dateIdHarp != orgDateIdHarp &&
            orgDateIdHarp != '-') {
          transaction.update(
              orgCsDetailRef, {'list\.${org.id}': null, 'updateAt': DateTime
              .now()
              .microsecondsSinceEpoch,});
        }
      }

      if (docRefSn.exists) {
        transaction.update(docRef, data.toJson());
      } else {
        transaction.set(docRef, data.toJson());
      }

      if (dateRefSn.exists) {
        transaction.update(
            dateRef, {'list\.${data.id}': data.toJson(), 'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,});
      } else {
        transaction.set(dateRef, {
          'list': { data.id: data.toJson()},
          'updateAt': DateTime
              .now()
              .microsecondsSinceEpoch,
        });
      }

      if (csDetailRefSn.exists) {
        transaction.update(csDetailRef,
            {
              'list\.${data.id}': data.toJson(),
              'updateAt': DateTime
                  .now()
                  .microsecondsSinceEpoch,
            });
      } else {
        transaction.set(csDetailRef, {
          'list': { data.id: data.toJson()},
          'updateAt': DateTime
              .now()
              .microsecondsSinceEpoch,
        });
      }

      if (create) transaction.update(
          csRef, {'puCount': FieldValue.increment(-1), 'updateAt': DateTime
          .now()
          .microsecondsSinceEpoch,});

      if (searchRefSn.exists) {
        transaction.update(
          searchRef, { 'list\.${data.id}': searchText, 'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,},);
      } else {
        transaction.set(searchRef, {
          'list': { data.id: searchText},
          'updateAt': DateTime
              .now()
              .microsecondsSinceEpoch,
        },);
      }
    }).then(
          (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => print("Error updatePurchase() $e"),
    );
  }

  static dynamic deletePu(Purchase data,) async {
    data.state = 'DEL';
    var dateId = StyleT.dateFormatM(
        DateTime.fromMicrosecondsSinceEpoch(data.purchaseAt));
    var dateIdQuarter = DateStyle.dateYearsQuarter(data.purchaseAt);
    var dateIdHarp = DateStyle.dateYearsHarp(data.purchaseAt);

    var db = FirebaseFirestore.instance;
    final batch = db.batch();

    var main = db.collection('purchase').doc(data.id);
    batch.update(main, data.toJson());

    var dateRef = db.collection('meta/date-m/purchase').doc(dateId);
    batch.update(dateRef, {'list\.${data.id}': null, 'updateAt': DateTime
        .now()
        .microsecondsSinceEpoch,});

    var csPurRef = db.collection('customer/${data.csUid}/cs-dateH-purchase')
        .doc(dateIdHarp);
    var csPurSn = await csPurRef.get();
    if (csPurSn.exists) batch.update(
        csPurRef, {'list\.${data.id}': null, 'updateAt': DateTime
        .now()
        .microsecondsSinceEpoch,});

    var csRef = db.collection('customer').doc(data.csUid);
    batch.update(
        csRef, {'puCount': FieldValue.increment(-1), 'updateAt': DateTime
        .now()
        .microsecondsSinceEpoch,});

    var searchRef = db.collection('meta/search/dateQ-purchase').doc(
        dateIdQuarter);
    var searchSn = await searchRef.get();
    if (searchSn.exists) batch.update(
        searchRef, {'list\.${data.id}': null, 'updateAt': DateTime
        .now()
        .microsecondsSinceEpoch,});

    batch.commit().then((_) {});
  }


  static dynamic getPurchaseWithDate(int start, int end) async {
    Map<String, Purchase> data = {};

    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'purchase');
    await coll.where('purchaseAt', isGreaterThan: start).where(
        'purchaseAt', isLessThan: end).orderBy('purchaseAt', descending: true)
        .limit(100).get().then((value) {
      print('get purchase data');
      if (value.docs == null) return;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var ct = Purchase.fromDatabase(a.data() as Map);
        if (ct.state == 'DEL') continue;
        data[ct.id] = ct;
      }
    });

    return data.values.toList();
  }

  static dynamic getPurchaseDoc(String id) async {
    Purchase? data;
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'purchase');
    await coll.doc(id).get().then((value) {
      print('get purchase doc data');
      if (!value.exists) return false;
      var pu = Purchase.fromDatabase(value.data() as Map);
      if (pu.state != 'DEL') data = pu;
    });
    return data;
  }


  static dynamic initStreamRevenue() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'revenue');
    await coll.orderBy('revenueAt', descending: true).limit(50)
        .snapshots()
        .listen((value) {
      print('get revenue data');
      if (value.docs == null) return;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var revenue = Revenue.fromDatabase(a.data() as Map);
        SystemT.revenue[revenue.id] = revenue;
      }
      SystemT.initREPU();
      FunT.setStateMain();
    });
  }

  static dynamic getRevenueOnlyContract(String ctUid) async {
    List<Revenue> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'revenue');
    await coll.orderBy('state').orderBy('revenueAt', descending: true).where(
        'state', isNotEqualTo: 'DEL')
        .where('ctUid', isEqualTo: ctUid).limit(25).get().then((value) {
      print('get revenues only contract data');
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var revenue = Revenue.fromDatabase(a.data() as Map);
        data.add(revenue);
      }
    });
    return data;
  }

  static dynamic getRevenueWithCS(String id) async {
    List<Revenue> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'revenue');
    await coll.where('csUid', isEqualTo: id)
        .where('state', whereIn: [ ''])
        .get()
        .then((value) {
      print('get revenue data');
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var tmp = Revenue.fromDatabase(a.data() as Map);
        data.add(tmp);
      }
    });
    return data;
  }


  static dynamic updateVersion(VersionInfo data) async {
    var db = FirebaseFirestore.instance;

    /// 메인문서 기록
    final docRef = db.collection("meta/version/log").doc(data.name);

    db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);

      if (docRefSn.exists) {
        transaction.update(docRef, data.toJson());
      } else {
        transaction.set(docRef, data.toJson());
      }
    }).then(
          (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => print("Error updatePurchase() $e"),
    );
  }

  static dynamic getVersionInfo() async {
    List<VersionInfo> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta/version/log');
    await coll.orderBy('updateAt', descending: true).limit(25).get().then((
        value) {
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var tmp = VersionInfo.fromDatabase(a.data() as Map);
        data.add(tmp);
      }
    });
    return data;
  }


  /// 기초정보 추가
  static dynamic updateAccount(Account ac) async {
    if (ac.id == '') ac.id = generateRandomString(8);

    DocumentReference doc = await FirebaseFirestore.instance.doc(
        'meta/account');
    try {
      await doc.update({
        'list\.' + ac.id: ac.toJson(),
      });
    } catch (e) {
      print(e);

      await FireStoreError.setDocument(
          'meta/account', 'AC.PATCH', { 'list': { ac.id: ac.toJson()}});
    }
  }

  static dynamic getAccount() async {
    Map<String, Account> accounts = {};
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta');
    await coll.doc('account').get().then((value) {
      print('get meta inventory items data');
      if (value.data() == null) return false;
      var data = value.data() as Map;

      if (data['list'] == null) return false;
      var itemList = data['list'] as Map;
      SystemT.balance.balance = data['balance'] ?? 0;
      SystemT.balance.cash = data['cash'] ?? 0;

      for (var a in itemList.values) {
        if (a == null) continue;
        var ac = Account.fromDatabase(a as Map);
        accounts[ac.id] = ac;
      }
    });
    return accounts;
  }

  static dynamic updateTransactionDate(TS ts) async {
    if (ts.id == '') ts.id = generateRandomString(16);
    var dateId = StyleT.dateFormatM(
        DateTime.fromMicrosecondsSinceEpoch(ts.transactionAt));

    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta/date-m/transaction');
    try {
      await coll.doc(dateId).update({
        'list\.${ts.id}': ts.toLJson(),
        'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,
      });
    } catch (e) {
      await coll.doc(dateId).set({
        'list': { ts.id: ts.toLJson()},
        'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,
      });
    }
  }

  static dynamic getTransaction(
      { String? startAt, int? startDate, int? lastDate,}) async {
    List<TS> tsList = [];
    if (startAt != null) {
      var doc = await FirebaseFirestore.instance.doc('transaction/$startAt')
          .get();

      if (startDate != null && lastDate != null) {
        await FirebaseFirestore.instance.collection('transaction')
            .orderBy('transactionAt', descending: true)
            .where('transactionAt', isLessThan: lastDate).where(
            'transactionAt', isGreaterThan: startDate)
            .where('type', whereIn: [ 'RE', 'PU'])
            .startAfterDocument(doc).limit(25).get().then((value) {
          print('get transaction data');
          if (value.docs == null) return;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var map = a.data() as Map;

            var ts = TS.fromDatabase(map);
            ts.id = a.id;
            tsList.add(ts);
          }
        });
      }
      else {
        await FirebaseFirestore.instance.collection('transaction').orderBy(
            'transactionAt', descending: true)
            .where('type', whereIn: [ 'RE', 'PU'])
            .startAfterDocument(doc).limit(25).get().then((value) {
          print('get transaction data');
          if (value.docs == null) return;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var map = a.data() as Map;

            var ts = TS.fromDatabase(map);
            ts.id = a.id;
            tsList.add(ts);
          }
        });
      }
    }
    else {
      if (startDate != null && lastDate != null) {
        await FirebaseFirestore.instance.collection('transaction')
            .orderBy('transactionAt', descending: true)
            .where('transactionAt', isLessThan: lastDate).where(
            'transactionAt', isGreaterThan: startDate)
            .where('type', whereIn: [ 'RE', 'PU'])
            .limit(25).get().then((value) {
          print('get transaction data');
          if (value.docs == null) return;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var map = a.data() as Map;

            var ts = TS.fromDatabase(map);
            ts.id = a.id;
            tsList.add(ts);
          }
        });
      }
      else {
        await FirebaseFirestore.instance.collection('transaction').orderBy(
            'transactionAt', descending: true)
            .where('type', whereIn: [ 'RE', 'PU'])
            .limit(25).get().then((value) {
          print('get transaction data');
          if (value.docs == null) return;

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var map = a.data() as Map;
            var ts = TS.fromDatabase(map);

            tsList.add(ts);
          }
        });
      }
    }
    return tsList;
  }

  static dynamic getTransactionWithDate(int startAt, int lastAt) async {
    List<TS> tsList = [];
    await FirebaseFirestore.instance.collection(
        'meta/date-by/dateM-transaction').orderBy('date', descending: true).
    where('date', isGreaterThanOrEqualTo: startAt - 5000000000000).where(
        'date', isLessThanOrEqualTo: lastAt + 5000000000000).limit(20)
        .get()
        .then((value) {
      print('get transaction data');
      if (value.docs == null) return;

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var map = a.data() as Map;
        for (var key in map.keys) {
          if (key == 'date') continue;
          var ts = TS.fromDatabase(map[key]);
          if (ts.transactionAt < startAt || ts.transactionAt > lastAt) continue;

          tsList.add(ts);
        }
      }
    });
    return tsList;
  }

  static dynamic getTransactionAll() async {
    List<TS> tsList = [];
    await FirebaseFirestore.instance.collection('transaction').orderBy(
        'transactionAt', descending: true)
        .where('type', whereIn: [ 'RE', 'PU']).get().then((value) {
      print('get transaction data');
      if (value.docs == null) return;

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var map = a.data() as Map;
        var ts = TS.fromDatabase(map);

        tsList.add(ts);
      }
    });
    return tsList;
  }


  static dynamic getPur_In_ERROR() async {
    List<Purchase> tsList = [];
    await FirebaseFirestore.instance.collection('purchase').orderBy(
        'updateAt', descending: true)
        .where('updateAt', isNull: false).get().then((value) {
      for (var a in value.docs) {
        if (a.data() == null) continue;
        //if(a.data()['list'].) continue;

        var map = a.data()['list'] as Map;
        var ts = Purchase.fromDatabase(map.values.first);
        tsList.add(ts);
      }
    });
    return tsList;
  }


  static dynamic getTransactionCt(String id) async {
    List<TS> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'transaction');
    await coll.orderBy('transactionAt', descending: true).where(
        'ctUid', isEqualTo: id).get().then((value) {
      print('get transaction data');
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var map = a.data() as Map;
        var type = map['type'] ?? 'DEL';
        if (type == 'DEL') continue;

        var ts = TS.fromDatabase(map);
        data.add(ts);
      }
    });
    return data;
  }

  static dynamic getTransactionCs(String id) async {
    List<TS> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'transaction');

    //.where('state', whereIn: [ '' ])
    await coll.where('csUid', isEqualTo: id).get().then((value) {
      print('get transaction data');
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var ts = TS.fromDatabase(a.data() as Map);
        data.add(ts);
      }
    });
    return data;
  }

  static dynamic getAmountAccount(String id) async {
    var amount = 0;
    await FirebaseFirestore.instance.collection('balance/dateM-account/${id}')
        .limit(100).get()
        .then((value) {
      print('get account ts data');
      if (value.docs == null) return false;
      print(value.docs.length);
      for (var a in value.docs) {
        if (a.data() == null) continue;

        var map = a.data() as Map;
        map.forEach((key, value) {
          amount += value as int;
        });
      }
    });
    return amount;
  }

  static dynamic getAmountItemBalance(String id) async {
    var amount = 0.0;
    await FirebaseFirestore.instance.collection('meta/itemInven/${id}').limit(
        100).get().then((value) {
      if (value.docs == null) return false;
      value.docs.forEach((e) {
        if (e.data() == null) return;
        e.data().forEach((key, value) {
          amount += value as double;
        });
      });
    });
    return amount;
  }

  static dynamic getAmountItemProcess(String id) async {
    var amount = 0.0;
    await FirebaseFirestore.instance.collection('balance/dateQ-process/${id}')
        .limit(100).get()
        .then((value) {
      if (value.docs == null) return false;
      value.docs.forEach((e) {
        if (e.data() == null) return;
        e.data().forEach((key, value) {
          amount += value as double;
        });
      });
    });
    return amount;
  }


  static dynamic getAmountAccountWithDate(String id, String startAt,
      String lastAt) async {
    var amount = 0;
    await FirebaseFirestore.instance.collection('balance/dateM-account/${id}')
        .limit(100).get()
        .then((value) {
      print('get balance in account');
      if (value.docs == null) return false;
      print(value.docs.length);
      for (var a in value.docs) {
        if (a.data() == null) continue;

        var map = a.data() as Map;
        map.forEach((key, value) {
          var aa = key.toString().split('-');
          if (aa.length < 3)
            amount += value as int;
          else if (startAt.compareTo(aa[1]) > 0)
            return;
          else if (lastAt.compareTo(aa[1]) < 0)
            return;
          else
            amount += value as int;
        });
      }
    });
    return amount;
  }

  /// 거래정보 업데이트 또는 신규 생성시 메타데이터 동기화
  static dynamic updateTsAtCs(TS data, bool isCreate) async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'customer/${data.csUid}/detail');
    try {
      await coll.doc('transaction-0').update({
        'list\.${data.id}': data.toCsJson(),
        'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,
      });
    } catch (e) {
      await coll.doc('transaction-0').set({
        'list': { data.id: data.toCsJson(),},
        'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,
      });
    }

    CollectionReference coll2 = await FirebaseFirestore.instance.collection(
        'customer');
    try {
      if (isCreate) await coll2.doc(data.csUid).update(
          {'tsCount': FieldValue.increment(1),});
    } catch (e) {
      print(e);
    }
  }

  /// 거래정보 업데이트 또는 신규 생성시 메타데이터 동기화
  static dynamic updateTsMeta(TS data, bool create) async {
    if (data.id == '') data.id = generateRandomString(16);
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta/search/transaction');
    try {
      await coll.doc(data.scUid).update({
        'list\.${data.id}': data.summary + '&:' + data.memo,
        'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,
      });

      /// 신규 추가시 해당 문서 메타에 개수 추가 업데이트
      if (create) await updateTsMetaMeta(data.scUid);
    } catch (e) {
      await coll.doc(data.scUid).set({
        'list': { data.id: data.summary + '&:' + data.memo,},
        'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,
      });

      /// 신규 추가시 해당 문서 메타에 개수 추가 업데이트
      if (create) await updateTsMetaMeta(data.scUid);
    }
  }

  /// 신규 검색 정보 문서 추가 또는 개수 변경 업데이트
  static dynamic updateTsMetaMeta(String id) async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta/search/transaction-meta');
    try {
      await coll.doc(id).update({'count': FieldValue.increment(1),});
    } catch (e) {
      await coll.doc(id).set({'count': FieldValue.increment(1),});
    }
    CollectionReference coll2 = await FirebaseFirestore.instance.collection(
        'meta');
    try {
      await coll2.doc('search').update({'tsCount': FieldValue.increment(1),});
    } catch (e) {}
  }


  static dynamic getTS_CS_PU_date(String id) async {
    Map<dynamic, TS> datas = {};
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'transaction');
    await coll
        .orderBy('transactionAt', descending: true)
        .where('csUid', isEqualTo: id)
        .where('type', whereIn: [ 'PU'])
        .get().then((value) {
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var ts = TS.fromDatabase(a.data() as Map);
        if (ts.type == 'DEL') continue;

        datas[ts.id] = ts;
      }
    });
    return datas;
  }

  static dynamic getTransactionQr_CsReDt(String id) async {
    Map<dynamic, TS> datas = {};
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'transaction');
    await coll.where('csUid', isEqualTo: id)
        .where('type', isEqualTo: 'RE')
        .get()
        .then((value) {
      print('get transaction data');
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var ts = TS.fromDatabase(a.data() as Map);
        datas[ts.id] = ts;
      }
    });
    return datas;
  }

  static dynamic getTsWithCsDoc(String id) async {
    Map<dynamic, TS> datas = {};
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'customer/${id}/detail');
    await coll.doc('transaction-0').get().then((value) {
      print('get transaction cs data');
      if (value.data() == null) return false;

      var data = value.data() as Map;
      var tsList = data['list'] as Map;

      tsList.forEach((key, value) {
        if (value == null) return;
        var ts = TS.fromDatabase(value as Map);
        if (ts.type == 'DEL') return;
        ts.id = key;
        datas[key] = ts;
      });
    });
    return datas;
  }

  static dynamic getTsDoc(String id) async {
    TS? data;
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'transaction');
    await coll.doc(id).get().then((value) {
      print('get ts doc data');
      if (!value.exists) return false;
      var ts = TS.fromDatabase(value.data() as Map);
      if (ts.type != 'DEL') data = ts;
    });
    return data;
  }


  static dynamic initStreamVersion() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta');
    await coll.doc('version').get().then((value) {
      print('version listen data changed');
      if (value.data() == null) return;
      var data = value.data() as Map;

      Version.fromDatabase(data);

      FunT.setStateMain();
    });

    await coll.doc('version').snapshots().listen((value) {
      print('version listen data changed');
      if (value.data() == null) return;
      var data = value.data() as Map;

      Version.fromDatabase(data);

      FunT.setStateMain();
    });
    return true;
  }

  static dynamic initStreamPurchase() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'purchase');
    await coll.orderBy('purchaseAt', descending: true).limit(50)
        .snapshots()
        .listen((value) {
      print('get purchase data');
      if (value.docs == null) return;
      print(value.docs.length);

      Map<String, Purchase> data = {};
      for (var a in value.docs) {
        if (a.data() == null) continue;
        var ct = Purchase.fromDatabase(a.data() as Map);
        if (ct.state == 'DEL') continue;
        data[ct.id] = ct;
      }
      SystemT.purchase = data;
      SystemT.initREPU();
      FunT.setStateMain();
    });
  }

  /// 전체 매입목록에서 가져오는 형태
  /// 거래처의 분류 매입 목록에서 가져오는 형태로 변경
  static dynamic getPur_withCS(String id) async {
    List<Purchase> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'purchase');
    await coll.orderBy('purchaseAt', descending: true)
        .where('csUid', isEqualTo: id).where('state', whereIn: [ ''])
        .get()
        .then((value) {
      print('get purchase data');
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var ct = Purchase.fromDatabase(a.data() as Map);
        if (ct.state == 'DEL') continue;
        data.add(ct);
      }
    });
    return data;
  }

  static dynamic getPur_withCT(String id) async {
    List<Purchase> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'purchase');
    await coll.orderBy('purchaseAt', descending: true)
        .where('ctUid', isEqualTo: id).where('state', whereIn: [ ''])
        .get()
        .then((value) {
      print('get purchase data');
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var ct = Purchase.fromDatabase(a.data() as Map);
        if (ct.state == 'DEL') continue;
        data.add(ct);
      }
    });
    return data;
  }


  static dynamic getPurchaseDelete({ String? startAt }) async {
    List<Purchase> data = [];
    CollectionReference coll = FirebaseFirestore.instance.collection(
        'purchase');

    if (startAt != null) {
      var doc = await FirebaseFirestore.instance.doc('purchase/$startAt').get();
      await coll.orderBy('purchaseAt', descending: true)
          .where('state', isEqualTo: 'DEL').startAfterDocument(doc)
          .limit(10)
          .get()
          .then((value) {
        if (value.docs == null) return false;
        print(value.docs.length);

        for (var a in value.docs) {
          if (a.data() == null) continue;
          var ct = Purchase.fromDatabase(a.data() as Map);
          data.add(ct);
        }
      });
    }
    else {
      await coll.orderBy('purchaseAt', descending: true)
          .where('state', isEqualTo: 'DEL').limit(10).get().then((value) {
        if (value.docs == null) return false;
        print(value.docs.length);

        for (var a in value.docs) {
          if (a.data() == null) continue;
          var ct = Purchase.fromDatabase(a.data() as Map);
          data.add(ct);
        }
      });
    }

    return data;
  }

  static dynamic getPurchase(
      { String? startAt, int? startDate, int? lastDate,}) async {
    List<Purchase> data = [];
    var coll = FirebaseFirestore.instance.collection('purchase');


    if (startAt != null) {
      var doc = await FirebaseFirestore.instance.doc('purchase/$startAt').get();

      if (startDate != null && lastDate != null) {
        await coll.orderBy('purchaseAt', descending: true)
            .where('purchaseAt', isLessThanOrEqualTo: lastDate).where(
            'purchaseAt', isGreaterThanOrEqualTo: startDate)
            .where('state', whereIn: [ ''],)
            .startAfterDocument(doc).limit(25).get().then((value) {
          if (value.docs == null) return false;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var ct = Purchase.fromDatabase(a.data() as Map);
            if (ct.state == 'DEL') continue;

            data.add(ct);
          }
        });
      }
      else {
        await coll.orderBy('purchaseAt', descending: true)
            .where('state', whereIn: [ ''],)
            .startAfterDocument(doc).limit(25).get().then((value) {
          if (value.docs == null) return false;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var ct = Purchase.fromDatabase(a.data() as Map);
            data.add(ct);
          }
        });
      }
    }
    else {
      if (startDate != null && lastDate != null) {
        await coll
            .orderBy('purchaseAt', descending: true)
            .where('purchaseAt', isLessThanOrEqualTo: lastDate).where(
            'purchaseAt', isGreaterThanOrEqualTo: startDate)
            .where('state', whereIn: [ ''],)
            .limit(25).get().then((value) {
          if (value.docs == null) return false;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var ct = Purchase.fromDatabase(a.data() as Map);
            if (ct.state == 'DEL') continue;

            data.add(ct);
          }
        });
      }
      else {
        await coll
            .orderBy('purchaseAt', descending: true)
            .where('state', isEqualTo: '',)
            .limit(25).get().then((value) {
          if (value.docs == null) return false;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var ct = Purchase.fromDatabase(a.data() as Map);
            data.add(ct);
          }
        });
      }
    }

    return data;
  }

  static dynamic getPurchaseAll(
      { String? startAt, int? startDate, int? lastDate,}) async {
    List<Purchase> data = [];
    CollectionReference coll = FirebaseFirestore.instance.collection(
        'purchase');
    await coll.orderBy('purchaseAt', descending: true)
        .where('state', whereIn: [ ''],).get().then((value) {
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var pur = Purchase.fromDatabase(a.data() as Map);
        data.add(pur);
      }
    });
    return data;
  }

  static dynamic getRevDelete({ String? startAt }) async {
    List<Revenue> data = [];
    CollectionReference coll = FirebaseFirestore.instance.collection('revenue');

    if (startAt != null) {
      var doc = await FirebaseFirestore.instance.doc('revenue/$startAt').get();
      await coll.orderBy('revenueAt', descending: true)
          .where('state', isEqualTo: 'DEL').startAfterDocument(doc)
          .limit(10)
          .get()
          .then((value) {
        if (value.docs == null) return false;
        print(value.docs.length);

        for (var a in value.docs) {
          if (a.data() == null) continue;
          var ct = Revenue.fromDatabase(a.data() as Map);
          data.add(ct);
        }
      });
    }
    else {
      await coll.orderBy('revenueAt', descending: true)
          .where('state', isEqualTo: 'DEL').limit(10).get().then((value) {
        if (value.docs == null) return false;
        print(value.docs.length);

        for (var a in value.docs) {
          if (a.data() == null) continue;
          var ct = Revenue.fromDatabase(a.data() as Map);
          data.add(ct);
        }
      });
    }

    return data;
  }

  static dynamic getRevenue(
      { String? startAt, int? startDate, int? lastDate,}) async {
    List<Revenue> data = [];
    CollectionReference coll = FirebaseFirestore.instance.collection('revenue');

    if (startAt != null) {
      var doc = await FirebaseFirestore.instance.doc('revenue/$startAt').get();

      if (startDate != null && lastDate != null) {
        await coll.orderBy('revenueAt', descending: true)
            .where('revenueAt', isLessThan: lastDate).where(
            'revenueAt', isGreaterThan: startDate)
            .startAfterDocument(doc).limit(25).get().then((value) {
          if (value.docs == null) return false;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var ct = Revenue.fromDatabase(a.data() as Map);
            if (ct.state == 'DEL') continue;

            data.add(ct);
          }
        });
      }
      else {
        await coll.orderBy('state').orderBy('revenueAt', descending: true)
            .where('state', isNotEqualTo: 'DEL').startAfterDocument(doc).limit(
            25).get().then((value) {
          if (value.docs == null) return false;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var ct = Revenue.fromDatabase(a.data() as Map);
            data.add(ct);
          }
        });
      }
    }
    else {
      if (startDate != null && lastDate != null) {
        await coll.orderBy('revenueAt', descending: true)
            .where('revenueAt', isLessThan: lastDate).where(
            'revenueAt', isGreaterThan: startDate)
            .limit(25).get().then((value) {
          if (value.docs == null) return false;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var ct = Revenue.fromDatabase(a.data() as Map);
            if (ct.state == 'DEL') continue;

            data.add(ct);
          }
        });
      }
      else {
        await coll.orderBy('state').orderBy('revenueAt', descending: true)
            .where('state', isNotEqualTo: 'DEL').limit(25).get().then((value) {
          if (value.docs == null) return false;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var ct = Revenue.fromDatabase(a.data() as Map);
            data.add(ct);
          }
        });
      }
    }

    return data;
  }

  static dynamic getRevenueAll(
      { String? startAt, int? startDate, int? lastDate,}) async {
    List<Revenue> data = [];
    CollectionReference coll = FirebaseFirestore.instance.collection('revenue');

    await coll.orderBy('state').orderBy('revenueAt', descending: true)
        .where('state', isNotEqualTo: 'DEL').get().then((value) {
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var ct = Revenue.fromDatabase(a.data() as Map);
        data.add(ct);
      }
    });
    return data;
  }

  static dynamic updateContract(Contract data,
      { Map<String, Uint8List>? files, Map<String,
          Uint8List>? ctFiles,}) async {
    if (data.id == '') data.id = generateRandomString(16);

    /// 메타값 무결성 확인
    await getCtMetaCountCheck();
    if (data.scUid == '')
      data.scUid = SystemT.searchMeta.contractCursor.toString();
    if (data.csName == '')
      data.csName = (await SystemT.getCS(data.csUid)).businessName;
    for (var a in data.contractList) {
      if (a['id'] == null) a['id'] = generateRandomString(16);
    }

    try {
      if (files != null) {
        for (int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if (data.filesMap[k] != null) continue;

          var url = await updateCtFile(data.id, f, k);

          if (url == null) {
            print('contract file upload failed');
            continue;
          }

          data.filesMap[k] = url;
        }
      }
      if (ctFiles != null) {
        for (int i = 0; i < ctFiles.length; i++) {
          var f = ctFiles.values.elementAt(i);
          var k = ctFiles.keys.elementAt(i);

          if (data.contractFiles[k] != null) continue;

          var url = await updateCtFile(data.id, f, k);

          if (url == null) {
            print('contract file upload failed');
            continue;
          }

          data.contractFiles[k] = url;
        }
      }

      await FireStoreHub.docUpdate(
        'contract/${data.id}', 'CT.PATCH', data.toJson(),);
      await FireStoreHub.docUpdate(
        'meta/search/contract/${data.scUid}', 'CT.META.PATCH',
        {
          'list\.' + data.id: data.csName + '&:' + data.ctName + '&:' +
              data.fileName + '&:' + data.manager + '&:' + data.memo,
        },
        setJson: {
          'list': {
            data.id: data.csName + '&:' + data.ctName + '&:' + data.fileName +
                '&:' + data.manager + '&:' + data.memo,
          }
        },);
    } catch (e) {
      if (files != null) {
        for (int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if (data.filesMap[k] != null) continue;

          var url = await updateCtFile(data.id, f, k);

          if (url == null) {
            print('contract file upload failed');
            continue;
          }

          data.filesMap[k] = url;
        }
      }
      if (ctFiles != null) {
        for (int i = 0; i < ctFiles.length; i++) {
          var f = ctFiles.values.elementAt(i);
          var k = ctFiles.keys.elementAt(i);

          if (data.contractFiles[k] != null) continue;

          var url = await updateCtFile(data.id, f, k);

          if (url == null) {
            print('contract file upload failed');
            continue;
          }

          data.contractFiles[k] = url;
        }
      }
    }
  }

  static dynamic deleteContract(Contract data,) async {
    data.state = 'DEL';
    await FireStoreHub.docUpdate(
      'contract/${data.id}', 'CT.DELETE', data.toJson(),);
    await FireStoreHub.docUpdate(
      'meta/search/contract/${data.scUid}', 'CT-Meta.DELETE',
      { 'list\.' + data.id: '',},
      setJson: { 'list': { '',}},);
  }

  static dynamic initStreamContract() async {
    /*.where('state', isNotEqualTo: 'DEL', isNull: true)*/
    await FirebaseFirestore.instance.collection('contract')
        .limit(50)
        .snapshots()
        .listen((value) async {
      print('get contract data');
      if (value.docs == null) return;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var ct = Contract.fromDatabase(a.data() as Map);
        if (ct.state == 'DEL') {
          SystemT.contractMap.remove(ct.id);
          continue;
        }

        SystemT.contractMap[ct.id] = ct;
      }

      await FunT.setStateMain();
    });
  }


  static dynamic getItemTrans(String uid) async {
    ItemTS? aaa;
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'transaction-items');
    await coll.doc(uid).get().then((value) {
      if (!value.exists) return false;
      aaa = ItemTS.fromDatabase(value.data() as Map);
    });
    return aaa;
  }


  /// 현재 검색정보를 저장하고 있는 메타데이터의 무서 리트트중 현제 커서의 문서내 검색 정보 개수 확인
  /// 1500 이상시 신규문서 생성 - 카운트를 늘릴 수 있기 때문에 커서위치가 나올떄 까지 계속 카운팅
  static dynamic getCtMetaCountCheck() async {
    var aaa = 0;
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta/search/contract-meta');
    await coll.doc(SystemT.searchMeta.contractCursor.toString()).get().then((
        value) {
      print('get search meta data');
      if (!value.exists) return false;
      var aa = value.data() as Map;
      aaa = aa['count'] ?? 0;
    });
    if (aaa > SystemT.searchMeta.indexLimit) {
      SystemT.searchMeta.contractCursor++;
      await updateScMeta();
    }

    return aaa;
  }

  static dynamic getTsMetaCountCheck() async {
    var aaa = 0;
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta/search/transaction-meta');
    await coll.doc(SystemT.searchMeta.tsCursor.toString()).get().then((value) {
      print('get search ts meta data');
      if (!value.exists) return false;
      var aa = value.data() as Map;
      aaa = aa['count'] ?? 0;
    });
    if (aaa > SystemT.searchMeta.tsLimit) {
      SystemT.searchMeta.tsCursor++;
      await updateScMeta();
    }

    return aaa;
  }

  static dynamic getCtWithCs(String id) async {
    List<Contract> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'contract');
    await coll.where('csUid', isEqualTo: id).get().then((value) {
      print('get contract data');
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var ct = Contract.fromDatabase(a.data() as Map);
        if (ct.state == 'DEL') continue;
        data.add(ct);
      }
    });
    return data;
  }

  static dynamic getContractDoc(String id) async {
    Contract data = Contract.fromDatabase({});
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'contract');
    await coll.doc(id).get().then((value) {
      print('get contract doc data');
      if (!value.exists) return false;
      if (value.data() == null) return false;
      data = Contract.fromDatabase(value.data() as Map);
    });
    return data;
  }

  static dynamic initStreamCtMeta() async {
    Map<dynamic, dynamic> search = {};

    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta/search/contract');
    await coll.snapshots().listen((value) {
      print('contract meta listen data changed');
      if (value.docs == null) return;

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var searchMap = a.data() as Map;
        var headers = searchMap['list'] as Map;
        SystemT.contractSearch[a.id] = headers;

        FireStoreHub.docUpdate(
          'meta/search/contract-meta/${a.id}', 'CT.META-COUNT.PATCH',
          { 'count': headers.length,},
          setJson: { 'count': headers.length,},
        );
      }
      FunT.setStateMain();
    });
    return search;
  }

  static dynamic initStreamTsMeta() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta/search/dateQ-transaction');
    return coll.snapshots().listen((value) {
      if (value.docs == null) return;
      print('initStream Ts: ${value.docs.length}');

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var searchMap = a.data() as Map;
        for (var s in searchMap.keys)
          SystemT.transactionSearch[s.toString()] = searchMap[s].toString();
      }

      FunT.setStateMain();
    });
  }

  static dynamic initStreamPuMeta() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta/search/dateQ-purchase');
    await coll.snapshots().listen((value) {
      if (value.docs == null) return;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var searchMap = a.data() as Map;
        var headers = searchMap['list'] as Map;
        SystemT.purSearch[a.id] = headers;
      }
    });
  }


  static dynamic updateScMeta() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta');
    try {
      await coll.doc('search').update(SystemT.searchMeta.toJson());
    } catch (e) {
      print(e);
    }
  }

  static dynamic getSearchMeta() async {
    SearchMeta data = SearchMeta.fromDatabase({});
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta');
    await coll.doc('search').get().then((value) {
      print('get search meta data');
      if (!value.exists) return false;
      data = SearchMeta.fromDatabase(value.data() as Map);
    });
    return data;
  }

  static dynamic deleteCustomer(Customer data,) async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'customer');
    CollectionReference coll2 = await FirebaseFirestore.instance.collection(
        'meta');
    try {
      data.state = 'DEL';
      await coll.doc(data.id).update(data.toJson());
      await coll2.doc('customer').update({
        'search\.${data.id}': '',
        'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,
      });
    } catch (e) {
      print(e);
    }
  }

  static dynamic updateCustomer(Customer data,
      { Map<String, Uint8List>? files }) async {
    if (data.id == '') data.id = generateRandomString(16);

    try {
      if (files != null) {
        for (int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if (data.filesMap[k] != null) continue;

          var url = await updateCsFile(data.id, f, k);

          if (url == null) {
            print('cs file upload failed');
            continue;
          }

          data.filesMap[k] = url;
        }
      }
    } catch (e) {}

    // 03.08 요청사항
    // 거래처 대표명으로 검색 필요
    // 데이터베이스 텍스트 검색 구조 변경
    var searchText = data.getSearchText();
    await FireStoreHub.docUpdate(
        'customer/${data.id}', 'CS.PATCH', data.toJson());
    await FireStoreHub.docUpdate('meta/customer', 'CS.PATCH',
        { 'search\.${data.id}': searchText, 'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,},
        setJson: { 'search': { searchText}, 'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,}
    );
  }

  static dynamic initStreamCSMeta() async {
    Map<dynamic, dynamic> search = {};

    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta');
    await coll.doc('customer').snapshots().listen((value) {
      print('get meta customer search data');
      if (value.data() == null) return;
      var data = value.data() as Map;

      if (data['search'] == null) return;

      SystemT.customerSearch.clear();
      search.clear();
      var sMap = data['search'] as Map;
      sMap.forEach((key, value) {
        if (value != 'DEL') search[key] = value;
      });
      SystemT.customerSearch = search;
    });
    return search;
  }

  static dynamic getCustomer({String? startAt}) async {
    List<Customer> data = [];

    if (startAt != null) {
      var doc = await FirebaseFirestore.instance.doc('customer/$startAt').get();
      await FirebaseFirestore.instance.collection('customer').orderBy('state')
          .where('state', isNotEqualTo: 'DEL').startAfterDocument(doc)
          .limit(25)
          .get()
          .then((value) {
        if (value.docs == null) return false;
        print(value.docs.length);

        for (var a in value.docs) {
          if (a.data() == null) continue;
          var cs = Customer.fromDatabase(a.data() as Map);
          data.add(cs);
        }
      });
    }
    else {
      await FirebaseFirestore.instance.collection('customer').orderBy('state')
          .where('state', isNotEqualTo: 'DEL').limit(25).get().then((value) {
        if (value.docs == null) return false;
        print(value.docs.length);

        for (var a in value.docs) {
          if (a.data() == null) continue;
          var cs = Customer.fromDatabase(a.data() as Map);
          data.add(cs);
        }
      });
    }
    return data;
  }

  static dynamic getCustomerDelete({String? startAt}) async {
    List<Customer> data = [];
    Query<Map<String, dynamic>> query;

    if (startAt != null) {
      var startAtDoc = await FirebaseFirestore.instance.doc('customer/$startAt')
          .get();
      query = FirebaseFirestore.instance.collection('customer').where(
          'state', isEqualTo: 'DEL').startAfterDocument(startAtDoc).limit(10);
    }
    else {
      query = FirebaseFirestore.instance.collection('customer').where(
          'state', isEqualTo: 'DEL').limit(10);
    }

    await query.get().then((value) {
      if (value.docs.isEmpty) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        var cs = Customer.fromDatabase(a.data() as Map);
        data.add(cs);
      }
    });
    return data;
  }

  static dynamic getCustomerDoc(String id,) async {
    if (id == '') return null;

    Customer? data;
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'customer');
    try {
      await coll.doc(id).get().then((value) {
        if (!value.exists) return false;
        var cs = Customer.fromDatabase(value.data() as Map);
        if (cs.state == 'DEL') return false;
        data = cs;
      });
    } catch (e) {
      print(e);
    }
    return data;
  }

  static dynamic getCustomerFromPuCount() async {
    /// 추후 지급, 미지급 금액을 저장 변동시 변동분 따로 저장, 해당값이 0이 아닐경우 읽기, 문서 정렬 필요
    List<Customer> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'customer');
    await coll.where('puCount', isGreaterThan: 0).limit(50).get().then((value) {
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var cs = Customer.fromDatabase(a.data() as Map);
        if (cs.state == 'DEL') continue;

        data.add(cs);
      }
    });
    return data;
  }


  /// 이 함수는 거래처 목록을
  static dynamic getTsWithCustomer(String id) async {
    List<TS> tsList = [];

    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'customer/$id/cs-dateH-transaction');
    await coll.limit(50).get().then((value) {
      if (value.docs == null) return false;
      for (var a in value.docs) {
        if (a.data() == null) continue;

        for (var ts in (a.data() as Map).values) {
          tsList.add(TS.fromDatabase(ts as Map));
        }
      }
    });

    return tsList;
  }

  static dynamic getCSWithRe() async {
    /// 추후 지급, 미지급 금액을 저장 변동시 변동분 따로 저장, 해당값이 0이 아닐경우 읽기, 문서 정렬 필요
    List<Customer> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'customer');
    await coll.where('reCount', isGreaterThan: 0).limit(50).get().then((value) {
      print('get customer data');
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var cs = Customer.fromDatabase(a.data() as Map);
        if (cs.state == 'DEL') continue;
        data.add(cs);
      }
    });
    return data;
  }

  static dynamic getContract({String? startAt}) async {
    List<Contract> data = [];

    if (startAt != null) {
      var doc = await FirebaseFirestore.instance.doc('contract/$startAt').get();
      await FirebaseFirestore.instance.collection('contract').orderBy('state')
          .where('state', isNotEqualTo: 'DEL').startAfterDocument(doc)
          .limit(50)
          .get()
          .then((value) {
        if (value.docs == null) return false;
        print(value.docs.length);

        for (var a in value.docs) {
          if (a.data() == null) continue;
          var cs = Contract.fromDatabase(a.data() as Map);
          data.add(cs);
        }
      });
    }
    else {
      await FirebaseFirestore.instance.collection('contract').orderBy('state')
          .where('state', isNotEqualTo: 'DEL').limit(50).get().then((value) {
        if (value.docs == null) return false;
        print(value.docs.length);

        for (var a in value.docs) {
          if (a.data() == null) continue;
          var cs = Contract.fromDatabase(a.data() as Map);
          data.add(cs);
        }
      });
    }
    return data;
  }

  static dynamic updateFactoryDWithFile(FactoryD data,
      { Map<String, Uint8List>? files,}) async {
    if (data.id == '') data.id = data.getID();
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'factory-daily');
    try {
      if (files != null) {
        for (int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if (data.filesMap[k] != null) continue;

          var url = await updateFDFile(data.id, f, k);

          if (url == null) {
            print('factory daily file upload failed');
            continue;
          }

          data.filesMap[k] = url;
        }
      }
      await coll.doc(data.id).update(data.toJson());
    } catch (e) {
      if (files != null) {
        for (int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if (data.filesMap[k] != null) continue;

          var url = await updateFDFile(data.id, f, k);

          if (url == null) {
            print('factory daily file upload failed');
            continue;
          }

          data.filesMap[k] = url;
        }
      }
      await coll.doc(data.id).set(data.toJson());
    }
  }

  static dynamic getFactory(
      { String? startAt, int? startDate, int? lastDate,}) async {
    List<FactoryD> factory_list = [];
    if (startAt != null) {
      if (startAt == '') return factory_list;

      var doc = await FirebaseFirestore.instance.doc('factory-daily/$startAt')
          .get();

      if (startDate != null && lastDate != null) {
        await FirebaseFirestore.instance.collection('factory-daily')
            .orderBy('date', descending: true)
            .where('date', isLessThan: lastDate).where(
            'date', isGreaterThan: startDate)
            .where('state', whereIn: [ ''])
            .startAfterDocument(doc).limit(25).get().then((value) {
          if (value.docs == null) return;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var map = a.data() as Map;

            var ts = FactoryD.fromDatabase(map);
            ts.id = a.id;
            factory_list.add(ts);
          }
        });
      }
      else {
        await FirebaseFirestore.instance.collection('factory-daily').orderBy(
            'date', descending: true)
            .where('state', whereIn: [ ''])
            .startAfterDocument(doc).limit(25).get().then((value) {
          print('get transaction data');
          if (value.docs == null) return;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var map = a.data() as Map;

            var ts = FactoryD.fromDatabase(map);
            ts.id = a.id;
            factory_list.add(ts);
          }
        });
      }
    }
    else {
      if (startDate != null && lastDate != null) {
        await FirebaseFirestore.instance.collection('factory-daily')
            .orderBy('date', descending: true)
            .where('date', isLessThan: lastDate).where(
            'date', isGreaterThan: startDate)
            .where('state', whereIn: [ ''])
            .limit(25).get().then((value) {
          if (value.docs == null) return;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var map = a.data() as Map;

            var ts = FactoryD.fromDatabase(map);
            ts.id = a.id;
            factory_list.add(ts);
          }
        });
      }
      else {
        await FirebaseFirestore.instance.collection('factory-daily').orderBy(
            'date', descending: true)
            .where('state', whereIn: [ ''])
            .limit(25).get().then((value) {
          if (value.docs == null) return;

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var map = a.data() as Map;
            var ts = FactoryD.fromDatabase(map);

            factory_list.add(ts);
          }
        });
      }
    }
    return factory_list;
  }

  static dynamic getProductList(
      { String? startAt, int? startDate, int? lastDate,}) async {
    List<ProductD> factory_list = [];
    if (startAt != null) {
      var doc = await FirebaseFirestore.instance.doc('product-daily/$startAt')
          .get();

      if (startDate != null && lastDate != null) {
        await FirebaseFirestore.instance.collection('product-daily')
            .orderBy('date', descending: true)
            .where('date', isLessThan: lastDate).where(
            'date', isGreaterThan: startDate)
            .where('state', whereIn: [ ''])
            .startAfterDocument(doc).limit(25).get().then((value) {
          if (value.docs == null) return;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var map = a.data() as Map;

            var ts = ProductD.fromDatabase(map);
            ts.id = a.id;
            factory_list.add(ts);
          }
        });
      }
      else {
        await FirebaseFirestore.instance.collection('product-daily').orderBy(
            'date', descending: true)
            .where('state', whereIn: [ ''])
            .startAfterDocument(doc).limit(25).get().then((value) {
          print('get transaction data');
          if (value.docs == null) return;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var map = a.data() as Map;

            var ts = ProductD.fromDatabase(map);
            ts.id = a.id;
            factory_list.add(ts);
          }
        });
      }
    }
    else {
      if (startDate != null && lastDate != null) {
        await FirebaseFirestore.instance.collection('product-daily')
            .orderBy('date', descending: true)
            .where('date', isLessThan: lastDate).where(
            'date', isGreaterThan: startDate)
            .where('state', whereIn: [ ''])
            .limit(25).get().then((value) {
          if (value.docs == null) return;
          print(value.docs.length);

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var map = a.data() as Map;

            var ts = ProductD.fromDatabase(map);
            ts.id = a.id;
            factory_list.add(ts);
          }
        });
      }
      else {
        await FirebaseFirestore.instance.collection('product-daily').orderBy(
            'date', descending: true)
            .where('state', whereIn: [ ''])
            .limit(25).get().then((value) {
          if (value.docs == null) return;

          for (var a in value.docs) {
            if (a.data() == null) continue;
            var map = a.data() as Map;
            var ts = ProductD.fromDatabase(map);

            factory_list.add(ts);
          }
        });
      }
    }
    return factory_list;
  }

  static dynamic getLedgerRevenueList(String csUid) async {
    List<Ledger> list = [];

    await FirebaseFirestore.instance.collection('ledger/revenue/article')
        .orderBy('date', descending: true)
        .where('csUid', isEqualTo: csUid)
        .where('state', isEqualTo: '')
        .limit(25).get().then((value) {
      if (value.docs == null) return;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var map = a.data() as Map;

        var ts = Ledger.fromDatabase(map);
        ts.id = a.id;
        list.add(ts);
      }
    });

    return list;
  }

  static dynamic getItemTranList(
      { String? startAt, int? startDate, int? lastDate,}) async {
    List<ItemTS> itemTs_list = [];

    var mainRoot = FirebaseFirestore.instance.collection('transaction-items');
    Query<Map<String, dynamic>> root = mainRoot.limit(25);
    if (startAt != null) {
      if (startAt == '') return itemTs_list;
      var doc = await mainRoot.doc(startAt).get();
      if (startDate != null && lastDate != null) {
        root = mainRoot
            .orderBy('date', descending: true)
            .where('date', isLessThan: lastDate)
            .where('date', isGreaterThan: startDate)
            .where('state', whereIn: [ ''])
            .startAfterDocument(doc).limit(25);
      }
      else {
        root = await mainRoot.orderBy('date', descending: true)
            .where('state', whereIn: [ ''])
            .startAfterDocument(doc).limit(25);
      }
    }
    else {
      if (startDate != null && lastDate != null) {
        root = await mainRoot
            .orderBy('date', descending: true)
            .where('date', isLessThan: lastDate)
            .where('date', isGreaterThan: startDate)
            .where('state', whereIn: [ ''])
            .limit(25);
      }
      else {
        root = await mainRoot
            .orderBy('date', descending: true)
            .where('state', whereIn: [ ''])
            .limit(25);
      }
    }

    await root.get().then((value) {
      if (value.docs == null) return;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var map = a.data() as Map;

        var ts = ItemTS.fromDatabase(map);
        ts.id = a.id;
        itemTs_list.add(ts);
      }
    });

    return itemTs_list;
  }

  static dynamic getItemTranListProduct(
      { String? startAt, int? startDate, int? lastDate,}) async {
    List<ItemTS> itemTs_list = [];

    var mainRoot = FirebaseFirestore.instance.collection('transaction-items');
    Query<Map<String, dynamic>> root = mainRoot.limit(25);
    if (startAt != null) {
      if (startAt == '') return itemTs_list;
      var doc = await mainRoot.doc(startAt).get();
      if (startDate != null && lastDate != null) {
        root = mainRoot
            .orderBy('date', descending: true)
            .where('date', isLessThan: lastDate)
            .where('date', isGreaterThan: startDate)
            .where('state', isEqualTo: "")
            .where('type', whereIn: [ 'PR', 'FR', 'DR'])
            .startAfterDocument(doc).limit(25);
      }
      else {
        root = await mainRoot.orderBy('date', descending: true)
            .where('state', isEqualTo: "")
            .where('type', whereIn: [ 'PR', 'FR', 'DR'])
            .startAfterDocument(doc).limit(25);
      }
    }
    else {
      if (startDate != null && lastDate != null) {
        root = await mainRoot
            .orderBy('date', descending: true)
            .where('date', isLessThan: lastDate)
            .where('date', isGreaterThan: startDate)
            .where('state', isEqualTo: "")
            .where('type', whereIn: [ 'PR', 'FR', 'DR'])
            .limit(25);
      }
      else {
        root = await mainRoot
            .orderBy('date', descending: true)
            .where('state', isEqualTo: "")
            .where('type', whereIn: [ 'PR', 'FR', 'DR'])
            .limit(25);
      }
    }

    await root.get().then((value) {
      if (value.docs == null) return;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var map = a.data() as Map;

        var ts = ItemTS.fromDatabase(map);
        ts.id = a.id;
        itemTs_list.add(ts);
      }
    });

    return itemTs_list;
  }


  static dynamic getItemProcessPu(String puUid) async {
    List<ProcessItem> itemProcessList = [];

    var mainRoot = FirebaseFirestore.instance.collection(
        'purchase/${puUid}/item-process');
    await mainRoot.limit(50).get().then((value) {
      if (value.docs == null) return;
      print(value.docs.length);

      value.docs.forEach((e) {
        if (e.data() == null) return;
        itemProcessList.add(ProcessItem.fromDatabase(e.data()));
      });
    });

    return itemProcessList;
  }

  static dynamic getProcessItemGroupList({bool all = false}) async {
    List<ProcessItem> itemProcessList = [];

    var mainRoot = FirebaseFirestore.instance.collectionGroup('item-process');

    if (all) {
      await mainRoot.orderBy('date', descending: true).where(
          'state', whereIn: [ '']).limit(50).get().then((value) {
        if (value.docs == null) return;
        print(value.docs.length);

        value.docs.forEach((e) {
          if (e.data() == null) return;
          itemProcessList.add(ProcessItem.fromDatabase(e.data()));
        });
      });
    } else {
      await mainRoot.orderBy('date', descending: true).where(
          'isOutput', isEqualTo: false)
          .where('isDone', isEqualTo: false).where('state', whereIn: [ ''])
          .limit(50).get()
          .then((value) {
        if (value.docs == null) return;
        print(value.docs.length);

        value.docs.forEach((e) {
          if (e.data() == null) return;
          itemProcessList.add(ProcessItem.fromDatabase(e.data()));
        });
      });
    }

    return itemProcessList;
  }

  static dynamic getProcessItemGroupByPrUid(String uid) async {
    List<ProcessItem> itemProcessList = [];

    var mainRoot = FirebaseFirestore.instance.collectionGroup('item-process');
    await mainRoot.orderBy('date', descending: true).where(
        'prUid', isEqualTo: uid)
        .where('isOutput', isEqualTo: true)
        .where('state', whereIn: [ '']).limit(50).get().then((value) {
      if (value.docs == null) return;
      print(value.docs.length);

      value.docs.forEach((e) {
        if (e.data() == null) return;
        itemProcessList.add(ProcessItem.fromDatabase(e.data()));
      });
    });

    return itemProcessList;
  }

  static dynamic getProcessItemGroupByCsUid(String uid,
      { bool isOutput = false }) async {
    List<ProcessItem> itemProcessList = [];

    var mainRoot = FirebaseFirestore.instance.collectionGroup('item-process');
    await mainRoot.orderBy('date', descending: true)
        .where('csUid', isEqualTo: uid)
        .where('isOutput', isEqualTo: isOutput)
        .where('state', whereIn: [ '']).limit(50).get().then((value) {
      if (value.docs == null) return;
      print(value.docs.length);

      value.docs.forEach((e) {
        if (e.data() == null) return;
        itemProcessList.add(ProcessItem.fromDatabase(e.data()));
      });
    });

    return itemProcessList;
  }

  static dynamic getProcessItemDoc(String rpUid, String id) async {
    ProcessItem? data;

    var mainRoot = FirebaseFirestore.instance.collection(
        'purchase/$rpUid/item-process').doc(id);
    await mainRoot.get().then((value) {
      if (!value.exists) return null;
      if (value.data() == null) return null;
      data = ProcessItem.fromDatabase(value.data() as Map);
    });
    return data;
  }


  static dynamic updateProductDWithFile(ProductD data,
      { Map<String, Uint8List>? files,}) async {
    if (data.id == '') data.id = data.getID();
    try {
      if (files != null) {
        for (int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if (data.filesMap[k] != null) continue;

          var url = await StorageHub.updateFile(
              'product-daily/${data.id}', 'PD-Date', f, k);

          if (url == null) {
            print('product daily file upload failed');
            continue;
          }

          data.filesMap[k] = url;
        }
      }
      await FireStoreHub.docUpdate(
        'product-daily/${data.id}', 'PD-Date.PATCH', data.toJson(),);
    } catch (e) {
      print(e);
      if (files != null) {
        for (int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if (data.filesMap[k] != null) continue;

          var url = await updateFDFile(data.id, f, k);

          if (url == null) {
            print('factory daily file upload failed');
            continue;
          }

          data.filesMap[k] = url;
        }
      }
    }
  }

  static dynamic initStreamProductDate() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'product-daily');
    await coll.orderBy('date', descending: true).limit(50).snapshots().listen((
        value) {
      print('product-daily listen data changed');
      if (value.docs == null) return;

      for (var doc in value.docs) {
        var fd = ProductD.fromDatabase(doc.data() as Map);
        if (fd.state == 'DEL') {
          ProductSystem.productStream.remove(fd.id);
          continue;
        }
        ProductSystem.productStream[doc.id] = fd;
      }
      ProductSystem.sortStream();
      FunT.setStateMain();
    });
  }


  static dynamic getSchedule() async {
    List<Schedule> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'schedule');
    await coll.orderBy('date', descending: true).limit(100).get().then((value) {
      print('get schedule data');
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var cs = Schedule.fromDatabase(a.data() as Map);
        data.add(cs);
      }
    });
    return data;
  }

  static dynamic getSCH_CT(String id) async {
    List<Schedule> data = [];
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'schedule');
    await coll.orderBy('date', descending: true).where('ctUid', isEqualTo: id)
        .limit(50).get()
        .then((value) {
      print('get schedule data');
      if (value.docs == null) return false;
      print(value.docs.length);

      for (var a in value.docs) {
        if (a.data() == null) continue;
        var cs = Schedule.fromDatabase(a.data() as Map);
        data.add(cs);
      }
    });
    return data;
  }

  static dynamic updateCsFile(String id, Uint8List data, String name) async {
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();
    final mountainImagesRef = storageRef.child("customer/$id/$name");
    print(data.length);
    print(name);
    try {
      await mountainImagesRef.putData(data);
      print('save storage data');
      var url = await mountainImagesRef.getDownloadURL();
      print(url);
      return url;
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }

  static dynamic updateCtFile(String id, Uint8List data, String name) async {
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();
    final mountainImagesRef = storageRef.child("contract/$id/$name");
    print(data.length);
    print(name);
    try {
      await mountainImagesRef.putData(data);
      print('save storage data');
      var url = await mountainImagesRef.getDownloadURL();
      print(url);
      return url;
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }

  static dynamic updateFDFile(String id, Uint8List data, String name) async {
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();
    final mountainImagesRef = storageRef.child("factory-daily/$id/$name");
    print(data.length);
    print(name);
    try {
      await mountainImagesRef.putData(data);
      print('save storage data');
      var url = await mountainImagesRef.getDownloadURL();
      print(url);
      return url;
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }

  static dynamic updateItemTS(ItemTS data, DateTime date) async {
    if (data.id == '') data.id = generateRandomString(8);
    var doc = StyleT.dateFormat(date);

    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'inventory');
    try {
      await coll.doc(doc).update({
        'transaction\.${data.id}': data.toJson(),
        'transactionCount': FieldValue.increment(1),
        'transactionAt': date.microsecondsSinceEpoch,
        'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,
      });
    } catch (e) {
      await coll.doc(doc).set({
        'transaction': {data.id: data.toJson(),},
        'transactionCount': FieldValue.increment(1),
        'transactionAt': date.microsecondsSinceEpoch,
        'updateAt': DateTime
            .now()
            .microsecondsSinceEpoch,
      });
    }
  }

  /// 품목이 추가된 문서 1개의 하위 리스트, 최대 1000개로 가정
  /// 추가시 Map 형태, key 설정 문제 - 품목의 이름, 신규추가시 넘버링, 무작위 번호,
  static dynamic updateItem(Item data) async {
    if (data.id == '') data.id = generateRandomString(8);

    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta');
    try {
      await coll.doc('item').update({
        'list\.${data.id}': data.toJson(),
        'count': FieldValue.increment(1)
      });
    } catch (e) {
      await coll.doc('item').set({
        'list\.${data.id}': data.toJson(),
        'count': FieldValue.increment(1)
      });
    }
  }

  static dynamic updateItemMetaGP(String id, String group,
      { Map<dynamic, dynamic>? groupAll }) async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta');

    try {
      if (groupAll != null) {
        await coll.doc('item').update({'group': groupAll,});
      } else {
        await coll.doc('item').update({'group\.${id}': group,});
      }
    } catch (e) {
      print(e);
    }
  }

  static dynamic deleteItem(Item data,) async {
    data.type = 'DEL';
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta');
    try {
      await coll.doc('item').update({
        'list\.${data.id}': data.toJson(),
      });
    } catch (e) {}
  }

  static dynamic getItems() async {
    Map<String, Item> itemDatas = {};
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta');
    await coll.doc('item').get().then((value) {
      print('get meta items data');
      if (value.data() == null) return false;
      var data = value.data() as Map;
      var itemList = data['list'] as Map;
      MetaT.itemGroup = data['group'] as Map;

      for (var a in itemList.values) {
        if (a == null) continue;
        var itemTmp = Item.fromDatabase(a as Map);
        if (itemTmp.type == 'DEL') continue;

        itemDatas[itemTmp.id] = itemTmp;
      }
    });
    return itemDatas;
  }

  static dynamic getItemsStream() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection(
        'meta');

    return coll.doc('item').snapshots().listen((value) {
      print('item snapshots listen data changed');
      FunT.setStateMain();
    });
  }

  static String generateRandomString(int len) {
    var r = Random();
    //const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    const _chars = '0123456789';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }


  static dynamic getUserDataWithUID(String uid) async {
    UserData user = UserData.fromDatabase({});
    var ref = await FirebaseFirestore.instance.collection('users').doc(uid);
    await ref.get().then((value) {
      if (!value.exists) return false;
      if (value.data() == null) return false;

      user = UserData.fromDatabase(value.data() as Map);
    });
    return user;
  }

  static dynamic getUserDataList() async {
    List<UserData> userList = [];
    var ref = await FirebaseFirestore.instance.collection('users');
    await ref.get().then((value) {
      if (value.docs.isEmpty) return false;

      value.docs.forEach((e) {
        if(!e.exists) return;
        userList.add(UserData.fromDatabase(e.data() as Map));
      });
    });

    return userList;
  }
}

class StorageHub {
  static dynamic updateFile(String path, String code, Uint8List data, String name) async {
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();
    final mountainImagesRef = storageRef.child("$path/$name");
    print(data.length);
    print(name);
    try {
      await mountainImagesRef.putData(data);
      print(code + '::DONE');
      var url = await mountainImagesRef.getDownloadURL();
      print(url);
      return url;
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }
  static dynamic deleteFile(String path, String code, String name) async {
    // Create a storage reference from our app
    final storageRef = FirebaseStorage.instance.ref();
    final mountainImagesRef = storageRef.child("$path/$name");
    print(name);
    try {
      await mountainImagesRef.delete();
      print(code + '::DONE');
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }
}

class FireStoreHub {
  static dynamic docUpdate(String path, String code, Map<String, dynamic> json, {  Map<String, dynamic>? setJson, }) async {
    DocumentReference doc = await FirebaseFirestore.instance.doc(path);
    try {
      await doc.update(json);
    } catch (e) {
      print('ERROR-' + code + '::' + e.toString());
      var exists = await FireStoreExists.doc(path);
      if(!exists) await FireStoreError.setDocument(path, code + '-SET', setJson ?? json);
    }
  }
  static dynamic docUpdateDel(String path, String code, Map<String, dynamic> json, {  Map<String, dynamic>? setJson,
    Map<dynamic, dynamic>? fileMap, Map<dynamic, dynamic>? fileName, }) async {
    DocumentReference doc = await FirebaseFirestore.instance.doc(path);

    if(fileMap != null) {
      fileMap.forEach((key, value) async {
        var fileN = key;
        if(fileName != null) { fileN = fileName[key] ?? key; }
        await StorageHub.deleteFile(path, code, fileN);
      });
    }

    try {
      await doc.update(json);
    } catch (e) {
      print('ERROR-' + code + '::' + e.toString());
    }
  }
  static dynamic docDelete(String path, String code, { Map<dynamic, dynamic>? fileMap, Map<dynamic, dynamic>? fileName, }) async {
    DocumentReference doc = await FirebaseFirestore.instance.doc(path);

    if(fileMap != null) {
      fileMap.forEach((key, value) async {
        var fileN = key;
        if(fileName != null) { fileN = fileName[key] ?? key; }
        await StorageHub.deleteFile(path, code, fileN);
      });
    }

    try {
      await doc.delete();
    } catch (e) {
      print('ERROR-' + code + '::' + e.toString());
    }
  }
}
class FireStoreExists {
  static dynamic doc(String path) async {
    bool exists = false;
    DocumentReference docu = await FirebaseFirestore.instance.doc(path);
    try {
      var checking = await docu.get();
      return checking.exists;
    } catch (e) {
      return false;
    }
    return exists;
  }
}
class FireStoreError {
  static dynamic setDocument(String path, String code, Map<String, dynamic> json) async {
    DocumentReference doc = await FirebaseFirestore.instance.doc(path);
    try {
      await doc.set(json);
    } catch (e) {
      print('ERROR-' + code + '::' + e.toString());
    }
  }
}
