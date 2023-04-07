
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:evers/helper/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import '../helper/firebaseCore.dart';
import 'Customer.dart';
import 'contract.dart';
import 'revenue.dart';
import 'system.dart';


import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/**
* 거래기록 클래스
* 
*
* @update YM
* @version 1.0.0
*/
class TS {
  var csUid = '';       /// 거래처번호
  var ctUid = '';       /// 계약번호
  var scUid = '';       /// 검색메타데이터저장위치
  var rpUid = '';       /// 매입매출번호
  var id = '';          /// 고유번호
  var type = '';        /// 입금/출금

  var amount = 0;         /// 합계
  var account = '';       /// 계좌 고유 아이디 값 또는 기초 문자열
  var transactionAt = 0;  /// 매출일

  var summary = '';       /// 적요
  var memo = '';          /// 메모

  /**
  * DeSerialize Json Form Sever
  * 
  * @ params map json
  * @ Creater function
  */
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
  
  /**
  * DeSerialize Class Form Purchase
  * 
  * @ params Purchase pu 매입데이터, string account 계좌, bool now 즉시수금여부
  * @ create function
  */
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
  
  /**
  * DeSerialize Class Form Revenue
  * 
  * @ params Revenue re 매출데이터, string account 계좌, bool now 즉시수금여부
  * @ create function
  */
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

  /**
  * Serialize this Class 
  * 
  * @ params none
  * @ return JsonData
  */
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
  
  /**
  * The Low Serialize this Class 
  * 
  * @ params none
  * @ return JsonData low
  */
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
  
  
  
  /**
  * 거래 금액을 반환
  * 매출의 경우 -, 매입의 경우 +
  * 
  * @ params none
  * @ return int 거래금액
  */
  int getAmount() {
   if(type =='PU') return amount * -1;
   else if(type == 'RE') return amount;
   else return 0;
  }
  
  /**
  * 거래기록의 계좌를 반환
  * 
  * @ params none
  * @ return String
  */
  String getAccountName() {
    return SystemT.getAccountName(account);
  }
  
