import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/database/process.dart';
import 'package:evers/class/system/records.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/slider.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/json.dart';
import 'package:evers/page/window/window_process_create.dart';
import 'package:evers/page/window/window_ts_editor.dart';
import 'package:flutter/material.dart';

import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/style.dart';
import '../../page/window/window_cs.dart';
import '../../ui/ux.dart';
import '../Customer.dart';
import '../contract.dart';
import '../database/item.dart';
import '../system.dart';
import '../system/state.dart';
import '../transaction.dart';
import '../widget/button.dart';
import '../widget/list.dart';
import '../widget/text.dart';

class CompProcess {
  static Widget tableHeader() {
    return WidgetUI.titleRowNone(['순번', '거래처', '품목명', '가공공정', '상태', '작업 진행도', "수량", '가공일', ''],
        [ 28, 999, 999, 100, 50, 80 * 3, 80, 150, 150], background: true, lite: true);
  }

  static Widget tableHeaderOutputCreate() {
    return WidgetUI.titleRowNone([ '공정완료일', '완성된 품목 수량', '가공완료품목', '사용된 작업물 수량', '현재 남은 작업물 수량' ],
        [ 150, 100, 250, 100, 250 ], lite: true, background: true);
  }


  static Widget tableHeaderOutput() {
    return WidgetUI.titleRowNone(['순번', '품목명', '가공공정', '상태', '가공가능수량'],
        [ 28, 200, 100, 100, 200], background: true, lite: true);
  }




  static Widget tableUI(
      BuildContext context,
      ProcessItem process,
      double usedAmount, {
        Customer? cs, Function? onTap, Function? setState,
        Function? refresh,
  }) {
    Item? item = SystemT.getItem(process.itUid);
    if(item == null) return const SizedBox();
    /// 현재 프로세스 공정이 아웃풋일 경우 - 아웃풋 전용 함수 이용
    if(process.isOutput) return const SizedBox();
    if(refresh == null) return const SizedBox();

    /// 현재 작업 공정이 재고추가 완료가 아닐경우 실행
    /// 기초 품목 가공 공정입니다.
    var amountM = process.amount - ((usedAmount == null) ? 0 : usedAmount!.abs());
    var w = InkWell(
      onTap: () async {
        if(onTap != null) onTap();
      },
      child: Container(
        height: 28,
        child: Row(
          children: [
            ExcelT.LitGrid(text: "-", width: 28),
            TextT.OnTap(
              context: context,
              text: cs == null ? 'NUll' : cs.businessName,
              width: 200,
              expand: true,
              onTap: () async {
                if(context == null || cs == null) return;
                if(UIState.current == UIType.dialog_customer) { WidgetT.showSnackBar(context, text: 'UI Error (Screen duplicate prevention error)'); return; }

                UIState.OpenNewWindow(context, WindowCS(org_cs: cs));
              },
            ),
            ExcelT.LitGrid(text: item.name, width: 200, center: true, expand: true),
            ExcelT.LitGrid(text: MetaT.processType[process.type] ?? 'NULL', width: 100, center: true),
            ExcelT.LitGrid(text: amountM <= 0 ? "완료" : process.isDone ? "완료" : '가공중', width: 50, center: true),

            SliderT.Lit(context, value: usedAmount, min: 0, max: process.amount,
              width: 80 * 3,
            ),

            ExcelT.LitGrid(text: "${StyleT.krwInt(((usedAmount == null) ? 0 : usedAmount!.abs()).toInt()) + item.unit} / ${ StyleT.krwInt(process.amount.toInt()) + item.unit }", width: 80, center: true),
            ExcelT.LitGrid(text: DateStyle.dateYearMonthDayHipen(process.date), width: 150, center: true),

            ButtonT.IconText(
              text: "수정",
              color: Colors.transparent,
              onTap: () async {
                if(context == null) return;

                WidgetT.loadingBottomSheet(context);
                await process.update();
                Navigator.pop(context);

                if(setState != null) setState();
              },
              icon: Icons.create,
            ),
            !process.isDone ? ButtonT.IconText(
              icon: Icons.done,
              text: "작업 완료하기",
              color: Colors.transparent,
              onTap: () async {
                if(context == null) return;
                /// 현재 작업은 완료로 변경
                /// 작업 완료 물품을 추가
                /// 작업완료 물품 입력폼을 추가후 해당목록을 업데이트할떄 모든 문서에대한 트랜잭션을 구현
                /// 추후 직접 입력으로 변경

                /// 작업완료대상의 품목정보 재구성 - 가공완료수량 리밋 수정
                var parentProcess = ProcessItem.fromDatabase(JsonManager.toJsonObject(process));
                UIState.OpenNewWindow(context, WindowProcessOutputCreate(process: parentProcess, refresh: refresh));
              },
            )
                : ButtonT.IconText(
              icon: Icons.check_box,
              text: "완료된    작업",
              color: Colors.transparent,
              onTap: () async {},
            )
          ],
        ),
      ),
    );

    return w;
  }






