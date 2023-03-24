
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import '../helper/firebaseCore.dart';
import 'Customer.dart';
import 'contract.dart';
import 'revenue.dart';
import 'system.dart';

class TS {
  var csUid = '';       /// 거래처번호
  var ctUid = '';       /// 계약번호
  var scUid = '';       /// 검색메타데이터저장위치
  var rpUid = '';       /// 매입매출번호
  var id = '';          /// 고유번호
  var type = '';        /// 입금/출금

  var amount = 0;   /// 합계
  var account = '';     /// 계좌 고유 아이디 값 또는 기초 문자열
  var transactionAt = 0;    /// 매출일

  var summary = '';     /// 적요
  var memo = '';        /// 메모

  TS.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    type = json['type'] ?? '';
    ctUid = json['ctUid'] ?? '';
    csUid = json['csUid'] ?? '';
    scUid = json['scUid'] ?? '';
    rpUid = json['rpUid'] ?? '';

    amount = json['amount'] ?? 0;
    account = json['account'] ?? '';
    transactionAt = json['transactionAt'] ?? 0;

    summary = json['summary'] ?? '';
    memo = json['memo'] ?? '';
  }
  TS.fromPu(Purchase data, String amountS, {bool now=false}) {
    type = 'PU';
    ctUid = data.ctUid;
    csUid = data.csUid;
    rpUid = data.id;

    amount = data.totalPrice;
    account = amountS;
    transactionAt = data.purchaseAt;

    summary = now ? SystemT.getItemName(data.item) : '';
    memo = data.memo;
  }
  TS.fromRe(Revenue data, String amountS, {bool now=false}) {
    type = 'RE';
    ctUid = data.ctUid;
    csUid = data.csUid;
    rpUid = data.id;

    amount = data.totalPrice;
    account = amountS;
    transactionAt = data.revenueAt;

    summary = now ? SystemT.getItemName(data.item) : '';
    memo = data.memo;
  }
  Map<String, dynamic> toCsJson() {
    return {
      'type': type,
      'ctUid': ctUid,
      'rpUid': rpUid,
      'amount': amount,
      'account': account,
      'transactionAt': transactionAt,

      'summary': summary,
      'memo': memo,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scUid': scUid,

      'type': type,
      'ctUid': ctUid,
      'csUid': csUid,
      'rpUid': rpUid,

      'amount': amount,
      'account': account,
      'transactionAt': transactionAt,

      'summary': summary,
      'memo': memo,
    };
  }
  int getAmount() {
   if(type =='PU') return amount * -1;
   else if(type == 'RE') return amount;
   else return 0;
  }
  String getAccountName() {
    return SystemT.getAccountName(account);
  }
  String getType() {
    if(type == 'RE') return '수입';
    else if(type == 'PU') return '지출';
    else return type;
  }
  Map<String, dynamic> toLJson() {
    return {
      //'id': id,
      'type': type,
      'ctUid': ctUid,
      'csUid': csUid,
      'rpUid': rpUid,

      'amount': amount,
      'account': account,
      'transactionAt': transactionAt,

      'summary': summary,
      'memo': memo,
    };
  }

  Future<String> getSearchText() async {
    var cs = (await SystemT.getCS(csUid)) ?? Customer.fromDatabase({});
    //var ct = (await SystemT.getCt(ctUid)) ?? Contract.fromDatabase({});

    var date = '';
    try {
      date = transactionAt.toString().substring(0, 8);
    } catch (e) {
      date = '';
    }
    return cs.businessName + '&:' + summary + '&:' + memo + '&:' + date;
  }
  
  
  // 2023.03.23 요청사항 거래 UID 발급 함수
  dynamic createUid() async {
    // 문서가 제거되도 복원 가능성이 있으므로 org 구현 없음
    var dateIdDayEp = DateStyle.dateEphoceD(transactionAt);
    var dateIdMonth = DateStyle.dateYearMM(transactionAt);

    var db = FirebaseFirestore.instance;
    final refMeta = db.collection('meta/uid/dateM-transaction').doc(dateIdMonth);
  
    return await db.runTransaction((transaction) async {
      final snMeta = await transaction.get(refMeta);

      // 개수는 100% 트랜잭션을 보장할 수 없음
      // 고유한 형식만 보장
      // 개수가 업데이트된 후 문서 저장에 실패할 경우 예외처리 안함

      if(snMeta.exists) {
        if((snMeta.data() as Map)[dateIdDayEp] != null) {
          var currentTsCount = (snMeta.data() as Map)[dateIdDayEp] as int;
          currentTsCount++;
          id = 'T-$dateIdDayEp-$currentTsCount';
          transaction.update(refMeta, { dateIdDayEp: FieldValue.increment(1)});
        }
        else {
          id = 'T-$dateIdDayEp-1';
          transaction.update(refMeta, { dateIdDayEp: 1});
        }
      } else {
        id = 'T-$dateIdDayEp-1';
        transaction.set(refMeta, { dateIdDayEp: 1 });
      }
    }).then(
    (value) { print("DocumentSnapshot successfully updated createUid!"); return true; },
      onError: (e) { print("Error ts.createUid() $e"); return false; }
    );
  }
  
  
  dynamic update({TS? org, Map<String, Uint8List>? files, }) async {
    var create = (id == '');
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(transactionAt));

    if(create) createUid();
    if(id == '') return;
    
    
    var orgDateId = '-';
    var orgDateQuarterId = '-';
    var orgDateIdHarp = '-';
    if(org != null) {
      orgDateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(org.transactionAt));
      orgDateQuarterId = DateStyle.dateYearsQuarter(org.transactionAt);
      orgDateIdHarp = DateStyle.dateYearsHarp(org.transactionAt);
    }

    var dateIdHarp = DateStyle.dateYearsHarp(transactionAt);
    var dateIdQuarter = DateStyle.dateYearsQuarter(transactionAt);
    var searchText = await getSearchText();

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("transaction").doc(id);
    final dateRef = db.collection('meta/date-m/transaction').doc(dateId);
    if(org != null) ref['orgDate'] = db.collection('meta/date-m/transaction').doc(orgDateId);
    if(org != null) ref['orgSearch'] = db.collection('meta/search/dateQ-transaction').doc(orgDateQuarterId);
    if(org != null) {
      if(org.csUid != '') ref['orgCsDetail'] = db.collection('customer/${org.csUid}/cs-dateH-transaction').doc(orgDateIdHarp);
      if(org.ctUid != '') ref['orgCtDetail'] = db.collection('contract/${org.ctUid}/ct-dateH-transaction').doc(orgDateIdHarp);
      if(org.getAmount() != 0 && org.account != '') ref['orgAccount'] =  db.collection('meta/account/${account}').doc(orgDateQuarterId);
    }
    if(getAmount() != 0 && account != '') ref['account'] =  db.collection('meta/account/${account}').doc(dateIdQuarter);
    if(csUid != '') ref['cs'] = db.collection('customer').doc(csUid);
    if(csUid != '') ref['csDetail'] = db.collection('customer/${csUid}/cs-dateH-transaction').doc(dateIdHarp);
    if(ctUid != '') ref['ct'] = db.collection('contract').doc(ctUid);
    if(ctUid != '') ref['ctDetail'] = db.collection('contract/${ctUid}/ct-dateH-transaction').doc(dateIdHarp);
    /// 검색 기록 문서 경로로
    final searchRef = db.collection('meta/search/dateQ-transaction').doc(dateIdQuarter);

    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final  docRefSn = await transaction.get(docRef);
      final  docDateRefSn = await transaction.get(dateRef);
      final  searchSn = await transaction.get(searchRef);
      if(ref['orgDate'] != null) sn['orgDate'] = await transaction.get(ref['orgDate']!);
      if(ref['orgSearch'] != null) sn['orgSearch'] = await transaction.get(ref['orgSearch']!);
      if(ref['orgCsDetail'] != null) sn['orgCsDetail'] = await transaction.get(ref['orgCsDetail']!);
      if(ref['orgCtDetail'] != null) sn['orgCtDetail'] = await transaction.get(ref['orgCtDetail']!);
      if(ref['orgAccount'] != null) sn['orgAccount'] = await transaction.get(ref['orgAccount']!);

      if(ref['account'] != null) sn['account'] = await transaction.get(ref['account']!);
      if(ref['cs'] != null) sn['cs'] = await transaction.get(ref['cs']!);
      if(ref['csDetail'] != null) sn['csDetail'] = await transaction.get(ref['csDetail']!);

      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);

      if(org != null) {
        if(sn['orgDate']!.exists && dateId != orgDateId && orgDateId != '-')
          transaction.update(ref['orgDate']!, {'list\.${org.id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});

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

        if(dateIdQuarter != orgDateQuarterId) {
          if(sn['orgSearch']!.exists) transaction.update(ref['orgSearch']!, { id: FieldValue.delete(), });
          if(sn['orgAccount'] != null) if(sn['orgAccount']!.exists) transaction.update(ref['orgAccount']!, { id: FieldValue.delete(), });
        }
      }

      if(docRefSn.exists)  transaction.update(docRef, toJson());
      else  transaction.set(docRef, toJson());

      if(docDateRefSn.exists) {
        transaction.update(dateRef, { 'list\.${id}': toJson(), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
      } else {
        transaction.set(dateRef, {  'list': { id: toJson() },  'updateAt': DateTime.now().microsecondsSinceEpoch, });
      }

      if(sn['account'] != null) {
        if(sn['account']!.exists) transaction.update(ref['account']!, { id: getAmount(), },);
        else transaction.set(ref['account']!, { id: getAmount() },);
      }

      if(ref['cs'] != null) {
        if(create) transaction.update(ref['cs']!, {'tsCount': FieldValue.increment(1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});

        if(sn['csDetail']!.exists) transaction.update(ref['csDetail']!, { id: toJson(), });
        else transaction.set(ref['csDetail']!, { id: toJson(), });
      }

      if(ref['ct'] != null) {
        if(create) if(sn['ct']!.exists) transaction.update(ref['ct']!, {'tsCount': FieldValue.increment(1),});

        if(sn['ctDetail']!.exists) transaction.update(ref['ctDetail']!, { id: toJson(), });
        else transaction.set(ref['ctDetail']!, { id: toJson(), });
      }

      if(searchSn.exists) {
        transaction.update(searchRef, { id : searchText, },);
      } else {
        transaction.set(searchRef, { id : searchText },);
      }
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error update transaction() $e"); return false; }
    );
  }
  dynamic delete() async {
    type = 'DEL';

    if(id == '') return false;
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(transactionAt));

    var dateIdHarp = DateStyle.dateYearsHarp(transactionAt);
    var dateIdQuarter = DateStyle.dateYearsQuarter(transactionAt);

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("transaction").doc(id);
    final dateRef = db.collection('meta/date-m/transaction').doc(dateId);

    if(account != '') ref['account'] =  db.collection('meta/account/${account}').doc(dateIdQuarter);
    if(csUid != '') ref['cs'] = db.collection('customer').doc(csUid);
    if(csUid != '') ref['csDetail'] = db.collection('customer/${csUid}/cs-dateH-transaction').doc(dateIdHarp);
    if(ctUid != '') ref['ct'] = db.collection('contract').doc(ctUid);
    if(ctUid != '') ref['ctDetail'] = db.collection('contract/${ctUid}/ct-dateH-transaction').doc(dateIdHarp);
    /// 검색 기록 문서 경로로
    final searchRef = db.collection('meta/search/dateQ-transaction').doc(dateIdQuarter);

    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final  docRefSn = await transaction.get(docRef);
      final  docDateRefSn = await transaction.get(dateRef);
      final  searchSn = await transaction.get(searchRef);

      if(ref['account'] != null) sn['account'] = await transaction.get(ref['account']!);
      if(ref['cs'] != null) sn['cs'] = await transaction.get(ref['cs']!);
      if(ref['csDetail'] != null) sn['csDetail'] = await transaction.get(ref['csDetail']!);

      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);



      /// 기초 거래기록 저장 컬렉션에서 데이터 삭제
      if(docRefSn.exists) transaction.update(docRef, toJson());

      /// 일자별 거래기록에 추가된 데이터 삭제
      if(docDateRefSn.exists) {
        transaction.update(dateRef, { 'list\.${id}': null, 'updateAt': DateTime.now().microsecondsSinceEpoch,});
      }

      /// 계좌 정보에 추가된 금액 삭제
      if(sn['account'] != null) {
        print('ascdascsadcsad');
        if(sn['account']!.exists) transaction.update(ref['account']!, { id: FieldValue.delete(), },);
      }

      /// 거래처 개별기록에 추가된 데이터 삭제 및 개수 감소
      if(ref['cs'] != null) {
        transaction.update(ref['cs']!, {'tsCount': FieldValue.increment(-1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        if(sn['csDetail']!.exists) transaction.update(ref['csDetail']!, { id: FieldValue.delete(), });
      }

      /// 계약 개별기록에 추가된 데이터 삭제 및 개수 감소
      if(ref['ct'] != null) {
        if(sn['ct']!.exists) transaction.update(ref['ct']!, {'tsCount': FieldValue.increment(-1),});
        if(sn['ctDetail']!.exists) transaction.update(ref['ctDetail']!, { id: FieldValue.delete(), });
      }

      /// 검색 메타데이터 데이터 삭제
      if(searchSn.exists)  transaction.update(searchRef, { id : FieldValue.delete(), },);
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error delete transaction() $e"); return false; }
    );
  }
}

/// 품목 리스트
class Item {
  var id = '';
  var name = '';
  /// 매출, 매입, 매출매입 품목 - PU, RE
  var type = '';
  /// 품목 분류
  var group = '';
  var unit = '';
  var unitPrice = 0;
  var cost = 0;
  var memo = '';

  var display = false;

  Item.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? '';
    type = json['type'] ?? '';
    group = json['group'] ?? '';
    unit = json['unit'] ?? '';
    unitPrice = json['unitPrice'] ?? 0;
    cost = json['cost'] ?? 0;
    memo = json['memo'] ?? '';
    display = json['display'] ?? false;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'group': group,
      'unit': unit,
      'unitPrice': unitPrice,
      'cost': cost,
      'memo': memo,
      'display': display,
    };
  }
}

