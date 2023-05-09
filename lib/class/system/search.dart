
import 'dart:ui';

import 'package:evers/class/system.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import '../transaction.dart';

/// 화면 타입
class Search {
  static List<SortKey> tsList = [];
  static int tsListIndex = 0;

  static void clear() {
    tsListIndex = 0;
    tsList.clear();
  }

  static dynamic searchTS() async {
    List<TS> search = [];
    for(int i = 0; i < 25; i++) {
      if(tsList.length <= tsListIndex) return search;

      var data = await DatabaseM.getTsDoc(tsList[tsListIndex++].id);
      if(data == null) continue;
      search.add(data);
    }
    return search;
  }
}