  /**
  * 거래 타입의 UI 표기값을 반환
  * RE: 수입, PU: 지출
  * 
  * @ params none
  * @ return String 수입, 지출
  */
  String getType() {
    if(type == 'RE') return '수입';
    else if(type == 'PU') return '지출';
    else return type;
  }
  
  
  /**
  * 검색 메타데이터 헤더 값을 반환
  * 구분자 "&:"
  * 
  * @ params none
  * @ return String "data&:data&:data&:data"
  */
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


  
  /**
  * 거래 UID 확인 함수
  * 거래 기록시 현재 거래문서 데이터베이스 ID 값을 확인
  * "T(거래구분자)-16845212(날짜 에폭시)-1(번호)"
  * 번호는 1부터 시작하며 날짜마다 고유
  *
  * @ params none
  * @ return String "T-16452222-1"
  */
  dynamic createUid() async {
    var dateIdDayEp = DateStyle.dateEphoceD(transactionAt);
    var dateIdMonth = DateStyle.dateYearMM(transactionAt);

    var db = FirebaseFirestore.instance;
    final refMeta = db.collection('meta/uid/dateM-transaction').doc(dateIdMonth);

    return await db.runTransaction((transaction) async {
      final snMeta = await transaction.get(refMeta);

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

  
  /**
  * 거래 UID 확인 함수
  * 거래 기록시 현재 거래문서 데이터베이스 ID 값을 확인
  * "T(거래구분자)-16845212(날짜 에폭시)-1(번호)"
  * 번호는 1부터 시작하며 날짜마다 고유
  *
  * @ params none
  * @ return String "T-16452222-1"
  */
  dynamic create() async {
    await createUid();
    await update();
  }
  
  
  dynamic update({TS? org, Map<String, Uint8List>? files, }) async {
    var create = false;
    if(id == '') create = true;
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(transactionAt));

    if(create) await createUid();
    if(id == '') return;

    var orgDateId = '-';
    var orgDateQuarterId = '-';
    var orgDateIdHarp = '-';
    var orgDateIdMonth = '-';
    if(org != null) {
      orgDateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(org.transactionAt));
      orgDateQuarterId = DateStyle.dateYearsQuarter(org.transactionAt);
      orgDateIdHarp = DateStyle.dateYearsHarp(org.transactionAt);
      orgDateIdMonth = DateStyle.dateYearMM(org.transactionAt);
    }

    var dateIdHarp = DateStyle.dateYearsHarp(transactionAt);
    var dateIdQuarter = DateStyle.dateYearsQuarter(transactionAt);
    var dateIdMonth = DateStyle.dateYearMM(transactionAt);
    var searchText = await getSearchText();

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("transaction").doc(id);
    final dateRef = db.collection('meta/date-by/dateM-transaction').doc(dateId);
    if(org != null) ref['orgDate'] = db.collection('meta/date-by/dateM-transaction').doc(orgDateId);
    if(org != null) ref['orgSearch'] = db.collection('meta/search/dateQ-transaction').doc(orgDateQuarterId);
    if(org != null) {
      if(org.csUid != '') ref['orgCsDetail'] = db.collection('customer/${org.csUid}/cs-dateH-transaction').doc(orgDateIdHarp);
      if(org.ctUid != '') ref['orgCtDetail'] = db.collection('contract/${org.ctUid}/ct-dateH-transaction').doc(orgDateIdHarp);
      if(org.getAmount() != 0 && org.account != '') ref['orgAccount'] =  db.collection('meta/account/${(org.account == '') ? '00000000' : org.account }').doc(orgDateQuarterId);
      if(org.getAmount() != 0 && org.account != '') ref['orgAccountDate'] = db.collection('balance/dateM-account/${(org.account == '') ? '00000000' : org.account }').doc(orgDateIdMonth);
    }

    if(getAmount() != 0 && account != '') ref['account'] =  db.collection('meta/account/${(account == '') ? '00000000' : account }').doc(dateIdQuarter);
    if(getAmount() != 0 && account != '') ref['accountDate'] =  db.collection('balance/dateM-account/${(account == '') ? '00000000' : account }').doc(dateIdMonth);

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
      if(ref['orgAccountDate'] != null) sn['orgAccountDate'] = await transaction.get(ref['orgAccountDate']!);

      if(ref['account'] != null) sn['account'] = await transaction.get(ref['account']!);
      if(ref['accountDate'] != null) sn['accountDate'] = await transaction.get(ref['accountDate']!);

      if(ref['cs'] != null) sn['cs'] = await transaction.get(ref['cs']!);
      if(ref['csDetail'] != null) sn['csDetail'] = await transaction.get(ref['csDetail']!);

      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);

      if(org != null) {
        if(sn['orgDate']!.exists && dateId != orgDateId && orgDateId != '-')
          transaction.update(ref['orgDate']!, { org.id : FieldValue.delete(), });

        if(sn['orgCsDetail'] != null)
          if(sn['orgCsDetail']!.exists && dateIdHarp != orgDateIdHarp && orgDateIdHarp != '-')
            transaction.update(ref['orgCsDetail']!, { org.id: FieldValue.delete(), });

        if(sn['orgCtDetail'] != null)
          if(sn['orgCtDetail']!.exists && dateIdHarp != orgDateIdHarp && orgDateIdHarp != '-')
            transaction.update(ref['orgCtDetail']!, { org.id: FieldValue.delete() });

        if(dateIdQuarter != orgDateQuarterId) {
          if(sn['orgSearch']!.exists) transaction.update(ref['orgSearch']!, { id: FieldValue.delete(), });
          if(sn['orgAccount'] != null) if(sn['orgAccount']!.exists) transaction.update(ref['orgAccount']!, { id: FieldValue.delete(), });
        }

        if(dateIdMonth != orgDateIdMonth) {
          if(sn['orgAccountDate'] != null)
            if(sn['orgAccountDate']!.exists) transaction.update(ref['orgAccountDate']!, { id: FieldValue.delete(), });
        }
      }

      if(docRefSn.exists)  transaction.update(docRef, toJson());
      else  transaction.set(docRef, toJson());

      if(docDateRefSn.exists) transaction.update(dateRef, { id: toJson(), 'date': DateTime.fromMicrosecondsSinceEpoch(transactionAt).microsecondsSinceEpoch});
      else transaction.set(dateRef, {  id: toJson(), 'date': DateTime.fromMicrosecondsSinceEpoch(transactionAt).microsecondsSinceEpoch });

      if(sn['account'] != null) {
        if(sn['account']!.exists) transaction.update(ref['account']!, { id: getAmount(), },);
        else transaction.set(ref['account']!, { id: getAmount() },);

        if(sn['accountDate']!.exists) transaction.update(ref['accountDate']!, { id: getAmount(), },);
        else transaction.set(ref['accountDate']!, { id: getAmount() },);
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
    var dateIdMonth = DateStyle.dateYearMM(transactionAt);

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("transaction").doc(id);
    final dateRef = db.collection('meta/date-by/dateM-transaction').doc(dateId);

    if(account != '') ref['account']     = db.collection('meta/account/${(account == '') ? '00000000' : account }').doc(dateIdQuarter);
    if(account != '') ref['accountDate'] = db.collection('balance/dateM-account/${(account == '') ? '00000000' : account }').doc(dateIdMonth);
    if(csUid != '')   ref['cs']          = db.collection('customer').doc(csUid);
    if(csUid != '')   ref['csDetail']    = db.collection('customer/${csUid}/cs-dateH-transaction').doc(dateIdHarp);
    if(ctUid != '')   ref['ct']          = db.collection('contract').doc(ctUid);
    if(ctUid != '')   ref['ctDetail']    = db.collection('contract/${ctUid}/ct-dateH-transaction').doc(dateIdHarp);
    /// 검색 기록 문서 경로로
    final searchRef = db.collection('meta/search/dateQ-transaction').doc(dateIdQuarter);

    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final  docRefSn = await transaction.get(docRef);
      final  docDateRefSn = await transaction.get(dateRef);
      final  searchSn = await transaction.get(searchRef);

      if(ref['account'] != null) sn['account'] = await transaction.get(ref['account']!);
      if(ref['accountDate'] != null) sn['accountDate'] = await transaction.get(ref['accountDate']!);
      if(ref['cs'] != null) sn['cs'] = await transaction.get(ref['cs']!);
      if(ref['csDetail'] != null) sn['csDetail'] = await transaction.get(ref['csDetail']!);

      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);



      /// 기초 거래기록 저장 컬렉션에서 데이터 삭제
      if(docRefSn.exists) transaction.update(docRef, toJson());

      /// 일자별 거래기록에 추가된 데이터 삭제
      if(docDateRefSn.exists) {
        transaction.update(dateRef, { id: FieldValue.delete(), });
      }

      /// 계좌 정보에 추가된 금액 삭제
      if(account != '') {
        if(sn['account']!.exists) transaction.update(ref['account']!, { id: FieldValue.delete(), },);
        if(sn['accountDate']!.exists) transaction.update(ref['accountDate']!, { id: FieldValue.delete(), },);
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
  dynamic getTable(int bal) async {
    var cs = await SystemT.getCS(csUid);
    return <String>[ StyleT.dateFormatYYMMDD(transactionAt), SystemT.getAccountName(account), cs.businessName, (type == 'RE') ? StyleT.krwInt(getAmount()) : '',
      (type == 'PU') ? StyleT.krwInt(getAmount().abs()) : '',  StyleT.krwInt(bal) , summary ];
  }
  dynamic updateDate() async {
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(transactionAt));

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    //final dateRef = db.collection('meta/date-by/dateM-transaction').doc(dateId);
    final dateRef = db.collection('balance/dateM-account/${(account == '') ? '00000000' : account }').doc(dateId);

    return await db.runTransaction((transaction) async {
      final  docDateRefSn = await transaction.get(dateRef);

      if(docDateRefSn.exists) transaction.update(dateRef, { id: getAmount(), });
      else transaction.set(dateRef, {  id: getAmount(), });
    }).then(
            (value) { print("successfully updated! - ts.amount-m::$id"); return true; },
        onError: (e) { print("Error update date transaction() $e"); return false; }
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
