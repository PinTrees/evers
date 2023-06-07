
import 'dart:ui';

import 'package:evers/class/system.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/page/window/window_article_create.dart';
import 'package:evers/page/window/window_cs.dart';
import 'package:evers/page/window/window_cs_create.dart';
import 'package:evers/page/window/window_ct_create.dart';
import 'package:evers/page/window/window_ledger_revenue.dart';
import 'package:evers/page/window/window_ledger_revenue_create.dart';
import 'package:evers/page/window/window_pageA_create.dart';
import 'package:evers/page/window/window_paper_product.dart';
import 'package:evers/page/window/window_process_create.dart';
import 'package:evers/page/window/window_process_info.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_pu_editor.dart';
import 'package:evers/page/window/window_re_create.dart';
import 'package:evers/page/window/window_re_create_ct.dart';
import 'package:evers/page/window/window_re_editor.dart';
import 'package:evers/page/window/window_schList_info.dart';
import 'package:evers/page/window/window_sch_create.dart';
import 'package:evers/page/window/window_sch_editor.dart';
import 'package:evers/page/window/window_shopitem_create.dart';
import 'package:evers/page/window/window_shopitem_editor.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/page/window/window_ts_editor.dart';
import 'package:evers/page/window/window_user_create.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:intl/intl.dart';

import '../../core/window/MdiController.dart';
import '../../core/window/window_base.dart';
import '../../page/window/window_ct.dart';
import '../../page/window/window_paper_factory.dart';

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

    if(window is WindowCS || window is WindowCsCreate) width = 1150;
    if(window is WindowCT || window is WindowCtCreate) width = 1150;

    if(window is WindowItemTS) width = 1000;

    if(window is WindowProcessOutputCreate || window is WindowProcessCreate) width = 1000;

    /// 원장 - 출고원장 및 각 원장들의 최대 가로사이즈 제한
    if(window is WindowLedgerRe) width = 1000;
    if(window is WindowLedgerReCreate) width = 1000;

    /// 공장일보 및 생산일보 창 사이즈
    if(window is WindowFactoryPaper || window is WindowProductPaper) width = 800;

    if(window is WindowPUCreate || window is WindowPUEditor || window is WindowPUCreateWithCS) width = 1000;
    if(window is WindowReCreate || window is WindowReEditor || window is WindowReCreateWithCt) width = 1000;
    if(window is WindowSchCreate || window is WindowSchEditor || window is WindowSchListInfo) width = 1000;

    if(window is WindowShopItemCreate) width = 1000;
    if(window is WindowShopItemEditor) width = 1000;




    var parent = mdiController!.createWindow(context, pw: width);
    window!.parent = parent;

    bool isFixedHeight = false;
    if(window is WindowCT) isFixedHeight = true;
    if(window is WindowCS) isFixedHeight = true;
    //if(window is WindowCtCreate) isFixedHeight = true;
    if(window is WindowCsCreate) isFixedHeight = true;
    if(window is WindowItemTS) isFixedHeight = false;
    if(window is WindowLedgerReCreate) isFixedHeight = true;

    if(window is WindowShopItemCreate) isFixedHeight = true;
    if(window is WindowShopItemEditor) isFixedHeight = true;
    if(window is WindowArticleCreate) isFixedHeight = true;
    if(window is WindowPageACreate) isFixedHeight = true;

    //if(window is WindowFactoryCreate) isFixedHeight = true;

    mdiController!.addWindow(context, widget: window, resizableWindow: parent, fixedHeight: isFixedHeight);
  }
}