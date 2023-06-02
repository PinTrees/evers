import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/textInput.dart';
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
import '../../ui/ux.dart';
import '../Customer.dart';
import '../contract.dart';
import '../database/item.dart';
import '../revenue.dart';
import '../system.dart';
import '../system/state.dart';
import '../transaction.dart';
import '../widget/button.dart';
import '../widget/list.dart';
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

  /// 이 함수는 검색창의 매출 테이블 상단 위젯을 반환합니다.
  static dynamic tableHeaderInputCt() {
    return WidgetUI.titleRowNone(['순번', '매출일자', '품목', '단위', '수량', '단가', '공급가액', '부가세', '합계',],
        [ 32, 100, 999, 50, 80, 80, 80, 80, 80,], background: true,lite: true);
  }


  static dynamic tableUI(BuildContext context, Revenue re, {
    Contract? ct,
    int? index,
    Customer? cs,
    Function? onTap,
    Function? setState,
    Function? refresh,
  }) {
    if(refresh == null) return SizedBox();
    var item = SystemT.getItem(re.item);

    var w = Container(
      height: 28,
      child: Row(
        children: [
          ExcelT.LitGrid(text: '${index ?? 0 + 1}', width: 28, center: true),
          ExcelT.LitGrid(width: 100, text: StyleT.dateInputFormatAtEpoch(re.revenueAt.toString()), center: true),
          ExcelT.Grid(width: 250, text: item == null ? re.item : item.name, expand: true, textSize: 10),
          ExcelT.LitGrid(text: item == null ? '-' : item.unit, width: 50, center: true),
          ExcelT.LitGrid(text: StyleT.krwInt(re.count), width: 80, center: true),
          ExcelT.LitGrid(text: StyleT.krwInt(re.unitPrice), width: 80, center: true),
          ExcelT.LitGrid(text: StyleT.krwInt(re.supplyPrice), width: 80, center: true),
          ExcelT.LitGrid(text: StyleT.krwInt(re.vat), width: 80, center: true),
          ExcelT.LitGrid(text: StyleT.krwInt(re.totalPrice), width: 80, center: true),
          ExcelT.LitGrid(text: re.memo, width: 200, center: true, expand: true),
          InkWell(
            onTap: () async {
              UIState.OpenNewWindow(context, WindowReEditor(re: re, refresh: refresh));
            },
            child: WidgetT.iconMini(Icons.create, size: 32),
          )
        ],
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
        UIState.OpenNewWindow(context, WindowReEditor(re: re, refresh: refresh));
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
              ButtonT.Icont(
                icon: Icons.create,
                onTap: () {
                  UIState.OpenNewWindow(context, WindowReEditor(re: re, refresh: refresh));
                }
              ),
              ButtonT.Icont(
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







  /// 이 함수는 매출목록 메인화면의 테이블 UI를 반환합니다.
  /// reaquied params
  ///   - Customer cs
  ///
  static dynamic tableUISelect(BuildContext context, Revenue re, {
    int? index,
    Contract? ct,
    Customer? cs,
    required Function onTap,
    required Function setState,
    Function? refresh,
  }) {
    if(refresh == null) return SizedBox();
    if(cs == null) return SizedBox();

    var item = SystemT.getItem(re.item);

    var w = InkWell(
      onTap: () async {
        await onTap();
      },
      child: Container(
        height: 28,
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
            ]
        ),
      ),
    );
    return w;
  }








  /// 이 함수는 신규매출을 추가하기위한 테이블 위젯입니다.
  /// 매출추가 화면의 위젯은 반드시 이 함수를 위젯을 생성해야 합니다.
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
        SizedBox(height: 6,),
        Row(
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
              ExcelT.LitInput(context, "${index}::item::input",
                setState: setState, index: index, width: 200, expand: true,
                onEdited: (i, data) { re.item = data;  },
                text: item == null ? re.item : item.name == '' ? re.item : item.name,
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
        SizedBox(height: 6,),
        InputWidget.LitText(context, "$index::메모",
          label: "메모", expand: true,
          setState: setState, index: index,
          onEdited: (i, data) { re.memo  = data ?? ''; },
          text: re.memo,
        ),
        SizedBox(height: 6,),
        ListBoxT.Rows(
          spacing: 6,
            children: [
              ButtonT.IconText(
                icon: Icons.add_box,
                text: "품목 직접 선택",
                onTap: () async {
                  Item? tmp  = await DialogT.selectItem(context);
                  if(tmp != null) re.item = tmp.id;
                  setState();
                },
              ),
              ButtonT.IconText(
                  icon: Icons.delete,
                  text: "매출 제거",
                  onTap: () {
                    re.state = "DEL";
                    setState();
                  }
              ),
            ]
        ),
      ],
    );
    return w;
  }






  static dynamic tableUIInputWithCt( BuildContext? context, Revenue re, {
    int? index,
    Function? onTap,
    Function? setState,
  }) {
    if(context == null) return Container();
    if(setState == null) return Container();

    var item = SystemT.getItem(re.item);

    var w = ListBoxT.Columns(
      spacingStartEnd: 6,
      children: [
        Row(
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
              ExcelT.LitInput(context, "$index::re.item", width: 80, index: index,
                setState: setState, expand: true,
                onEdited: (i, data) { re.item = data; },
                text: item == null ? re.item : item.name,
                value: item == null ? re.item : item.id,
              ),
              ButtonT.IconText(
                icon: Icons.search, text: "품목검색",
                onTap: () async {
                  Item? tmp  = await DialogT.selectItem(context);
                  if(tmp != null) re.item = tmp.id;
                  setState();
                },
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
        Row(
            children: [
              TextT.Lit(text: "메모", width: 100),
              ExcelT.LitInput(context, "$index::메모", width: 200, index: index,
                setState: setState, expand: true, textSize: 10,
                onEdited: (i, data) { re.memo  = data ?? ''; },
                text: re.memo,
              ),
            ]
        ),
        Row(
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

    var w = ListBoxT.Columns(
      spacingStartEnd: 6,
      children: [
        Row(
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
        Row(
            children: [
              ExcelT.Grid(text: "메모", width: 80, ),
              ExcelT.LitInput(context, "$index::메모", width: 200, index: index,
                setState: setState, expand: true, textSize: 10,
                onEdited: (i, data) { re.memo  = data ?? ''; },
                text: re.memo,
              ),
            ]
        ),
      ],
    );
    return w;
  }
}