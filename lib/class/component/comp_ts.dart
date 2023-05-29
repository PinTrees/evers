import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/system/records.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/page/window/window_ts_editor.dart';
import 'package:flutter/material.dart';

import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/style.dart';
import '../../page/window/window_cs.dart';
import '../../ui/ux.dart';
import '../Customer.dart';
import '../contract.dart';
import '../system.dart';
import '../system/state.dart';
import '../transaction.dart';
import '../widget/button.dart';
import '../widget/list.dart';
import '../widget/text.dart';

class CompTS {
  static dynamic tableHeader() {
    return WidgetUI.titleRowNone([ '순번', '거래번호', '거래일자', '거래처', '적요', '수입', '지출', '계좌', '', ],
        [ 32, 80, 80, 150, 999, 80, 80, 100, 32, ], background: true, lite: true);
  }


  static dynamic tableHeaderEditor() {
    return WidgetUI.titleRowNone([ '순번', '거래일자', '수입/지출', '적요', '금액', '계좌', '', ],
        [ 32, 150, 100, 999, 100, 150, 32, ], background: true, lite: true);
  }



  /// 이 함수는 미지급 테이블 UI 헤더 위젯을 반환합니다.
  static dynamic tableHeaderPaymentPU() {
    return WidgetUI.titleRowNone([ '순번', '거래처', '총 매입금', '총 지급금', '미 지급금', ],
        [ 32, 999, 200, 200, 200, 0, 0, ],);
  }



  static dynamic tableUI(BuildContext context, TS ts, {
    Contract? ct,
    int? index,
    Customer? cs,
    Function? onTap,
    Function? setState,
    Function? refresh,
  }) {
    var w = InkWell(
      onTap: () async {
        if(onTap != null) await onTap();
        if(setState != null) await setState();
      },
      child: Container(
        height: 28,
        child: Row(
            children: [
              ExcelT.LitGrid(text: '${index ?? '-'}', width: 32, center: true),
              ExcelT.LitGrid(text: ts.id, width: 80, center: true),
              ExcelT.LitGrid(text: StyleT.dateFormatAtEpoch(ts.transactionAt.toString()), width: 80, center: true),
              TextT.OnTap(
                  text: cs == null ? '-' : cs.businessName == '' ? 'ㅡ' : cs.businessName,
                  width: 150,
                  enable: cs == null ? false : cs.businessName != '',
                  onTap: () async {
                    if(context == null) return;
                    if(cs == null) { return; }
                    if(cs.businessName == '') { return; }

                    UIState.OpenNewWindow(context, WindowCS(org_cs: cs,));
                    if(refresh != null) await refresh();
                  }
              ),
              ExcelT.Grid(textSize: 10, text: ts.summary, expand: true, width: 250),
              ExcelT.LitGrid(text: StyleT.krwInt(ts.amount), width: 80, center: true,
                  textColor: (ts.type == 'RE') ? Colors.blue.withOpacity(0.7) : Colors.transparent),
              ExcelT.LitGrid(text: StyleT.krwInt(ts.amount), width: 80, center: true,
                  textColor: (ts.type == 'PU') ? Colors.red.withOpacity(0.7) : Colors.transparent),
              ExcelT.LitGrid(text: SystemT.getAccountName(ts.account) ?? '-', width: 100, center: true),
              ExcelT.LitGrid(text: ts.memo, width: 100, center: true, expand: true),

              ButtonT.Icon(
                  icon: Icons.create,
                  onTap: () async {
                    if(refresh == null) { WidgetT.showSnackBar(context, text: 'refresh state is not nullable'); return; }

                    var cs = await DatabaseM.getCustomerDoc(ts.csUid);
                    UIState.OpenNewWindow(context, WindowTSEditor(ts: ts, cs: cs, refresh: refresh));
                  }
              ),
              ButtonT.Icon(
                  icon: Icons.delete,
                  onTap: () async {
                    if(context == null) return;

                    if(!await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?')){
                      WidgetT.showSnackBar(context, text: '삭제 취소됨');
                      return;
                    }
                    WidgetT.loadingBottomSheet(context, text: '삭제중');

                    var ret = await ts.delete();

                    Navigator.pop(context);

                    if(ret) WidgetT.showSnackBar(context, text: '삭제됨');
                    else WidgetT.showSnackBar(context, text: '삭제에 실패했습니다. 나중에 다시 시도해 주세요.');

                    if(refresh != null) await refresh();
                  }
              ),
            ]
        ),
      ),
    );
    return w;
  }


