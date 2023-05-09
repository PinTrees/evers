
import 'dart:ui';

import 'package:evers/class/system.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

/// 화면 타입
enum UIType {
  dialog_customer('customer', '거래처'),
  dialog_contract('contract', '자유게시판'),
  undefined('undefined', '');

  const UIType(this.code, this.displayName);
  final String code;
  final String displayName;

  factory UIType.getByCode(String code){
    return UIType.values.firstWhere((value) => value.code == code,
        orElse: () => UIType.undefined);
  }
}

/// 화면 상태 관리 클래스입니다.
class UIState {
  static UIType current = UIType.undefined;
}