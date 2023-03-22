
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/Customer.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/firebaseCore.dart';

import '../helper/style.dart';
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

  // 2023.03.22 요청사항
  dynamic createUid() {
    // 문서가 제거되도 복원 가능성이 있으므로 org 구현 없음
    var dateIdDay = DateStyle.dateYearMD(revenueAt);
    
    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    if(csUid != '') ref['csMetaCount'] = db.collection('meta/uid/dateD-revenue${csUid}').doc(dateIdDay);
  
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      if(ref['csMetaCount'] != null) sn['csMetaCount'] = await transaction.get(ref['csMetaCount']!);
      
   
      if(ref['cs'] != null) 
      {
         // Get
         var currentRevenueCount = 0;
         if(sn['csMetaCount']!.exists) currentRevenueCount = ((await sn['csMetaCount']!.get()).data() as Map)[csUid] as int;
         else currentRevenueCount++:
         
         // 데이터베이스 트랜잭션 읽기 쓰기순으로 실행됨으로 누락 가능성 / 보완
         if(sn['csMetaCount']!.exists) sn['csMetaCount']!.update(ref['csMetaCount'], { csUid: FieldValue.increment(1) });
         else sn['csMetaCount']!.set(ref['csMetaCount'], { csUid: 1 });
      }
    }).then(
          (value) { print("DocumentSnapshot successfully updated createUid!"); return true; },
      onError: (e) { print("Error createUid() $e"); return false; }
    );
  }
  
  // 데이터베이스 접근 함수
  dynamic update({Revenue? org, Map<String, Uint8List>? files, }) async {
    var create = false;
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(revenueAt));
    
    // 추후 아이디 발급 형태 
    if(id == '')  { id = FireStoreT.generateRandomString(16);  create = true; }

    var orgDateId = '-';
    var orgDateQuarterId = '-';
    var orgDateIdHarp = '-';
    if(org != null) {
      orgDateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(org.revenueAt));
      orgDateQuarterId = DateStyle.dateYearsQuarter(org.revenueAt);
      orgDateIdHarp = DateStyle.dateYearsHarp(org.revenueAt);
    }

    var dateIdHarp = DateStyle.dateYearsHarp(revenueAt);
    var dateIdQuarter = DateStyle.dateYearsQuarter(revenueAt);
    var dateIdDay = DateStyle.dateYearMD(revenueAt);
    
    var searchText = await getSearchText();

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("revenue").doc(id);
    final dateRef = db.collection('meta/date-m/revenue').doc(dateId);
    if(org != null) ref['orgDate'] = db.collection('meta/date-m/revenue').doc(orgDateId);
    if(org != null) ref['orgSearch'] = db.collection('meta/search/dateQ-revenue').doc(orgDateQuarterId);
    if(org != null) {
      if(org.csUid != '') ref['orgCsDetail'] = db.collection('customer/${org.csUid}/cs-dateH-revenue').doc(orgDateIdHarp);
      if(org.ctUid != '') ref['orgCtDetail'] = db.collection('contract/${org.ctUid}/ct-dateH-revenue').doc(orgDateIdHarp);
    }

    if(csUid != '') ref['cs'] = db.collection('customer').doc(csUid);
    if(csUid != '') ref['csDetail'] = db.collection('customer/${csUid}/cs-dateH-revenue').doc(dateIdHarp);
    if(csUid != '') ref['csMetaCount'] = db.collection('meta/uid/dateD-revenue${csUid}').doc(dateIdDay);
    
    if(ctUid != '') ref['ct'] = db.collection('contract').doc(ctUid);
    if(ctUid != '') ref['ctDetail'] = db.collection('contract/${ctUid}/ct-dateH-revenue').doc(dateIdHarp);
    /// 검색 기록 문서 경로로
    final searchRef = db.collection('meta/search/dateQ-revenue').doc(dateIdQuarter);

    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final  docRefSn = await transaction.get(docRef);
      final  docDateRefSn = await transaction.get(dateRef);
      final  searchSn = await transaction.get(searchRef);
      if(ref['orgDate'] != null) sn['orgDate'] = await transaction.get(ref['orgDate']!);
      if(ref['orgSearch'] != null) sn['orgSearch'] = await transaction.get(ref['orgSearch']!);
      if(ref['orgCsDetail'] != null) sn['orgCsDetail'] = await transaction.get(ref['orgCsDetail']!);
      if(ref['orgCtDetail'] != null) sn['orgCtDetail'] = await transaction.get(ref['orgCtDetail']!);

      if(ref['cs'] != null) sn['cs'] = await transaction.get(ref['cs']!);
      if(ref['csDetail'] != null) sn['csDetail'] = await transaction.get(ref['csDetail']!);
      if(ref['csMetaCount'] != null) sn['csMetaCount'] = await transaction.get(ref['csMetaCount']!);

      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);

      if(org != null) {
        if(sn['orgDate']!.exists && dateId != orgDateId && orgDateId != '-')
          transaction.update(ref['orgDate']!, {'list\.${org.id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        if(sn['orgSearch']!.exists && dateIdQuarter != orgDateQuarterId && orgDateQuarterId != '-')
          transaction.update(ref['orgSearch']!, {'list\.${org.id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});

        if(sn['orgCsDetail'] != null) {
          if(sn['orgCsDetail']!.exists && dateIdHarp != orgDateIdHarp && orgDateIdHarp != '-') {
            transaction.update(ref['orgCsDetail']!, { org.id: FieldValue.delete(), });
          }
        }
        if(sn['orgCtDetail'] != null) {
          if(sn['orgCtDetail']!.exists && dateIdHarp != orgDateIdHarp && orgDateIdHarp != '-') {
            transaction.update(ref['orgCtDetail']!, { org.id: FieldValue.delete() });
          }
        }
      }

      if(docRefSn.exists)  transaction.update(docRef, toJson());
      else  transaction.set(docRef, toJson());

      if(docDateRefSn.exists) {
        transaction.update(dateRef, { 'list\.${id}': toJson(), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
      } else {
        transaction.set(dateRef, {  'list': { id: toJson() },  'updateAt': DateTime.now().microsecondsSinceEpoch, });
      }

      // 2023.03.22 
      if(ref['cs'] != null) 
      {
         if(create) transaction.update(ref['cs']!, {'reCount': FieldValue.increment(1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        
         if(sn['csDetail']!.exists) transaction.update(ref['csDetail']!, { id: toJson(), });
         else transaction.set(ref['csDetail']!, { id: toJson(), });
         
         // 메인문서 트랜잭션과 동시 수행될 수 
         // Get
         var currentRevenueCount = 0;
         if(sn['csMetaCount']!.exists) currentRevenueCount = ((await sn['csMetaCount']!.get()).data() as Map)[csUid] as int;
         else currentRevenueCount++:
         
         if(create)
        
         // 데이터베이스 트랜잭션 읽기 쓰기순으로 실행됨으로 누락 가능성 / 보완
         if(sn['csMetaCount']!.exists) sn['csMetaCount']!.update(ref['csMetaCount'], { csUid: FieldValue.increment(1) });
         else sn['csMetaCount']!.set(ref['csMetaCount'], { csUid: 1 });
      }

      if(ref['ct'] != null) {
        if(create) if(sn['ct']!.exists) transaction.update(ref['ct']!, {'reCount': FieldValue.increment(1),});

        if(sn['ctDetail']!.exists) transaction.update(ref['ctDetail']!, { id: toJson(), });
        else transaction.set(ref['ctDetail']!, { id: toJson(), });
      }

      if(searchSn.exists) {
        transaction.update(searchRef, { 'list\.${id}': searchText, 'updateAt': DateTime.now().microsecondsSinceEpoch, },);
      } else {
        transaction.set(searchRef, {  'list' : { id : searchText },'updateAt': DateTime.now().microsecondsSinceEpoch, },);
      }
    }).then(
          (value) { print("DocumentSnapshot successfully updated!"); return true; },
      onError: (e) { print("Error updatePurchase() $e"); return false; }
    );
  }
  
  // 데이터베이스 삭제 호출 
  dynamic delete() async {
    state = 'DEL';
    if(id == '')  { return false; }
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(revenueAt));
    var dateIdHarp = DateStyle.dateYearsHarp(revenueAt);
    var dateIdQuarter = DateStyle.dateYearsQuarter(revenueAt);
    var searchText = await getSearchText();

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    final docRef = db.collection("revenue").doc(id);
    final dateRef = db.collection('meta/date-m/revenue').doc(dateId);
    if(csUid != '') ref['cs'] = db.collection('customer').doc(csUid);
    if(csUid != '') ref['csDetail'] = db.collection('customer/${csUid}/cs-dateH-revenue').doc(dateIdHarp);
    if(ctUid != '') ref['ct'] = db.collection('contract').doc(ctUid);
    if(ctUid != '') ref['ctDetail'] = db.collection('contract/${ctUid}/ct-dateH-revenue').doc(dateIdHarp);
    final searchRef = db.collection('meta/search/dateQ-revenue').doc(dateIdQuarter);

    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final  docRefSn = await transaction.get(docRef);
      final  docDateRefSn = await transaction.get(dateRef);
      final  searchSn = await transaction.get(searchRef);

      if(ref['cs'] != null) sn['cs'] = await transaction.get(ref['cs']!);
      if(ref['csDetail'] != null) sn['csDetail'] = await transaction.get(ref['csDetail']!);
      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);

      if(docRefSn.exists) transaction.update(docRef, toJson());

      if(docDateRefSn.exists) {
        transaction.update(dateRef, { 'list\.${id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});
      }

      if(sn['csDetail']!.exists) transaction.update(ref['csDetail']!, { id: FieldValue.delete(), });
      transaction.update(ref['cs']!, {'reCount': FieldValue.increment(-1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});

      if(ref['ct'] != null) {
        if(sn['ct']!.exists) transaction.update(ref['ct']!, {'reCount': FieldValue.increment(-1),});

        if(sn['ctDetail']!.exists) transaction.update(ref['ctDetail']!, { id: FieldValue.delete(), });
      }

      if(searchSn.exists) {
        transaction.update(searchRef, { 'list\.${id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch, },);
      }
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error deleteRevenue() $e"); return false; }
    );
  }
}
