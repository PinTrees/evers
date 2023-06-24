
import 'dart:ui';

import 'package:evers/class/Customer.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/revenue.dart';
import 'package:evers/class/system.dart';
import 'package:evers/class/system/records.dart';
import 'package:evers/core/database/database_search.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import 'package:async/async.dart';
import 'package:korea_regexp/get_regexp.dart';
import 'package:korea_regexp/models/regexp_options.dart';
import '../transaction.dart';


/// 검색 시스템 최상위 관리 클래스입니다.
class Search {

  /// 거래기록 검색 목록. : 정렬됨
  static List<SortKey> tsList = [];
  static int tsListIndex = 0;


  /// 매출기록 검색 목록. : 정렬됨
  static List<SortKey> reList = [];
  static int reListIndex = 0;


  /// 매입기록 검색 목록. : 정렬됨
  static List<SortKey> puList = [];
  static int puListIndex = 0;


  /// 미수현황을 계산해야 하는 거래처 목록
  static List<Customer> purCsList = [];
  static List<String> csList = [];

  /// 미지급 현황을 계산해야하는 계약 목록
  static List<Contract> revCtList = [];


  /// 이 함수는 모든 검색목록을 초기화 합니다.
  static void clear() {
    tsListIndex = 0;
    tsList.clear();
    csList.clear();
    purCsList.clear();
  }


  /// 이 함수는 거래기록 검색을 비동기로 요청합니다.
  /// 반환
  ///   List<TS> list; TS는 Null일 수 없습니다.
  static dynamic searchTS() async {
    List<TS> search = [];
    if(tsList.length <= tsListIndex) return search;

    final futureGroup = FutureGroup();
    for(int i = 0; i < 25; i++) {
      if(tsList.length <= tsListIndex) break;

      futureGroup.add(DatabaseM.getTsDoc(tsList[tsListIndex++].id));
    }

    futureGroup.close();

    await futureGroup.future.then((value) {
      value.forEach((e) {
        if(e == null) return;
          search.add(e);
      });
    });

    return search;
  }


  /// 이 함수는 매출기록 검색을 비동기로 요청합니다.
  /// 반환
  ///   List<Revenue> list; Revenue는 NUll일 수 없습니다.
  ///     목록은 항상 날짜로 Dec 정렬되어 반환됩니다.
  static dynamic searchRevenue() async {
    List<TS> search = [];
    if(reList.length <= reListIndex) return search;

    final futureGroup = FutureGroup();
    for(int i = 0; i < 25; i++) {
      if(reList.length <= reListIndex) break;

      futureGroup.add(DatabaseM.getRevenueDoc(reList[reListIndex++].id));
    }

    futureGroup.close();

    await futureGroup.future.then((value) {
      value.forEach((e) {
        if(e == null) return;
        search.add(e);
      });
    });

    return search;
  }


  /// *********************************
  /// 구조 변경 필요 매우 중료 / 거래기록 검색 시스템으로 변경 필요
  /// 이 함수는 매입기록 검색을 비동기로 요청합니다.
  /// 반환
  ///   List<Purchase> list; Purchase는 NUll일 수 없습니다.
  ///     목록은 항상 날짜로 Dec 정렬되어 반환됩니다.
  static dynamic searchPurchase() async {
    puListIndex = 0;

    List<Purchase> search = [];
    if(puList.length <= puListIndex) return search;

    final futureGroup = FutureGroup();
    for(int i = 0; i < 200; i++) { 
      if(puList.length <= puListIndex) break;
      futureGroup.add(DatabaseM.getPurchaseDoc(puList[puListIndex++].id));
    }
    futureGroup.close();

    await futureGroup.future.then((List<dynamic> value) {
      value.forEach((e) { if(e != null) search.add(e); });
    });

    search.sort((a, b) => b.purchaseAt.compareTo(a.purchaseAt));
    return search;
  }
  static dynamic searchPuMeta(String search) async {
    search = search.trim();
    puList.clear();

    late RegExp regExp;
    try {
      regExp = getRegExp(search, RegExpOptions(initialSearch: true, startsWith: false, endsWith: false));
    } catch (e) {  print(e);return [];  }

    for(var a in SystemT.purSearch.values) {
      var meta = a as Map;
      meta.forEach((k, e) {
        if(e != null) if(regExp.hasMatch(e)) puList.add(SortKey.fromData(id: k, data: e));
      });
    }

    puList.sort((a, b) => b.data.compareTo(a.data));
  }



  /// 이 함수는 거래처 검색이 필요한 문서의 키값을 목록으로 저장후 작업 결과를 반환합니다.
  static dynamic searchCSMeta(String search) async {
    List<Customer> searchList = [];

    Search.clear();
    search.trim();

    if(search == "") return searchList;
    DatabaseSearch.setSearch_CS(search);

    late RegExp regExp;
    try { regExp = getRegExp(search, RegExpOptions(initialSearch: true, startsWith: false, endsWith: false)); }
    catch (e) { print(e); return; }

    SystemT.customerSearch.forEach((k, e) { if(regExp.hasMatch(e)) Search.csList.add(k);});

    return await searchCS();
  }


