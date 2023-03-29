
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
  var selectIsTaxed = false;    // - ???
  var isTaxed = false;          // 세금계산서 마감

  var fixedVat = false;          // 부가세 자동 계산 - 변수명 변경 필요
  var fixedSup = false;          // 공급가액 자동 계산 - 변수명 변경 필요

  var state = '';       /// 상태

  var csUid = '';       /// 거래처번호
  var scUid = '';       /// 검색 메타데이터 번호 - 삭제 예정

  var ctUid = '';       /// 계약번호
  var tsUid = '';       /// 계좌이체 번호
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
    fixedVat = json['fixedVat'] ?? false;
    fixedSup = json['fixedSup'] ?? false;
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
      'fixedVat': fixedVat,
      'fixedSup': fixedSup,
    };
  }

  // 부가세 직접 입력시 자동계산 수식 수정
  // 부가세 직접 입력 구분값 추가 저장
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

  
  Future<String> getSearchText() async {
    var cs = await SystemT.getCS(csUid) ?? Customer.fromDatabase({});
    var ct = await SystemT.getCt(ctUid) ?? Contract.fromDatabase({});
    var it = SystemT.getItemName(item);

    return cs.businessName + '&:' + ct.ctName + '&:' + it + '&:' + memo;
  }

  // 2023.03.22 요청사항 문서 UID 발급 함수
  dynamic createUid() async {
    // 문서가 제거되도 복원 가능성이 있으므로 org 구현 없음
    var dateIdDay = DateStyle.dateYearMD(revenueAt);
    var dateIdMonth = DateStyle.dateYearMM(revenueAt);

    var db = FirebaseFirestore.instance;
    final refMeta = db.collection('meta/uid/dateM-revenue').doc(dateIdMonth);
  
    return await db.runTransaction((transaction) async {
      final snMeta = await transaction.get(refMeta);

      // 개수는 100% 트랜잭션을 보장할 수 없음
      // 고유한 형식만 보장
      // 개수가 업데이트된 후 문서 저장에 실패할 경우 예외처리 안함

      if(snMeta.exists) {
        if((snMeta.data() as Map)[dateIdDay] != null) {
          var currentRevenueCount = (snMeta.data() as Map)[dateIdDay] as int;
          currentRevenueCount++;
          id = 'R-$dateIdDay-$currentRevenueCount';
          transaction.update(refMeta, { dateIdDay: FieldValue.increment(1)});
        }
        else {
          id = 'R-$dateIdDay-1';
          transaction.update(refMeta, { dateIdDay: 1});
        }
      } else {
        id = 'R-$dateIdDay-1';
        transaction.set(refMeta, { dateIdDay: 1 });
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
    if(id == '')  { create = true; }
    if(create) await createUid();
    if(id == '') return false;
    // 현재까지 정상적으로 실행된 경우
    // id 존재
    
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

      // 매출UID 중복에러 - 가능성 없지만 구현
      if(create && docRefSn.exists) return false;
      if(docRefSn.exists)  transaction.update(docRef, toJson());
      else transaction.set(docRef, toJson());

      if(docDateRefSn.exists) {
        transaction.update(dateRef, { 'list\.${id}': toJson(), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
      } else {
        transaction.set(dateRef, {  'list': { id: toJson() },  'updateAt': DateTime.now().microsecondsSinceEpoch, });
      }

      // 2023.03.22 
      if(ref['cs'] != null) {
         if(create) transaction.update(ref['cs']!, {'reCount': FieldValue.increment(1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        
         if(sn['csDetail']!.exists) transaction.update(ref['csDetail']!, { id: toJson(), });
         else transaction.set(ref['csDetail']!, { id: toJson(), });
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
  
  // 데이터베이스 삭제 호출 - 트랜잭션 구현됨
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
