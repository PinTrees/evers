import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/interfaceUI.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:evers/page/window/window_ct.dart';
import 'package:evers/page/window/window_process_create.dart';
import 'package:evers/page/window/window_process_info.dart';
import 'package:flutter/material.dart';

import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/style.dart';
import '../../page/window/window_cs.dart';
import '../../ui/dialog_contract.dart';
import '../../ui/ux.dart';
import '../Customer.dart';
import '../contract.dart';
import '../database/item.dart';
import '../database/process.dart';
import '../system.dart';
import '../system/state.dart';

class CompItem {

  /// 이 함수는 검색창의 품목 테이불 상단 위젯을 반환합니다.
  static dynamic tableHeaderSearch() {
    return WidgetUI.titleRowNone([ '순번', "품목명", '타입', '분류', '단위', '단가', "원가", ""],
        [ 32, 999, 100, 50, 50, 80, 80, 80], background: true, lite: true);
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
  static dynamic tableUISearch(BuildContext context, Item item, {
    int? index,
    Function? onTap,
  }) {
    if(item == null) return SizedBox();
    if(item.id == '') return SizedBox();

    var w = Container( height: 28,
      decoration: StyleT.inkStyleNone(color: Colors.transparent),
      child: Row(
          children: [
            ExcelT.LitGrid(text: "${index ?? '-'}", width: 32, center: true),
            ExcelT.Grid(text: item.name, width: 200, expand: true),
            ExcelT.LitGrid(text: MetaT.itemType[item.group], width: 100, center: true),
            ExcelT.LitGrid(text: MetaT.itemType[item.type] ?? '-', width: 50, center: true),
            ExcelT.LitGrid(text: item.unit, width: 50, center: true),
            ExcelT.LitGrid(text: StyleT.krwInt(item.unitPrice), width: 80, center: true),
            ExcelT.LitGrid(text: StyleT.krwInt(item.cost), width: 80, center: true),
            ButtonT.IconText(
              icon: Icons.check_box, text: "선택",
              onTap: () async {
                if(onTap != null) await onTap();
              }
            )
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





class CompItemTS {
  static dynamic tableHeader() {
    return WidgetUI.titleRowNone(['매입일자', '품목', '단위', '수량', '단가', '메모', '저장위치', ],
        [ 150, 200, 50, 100, 100, 999, 200, 150, 200, 0],lite: true, background: true );
  }


  static dynamic tableUI(
      BuildContext context,
      ItemTS itemTs, {
        Function? setState,
        Function? refresh,
        Function? onTap,
  }) {
    Item? item = SystemT.getItem(itemTs.itemUid);
    if(item == null) return const SizedBox();
    if(item.id == '') return const SizedBox();
    if(setState == null) return const SizedBox();

    List<Widget> fileWidgetList = [];

    itemTs.filesMap.forEach((key, value) {
      var w = ButtonT.IconText(
          text: key, icon: Icons.cloud,
        onTap: () {
          PdfManager.OpenPdf(value, key);
        },
        leaging: ButtonT.Icont(
          icon: Icons.delete,
          onTap: () {
            Messege.toReturn(context, '개발중', false);
            setState();
          }
        )
      );
      fileWidgetList.add(w);
    });

    Widget fileWidget = Wrap( runSpacing: 6, spacing: 6,children: fileWidgetList,);

    var w = Column(
      children: [
        Container( height: 28,
          child: Row(
              children: [
                ExcelT.LitGrid(text: StyleT.dateInputFormatAtEpoch(itemTs.date.toString()), width: 150, center: true),
                ExcelT.LitGrid(text: SystemT.getItemName(itemTs.itemUid), width: 200, center: true),
                ExcelT.LitGrid(text: item.unit, width: 50),
                ExcelT.LitGrid(text: StyleT.krwDouble(itemTs.amount), width: 100, center: true),
                ExcelT.LitGrid(text: StyleT.krwInt(itemTs.unitPrice), width: 100, center: true),
                ExcelT.LitGrid(text: itemTs.memo, width: 200, expand: true, center: true),
                ExcelT.LitGrid(text: itemTs.storageLC, width: 200, expand: true),
              ]
          ),
        ),
        Container(
          height: 28 + 6,
          child: Row(
              children: [
                TextT.Lit(text: "첨부파일", width: 100, size: 12, color: StyleT.titleColor, bold: true),
                Expanded(
                    child: Container( padding: EdgeInsets.all(6), child: fileWidget),
                ),
              ]
          ),
        ),
      ],
    );
    return w;
  }



  static dynamic tableUIOutput(
      BuildContext context,
      ItemTS itemTs,
      double usedCount, {
        Function? setState,
        Function? refresh,
      }) {
    Item? item = SystemT.getItem(itemTs.itemUid);
    if(item == null) return const SizedBox();
    if(item.id == '') return const SizedBox();
    if(setState == null) return const SizedBox();
    if(refresh == null) return const SizedBox();

    var w = InkWell(
      onTap: () async {
        var process = ProcessItem.fromItemTS(itemTs);
        process.id = itemTs.id;
        process.amount = (itemTs.amount - usedCount);
        process.itUid = itemTs.itemUid;

        UIState.OpenNewWindow(context, WindowProcessCreate(process: process, refresh: refresh));
      },
      child: Container(
        height: 28,
        child: Row(
          children: [
            ExcelT.LitGrid(text: "-", width: 28),
            ExcelT.LitGrid(text: item.name + '(원물)', width: 200, center: true),
            ExcelT.LitGrid(text: '미가공', width: 100, center: true),
            ExcelT.LitGrid(text: '완료', width: 100, center: true),
            ExcelT.LitGrid(text: StyleT.krwDouble(itemTs.amount - usedCount), width: 200, center: true),
          ],
        ),
      ),
    );

    return w;
  }






  static Widget tableUIMain(BuildContext context,
      ItemTS itemTS, {
        required Function refresh,
        int? index, Customer? cs, Function? onCs, Contract? ct,
        Function? onTap,
      }) {
    Item? item = SystemT.getItem(itemTS.itemUid);
    return InkWell(
      onTap: () {
        if(itemTS.type == "PU") {
          UIState.OpenNewWindow(context, WindowItemTS(itemTS: itemTS, refresh: refresh));
        }
        else if(itemTS.type == "RE") {

        }
      },
      child: Container(
        height: 36,
        decoration: StyleT.inkStyleNone(color: Colors.transparent),
        child: Row(
            children: [
              ExcelT.LitGrid(text: "${ index ?? 0 + 1 }", width: 32),
              ExcelT.LitGrid(text: StyleT.dateFormatAtEpoch(itemTS.date.toString()), width: 80),
              ExcelT.Grid(text: MetaT.itemTsType[itemTS.type] ?? 'NULL', width: 50, textSize: 10),

              ListBoxT.Rows(
                  width: 150,
                  expand: true,
                  children: [
                    TextT.OnTap(
                        text: '${ cs == null ? '-' : cs.businessName }',
                        onTap: () async {
                          if(onCs != null) onCs();
                        }
                    ),
                    TextT.Lit(text: " / "),
                    TextT.OnTap(
                        text: '${ ct == null ? '-' : ct.ctName }',
                        onTap: () async {

                        }
                    ),
                  ]
              ),

              ExcelT.Grid(text: item == null ? '-' : item.name, width: 150, textSize: 10, expand: true, alignment: Alignment.center),
              ExcelT.LitGrid(text: StyleT.krwDouble(itemTS.amount), width: 80, textSize: 10, alignment: Alignment.center),
              ExcelT.LitGrid(text: "${itemTS.rh} RH(%)", width: 80, textSize: 10, alignment: Alignment.center),
              ExcelT.LitGrid(text: "${ itemTS.getStorageLC() }", width: 80, textSize: 10, alignment: Alignment.center),
              ExcelT.LitGrid(text: "${ itemTS.manager }", width: 80, textSize: 10, alignment: Alignment.center),
              ButtonT.Icont(
                  icon: Icons.create,
                  onTap: () async {
                    Messege.show(context, "개발중입니다.");
                  }
              ),
              ButtonT.Icont(
                  icon: Icons.delete,
                  onTap: () async {
                    var rst = await DialogT.showAlertDl(context, text: "품목 입출 정보를 삭제하시겠습니까?");
                    if(!rst)  return Messege.toReturn(context,"취소됨", false);
                    else {
                      WidgetT.loadingBottomSheet(context);

                      await itemTS.delete();

                      Messege.show(context, "삭제됨");
                      Navigator.pop(context);

                      FunT.CallFunction(refresh);
                    }
                  }
              ),
            ]
        ),
      ),
    );
  }
}