/// 품목 사용 및 생산 개수
class ItemFD {
  var id = '';
  var count = 0;

  ItemFD.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    count = json['count'] ?? 0;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'count': count,
    };
  }
}

/// 품목 거래 이동 입출 현황
class ItemTS {
  var id = '';
  var state = '';
  var type = '';        /// PU/RE
  var rpUid = '';       /// 매입매출번호
  var itemType = '';
  var itemUid = '';
  var amount = 0;
  var unitPrice = 0;
  var date = 0;
  var ctUid = '';
  var csUid = '';

  ItemTS.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';
    itemType = json['itemType'] ?? '';
    csUid = json['csUid'] ?? '';
    ctUid = json['ctUid'] ?? '';
    type = json['type'] ?? '';
    rpUid = json['rpUid'] ?? '';
    itemUid = json['itemUid'] ?? '';
    amount = json['amount'] ?? 0;
    unitPrice = json['unitPrice'] ?? 0;
    date = json['date'] ?? 0;
  }
  ItemTS.fromRe(Revenue revenue) {
    type = 'RE';
    rpUid = revenue.id;
    itemUid = revenue.item;
    amount = revenue.count * -1;
    unitPrice = revenue.unitPrice;
    csUid = revenue.csUid;
    ctUid = revenue.ctUid;
  }
  ItemTS.fromPu(Purchase purchase) {
    type = 'PU';
    id = purchase.id;
    rpUid = purchase.id;
    itemUid = purchase.item;
    amount = purchase.count;
    unitPrice = purchase.unitPrice;
    csUid = purchase.csUid;
    ctUid = purchase.ctUid;
    date = purchase.purchaseAt;

    var item = SystemT.getItem(itemUid);
    if(item == null) return;
    itemType = item.type;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'csUid': csUid,
      'ctUid': ctUid,
      'type': type,
      'rpUid': rpUid,
      'itemUid': itemUid,
      'amount': amount,
      'unitPrice': unitPrice,
      'date': date,
      'itemType': itemType,
      'state': state,
    };
  }

  dynamic update({ Purchase? org }) async {
    if(id == '') return;
    if(id == '') id = DateTime.now().microsecondsSinceEpoch.toString();
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(date));

    if(org != null) {
      var itemTsOrg = ItemTS.fromPu(org);
      var orgDateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(itemTsOrg.date));

      await FireStoreHub.docUpdate('meta/date-m/transaction-item/${orgDateId}', 'ItemTS.PATCH',
          { 'list\.${itemTsOrg.id}': toJson() },
          setJson: { 'list': { itemTsOrg.id: toJson() } }
      );
    }

    await FireStoreHub.docUpdate('transaction-item/${id}', 'ItemTS.PATCH', toJson());
    await FireStoreHub.docUpdate('meta/date-m/transaction-item/${dateId}', 'ItemTS.PATCH',
      { 'list\.$id': toJson() },
      setJson: { 'list': { id: toJson() } }
    );
  }
}


