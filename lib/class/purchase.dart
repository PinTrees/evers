
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/system.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/aes.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import '../helper/style.dart';
import '../ui/dialog_revenue.dart';
import '../ui/ux.dart';
import 'Customer.dart';
import 'contract.dart';
import 'database/item.dart';
import 'package:http/http.dart' as http;


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
  var updateAt = 0;

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
    vat = json['vat'] ?? 0;
    totalPrice = json['totalPrice'] ?? 0;
    paymentAt = json['paymentAt'] ?? 0;
    purchaseAt = json['purchaseAt'] ?? 0;
    updateAt = json['updateAt'] ?? 0;

    memo = json['memo'] ?? '';
    filesMap = (json['filesMap'] == null) ? {} : json['filesMap'] as Map;

    fixedVat = json['fixedVat'] ?? false;
    fixedSup = json['fixedSup'] ?? false;
    isItemTs = json['isItemTs'] ?? false;
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
      'vat': vat,
      'totalPrice': totalPrice,
      'paymentAt': paymentAt,
      'purchaseAt': purchaseAt,
      'updateAt': updateAt,

      'memo': memo,
      'fixedVat': fixedVat,
      'fixedSup': fixedSup,
      'isItemTs': isItemTs,
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



  /// 이 함수는 현재 매입목록에 대한 과거 변경기록정보를 요청하고 결과를 반환합니다.
  dynamic getHistory() async {
    List<Purchase> history = [];
    await FirebaseFirestore.instance.collection('purchase/${id}/history').limit(10).get().then((value) {
      if(value.docs.isEmpty) return;
      value.docs.forEach((e) {
        if(!e.exists) return;
        if(e.data() == null) return;
        history.add(Purchase.fromDatabase(e.data() as Map));
      });
    });
    return history;
  }

  /// 이 함수는 데이터베이스에서 신규 매입정보에 대한 유일한 문서Key를 요청하고 자신의 값에 할당합니다.
  dynamic createUid() async {
    var dateIdDay = DateStyle.dateYearMD(purchaseAt);
    var dateIdMonth = DateStyle.dateYearMM(purchaseAt);

    var db = FirebaseFirestore.instance;
    final refMeta = db.collection('meta/uid/dateM-purchase').doc(dateIdMonth);

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

  /// 이 함수는 현재 매입정보를 데이터베이스에 저장하고 결과를 반환합니다.
  /// 신규 생성 또는 기존문서 변경모두 해당 함수를 통해 이루어져야 합니다.
  /// 기존문서가 존재할 경우 History 문서로 이동하는 시스템이 구현되어 있습니다.
  /// 품목 정보 변경시 재고 정보 재계산
  Future<bool> update({ Map<String, Uint8List>? files, ItemTS? itemTs}) async {
    var create = false;
    var result = false;

    if(id == '') { await createUid(); create = true; }
    if(id == '') return result;

    updateAt = DateTime.now().microsecondsSinceEpoch;

    Purchase? org;
    if(!create) {
      org = await DatabaseM.getPurchaseDoc(id);
      if(org != null) org!.id = SystemT.generateRandomString(16);
    }

    var orgHistoryDate = 0;
    var orgDateId = '-';
    var orgDateQuarterId = '-';
    var orgDateIdHarp = '-';
    if(org != null) {
      orgHistoryDate = org.updateAt == 0 ? org.purchaseAt : org.updateAt;
      orgDateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(org.purchaseAt));
      orgDateQuarterId = DateStyle.dateYearsQuarter(org.purchaseAt);
      orgDateIdHarp = DateStyle.dateYearsHarp(org.purchaseAt);
    }

    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(purchaseAt));
    var dateIdHarp = DateStyle.dateYearsHarp(purchaseAt);
    var dateIdQuarter = DateStyle.dateYearsQuarter(purchaseAt);
    var searchText = await getSearchText();

    /// 거래명세서 파일 업로드
    if(files != null) {
      try {
        for(int i = 0; i < files.length; i++) {
          var f = files.values.elementAt(i);
          var k = files.keys.elementAt(i);

          if(filesMap[k] != null) continue;

          final mountainImagesRef = FirebaseStorage.instance.ref().child("purchase/${id}/${k}");
          await mountainImagesRef.putData(f);
          var url = await mountainImagesRef.getDownloadURL();
          if(url == null) {
            print('pur file upload failed');
            continue;
          }

          filesMap[k] = url;
        }
      } catch (e) {
        print(e);
      }
    }

    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("purchase").doc(id);
    /// 이전기록 히스토리 문서경로
    final docHistoryRef = (org != null) ? docRef.collection("history").doc(orgHistoryDate.toString()) : null;
    /// 월별 매입기록 읽기 효율화
    final dateRef = db.collection('meta/date-m/purchase').doc(dateId);
    final orgDateRef = db.collection('meta/date-m/purchase').doc(orgDateId);
    /// 거래처 총매입 개수 읽기 효율화
    final csRef = db.collection('customer').doc(csUid);
    /// 거래처 매입문서 읽기 효율화
    final csDetailRef = db.collection('customer/${csUid}/cs-dateH-purchase').doc(dateIdHarp);
    final orgCsDetailRef = db.collection('customer/${csUid}/cs-dateH-purchase').doc(orgDateIdHarp);
    /// 검색 기록 문서 경로로
    final searchRef = db.collection('meta/search/dateQ-purchase').doc(dateIdQuarter);
    final orgSearchRef = db.collection('meta/search/dateQ-purchase').doc(orgDateQuarterId);
    final itemInvenRef = db.collection('meta/itemInven/${item}').doc(dateIdQuarter);

    var itemRef = null;
    if(isItemTs) {
      if(itemTs == null) {
        itemTs = await DatabaseM.getItemTrans(id);
        if(itemTs != null) itemTs.fromPu(this);
        else itemTs = ItemTS.fromPu(this);
      }
      itemRef = db.collection('transaction-items').doc(id);
    }

    await db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);
      final docHistorySn = docHistoryRef != null ? await transaction.get(docHistoryRef) : null;
      final dateRefSn = await transaction.get(dateRef);
      final orgDateRefSn = await transaction.get(orgDateRef);
      final csDetailRefSn = await transaction.get(csDetailRef);
      final searchRefSn = await transaction.get(searchRef);
      final orgSearchSn = await transaction.get(orgSearchRef);
      final orgCsDetailSn = await transaction.get(orgCsDetailRef);
      final itemInvenSn = await transaction.get(itemInvenRef);

      DocumentSnapshot<Map<String, dynamic>>? itemSn = null;
      if(itemRef != null) itemSn = await transaction.get(itemRef);


      if(org != null) {
        if(orgDateRefSn.exists && dateId != orgDateId && orgDateId != '-') {
          transaction.update(orgDateRef, {'list\.${org.id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        }
        if(orgSearchSn.exists && dateIdQuarter != orgDateQuarterId && orgDateQuarterId != '-') {
          transaction.update(orgSearchRef, {'list\.${org.id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        }
        if(orgCsDetailSn.exists && dateIdHarp != orgDateIdHarp && orgDateIdHarp != '-') {
          transaction.update(orgCsDetailRef, {'list\.${org.id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        }
      }

      /// 품목 UID 개별 메타데이터 하위 날짜분기 하위 거래목록으로 저장
      if(itemInvenSn.exists) transaction.update(itemInvenRef, { id: count.abs() });
      else transaction.set(itemInvenRef, { id: count.abs() });

      /// 품목 매입의 경우 매입 문서와 함께 추가
      if(itemSn != null) {
        if(itemSn!.exists) transaction.update(itemRef, itemTs!.toJson());
        else transaction.set(itemRef, itemTs!.toJson());
      }

      /// 과거 기록추가
      if(docHistorySn != null) {
        transaction.set(docHistoryRef!, org!.toJson());
      }

      /// 매입문서 기조 저장경로
      if(docRefSn.exists) {
        transaction.update(docRef, toJson());
      } else {
        transaction.set(docRef, toJson());
      }

      /// 추후 리스트내부 목록으로 저장이 아닌 필드값으로 변경
      if(dateRefSn.exists) {
        transaction.update(dateRef, {'list\.${id}': toJson(), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
      } else {
        transaction.set(dateRef, {  'list': { id: toJson() }, 'updateAt': DateTime.now().microsecondsSinceEpoch, });
      }

      /// 추후 리스트내부 목록으로 저장이 아닌 필드값으로 변경
      /// 기존 모든 기록 마이그레이션 필요
      if(csDetailRefSn.exists) {
        transaction.update(csDetailRef, { 'list\.${id}': toJson(),  'updateAt': DateTime.now().microsecondsSinceEpoch, });
      } else {
        transaction.set(csDetailRef, { 'list': { id: toJson() }, 'updateAt': DateTime.now().microsecondsSinceEpoch, });
      }

      if(create) transaction.update(csRef, {'puCount': FieldValue.increment(1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});

      if(searchRefSn.exists) {
        transaction.update(searchRef, { 'list\.${id}': searchText, 'updateAt': DateTime.now().microsecondsSinceEpoch, },);
      } else {
        transaction.set(searchRef, { 'list' : { id : searchText },   'updateAt': DateTime.now().microsecondsSinceEpoch,  },);
      }
    }).then(
          (value) {
            print("DocumentSnapshot successfully updated!");
            result = true;
            },
      onError: (e) { print("Error updatePurchase() $e");
            result = false;
            },
    );

    return result;
  }

  dynamic delete() async {
    state = 'DEL';
    updateAt = DateTime.now().microsecondsSinceEpoch;
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(purchaseAt));
    var dateIdHarp = DateStyle.dateYearsHarp(purchaseAt);
    var dateIdQuarter = DateStyle.dateYearsQuarter(purchaseAt);
    var searchText = await getSearchText();

    ItemTS? itemTS = await DatabaseM.getItemTrans(id);
    itemTS!.state = "DEL";

    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("purchase").doc(id);
    /// 월별 매입기록 읽기 효율화
    final dateRef = db.collection('meta/date-m/purchase').doc(dateId);
    /// 거래처 총매입 개수 읽기 효율화
    final csRef = db.collection('customer').doc(csUid);
    /// 거래처 매입문서 읽기 효율화
    final csDetailRef = db.collection('customer/${csUid}/cs-dateH-purchase').doc(dateIdHarp);
    /// 검색 기록 문서 경로로
    final searchRef = db.collection('meta/search/dateQ-purchase').doc(dateIdQuarter);
    var itemRef = null;
    if(isItemTs) {
      itemRef = db.collection('transaction-items').doc(id);
    }
    db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);
      final dateRefSn = await transaction.get(dateRef);
      final csDetailRefSn = await transaction.get(csDetailRef);
      final searchRefSn = await transaction.get(searchRef);
      DocumentSnapshot<Map<String, dynamic>>? itemSn = null;
      if(itemRef != null) itemSn = await transaction.get(itemRef);

      /// 품목 매입의 경우 매입 문서와 함께 추가
      if(itemSn != null) {
        if(itemSn!.exists) transaction.update(itemRef, itemTS!.toJson());
      }

      /// 매입문서 기조 저장경로
      if(docRefSn.exists) transaction.update(docRef, toJson());

      /// 추후 리스트내부 목록으로 저장이 아닌 필드값으로 변경
      if(dateRefSn.exists) transaction.update(dateRef, {'list\.${id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});

      /// 추후 리스트내부 목록으로 저장이 아닌 필드값으로 변경
      /// 기존 모든 기록 마이그레이션 필요
      if(csDetailRefSn.exists) transaction.update(csDetailRef, { 'list\.${id}': null,  'updateAt': DateTime.now().microsecondsSinceEpoch, });

      transaction.update(csRef, {'puCount': FieldValue.increment(-1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});

      if(searchRefSn.exists) transaction.update(searchRef, { 'list\.${id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch, },);
    }).then(
          (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => print("Error updatePurchase() $e"),
    );
  }

  dynamic setUpdate() {
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("purchase").doc(id);
    db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);

      transaction.set(docRef, toJson());
    }).then(
          (value) => print("DocumentSnapshot successfully updated!"),
      onError: (e) => print("Error updatePurchase() $e"),
    );
  }
}