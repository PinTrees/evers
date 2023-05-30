import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/page/window/window_ct.dart';
import 'package:flutter/material.dart';

import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/style.dart';
import '../../page/window/window_cs.dart';
import '../../ui/dialog_contract.dart';
import '../../ui/ux.dart';
import '../Customer.dart';
import '../contract.dart';
import '../system/state.dart';

class CompContract {
  static dynamic tableHeader() {
     return WidgetUI.titleRowNone([ '순번', '거래처', '계약명', '담당자', '연락처', '', ],
       [ 32, 250, 250, 150, 150, 999, ], background: true, lite: true);
  }

  /// 이 함수는 계약 검색창의 계약목록 테이블 상단위젯을 반환합니다.
  static dynamic tableHeaderSearch() {
    return WidgetUI.titleRowNone([ '순번', '거래처 / 계약명', '담당자', '연락처', '',],
        [ 32, 999, 100, 100, 100 ], background: true, lite: true);
  }

  static dynamic tableHeaderMain() {
    return Container( padding: EdgeInsets.fromLTRB(6, 0, 6, 6),
      child: WidgetUI.titleRowNone([ '순번', '거래처', '계약명', '담당자', '연락처', '', ],
          [ 32, 250, 250, 150, 150, 999, ]),
    );
  }

  static dynamic tableUI(BuildContext context, Contract ct, {
    int? index,
    Function? onTap,
  }) {
    var w = InkWell(
        onTap: () async {
          UIState.OpenNewWindow(context, WindowCT(org_ct: ct,));
        },
        child: Container( height: 28,
          decoration: StyleT.inkStyleNone(color: Colors.transparent),
          child: Row(
              children: [
                ExcelT.LitGrid(text: '${index ?? '-'}', width: 32, center: true),
                ExcelT.LitGrid(text: ct.csName, width: 250, center: true),
                ExcelT.LitGrid(text: ct.ctName, width: 250, center: true),
                ExcelT.LitGrid(text: ct.manager, width: 150, center: true),
                ExcelT.LitGrid(text: ct.managerPhoneNumber, width: 150, center: true),
              ]
          ),
        ));
    return w;
  }


  /// 이 함수는 계약목록의 테이블 위젯을 반환합니다.
  static dynamic tableUISearch(BuildContext context, Contract ct, {
    int? index,
    Function? onTap,
  }) {
    var w = Container(
      height: 28,
      decoration: StyleT.inkStyleNone(color: Colors.transparent),
      child: Row(
          children: [
            ExcelT.LitGrid(text: '${index ?? '-'}', width: 32, center: true),
            ExcelT.LitGrid(text: ct.csName + ' / ' +  ct.ctName, width: 250, center: true, expand: true),
            ExcelT.LitGrid(text: ct.manager, width: 100, center: true),
            ExcelT.LitGrid(text: ct.managerPhoneNumber, width: 100, center: true),
            ButtonT.IconText(
              icon: Icons.check_box, text: "선택",
              onTap: () async {
                if(onTap != null) await onTap();
              }
            ),
          ]
      ),
    );
    return w;
  }

  static dynamic tableUIMain(BuildContext context, Contract ct, Customer cs, {
    int? index,
    Function? onTap,
    Function? setState,
    Function? refresh,
  }) {
    var w = InkWell(
        onTap: () async {
          /// 윈도우로 변경
          await UIState.OpenNewWindow(context, WindowCT(org_ct: ct,));
        },
        child: Container( height: 36 + 6,
          child: Row(
              children: [
                ExcelT.LitGrid(text: '${index ?? '-'}', width: 32, center: true),
                TextT.OnTap(
                  text: cs.businessName,
                  width: 250,
                  onTap: () async {
                    UIState.OpenNewWindow(context, WindowCS(org_cs: cs,));
                    if(setState != null) setState();
                  }
                ),
                ExcelT.LitGrid(text: ct.ctName, width: 250, center: true, bold: true),
                ExcelT.LitGrid(text: ct.manager, width: 150, center: true),
                ExcelT.LitGrid(text: ct.managerPhoneNumber, width: 150, center: true, expand: true),
                ButtonT.Icont(
                  icon: Icons.delete,
                  onTap: () async {
                    var alt = await DialogT.showAlertDl(context, text: '"${ct.ctName}" 계약을 데이터베이스에서 삭제하시겠습니까?');
                    if(!alt) { return; }

                    await DatabaseM.deleteContract(ct);
                    if(setState != null) setState();
                    if(refresh != null) refresh();
                  }
                ),
              ]
          ),
        ));
    return w;
  }
}