  static Widget tableUIInput(
      BuildContext context,
      ProcessItem process,
      ProcessItem parentProcess, {
        Customer? cs, Function? onTap,
        Function? setState,
      }) {

    if(setState == null) return const SizedBox();

    var w = Container(
      padding: EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        children: [
          ExcelT.LitInput(context, 'process.date',
            width: 150,
            onEdited: (i, data) {
              var date = DateTime.tryParse(data.toString()) ?? DateTime.now();
              process.date = date.microsecondsSinceEpoch;
            },
            setState: setState,
            text: DateStyle.dateYearMD(process.date),
            value: DateStyle.dateYearMD(process.date),
          ),
          InputWidget.DropButtonT<dynamic>(
            labelText: (value) { return value; },
            dropMenuMaps: MetaT.processType,
            width: 250,
            setState: setState,
            onEditeKey: (i, data) {
              process.type = data;
            },
            text: MetaT.processType[process.type] == null ?
            '선택안됨' : MetaT.processType[process.type].toString(),
          ),
          ExcelT.LitInput(context, 'process.amount', width: 250,
            onEdited: (i, data) {
              process.amount = double.tryParse(data) ?? 0;

              /// 현재 공정 입력수량이 부모의 수량을 초과한 경우 부모 수량으로 고정
              if(process.amount > parentProcess.amount) {
                process.amount = parentProcess.amount;
              }
            },
            setState: setState,
            text: process.amount.toString(), value: process.amount.toString(),
          ),
          ExcelT.LitGrid(text: StyleT.krwInt(parentProcess.amount.toInt()), width: 250, center: true),
        ],
      ),
    );