class Account {
  var id = '';
  var type = '';
  var name = '';
  var account = '';
  var balanceStartAt = 0;
  var user = '';
  var memo = '';
  Account.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    type = json['type'] ?? '';
    name = json['name'] ?? '';
    account = json['account'] ?? '';
    balanceStartAt = json['balanceStartAt'] ?? 0;
    user = json['user'] ?? '';
    memo = json['memo'] ?? '';
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'account': account,
      'balanceStartAt': balanceStartAt,
      'user': user,
      'memo': memo,
    };
  }
}

class LTS {
  var id = '';
  var account = '';
  var amount = 0;
  var type = 0;       /// 0 지출, 1 수입
  var tsAt = 0;
  LTS.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    account = json['account'] ?? '';
    amount = json['amount'] ?? 0;
    type = json['type'] ?? 0;
    tsAt = json['tsAt'] ?? 0;
  }
  LTS.fromTS(TS data) {
    id = data.id;
    account = data.account;
    type = (data.type == 'PU') ? 0 : 1;
    amount = data.amount;
    tsAt = data.transactionAt;
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'account': account,
      'amount': amount,
      'type': type,
      'tsAt': tsAt,
    };
  }

}

class Balance {
  var balance = 0;
  var cash = 0;
}

class LoadingCounter {
  int counter = 0;
}

