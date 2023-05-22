
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

class FunT {
  static Function? setStateD;
  static Function? setState;
  static Function? setStateO;

  static Function? scheduleRf;
  static Function? refresh;


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

  static dynamic setStateOnly() async {
    if(setStateO != null) await setStateO!();
    return '';
  }


  static dynamic setRefreshMain() async {
    if(refresh != null) await refresh!();
    return true;
   }

  static dynamic refreshScheduleView() async {
    if(scheduleRf != null) await scheduleRf!();
    return '';
  }
}
