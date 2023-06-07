
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import 'interfaceUI.dart';

class FunT {
  static Function? setStateD;
  static Function? setState;
  static Function? setStateO;


  static Function(List<String>, List<String>)? streamSearchHistory;


  static Function? scheduleRf;
  static Function? refresh;

  /// 이 함수는 로드바와 함께 로직을 실행합니다.
  static dynamic WithLoading(BuildContext context, {Function? onLoad, Function? setState}) async {
    WidgetT.loadingBottomSheet(context, text: '로딩중');
    if(onLoad != null) await onLoad();
    Navigator.pop(context);
    if(setState != null) await setState();
  }

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


  static dynamic CallFunction(Function? fun) async {
    if(fun != null) return await fun();
    else return null;
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