class SearchMeta {
  var contractCount = 0;
  var contractCursor = 0;        /// PU/RE
  var indexLimit = 0;        /// PU/RE

  var tsCount = 0;        ///
  var tsCursor = 0;        ///
  var tsLimit = 0;        ///

  var reCount = 0;        ///
  var reCursor = 0;        ///
  var reLimit = 0;        ///

  var puCount = 0;        ///
  var puCursor = 0;        ///
  var puLimit = 0;        ///

  SearchMeta.fromDatabase(Map<dynamic, dynamic> json) {
    indexLimit = json['indexLimit'] ?? 0;
    contractCursor = json['contractCursor'] ?? 0;
    contractCount = json['contractCount'] ?? 0;
    tsLimit = json['tsLimit'] ?? 0;
    tsCount = json['tsCount'] ?? 0;
    tsCursor = json['tsCursor'] ?? 0;

    reCount = json['reCount'] ?? 0;
    reCursor = json['reCursor'] ?? 0;
    reLimit = json['reLimit'] ?? 0;

    puCount = json['puCount'] ?? 0;
    puCursor = json['puCursor'] ?? 0;
    puLimit = json['puLimit'] ?? 0;
  }
  Map<String, dynamic> toJson() {
    return {
      'indexLimit': indexLimit,
      'contractCursor': contractCursor,
      'contractCount': contractCount,
      'tsLimit': tsLimit,
      'tsCount': tsCount,
      'tsCursor': tsCursor,

      'reCount': reCount,
      'reCursor': reCursor,
      'reLimit': reLimit,

      'puCount': puCount,
      'puCursor': puCursor,
      'puLimit': puLimit,
    };
  }
}
