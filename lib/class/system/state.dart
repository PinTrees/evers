
import 'dart:ui';

import 'package:evers/class/system.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/page/window/window_cs.dart';
import 'package:evers/page/window/window_sch_create.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/page/window/window_ts_editor.dart';
import 'package:evers/page/window/window_user_create.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import '../../core/window/MdiController.dart';
import '../../core/window/window_base.dart';
import '../../page/window/window_ct.dart';

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


class PageInfo {
  static int pageLimit = 10;
}

/// 화면 상태 관리 클래스입니다.
class UIState {
  static MdiController? mdiController;
  static UIType current = UIType.undefined;


  /// 이 함수는 윈도우기반 멀티 인터페이스를 신규 생성하는 함수입니다.
  /// 신규 창을 생성하기 위해서는 반드시 이 함수를 호출해야 합니다.
  static dynamic OpenNewWindow(BuildContext context, WindowBaseMDI window) async {

    var width = 1000000.0;
    if(window is WindowTsCreate || window is WindowTSEditor || window is Window) width = 1000;
    if(window is WindowUserCreate) width = 800;
    if(window is WindowCT || window is WindowCS) width = 1200;

    var parent = mdiController!.createWindow(context, pw: width);
    window!.parent = parent;

    bool isFixedHeight = false;
    if(window is WindowCT) isFixedHeight = true;
    if(window is WindowCS) isFixedHeight = true;
    //if(window is WindowSchCreate) isFixedHeight = true;

    mdiController!.addWindow(context, widget: window, resizableWindow: parent, fixedHeight: isFixedHeight);
  }
}