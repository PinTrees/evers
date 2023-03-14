
import 'dart:math';
import 'dart:ui';

import 'package:evers/class/contract.dart';
import 'package:evers/class/employee.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/revenue.dart';
import 'package:evers/class/schedule.dart';
import 'package:evers/class/transaction.dart';
import 'package:evers/helper/algolia.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/system/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';
import 'package:korea_regexp/get_regexp.dart';
import 'package:korea_regexp/models/regexp_options.dart';


class SystemDate {
  static DateTime selectWorkDate = DateTime.now();
  static List<int> years = [ 2022, 2023, 2024, 2025 ];
  static List<int> months = [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12 ];

  static String dateFormat_YYYY_kr(DateTime date) {
    return DateFormat('yyyy년').format(date) ?? '';
  }
  static String dateFormat_MM_kr(DateTime date) {
    return DateFormat('M월').format(date) ?? '';
  }
  static String dateFormat_EE(DateTime date) {
    var e = DateFormat('E').format(date) ?? '';
    if(e == 'Mon') return '월';
    if(e == 'Tue') return '화';
    if(e == 'Wed') return '수';
    if(e == 'Thu') return '목';
    if(e == 'Fri') return '금';
    if(e == 'Sat') return '토';
    if(e == 'Sun') return '일';
    return e;
  }
}