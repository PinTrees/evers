
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

class FunT {
  static Function? setStateD;
  static Function? setState;
  static Function? scheduleRf;

  static dynamic setStateAll() async {
    if(setStateD != null) await setStateD!();
    if(setState != null) await setState!();
    return '';
  }
  static dynamic setStateDT() async {
    if(setStateD != null) await setStateD!();
    return '';
  }
  static dynamic setStateMain() async {
    if(setState != null) await setState!();
    return '';
  }

  static dynamic refreshScheduleView() async {
    if(scheduleRf != null) await scheduleRf!();
    return '';
  }
}