  /// 이 함수는 거래처문서 검색을 비동기로 요청합니다.
  /// 반환
  ///   List<Customer> list : 반환 거래처는 Null일 수 없습니다.
  static dynamic searchCS() async {
    List<Customer> search = [];

    final futureGroup = FutureGroup();
    for(int i = 0; i < 100; i++) {
      if(csList.length <= i) break;
      futureGroup.add(DatabaseM.getCustomerDoc(csList[i]));
    }
    futureGroup.close();

    await futureGroup.future.then((value) {
      value.forEach((e) {
        if(e == null) return;
        search.add(e);
      });
    });

    return search;
  }

  static dynamic searchCSOrder(List<dynamic> searchOrder) async {
    List<Customer> search = [];

    final futureGroup = FutureGroup();
    for(int i = 0; i < 100; i++) {
      if(searchOrder.length <= i) break;
      futureGroup.add(DatabaseM.getCustomerDoc(searchOrder[i]));
    }
    futureGroup.close();

    await futureGroup.future.then((value) {
      value.forEach((e) {
        if(e == null) return;
        search.add(e);
      });
    });

    return search;
  }


  /// 이 함수는 미지급 현황 검색을 비동기로 요청합니다.
  /// 반환
  ///   Map<Customer, Records<List<TS>, List<Purchase>>> list 반환값은 NUll일 수 없습니다.
  static dynamic searchPurCs() async {
    /// 일대일 대응값이 아닌 모든 계산이므로 레코드로 반환합니다.
    Map<Customer, Records<List<TS>, List<Purchase>>> list = {};
    purCsList = await DatabaseM.getCustomerFromPuCount();

    final futureGroup = FutureGroup();
    for(int i = 0; i < purCsList.length; i++) {
      futureGroup.add(DatabaseM.getTsWithCustomer(purCsList[i].id));
      futureGroup.add(purCsList[i].getPurchase());
    }
    futureGroup.close();

    Map<String, List<TS>> tsMap = {};
    Map<String, List<Purchase>> puMap = {};

    await futureGroup.future.then((value) {
      /// value is List<List<TS> ?? List<Purchase>> data
      value.forEach((e) {
        /// e is List<TS>
        if(e is List<TS>) {
          var tsList = e as List<TS>;
          tsList.removeWhere((e) => e.type != 'PU');
          if(tsList.length <= 0) return;
          tsMap[tsList.first.csUid] = tsList;
        }
        /// e is List<Purchase>
        else if(e is List<Purchase>) {
          var puList = e as List<Purchase>;
          if(puList.length <= 0) return;
          puMap[puList.first.csUid] = puList;
        }
      });
    });

    //print("sadsddssddsaddaaddadsa:${tsMap.length}");

    purCsList.forEach((Customer cs) {
      if(!tsMap.containsKey(cs.id) || !puMap.containsKey(cs.id)) return;
      list[cs] = Records<List<TS>, List<Purchase>>(tsMap[cs.id] as List<TS>, puMap[cs.id] as List<Purchase>);
    });
    return list;
  }


  /// 이 함수는 미수 현황 검색을 비동기로 요청합니다.
  /// 반환
  ///   Map<Customer, Records<List<TS>, List<Purchase>>> list 반환값은 NUll일 수 없습니다.
  static dynamic searchRevCt() async {
    /// 일대일 대응값이 아닌 모든 계산이므로 레코드로 반환합니다.
    Map<Contract, Records<List<TS>, List<Revenue>>> list = {};
    revCtList = await DatabaseM.getContractFromReCount();

    final futureGroup = FutureGroup();
    for(int i = 0; i < revCtList.length; i++) {
      futureGroup.add(DatabaseM.getTransactionCt(revCtList[i].id));
      futureGroup.add(DatabaseM.getRevenueOnlyContract(revCtList[i].id));
    }
    futureGroup.close();

    Map<String, List<TS>> tsMap = {};
    Map<String, List<Revenue>> revMap = {};

    print("미수 계약 정보에 대한 목록 비동기 요청 완료");

    /// value 는 List<TS> 또는 List<Revenue> 의 목록입니다.
    await futureGroup.future.then((value) {
      value.forEach((dataList) {
        if(dataList is List<TS>) {
          /// Database 쿼리식에서 제한하는 형태로 변경
          dataList.removeWhere((ts) => ts.type != 'RE');
          if(dataList.isNotEmpty) tsMap[dataList.first.ctUid] = dataList;
        }
        else if(dataList is List<Revenue>) {
          if(dataList.isNotEmpty) revMap[dataList.first.ctUid] = dataList;
        }
      });
    });

    print("미수 계약 정보에 대한 목록 비동기 요청 반환 완료");

    revCtList.forEach((Contract ct) {
      if(!tsMap.containsKey(ct.id) && !revMap.containsKey(ct.id)) return;
      list[ct] = Records<List<TS>, List<Revenue>>(
          tsMap.containsKey(ct.id) ? tsMap[ct.id] as List<TS> : [],
          revMap.containsKey(ct.id) ? revMap[ct.id] as List<Revenue> : []);
    });

    print("미수 계약 개수: ${ list.length }");
    return list;
  }
}