  static dynamic tableUIMain(TS ts, {
    BuildContext? context,
    int? index,
    Customer? cs,
    Function? onTap,
    Function? setState,
    Function? refresh,
  }) {
    var w = InkWell(
      onTap: () async {
        if(context == null) { return; }
        if(refresh == null) { WidgetT.showSnackBar(context, text: 'refresh state is not nullable'); return; }

        var cs = await DatabaseM.getCustomerDoc(ts.csUid);
        UIState.OpenNewWindow(context, WindowTSEditor(ts: ts, cs: cs, refresh: refresh));
      },
      child: Container(
        height: 36 + 6,
        child: Row(
            children: [
              ExcelT.LitGrid(text: '${index ?? '-'}', width: 32, center: true),
              ExcelT.LitGrid(text: ts.id, width: 80, center: true),
              ExcelT.LitGrid(text: StyleT.dateFormatAtEpoch(ts.transactionAt.toString()), width: 80, center: true),
              TextT.OnTap(
                  text: cs == null ? '-' : cs.businessName == '' ? 'ㅡ' : cs.businessName,
                  width: 150,
                  enable: cs == null ? false : cs.businessName != '',
                  onTap: () async {
                    if(context == null) return;
                    if(cs == null) { return; }
                    if(cs.businessName == '') { return; }

                    UIState.OpenNewWindow(context, WindowCS(org_cs: cs));
                    if(setState != null) await setState();
                  }
              ),
              ExcelT.Grid(textSize: 10, text: ts.summary, expand: true, width: 250),
              ExcelT.LitGrid(text: StyleT.krwInt(ts.amount), width: 80, center: true,
                  textColor: (ts.type == 'RE') ? Colors.blue.withOpacity(0.7) : Colors.transparent),
              ExcelT.LitGrid(text: StyleT.krwInt(ts.amount), width: 80, center: true,
                  textColor: (ts.type == 'PU') ? Colors.red.withOpacity(0.7) : Colors.transparent),
              ExcelT.LitGrid(text: SystemT.getAccountName(ts.account) ?? '-', width: 100, center: true),
              ExcelT.LitGrid(text: ts.memo, width: 100, center: true, expand: true),

              ButtonT.Icon(
                  icon: Icons.delete,
                  onTap: () async {
                    if(context == null) return;

                    if(!await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?')){
                      WidgetT.showSnackBar(context, text: '삭제 취소됨');
                      return;
                    }
                    WidgetT.loadingBottomSheet(context, text: '삭제중');

                    var ret = await ts.delete();

                    Navigator.pop(context);

                    if(ret) WidgetT.showSnackBar(context, text: '삭제됨');
                    else WidgetT.showSnackBar(context, text: '삭제에 실패했습니다. 나중에 다시 시도해 주세요.');

                    if(setState != null) await setState();
                  }
              ),
            ]
        ),
      ),
    );
    return w;
  }


