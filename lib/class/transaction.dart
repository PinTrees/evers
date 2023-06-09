
import 'dart:typed_data';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/user.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:evers/helper/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import '../ui/ux.dart';
import 'Customer.dart';
import 'contract.dart';
import 'revenue.dart';
import 'system.dart';


import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;


/// 거래기록 클래스
///
///
/// @update YM
/// @version 1.0.0
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

  var writer = "";
  var updateAt = 0;

  var summary = '';       /// 적요
  var memo = '';          /// 메모


  /// DeSerialize Json Form Sever
  ///
  /// @params map json
  /// @Creater function
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
    updateAt = json["updateAt"] ?? 0;

    writer = json["writer"] ?? "";
    summary = json['summary'] ?? '';
    memo = json['memo'] ?? '';
  }
  
  /// DeSerialize Class Form Purchase
  ///
  /// @param Purchase pu 매입데이터
  /// @param string account 계좌
  /// @param bool now 즉시수금여부
  /// @create function
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
  
  /// DeSerialize Class Form Revenue
  ///
  /// @param Revenue re 매출데이터
  /// @param string account 계좌
  /// @param bool now 즉시수금여부
  /// @create function
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

      'writer': writer,
      'updateAt': updateAt,

      'summary': summary,
      'memo': memo,
    };
  }

  /// Serialize this Class
  ///
  /// @param none
  /// @return JsonData
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
      'updateAt': updateAt,
      'writer': writer,

      'summary': summary,
      'memo': memo,
    };
  }
  
  /// The Low Serialize this Class
  ///
  /// @param none
  /// @return JsonData low
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

      'writer': writer,
      'updateAt': updateAt,

      'summary': summary,
      'memo': memo,
    };
  }
  
  
  
  /// 거래 금액을 반환
  /// 매출의 경우 -, 매입의 경우 +
  ///
  /// @param none
  /// @return int 거래금액
  int getAmount() {
   if(type =='PU') return amount * -1;
   else if(type == 'RE') return amount;
   else return 0;
  }


   /// 지출에 대한 거래 금액을 반환
   /// 모든 금액은 절댓값으로 반환
   ///
   /// @param none
   /// @return int 거래금액
  int getAmountOnlyPu() {
    if(type =='PU') return amount.abs();
    else return 0;
  }

  /// 수금에 대한 거래 금액을 반환
  /// 모든 금액은 절댓값으로 반환
  ///
  /// @param none
  /// @return int 거래금액
  int getAmountOnlyRE() {
    if(type == 'RE') return amount.abs();
    else return 0;
  }



  /// 거래기록의 계좌를 반환
  ///
  /// @param none
  /// @return String
  String getAccountName() {
    return SystemT.getAccountName(account);
  }
  
  /// 거래 타입의 UI 표기값을 반환
  /// RE: 수입, PU: 지출
  ///
  /// @param none
  /// @return String 수입, 지출
  String getType() {
    if(type == 'RE') return '수입';
    else if(type == 'PU') return '지출';
    else return type;
  }
  
  
  /// 검색 메타데이터 헤더 값을 반환
  ///
  /// 구분자 "&:"
  ///
  /// @params none
  /// @return String "data&:data&:data&:data"
  Future<String> getSearchText() async {
    var cs = (await SystemT.getCS(csUid)) ?? Customer.fromDatabase({});
    //var ct = (await SystemT.getCt(ctUid)) ?? Contract.fromDatabase({});

    var date = '';
    try {
      date = transactionAt.toString().substring(0, 8);
    } catch (e) {
      date = '';
    }
    return "${id}&:${cs.businessName}&:${summary}&:${memo}&:AC=${account}&:${date}";
  }


  Future<List<TS>> getHistory() async {
    List<TS> history = [];
    var coll = FirebaseFirestore.instance.collection('transaction/${id}/history');
    await coll.orderBy('updateAt', descending: true).limit(10).get().then((value) async {
      value.docs.forEach((e) {
        if(!e.exists) return;
        if(e.data() == null) return;

        history.add(TS.fromDatabase(e.data() as Map));
      });
      return true;
    });

    return history;
  }

  
  /// 거래 UID 확인 함수
  ///
  /// 거래 기록시 현재 거래문서 데이터베이스 ID 값을 확인
  /// "T(거래구분자)-16845212(날짜 에폭시)-1(번호)"
  /// 번호는 1부터 시작하며 날짜마다 고유
  ///
  /// @params none
  /// @return String "T-16452222-1"
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


  /// 거래기록 데이터베이스 업데이트 함수
  ///
  /// 결재계좌 수정시 잔고 계산 미차감 오류 해결 - 과거 기록 재 구축 필요
  ///
  /// @param org 원본 거래기록
  /// @param files 거래기록 신규 첨부파일
  /// @return 업데이트 성공 여부
  /// @throws 업데이트가 실패할 경우 모든 작업 취소 (문서간 트랜잭션)
  ///
  /// (***) storage - document 간 트랜잭션 구현안됨
  dynamic update({Map<String, Uint8List>? files,}) async {
    writer = UserSystem.userData.id;

    var create = false;
    if(id == '') create = true;
    var dateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(transactionAt));

    if(create) await createUid();
    if(id == '') return;


    TS? org;
    if(!create) org = await DatabaseM.getTsDoc(id);

    var orgDocId = '';
    var orgDateId = '-';
    var orgDateQuarterId = '-';
    var orgDateIdHarp = '-';
    var orgDateIdMonth = '-';
    if(org != null) {
      orgDateId = StyleT.dateFormatM(DateTime.fromMicrosecondsSinceEpoch(org.transactionAt));
      orgDateQuarterId = DateStyle.dateYearsQuarter(org.transactionAt);
      orgDateIdHarp = DateStyle.dateYearsHarp(org.transactionAt);
      orgDateIdMonth = DateStyle.dateYearMM(org.transactionAt);

      orgDocId = SystemT.generateRandomString(16);
      org.updateAt = DateTime.now().microsecondsSinceEpoch;
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

    if(org != null) {
      ref['orgDate'] = db.collection('meta/date-by/dateM-transaction').doc(orgDateId);
      ref['orgSearch'] = db.collection('meta/search/dateQ-transaction').doc(orgDateQuarterId);
      ref['history'] = db.collection('transaction/$id/history').doc(orgDocId);

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
      if(ref['history'] != null) sn['history'] = await transaction.get(ref['history']!);

      if(ref['account'] != null) sn['account'] = await transaction.get(ref['account']!);
      if(ref['accountDate'] != null) sn['accountDate'] = await transaction.get(ref['accountDate']!);

      if(ref['cs'] != null) sn['cs'] = await transaction.get(ref['cs']!);
      if(ref['csDetail'] != null) sn['csDetail'] = await transaction.get(ref['csDetail']!);

      if(ref['ct'] != null) sn['ct'] = await transaction.get(ref['ct']!);
      if(ref['ctDetail'] != null) sn['ctDetail'] = await transaction.get(ref['ctDetail']!);

      if(org != null) {
        if(sn['history'] != null) {
          transaction.set(ref['history']!, org.toJson());
        }

        /// 과거 기록과 현재 기록간 날짜 정보가 달라졌을 경우 과거 기록을 제거합니다.
        if(sn['orgDate']!.exists && dateId != orgDateId && orgDateId != '-') {
          transaction.update(ref['orgDate']!, { org.id : FieldValue.delete(), });
        }

        if(sn['orgCsDetail'] != null) {
          /// 거래처 분산기록도 날짜 기반으로 상위문서를 확인함으로 과거 기록을 제거합니다.
          if(sn['orgCsDetail']!.exists && dateIdHarp != orgDateIdHarp && orgDateIdHarp != '-') {
            transaction.update(ref['orgCsDetail']!, { org.id: FieldValue.delete(), });
          }
        }

        if(sn['orgCtDetail'] != null) {
          /// 계약 분산기록도 날짜 기반으로 상위문서를 확인함으로 과거기록을 제거합니다.
          if(sn['orgCtDetail']!.exists && dateIdHarp != orgDateIdHarp && orgDateIdHarp != '-') {
            transaction.update(ref['orgCtDetail']!, { org.id: FieldValue.delete() });
          }
        }

        /// 날짜가 변경되었을 경우
        if(dateIdQuarter != orgDateQuarterId) {
          /// 검색정보도 날짜 기반으로 상위문서를 결정함으로 기존기록 제거
          if(sn['orgSearch']!.exists) transaction.update(ref['orgSearch']!, { id: FieldValue.delete(), });
          /// 잔고기록도 날짜 기반으로 상위문서를 결정함으로 기존기록 제거
          if(sn['orgAccount'] != null) if(sn['orgAccount']!.exists) transaction.update(ref['orgAccount']!, { id: FieldValue.delete(), });
        }

        /// 월별 날짜가 변경되었을 경우
        if(dateIdMonth != orgDateIdMonth) {
          /// 보다 상세한 날짜기반 잔고계산 문서의 과거 기록을 제거 - 중복 방지
          if(sn['orgAccountDate'] != null)
            if(sn['orgAccountDate']!.exists) transaction.update(ref['orgAccountDate']!, { id: FieldValue.delete(), });
        }

        /// 계좌 정보가 변경되었을 경우 기존 잔고차감계좌 기록 제거후 신규 계좌로 데이터 기록
        if(org.account != account) {
          if(sn['orgAccount'] != null) if(sn['orgAccount']!.exists) transaction.update(ref['orgAccount']!, { id: FieldValue.delete(), });
          if(sn['orgAccountDate'] != null)  if(sn['orgAccountDate']!.exists) transaction.update(ref['orgAccountDate']!, { id: FieldValue.delete(), });
        }
      }

      /// 기초 경로에 문서 저장
      if(docRefSn.exists) {
        transaction.update(docRef, toJson());
      } else {
        transaction.set(docRef, toJson());
      }

      /// 날짜기반 문서 저장
      if(docDateRefSn.exists) {
        transaction.update(dateRef, { id: toJson(), 'date': DateTime.fromMicrosecondsSinceEpoch(transactionAt).microsecondsSinceEpoch});
      } else {
        transaction.set(dateRef, { id: toJson(), 'date': DateTime.fromMicrosecondsSinceEpoch(transactionAt).microsecondsSinceEpoch});
      }

      /// 잔고 분산 문서 저장 - 날짜기반
      if(sn['account'] != null) {
        if (sn['account']!.exists) {
          transaction.update(ref['account']!, { id: getAmount(),},);
        } else {
          transaction.set(ref['account']!, { id: getAmount()},);
        }

        if (sn['accountDate']!.exists) {
          transaction.update(ref['accountDate']!, { id: getAmount(),},);
        } else {
          transaction.set(ref['accountDate']!, { id: getAmount()},);
        }
      }


      /// 수납 변경시 거래처와 계약 정보 수정이 불가능하도록 설게할 예정이므로 해당 구현이 누락되어있습니다.
      /// 수납정보에 거래처가 포함되었을 경우 해당 거래처에 분산 기록
      if(ref['cs'] != null) {
        if (create) {
          /// 신규수납정보 등록시 거래처 총 수납개수 증가
          transaction.update(ref['cs']!, {'tsCount': FieldValue.increment(1), 'updateAt': DateTime.now().microsecondsSinceEpoch,});

          /// 거래처 상세주소 활성화시 수납정보 거래처에 분산기록
          if (sn['csDetail']!.exists) {
            transaction.update(ref['csDetail']!, { id: toJson(),});
          } else {
            transaction.set(ref['csDetail']!, { id: toJson(),});
          }
        }
      }

      /// 수납정보에 계약이 포함되었을 경우 해당 거래처에 분산 기록
      if(ref['ct'] != null) {
        /// 신규 등록시 계약문서의 일부 정보 업데이트
        if(create) if(sn['ct']!.exists) transaction.update(ref['ct']!, {'tsCount': FieldValue.increment(1),});

        /// 계약 하위에 수납정보 분산기록
        if(sn['ctDetail']!.exists) {
          transaction.update(ref['ctDetail']!, { id: toJson(), });
        } else {
          transaction.set(ref['ctDetail']!, { id: toJson(),});
        }
      }


      /// 검색 메타정보 업데이트
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


  /// 거래기록 데이터베이스 삭제 함수
  ///
  /// @param none
  /// @return 데이터베이스 삭제 여부
  /// @throws 삭제에 실패할 경우 모든 작업 취소 (문서간 트랜잭션)
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
  
  /// PDF 파일 변환시 테이블의 열 값 구조
  ///
  /// 거래처 기록이 필요함으로 비동기 함수로 작성
  /// 
  /// @param bal 현재 순번
  /// @return List<String> 테이블 열 값의 리스트
  dynamic getTable(int bal) async {
    var cs = await SystemT.getCS(csUid);
    return <String>[ StyleT.dateFormatYYMMDD(transactionAt), SystemT.getAccountName(account), cs.businessName, (type == 'RE') ? StyleT.krwInt(getAmount()) : '',
      (type == 'PU') ? StyleT.krwInt(getAmount().abs()) : '',  StyleT.krwInt(bal) , summary.length > 16 ? summary.substring(0, 16) : summary ];
  }


  /// 제거 예정 코드
  /// 확인 필요
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





  static Widget OnTableHeader() {
    return  WidgetUI.titleRowNone([ '순번', '거래일자', '구분', '적요', '금액', '결제', "" ],
        [ 28, 150, 100 + 28, 999, 120, 200, 28], background: true, lite: true);
  }
  static Widget OnTableHeaderMain() {
    return Container( padding: EdgeInsets.fromLTRB(6, 0, 6, 6),
      child: WidgetUI.titleRowNone([ '순번', '거래번호', '거래일자', '거래처', '적요', '수입', '지출', '계좌', '메모', '', ],
          [ 32, 80, 80, 150, 999, 80, 80, 100, 999, 32, 0,  ]),
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
