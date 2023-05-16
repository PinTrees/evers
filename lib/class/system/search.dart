
import 'dart:ui';

import 'package:evers/class/Customer.dart';
import 'package:evers/class/system.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import 'package:async/async.dart';
import '../transaction.dart';


/// 검색 시스템 최상위 관리 클래스입니다.
class Search {
  static List<SortKey> tsList = [];
  static int tsListIndex = 0;

  static List<String> csList = [];

  static void clear() {
    tsListIndex = 0;
    tsList.clear();

    csList.clear();
  }

  /// 이 함수는 거래기록 검색을 비동기로 요청합니다.
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
}