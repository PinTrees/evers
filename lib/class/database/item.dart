import 'dart:typed_data';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/database/process.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/ux.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../Customer.dart';
import '../contract.dart';
import '../revenue.dart';
import '../system.dart';
import '../widget/excel.dart';
import '../widget/list.dart';
import '../widget/text.dart';

/// 품목 선언 파일 변경
///
///
/// @Update YM
/// @version 1.1.0
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



  dynamic update() async {
    var create = false;
    var result = false;

    if (id == '') {
      create = true;
      id = DatabaseM.generateRandomString(8);
    }

    var db = FirebaseFirestore.instance;
    /// 메인문서 기록
    final docRef = db.collection("meta").doc('item');
    await db.runTransaction((transaction) async {
      final docRefSn = await transaction.get(docRef);

      /// 매입문서 기조 저장경로
      if(docRefSn.exists) {
        transaction.update(docRef, {
          'list\.$id': toJson(),
          'count': FieldValue.increment(1)
        });
      } else {
        transaction.set(docRef, {
          'list\.$id': toJson(),
          'count': FieldValue.increment(1)
        });
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




  dynamic getAmountBalance() async {
    return await DatabaseM.getAmountItemBalance(id);
  }
}

class ItemCount {
  late Item item;
  var amount = 0.0;
  ItemCount.fromData(Item item, double amount) {
    this.item = item;
    this.amount = amount;
  }

  void incrementCount(double amount) {
    this.amount += amount;
  }


  static Widget OnTableHeader() {
    return WidgetUI.titleRowNone([ "순번", "품목명", "분류", '재고량' ],
      [ 28, 999, 100, 100 ], background: true, lite: true);
  }
  Widget OnTableUI() {
    return Container(
      height: 28,
      child: Row(
        children: [
          ExcelT.LitGrid(text: '-', width: 28, center: true),
          ExcelT.LitGrid(text: item.name, width: 200, center: true, expand: true,),
          ExcelT.LitGrid(text: MetaT.itemGroup[item.group] ?? '-', width: 100, center: true),
          ExcelT.LitGrid(text: StyleT.krwInt(amount.toInt()) + item.unit, width: 100, center: true),
        ],
      ),
    );
  }
}

/// 품목 사용 및 생산 개수
/// (***) 변경 필요
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


/// 품목 거래 이동 입출 현황 기록 클래스
///
/// @Create YM
/// @Update YM 23.04.10
/// @Version 1.1.0
class ItemTS {
  var id = '';
  var state = '';       // D,
  var type = '';       // P 매입, R 매출, F 동결,

  var rpUid = '';       /// 매입매출번호
  var itemUid = '';     /// 품목 고유번호

  double amount = 0.0;       /// 입고량

  var storageLC = '';     /// 입고창고위치

  var ctUid = '';         /// 입고계약
  var csUid = '';         /// 거래처

  var date = 0;           /// 입고일자

  var unitPrice = 0;      /// 참고용 단가
  
  var rh = 0.0;
  var manager = '';       /// 입고자(검수자)
  var writer = '';        /// 작성자
  var updateAt = 0;       /// 문서 변경시각

  var filesMap = {};      /// 첨부파일
  var memo = "";
  //var filesDetail = {};

  ItemTS.fromDatabase(Map<dynamic, dynamic> json) {
    id = json['id'] ?? '';
    state = json['state'] ?? '';
    type = json['type'] ?? '';

    csUid = json['csUid'] ?? '';
    ctUid = json['ctUid'] ?? '';

    storageLC = json['storageLC'] ?? '';
    manager = json['manager'] ?? '';
    writer = json['writer'] ?? '';

    rpUid = json['rpUid'] ?? '';
    itemUid = json['itemUid'] ?? '';
    amount = json['amount'] ?? 0;
    unitPrice = json['unitPrice'] ?? 0;
    rh = json['rh'] ?? 0.0;

    date = json['date'] ?? 0;
    updateAt = json['updateAt'] ?? 0;
    filesMap = (json['filesMap'] != null) ? json['filesMap'] as Map : {};

    memo = json['memo'] ?? '';
  }
  ItemTS.fromRe(Revenue revenue) {
    type = 'RE';

    id = revenue.id;
    rpUid = revenue.id;
    itemUid = revenue.item;

    csUid = revenue.csUid;
    ctUid = revenue.ctUid;

    date = revenue.revenueAt;
    amount = revenue.count.toDouble();
    unitPrice = revenue.unitPrice;
  }
  ItemTS.fromPu(Purchase purchase) {
    type = 'PU';
    id = purchase.id;
    rpUid = purchase.id;

    itemUid = purchase.item;
    csUid = purchase.csUid;
    ctUid = purchase.ctUid;
    date = purchase.purchaseAt;
    amount = purchase.count.toDouble();
    unitPrice = purchase.unitPrice;

    var item = SystemT.getItem(itemUid);
    if(item == null) return;
  }

  void fromPu(Purchase pu) {
    type = 'PU';
    rpUid = pu.id;
    itemUid = pu.item;
    csUid = pu.csUid;
    ctUid = pu.ctUid;

    date = pu.purchaseAt;
    amount = pu.count.toDouble();
    unitPrice = pu.unitPrice;

    var item = SystemT.getItem(itemUid);
    if(item == null) return;
  }

  Map<String, dynamic> toJson() {
    return {
     'id' : id,
     'state' : state,       // D,
     'type' : type,       // P 매입, R 매출, F 동결,

     'rpUid' : rpUid,       /// 매입매출번호
     'itemUid' : itemUid,     /// 품목 고유번호
     'amount' : amount,       /// 입고량
     'storageLC' : storageLC,     /// 입고창고위치

     'ctUid' : ctUid,         /// 입고계약
     'csUid' : csUid,         /// 거래처

     'date' : date,          /// 입고일자

     'unitPrice' : unitPrice,      /// 참고용 단가

     'rh' : rh,
     'manager' : manager,       /// 입고자(검수자)
     'writer' : writer,        /// 작성자
     'updateAt' : updateAt,       /// 문서 변경시각

      'filesMap' : filesMap,      /// 첨부파일
      'memo' : memo,
    };
  }


  String getStorageLC() {
    if(storageLC == '') return 'ㅡ';
    else return storageLC;
  }

  
  dynamic getHistory({ int? startAt, int? lastAt }) async {

  }

  dynamic createUID() async {
    // 문서가 제거되도 복원 가능성이 있으므로 org 구현 없음
    var dateIdDay = DateStyle.dateYearMD(date);
    var dateIdMonth = DateStyle.dateYearMM(date);

    var db = FirebaseFirestore.instance;
    final refMeta = db.collection('meta/uid/dateM-item_ts').doc(dateIdMonth);

    return await db.runTransaction((transaction) async {
      final snMeta = await transaction.get(refMeta);

      /// 개수는 100% 트랜잭션을 보장할 수 없음
      /// 고유한 형식만 보장
      /// 개수가 업데이트된 후 문서 저장에 실패할 경우 예외처리 안함
      if(snMeta.exists) {
        if((snMeta.data() as Map)[dateIdDay] != null) {
          var currentRevenueCount = (snMeta.data() as Map)[dateIdDay] as int;
          currentRevenueCount++;
          id = 'TI-$dateIdDay-$currentRevenueCount';
          transaction.update(refMeta, { dateIdDay: FieldValue.increment(1)});
        }
        else {
          id = 'TI-$dateIdDay-1';
          transaction.update(refMeta, { dateIdDay: 1});
        }
      } else {
        id = 'TI-$dateIdDay-1';
        transaction.set(refMeta, { dateIdDay: 1 });
      }
    }).then(
            (value) { print("DocumentSnapshot successfully updated createUid!"); return true; },
        onError: (e) { print("Error createUid() $e"); return false; }
    );
  }


  /// 이 함수는 해당 클래스를 직렬화 하여 데이터베이스에 기록합니다.
  ///
  /// (***) 문서 업데이트시 기존 org 반드시 첨부
  /// 현재 문서의 UID 가 != ''이 아닐경우 기존 기록을 히스토리로 변경
  /// 히스토리에 기록시 문서 UID는 현재 시간의 에폭시 값으로 변경
  dynamic update({ Map<String, Uint8List>? files, }) async {
    var create = false;
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(date));

    if(id == '')  { create = true; }
    if(create) await createUID();
    if(id == '') return false;

    ItemTS? org = await DatabaseM.getItemTrans(id);

    var orgDateId = '-';
    var orgDateQuarterId = '-';
    var orgDateIdHarp = '-';
    if(org != null) {
      orgDateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(org.date));
      orgDateQuarterId = DateStyle.dateYearsQuarter(org.date);
      orgDateIdHarp = DateStyle.dateYearsHarp(org.date);
    }

    var dateIdHarp = DateStyle.dateYearsHarp(date);
    var dateIdQuarter = DateStyle.dateYearsQuarter(date);

    //var searchText = await getSearchText();

    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;
    
    /// 내부 트랜잭션 다시 작성
    /// 테스트 필요
    /// 메인문서 기록
    final docRef = db.collection("transaction-items").doc(id);
    final dateRef = db.collection('meta/date-m/transaction-items').doc(dateId);
    if(org != null) {
      ref['orgDate'] = db.collection('meta/date-m/transaction-items').doc(orgDateId);
      if(org.csUid != '') ref['orgCsDetail'] = db.collection('customer/${org.csUid}/cs-dateH-item_ts').doc(orgDateIdHarp);
      if(org.ctUid != '') ref['orgCtDetail'] = db.collection('contract/${org.ctUid}/ct-dateH-item_ts').doc(orgDateIdHarp);
    }

    if(csUid != '') ref['cs'] = db.collection('customer').doc(csUid);
    if(csUid != '') ref['csDetail'] = db.collection('customer/${csUid}/cs-dateH-item_ts').doc(dateIdHarp);

    if(ctUid != '') ref['ct'] = db.collection('contract').doc(ctUid);
    if(ctUid != '') ref['ctDetail'] = db.collection('contract/${ctUid}/ct-dateH-item_ts').doc(dateIdHarp);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final  docRefSn = await transaction.get(docRef);
      final  docDateRefSn = await transaction.get(dateRef);
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
          transaction.update(ref['orgDate']!, { org.id: FieldValue.delete() });

        //if(sn['orgSearch']!.exists && dateIdQuarter != orgDateQuarterId && orgDateQuarterId != '-')
        //  transaction.update(ref['orgSearch']!, { org.id: FieldValue.delete() });

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


      /// 트랜잭션 내부
      if(create && docRefSn.exists) return false;
      if(docRefSn.exists) transaction.update(docRef, toJson());
      else transaction.set(docRef, toJson());


      if(docDateRefSn.exists) {
        transaction.update(dateRef, { id: toJson(),});
      } else {
        transaction.set(dateRef, {  id: toJson() });
      }

      if(ref['cs'] != null) {
        if(create) transaction.update(ref['cs']!, {'tsiCount': FieldValue.increment(1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});

        if(sn['csDetail']!.exists) transaction.update(ref['csDetail']!, { id: toJson(), });
        else transaction.set(ref['csDetail']!, { id: toJson(), });
      }

      if(ref['ct'] != null) {
        if(create) if(sn['ct']!.exists) transaction.update(ref['ct']!, {'tsiCount': FieldValue.increment(1),});

        if(sn['ctDetail']!.exists) transaction.update(ref['ctDetail']!, { id: toJson(), });
        else transaction.set(ref['ctDetail']!, { id: toJson(), });
      }
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error update ts item() $e"); return false; }
    );
  }

  dynamic delete() async {
    state = "DEL";

    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(date));
    var dateIdHarp = DateStyle.dateYearsHarp(date);
    var dateIdQuarter = DateStyle.dateYearsQuarter(date);

    //var searchText = await getSearchText();
    Map<String, DocumentReference<Map<String, dynamic>>> ref = {};
    var db = FirebaseFirestore.instance;

    List<ProcessItem> processList = await DatabaseM.getProcessListAllWithPu(rpUid);
    processList.forEach((e) { e.delete(); });

    /// 내부 트랜잭션 다시 작성
    /// 테스트 필요
    /// 메인문서 기록
    final docRef = db.collection("transaction-items").doc(id);
    final dateRef = db.collection('meta/date-m/transaction-items').doc(dateId);

    if(csUid != '') ref['cs'] = db.collection('customer').doc(csUid);
    if(csUid != '') ref['csDetail'] = db.collection('customer/${csUid}/cs-dateH-item_ts').doc(dateIdHarp);

    if(ctUid != '') ref['ct'] = db.collection('contract').doc(ctUid);
    if(ctUid != '') ref['ctDetail'] = db.collection('contract/${ctUid}/ct-dateH-item_ts').doc(dateIdHarp);

    /// 매입 트랜잭션을 수행합니다.
    return await db.runTransaction((transaction) async {
      Map<String, DocumentSnapshot<Map<String, dynamic>>> sn = {};
      final  docRefSn = await transaction.get(docRef);
      final  docDateRefSn = await transaction.get(dateRef);
      if(ref['cs'] != null) sn['cs'] = await transaction.get(ref['cs']!);
      if(ref['csDetail'] != null) sn['csDetail'] = await transaction.get(ref['csDetail']!);

      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);

      /// 트랜잭션 내부
      if(docRefSn.exists) {
        transaction.update(docRef, toJson());
      }
      if(docDateRefSn.exists) {
        transaction.update(dateRef, { id: toJson(),});
      }

      if(ref['cs'] != null) {
        transaction.update(ref['cs']!, {'tsiCount': FieldValue.increment(-1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});
        if(sn['csDetail']!.exists) transaction.update(ref['csDetail']!, { id: FieldValue.delete(), });
      }

      if(ref['ct'] != null) {
        if(sn['ct']!.exists) transaction.update(ref['ct']!, {'tsiCount': FieldValue.increment(-1),});
        if(sn['ctDetail']!.exists) transaction.update(ref['ctDetail']!, { id: FieldValue.delete(), });
      }
    }).then(
            (value) { print("DocumentSnapshot successfully updated!"); return true; },
        onError: (e) { print("Error update ts item() $e"); return false; }
    );
  }


  static Widget onTableHeader() {
    return WidgetUI.titleRowNone([ '순번', '입출일', '구분', '품목', '단위', '수량', '단가', '합계', '', '' ],
        [ 32, 100, 100, 999, 50, 100, 100, 100, 100, 64 ]);
  }
  static Widget OnBalanceTableHeader() {
    return Column(
      children: [
        WidgetUI.titleRowNone([ '순번', '품목명', '분류', '재고', '작업중', '총생산'  ],
            [ 28, 200, 150, 100, 100, 100, 100 ]),
        WidgetT.dividHorizontal(size: 0.7),
      ],
    );
  }
}