  static dynamic tableUIInput( BuildContext? context, TS ts, {
    int? index,
    Customer? cs,
    Function? onTap,
    Function? setState,
  }) {
    if(context == null) return Container();
    if(setState == null) return Container();

    var w = ListBoxT.Columns(
      spacingStartEnd: 6,
      children: [
        Row(
            children: [
              ExcelT.LitGrid(text: '${ index ?? '-'}', width: 28, center: true),
              ExcelT.LitInput(context, '$index::ts거래일자', width: 150, index: index,
                onEdited: (i, data) {
                  var date = DateTime.tryParse(data.toString().replaceAll('/','')) ?? DateTime.now();
                  ts.transactionAt = date.microsecondsSinceEpoch;
                },
                setState: setState,
                text: StyleT.dateInputFormatAtEpoch(ts.transactionAt.toString()),
              ),
              ExcelT.LitGrid(text: (ts.type != 'PU') ? '수입' : '지출', width: 100, center: true),
              SizedBox(
                height: 28, width: 28,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    focusColor: Colors.transparent,
                    focusNode: FocusNode(),
                    autofocus: false,
                    customButton: WidgetT.iconMini(Icons.arrow_drop_down_circle_sharp),
                    items: ['수입', '지출'].map((item) => DropdownMenuItem<dynamic>(
                      value: item,
                      child: Text(
                        item,
                        style: StyleT.titleStyle(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                    onChanged: (value) async {
                      if(value == '수입') ts.type = 'RE';
                      else if(value == '지출') ts.type = 'PU';
                      else ts.type = 'ETC';
                      setState();
                    },
                    itemHeight: 24,
                    itemPadding: const EdgeInsets.only(left: 16, right: 16),
                    dropdownWidth: 100 + 28,
                    dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
                    dropdownDecoration: BoxDecoration(
                      border: Border.all(
                        width: 1.7,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(0),
                      color: Colors.white.withOpacity(0.95),
                    ),
                    dropdownElevation: 0,
                    offset: const Offset(-128 + 28, 0),
                  ),
                ),
              ),
              ExcelT.LitInput(context, '$index::ts적요', width: 250, index: index,
                onEdited: (i, data) { ts.summary = data; }, text: ts.summary,
                setState: setState, expand: true,
              ),
              ExcelT.LitGrid(text: (SystemT.accounts[ts.account] != null) ? SystemT.accounts[ts.account]!.name : 'NULL', width: 180, center: true),
              SizedBox(
                height: 28, width: 28,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    focusColor: Colors.transparent,
                    focusNode: FocusNode(),
                    autofocus: false,
                    customButton: WidgetT.iconMini(Icons.arrow_drop_down_circle_sharp),
                    items: SystemT.accounts.keys.map((item) => DropdownMenuItem<dynamic>(
                      value: item,
                      child: Text(
                        (SystemT.accounts[item] != null) ? SystemT.accounts[item]!.name : 'NULL',
                        style: StyleT.titleStyle(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                    onChanged: (value) async {
                      ts.account = value;
                      setState();
                    },
                    itemHeight: 24,
                    itemPadding: const EdgeInsets.only(left: 16, right: 16),
                    dropdownWidth: 180 + 28,
                    dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
                    dropdownDecoration: BoxDecoration(
                      border: Border.all(
                        width: 1.7,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(0),
                      color: Colors.white.withOpacity(0.95),
                    ),
                    dropdownElevation: 0,
                    offset: const Offset(-208 + 28, 0),
                  ),
                ),
              ),
              ExcelT.LitInput(context, '$index::ts금액', width: 120, index: index,
                onEdited: (i, data) {  ts.amount = int.tryParse(data) ?? 0; },
                setState: setState,
                text: StyleT.krwInt(ts.amount), value: ts.amount.toString(),),
              ButtonT.Icon(
                icon: Icons.cancel,
                onTap: () async {
                  ts.type = 'DEL';
                  setState();
                },
              ),
            ]
        ),
        Row(
          children: [
            TextT.Lit(text: "메모", width: 100),
            ExcelT.LitInput(context, '$index::ts메모', width: 250, index: index,
              setState: setState, expand: true,
              onEdited: (i, data) { ts.memo = data;}, text: ts.memo,  ),
          ],
        )
      ],
    );
    return w;
  }


  static dynamic tableUIEditor( BuildContext? context, TS ts, {
    int? index,
    Customer? cs,
    Function? onTap,
    Function? setState,
    Function? refresh,
  }) {
    if(context == null) return Container();
    if(setState == null) return Container();

    var w = ListBoxT.Columns(
      spacingStartEnd: 6,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
            children: [
              ExcelT.LitGrid(text: '${ index ?? '-'}', width: 28, center: true),
              ExcelT.LitInput(context, '$index::ts.editor.거래일자', width: 150, index: index,
                onEdited: (i, data) {
                  var date = DateTime.tryParse(data.toString().replaceAll('/','')) ?? DateTime.now();
                  ts.transactionAt = date.microsecondsSinceEpoch;
                },
                setState: setState,
                text: StyleT.dateInputFormatAtEpoch(ts.transactionAt.toString()),
              ),
              ExcelT.LitGrid(text: (ts.type != 'PU') ? '수입' : '지출', width: 100, center: true),
              SizedBox(
                height: 28, width: 28,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    focusColor: Colors.transparent,
                    focusNode: FocusNode(),
                    autofocus: false,
                    customButton: WidgetT.iconMini(Icons.arrow_drop_down_circle_sharp),
                    items: ['수입', '지출'].map((item) => DropdownMenuItem<dynamic>(
                      value: item,
                      child: Text(
                        item,
                        style: StyleT.titleStyle(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                    onChanged: (value) async {
                      if(value == '수입') ts.type = 'RE';
                      else if(value == '지출') ts.type = 'PU';
                      else ts.type = 'ETC';
                      setState();
                    },
                    itemHeight: 24,
                    itemPadding: const EdgeInsets.only(left: 16, right: 16),
                    dropdownWidth: 100 + 28,
                    dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
                    dropdownDecoration: BoxDecoration(
                      border: Border.all(
                        width: 1.7,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(0),
                      color: Colors.white.withOpacity(0.95),
                    ),
                    dropdownElevation: 0,
                    offset: const Offset(-128 + 28, 0),
                  ),
                ),
              ),
              ExcelT.LitInput(context, '$index::ts.editor.적요', width: 250, index: index,
                onEdited: (i, data) { ts.summary = data; }, text: ts.summary, expand: true,
                setState: setState,
              ),
              ExcelT.LitInput(context, '$index::ts.editor.금액', width: 150, index: index,
                onEdited: (i, data) {  ts.amount = int.tryParse(data) ?? 0; },
                setState: setState,
                text: StyleT.krwInt(ts.amount), value: ts.amount.toString(),),
              ExcelT.LitGrid(text: (SystemT.accounts[ts.account] != null) ? SystemT.accounts[ts.account]!.name : 'NULL', width: 150, center: true),
              SizedBox(
                height: 28, width: 28,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    focusColor: Colors.transparent,
                    focusNode: FocusNode(),
                    autofocus: false,
                    customButton: WidgetT.iconMini(Icons.arrow_drop_down_circle_sharp),
                    items: SystemT.accounts.keys.map((item) => DropdownMenuItem<dynamic>(
                      value: item,
                      child: Text(
                        (SystemT.accounts[item] != null) ? SystemT.accounts[item]!.name : 'NULL',
                        style: StyleT.titleStyle(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                    onChanged: (value) async {
                      ts.account = value;
                      setState();
                    },
                    itemHeight: 24,
                    itemPadding: const EdgeInsets.only(left: 16, right: 16),
                    dropdownWidth: 180 + 28,
                    dropdownPadding: const EdgeInsets.symmetric(vertical: 6),
                    dropdownDecoration: BoxDecoration(
                      border: Border.all(
                        width: 1.7,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(0),
                      color: Colors.white.withOpacity(0.95),
                    ),
                    dropdownElevation: 0,
                    offset: const Offset(-208 + 28, 0),
                  ),
                ),
              ),
            ]
        ),
        Row(
            children: [
              TextT.Lit(text: "메모", size: 12, bold: true, width: 80),
              ExcelT.LitInput(context, '$index::ts.editor.메모', width: 250, index: index,
                setState: setState, expand: true, alignment: Alignment.centerLeft, textSize: 10,
                onEdited: (i, data) { ts.memo = data;}, text: ts.memo,  ),
            ]
        ),
      ],
    );
    return w;
  }



  /// 미지급 테이블 위젯을 반환합니다.
  /// regued
  ///   Customer는 NULL일 수 없습니다.
  static dynamic tableUIPaymentPU(BuildContext context, Records<int, int> amount, {
    int? index,
    Customer? cs,
    Function? onTap,
    Function? setState,
    Function? refresh,
  }) {
    if(cs == null) return SizedBox();

    var w = InkWell(
        onTap: () async {
          UIState.OpenNewWindow(context, WindowCS(org_cs: cs));
        },
        child: Container(
          height: 36,
          child: Row(
              children: [
                ExcelT.LitGrid(text: "${index ?? '-'}", width: 32, center: true),
                TextT.OnTap(
                  text: cs.businessName,
                  width: 250, expand: true,
                  onTap: () {
                    UIState.OpenNewWindow(context, WindowCS(org_cs: cs,));
                  }
                ),
                ExcelT.Grid(text: StyleT.krwInt(amount.Item1), width: 200, ),
                ExcelT.Grid(text: StyleT.krwInt(amount.Item2), width: 200, ),
                ExcelT.Grid(text: StyleT.krwInt(amount.Item1 - amount.Item2), width: 200,),
              ]
          ),
        )
    );
    return w;
  }

}