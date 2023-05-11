
import 'dart:ui';

import 'package:evers/class/system.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import 'package:async/async.dart';
import '../transaction.dart';

///
class Search {
  static List<SortKey> tsList = [];
  static int tsListIndex = 0;

  static void clear() {
    tsListIndex = 0;
    tsList.clear();
  }

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
}