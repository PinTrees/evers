import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/page/window/window_re_editor.dart';
import 'package:evers/page/window/window_ts_editor.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';

import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/style.dart';
import '../../page/window/window_cs.dart';
import '../../page/window/window_ct.dart';
import '../../ui/cs.dart';
import '../../ui/dialog_item.dart';
import '../../ui/dialog_revenue.dart';
import '../../ui/ux.dart';
import '../Customer.dart';
import '../contract.dart';
import '../database/item.dart';
import '../revenue.dart';
import '../system.dart';
import '../system/state.dart';
import '../transaction.dart';
import '../widget/button.dart';
import '../widget/text.dart';

class CompRE {
  static dynamic tableHeaderEdite() {
    return WidgetUI.titleRowNone([ '순번', '매출일자', '품목', "", '단위', '수량', '단가', '공급가액', '부가세', '합계' ],
        [ 32, 100, 999, 80, 50, 80, 80, 80, 80, 80,], background: true, lite: true);
  }

  /// 이 함수는 검색창의 매출 테이블 상단 위젯을 반환합니다.
  static dynamic tableHeaderSearch() {
    return WidgetUI.titleRowNone(['순번', '거래처', '매출일자', '품목', '단위', '수량', '단가', '공급가액', '부가세', '합계',],
        [ 32, 200, 100, 999, 50, 80, 80, 80, 80, 80,], background: true,lite: true);
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

                    /// 윈도우로 변경
                    await DialogCS.showCustomerDialog(context, org: cs);
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
                    var parent = UIState.mdiController!.createWindow(context, ph: 720);
                    var page = WindowTSEditor(ts: ts, cs: cs, refresh: refresh, parent: parent,);
                    UIState.mdiController!.addWindow(context, widget: page, resizableWindow: parent);
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



  /// 이 함수는 매출목록 메인화면의 테이블 UI를 반환합니다.
  /// reaquied params
  ///   - Customer cs
  ///
  static dynamic tableUIMain(BuildContext context, Revenue re, {
    int? index,
    Contract? ct,
    Customer? cs,
    Function? onTap,
    Function? setState,
    Function? refresh,
  }) {
    if(setState == null) return SizedBox();
    if(refresh == null) return SizedBox();
    if(cs == null) return SizedBox();

    var item = SystemT.getItem(re.item);

    var w = InkWell(
      onTap: () async {
        //UIState.OpenNewWindow(context, WindowCT(org_ct: ct!));
      },
      child: Container(
        height: 36 + 6,
        decoration: StyleT.inkStyleNone(color: Colors.transparent),
        child: Row(
            children: [
              ExcelT.LitGrid(text: "${ index ?? '-'}", width: 32, center: true),
              ExcelT.LitGrid(text: re.id, width: 80, center: true),
              ExcelT.LitGrid(text: StyleT.dateFormatAtEpoch(re.revenueAt.toString()), width: 80, center: true),
              ExcelT.LitGrid(text: "매출", width: 50, center: true, textColor: Colors.blueAccent.withOpacity(0.5)),
              TextT.OnTap(
                  width: 150, expand: true,
                  text: '${ cs.businessName } / ${ ct == null ? '-' : ct.ctName }',
                  onTap: () async {
                    UIState.OpenNewWindow(context, WindowCT(org_ct: ct!));
                  }
              ),
              ExcelT.Grid(textSize: 10, text: item == null ? re.item : item.name, width: 100,  expand: true, ),
              ExcelT.LitGrid(text: item == null ? '-' : item.unit, width: 50, center: true),
              ExcelT.LitGrid(text: StyleT.krw(re.count.toString()), width: 50, center: true),
              ExcelT.LitGrid(text: StyleT.krw(re.unitPrice.toString()), width: 80, center: true),
              ExcelT.LitGrid(text: StyleT.krw(re.supplyPrice.toString()), width: 80, center: true),
              ExcelT.LitGrid(text: StyleT.krw(re.vat.toString()), width: 80, center: true),
              ExcelT.LitGrid(text: StyleT.krw(re.totalPrice.toString()), width: 80, center: true),
              SizedBox(height: 28,width: 32,),
              ButtonT.Icon(
                icon: Icons.create,
                onTap: () {
                  UIState.OpenNewWindow(context, WindowReEditor(re: re, refresh: refresh));
                }
              ),
              ButtonT.Icon(
                  icon: Icons.delete,
                  onTap: () async {
                    var alt = await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?');
                    if(!alt) { WidgetT.showSnackBar(context, text: '취소됨'); return; }
                    var task = await re.delete();
                    if(!task) {
                      WidgetT.showSnackBar(context, text: '삭제에 실패했습니다. 나중에 다시 시도하세요.');
                      return;
                    }
                    WidgetT.showSnackBar(context, text: '삭제됨');
                    refresh();
                  }
              ),
            ]
        ),
      ),
    );
    return w;
  }



  static dynamic tableUIInput( BuildContext? context, Revenue re, {
    int? index,
    Customer? cs,
    Contract? ct,
    Function? onTap,
    Function? setState,
  }) {
    if(context == null) return Container();
    if(setState == null) return Container();

    var item = SystemT.getItem(re.item);

    var w = Column(
      children: [
        Container(
          height: 28,
          decoration: StyleT.inkStyleNone(color: Colors.transparent),
          child: Row(
              children: [
                ExcelT.LitGrid(text: "${index ?? '-'}" ,width: 32),
                ButtonT.Text(
                  width: 200, color: Colors.transparent,
                  onTap: () async {
                    Contract? tmp  = await DialogT.selectCt(context);
                    if(tmp == null) return;
                    if(ct != null) ct.fromJson(tmp.toJson());
                    setState();
                  },
                  text: ct == null ? '-' : (ct.csName + ' / ' + ct.ctName),
                ),
                ExcelT.LitInput(context, "$index::매출일자", width: 100, index: index,
                  setState: setState, textSize: 10,
                  onEdited: (i, data) {
                    var date = DateTime.tryParse(data.toString().replaceAll("/", "")) ?? DateTime.now();
                    re.revenueAt = date.microsecondsSinceEpoch;
                  },
                  text: StyleT.dateInputFormatAtEpoch(re.revenueAt.toString()),
                ),
                ButtonT.Text(
                  width: 150, color: Colors.transparent, expand: true,
                  onTap: () async {
                    Item? tmp  = await DialogT.selectItem(context);
                    if(tmp != null) re.item = tmp.id;
                    setState();
                  },
                  text: item == null ? '품목선택' : item.name,
                ),
                ExcelT.LitGrid(text: item == null ? '-' : item.unit,width: 32),
                ExcelT.LitInput(context, "$index::re.count", width: 80, index: index,
                  setState: setState,
                  onEdited: (i, data) { re.count = int.tryParse(data) ?? 0; },
                  text: StyleT.krw(re.count.toString()), value: re.count.toString(),
                ),
                ExcelT.LitInput(context, "$index::re.unitPrice", width: 80, index: index,
                  setState: setState,
                    onEdited: (i, data) => re.unitPrice = int.tryParse(data) ?? 0,
                    text: StyleT.krw(re.unitPrice.toString()), value: re.unitPrice.toString()
                ),
                ExcelT.LitInput(context, "$index::re.supplyPrice", width: 80, index: index,
                    setState: setState,
                    onEdited: (i, data) {
                      re.supplyPrice = int.tryParse(data) ?? 0;
                      re.fixedSup = true;
                    }, text: StyleT.krw(re.supplyPrice.toString()), value: re.supplyPrice.toString()
                ),
                ExcelT.LitInput(context, "$index::re.vat", width: 80, index: index,
                    setState: setState,
                    onEdited: (i, data) {
                      re.vat = int.tryParse(data) ?? 0;
                      re.fixedVat = true;
                    }, text: StyleT.krw(re.vat.toString()), value: re.vat.toString()
                ),
                ExcelT.LitGrid(text: StyleT.krw(re.totalPrice.toString()),width: 80, center: true),
              ]
          ),
        ),
        Container(
          height: 28,
          decoration: StyleT.inkStyleNone(color: Colors.transparent),
          child: Row(
              children: [
                TextT.Lit(text: "메모", width: 100),
                ExcelT.LitInput(context, "$index::메모", width: 200, index: index,
                  setState: setState, expand: true, textSize: 10,
                  onEdited: (i, data) { re.memo  = data ?? ''; },
                  text: re.memo,
                ),
              ]
          ),
        ),
        SizedBox(height: 6,),
        Container(
          height: 28,
          decoration: StyleT.inkStyleNone(color: Colors.transparent),
          child: Row(
              children: [
                ButtonT.IconText(
                    icon: Icons.cancel,
                    text: "매출 제거",
                    onTap: () {
                      re.state = "DEL";
                      setState();
                    }
                ),
              ]
          ),
        ),
      ],
    );
    return w;
  }



  /// 이 함수는 이미 완성된 매출 데이터를 수정하는 위젝을 반환합니다.
  /// 매출데이터를 수정하기 위해서는 반드시 이 함수를 호출해야 합니다.
  static dynamic tableUIEditor( BuildContext? context, Revenue re, {
    int? index,
    Function? onTap,
    Function? setState,
  }) {
    if(context == null) return Container();
    if(setState == null) return Container();

    Item? item = SystemT.getItem(re.item);

    var w = Column(
      children: [
        Container(
          height: 28,
          decoration: StyleT.inkStyleNone(color: Colors.transparent),
          child: Row(
              children: [
                ExcelT.LitGrid(text: "${index ?? '-'}" ,width: 32),
                ExcelT.LitInput(context, "$index::매출일자", width: 100, index: index,
                  setState: setState, textSize: 10,
                  onEdited: (i, data) {
                    var date = DateTime.tryParse(data.toString().replaceAll("/", "")) ?? DateTime.now();
                    re.revenueAt = date.microsecondsSinceEpoch;
                  },
                  text: StyleT.dateInputFormatAtEpoch(re.revenueAt.toString()),
                ),
                ExcelT.LitInput(
                  context, "key::re.item.userInput",
                  expand: true,
                  text: item == null ? re.item : item.name,
                  index: index, width: 100,
                  onEdited: (i, data) async {
                    re.item = data;
                  },
                  setState: setState,
                ),
                ButtonT.IconText(
                  icon: Icons.search,
                  onTap: () async {
                    Item? selectItem = await DialogT.selectItem(context);
                    if(selectItem != null) {
                      re.item = selectItem.id;
                      print(re.item);
                      print(selectItem.name);
                    }
                    setState();
                  },
                  text: '품목선택',
                ),
                ExcelT.LitGrid(text: item == null ? '-' : item.unit,width: 50),
                ExcelT.LitInput(context, "$index::re.count", width: 80, index: index,
                  setState: setState,
                  onEdited: (i, data) { re.count = int.tryParse(data) ?? 0; },
                  text: StyleT.krw(re.count.toString()), value: re.count.toString(),
                ),
                ExcelT.LitInput(context, "$index::re.unitPrice", width: 80, index: index,
                    setState: setState,
                    onEdited: (i, data) => re.unitPrice = int.tryParse(data) ?? 0,
                    text: StyleT.krw(re.unitPrice.toString()), value: re.unitPrice.toString()
                ),
                ExcelT.LitInput(context, "$index::re.supplyPrice", width: 80, index: index,
                    setState: setState,
                    onEdited: (i, data) {
                      re.supplyPrice = int.tryParse(data) ?? 0;
                      re.fixedSup = true;
                    }, text: StyleT.krw(re.supplyPrice.toString()), value: re.supplyPrice.toString()
                ),
                ExcelT.LitInput(context, "$index::re.vat", width: 80, index: index,
                    setState: setState,
                    onEdited: (i, data) {
                      re.vat = int.tryParse(data) ?? 0;
                      re.fixedVat = true;
                    }, text: StyleT.krw(re.vat.toString()), value: re.vat.toString()
                ),
                ExcelT.LitGrid(text: StyleT.krw(re.totalPrice.toString()),width: 80, center: true),
              ]
          ),
        ),
        Container(
          height: 28,
          decoration: StyleT.inkStyleNone(color: Colors.transparent),
          child: Row(
              children: [
                ExcelT.Grid(text: "메모", width: 80, ),
                ExcelT.LitInput(context, "$index::메모", width: 200, index: index,
                  setState: setState, expand: true, textSize: 10,
                  onEdited: (i, data) { re.memo  = data ?? ''; },
                  text: re.memo,
                ),
              ]
          ),
        ),
      ],
    );
    return w;
  }
}