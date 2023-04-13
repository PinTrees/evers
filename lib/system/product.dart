
import 'dart:math';
import 'dart:ui';

import 'package:evers/class/contract.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/revenue.dart';
import 'package:evers/class/schedule.dart';
import 'package:evers/class/transaction.dart';
import 'package:evers/helper/algolia.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';
import 'package:korea_regexp/get_regexp.dart';
import 'package:korea_regexp/models/regexp_options.dart';


class ProductSystem {
  static Map<dynamic, ProductD> productStream = {};

  static var searchText = '';

  static dynamic init() async {
    await initStream();
  }
  static dynamic initStream() async {
     await DatabaseM.initStreamProductDate();
  }
  static void sortStream() {
    productStream = Map.fromEntries(productStream.entries.toList()..sort((e1, e2) => e2.key.compareTo(e1.key)));
  }
}