    return w;
  }





  /// 이 함수는 출력할 데이터가 재고품목을 신규추가하는 위젯을 반환합니다.
  /// Params
  ///   ProcessItem process: 신규추가되는 재고품목의 부모 가공기록입니다. 해당 가공기록정보에서 파생되는 가공완료와 재고정보를 위한 데이터입니다.
  ///   ProcessItem inputProcess: 데이터베이스에 저장된 신규 가공완료기록 입니다.
  static Widget tableUIOutputCreate(
      BuildContext context,
      ProcessItem inputProcess,
      ProcessItem process, {
        required double usedLimitAmount,
        Customer? cs,
        Function? setState,
        Function? refresh,
      }) {

    Item? item = SystemT.getItem(process.itUid);
    if(item == null) return SizedBox();
    if(setState == null) return const SizedBox();
    if(refresh == null) return const SizedBox();

    Item? inputItem = SystemT.getItem(inputProcess.itUid);

    var itemNameList = [];
    SystemT.itemMaps.values.forEach((e) {
      itemNameList.add(e.name);
    });

    var w = Container(
      padding: EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        children: [
          ExcelT.LitInput(context, 'out.process.date',
            width: 150,
            onEdited: (i, data) {
              var date = DateTime.tryParse(data.toString()) ?? DateTime.now();
              inputProcess.date = date.microsecondsSinceEpoch;
            },
            setState: setState,
            text: DateStyle.dateYearMD(inputProcess.date),
            value: DateStyle.dateYearMD(inputProcess.date),
          ),
          ExcelT.LitInput(context, 'out.process.out.amount', width: 100,
            onEdited: (i, data) {
              inputProcess.amount = double.tryParse(data) ?? 0;
            },
            setState: setState,
            text: StyleT.krwInt(inputProcess.amount.toInt()), value: inputProcess.amount.toString(),
          ),

          /// 품목선택 드롭다운 메뉴
          InputWidget.DropButtonT<Item>(
            width: 250,
            labelText: (item) { return item.name; },
            dropMenuMaps: SystemT.itemMaps,
            setState: setState,
            onEditeValue: (i, value) {
              inputProcess.itUid = value.id;
            },
            text: inputItem == null ? '선택안됨': inputItem!.name
          ),

          ExcelT.LitInput(context, 'process.use.amount', width: 100,
            onEdited: (i, data) {
              var usedAmount = double.tryParse(data) ?? 0;

              if(usedAmount.abs() > usedLimitAmount) usedAmount = usedLimitAmount;

              process.amount = usedLimitAmount - usedAmount;
              inputProcess.usedAmount = usedAmount;
            },
            setState: setState,
            text: StyleT.krwInt(inputProcess.usedAmount.toInt()), value: inputProcess.usedAmount.toString(),
          ),
          ExcelT.LitGrid(text: StyleT.krwInt(process.amount.toInt()), width: 250, center: true),
        ],
      ),
    );
    return w;
  }






  /// 이 함수는 출력할 데이터가 재고품목일 경우 표시되는 위젯을 반환합니다.
  static Widget tableUIOutput(
      BuildContext context,
      ProcessItem process,
      ItemTS itemTs,
      double usedAmount, {
        Customer? cs,
        Function? setState,
        Function? refresh,
      }) {

    Item? item = SystemT.getItem(process.itUid);
    if(item == null) return SizedBox();
    if(setState == null) return const SizedBox();
    if(refresh == null) return const SizedBox();
    if(!process.isOutput) return const SizedBox();

    /// 현재 프로세스 공정이 아웃풋일 경우만 위젯 반환
    var w = InkWell(
      onTap: () async {
        var inputProcess = ProcessItem.fromItemTS(itemTs);
        inputProcess.amount = (process.amount - usedAmount);
        inputProcess.itUid = process.itUid;
        UIState.OpenNewWindow(context, WindowProcessCreate(process: inputProcess, refresh: refresh));
      },
      child: Container(
        height: 28,
        child: Row(
          children: [
            ExcelT.LitGrid(text: "-", width: 28),
            ExcelT.LitGrid(text: item == null ? 'NULL' : item.name, width: 200, center: true),
            ExcelT.LitGrid(text: MetaT.processType[process.type] ?? 'NULL', width: 100, center: true),
            ExcelT.LitGrid(text: '가공가능', width: 100, center: true),
            ExcelT.LitGrid(text: StyleT.krwInt((process.amount).toInt()), width: 200, center: true),
            ExcelT.LitGrid(text: DateStyle.dateYearMonthDayHipen(process.date), width: 150, center: true),
            ButtonT.IconText(
              text: "수정",
              color: Colors.transparent,
              onTap: () async {
                if(context == null) return;

                WidgetT.showSnackBar(context, text: '개발중');

                if(setState != null) setState();
              },
              icon: Icons.create,
            ),
          ],
        ),
      ),
    );
    return w;
  }


  /// 이 함수는 미지급 테이블 UI 헤더 위젯을 반환합니다.
  static dynamic tableHeaderPaymentPU() {
    return WidgetUI.titleRowNone([ '순번', '거래처', '총 매입금', '총 지급금', '미 지급금', ],
      [ 32, 999, 200, 200, 200, 0, 0, ],);
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

              ButtonT.Icont(
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