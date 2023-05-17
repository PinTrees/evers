
import 'dart:ui';

import 'package:evers/class/Customer.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/system.dart';
import 'package:evers/class/system/records.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import 'package:async/async.dart';
import '../transaction.dart';


/// 검색 시스템 최상위 관리 클래스입니다.
class Search {

  /// 거래기록 검색 목록. : 정렬됨
  static List<SortKey> tsList = [];
  static int tsListIndex = 0;

  /// 미수현황을 계산해야 하는 거래처 목록
  static List<Customer> purCsList = [];

  static List<String> csList = [];

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

    print("sadsddssddsaddaaddadsa:${tsMap.length}");

    purCsList.forEach((Customer cs) {
      if(!tsMap.containsKey(cs.id) || !puMap.containsKey(cs.id)) return;
      list[cs] = Records<List<TS>, List<Purchase>>(tsMap[cs.id] as List<TS>, puMap[cs.id] as List<Purchase>);
    });
    return list;
  }
}