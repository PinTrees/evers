import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/page/window/window_process_info.dart';
import 'package:evers/page/window/window_pu_editor.dart';
import 'package:evers/page/window/window_ts_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../helper/aes.dart';
import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/pdfx.dart';
import '../../helper/style.dart';
import '../../page/window/window_cs.dart';
import '../../page/window/window_ct.dart';
import '../../ui/ux.dart';
import '../Customer.dart';
import '../contract.dart';
import '../database/item.dart';
import '../system.dart';
import '../system/state.dart';
import '../transaction.dart';
import '../widget/button.dart';
import '../widget/text.dart';
import 'package:http/http.dart' as http;

/// 이 클래스는 거래처에 관한 목록UI의 집합입니다.
class CompCS {
  static dynamic tableHeader() {
    return WidgetUI.titleRowNone([ '순번', '매입일자', '품목', "",  '단위', '수량', '단가', '공급가액', 'VAT', '합계', '메모', ],
        [ 28, 80, 999, 28 * 2, 50, 80, 80, 80, 80, 80, 999 ], background: true, lite: true);
  }

  static dynamic tableHeaderSearch() {
    return WidgetUI.titleRowNone([ '순번', '업체명', '대표자', '업체번호', '연락처', "" ],
        [ 32, 999, 100, 100, 100, 80 * 1, 0, 0,  ],
        background: true, lite: true
    );
  }

  static dynamic tableHeaderMain() {
    return Container( padding: EdgeInsets.fromLTRB(6, 0, 6, 6),
      child: WidgetUI.titleRowNone([ '순번', '업체명', '대표자', '업체번호', '연락처', "" ],
          [ 32, 999, 100, 100, 100, 80 * 3 + 120, 0, 0,  ]),
    );
  }


  /// 이 함수는 메인 페이지에 노출되는 거래처 테이블 위젯을 반환합니다.
  static dynamic tableUIMain(BuildContext context, Customer cs, {
    int? index,
    Function? setState,
    Function? refresh,
  }) {
    var w = InkWell(
        onTap: () async {
          UIState.OpenNewWindow(context, WindowCS( org_cs: cs, refresh: refresh,));
        },
        child: Container( height: 36 + 6,
          decoration: StyleT.inkStyleNone(color: Colors.transparent),
          child: Row(
              children: [
                ExcelT.LitGrid(text: '${index ?? '-'}', width: 32, center: true),
                ExcelT.Grid(text: " " * 5 + cs.businessName, width: 250, expand: true),
                ExcelT.LitGrid(text: cs.representative, width: 100, center: true),
                ExcelT.LitGrid(text: cs.companyPhoneNumber, width: 100, center: true),
                ExcelT.LitGrid(text: cs.phoneNumber, width: 100, center: true),


                /*ButtonT.IconText(
                    color: Colors.transparent,
                    icon: Icons.input, text: "매입",
                    onTap: () async {
                      await DialogCS.showPurInCs(context, cs);
                    }
                ),
                ButtonT.IconText(
                    color: Colors.transparent,
                    icon: Icons.output, text: "매출",
                    onTap: () async {
                      await DialogCS.showRevInCs(context, cs);
                    }
                ),
                ButtonT.IconText(
                    color: Colors.transparent,
                    icon: Icons.all_inbox, text: "전체",
                    onTap: () async {
                      await DialogCS.showPUrRevTs(context, cs);

                    }
                ),*/
              ]
          ),
        ));
    return w;
  }

  /// 이 함수는 검색창에 노출되는 거래처 테이블 위젯을 반환합니다.
  static dynamic tableUISearch(BuildContext context, Customer cs, {
    int? index,
    Function? onTap,
    Function? setState,
    Function? refresh,
  }) {
    var w = Container( height: 28,
      decoration: StyleT.inkStyleNone(color: Colors.transparent),
      child: Row(
          children: [
            ExcelT.LitGrid(text: '${index ?? '-'}', width: 32, center: true),
            ExcelT.Grid(text: " " * 5 + cs.businessName, width: 250, textSize: 10, expand: true),
            ExcelT.LitGrid(text: cs.representative, width: 100, center: true),
            ExcelT.LitGrid(text: cs.companyPhoneNumber, width: 100, center: true),
            ExcelT.LitGrid(text: cs.phoneNumber, width: 100, center: true),
            ButtonT.IconText(
              color: Colors.transparent,
                icon: Icons.input, text: "선택",
                onTap: () async {
                  if(onTap != null) await onTap();
                }
            ),
          ]
      ),
    );
    return w;
  }


  static dynamic tableUI(BuildContext context, Purchase pu, {
    int? index,
    Customer? cs,
    Function? onTap,
    Function? setState,
    Function? refresh,
    Function? onClose,
  }) {
    var item = SystemT.getItem(pu.item);

    var w = Column(
      children: [
        Container(
          height: 28,
          child: Row(
              children: [
                ExcelT.LitGrid(center: true, text: index == null ? "" : '${index}', width: 28),
                ExcelT.LitGrid(center: true, text: StyleT.dateInputFormatAtEpoch(pu.purchaseAt.toString()), width: 80),
                ExcelT.LitGrid(center: true, text: item == null ? pu.item : item.name == "" ? pu.item : item.name, width: 200, expand: true),
                ExcelT.LitGrid(center: true, text: item == null ? '-' : item.unit == "" ? '-' : item.unit, width: 50),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwDouble(pu.count),),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(pu.unitPrice),),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(pu.supplyPrice),),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(pu.vat),),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(pu.totalPrice),),
                ExcelT.LitGrid(center: true, width: 200, text: pu.memo, expand: true),

                /// 수정
                ButtonT.Icont(
                  icon: Icons.create,
                  onTap: () async {
                    var parent = UIState.mdiController!.createWindow(context);
                    UIState.OpenNewWindow(context, WindowPUEditor(pu: pu, refresh: refresh ?? () {}, ));
                    if(setState != null) setState();
                  },
                ),
                pu.isItemTs ? ButtonT.IconText(
                  icon: Icons.account_tree,
                  text: '품목확인',
                  color: Colors.transparent,
                  onTap: () async {
                    var itemTs = await DatabaseM.getItemTrans(pu.id);
                    if(itemTs == null) return;

                    UIState.OpenNewWindow(context, WindowItemTS(itemTS: itemTs, refresh: () { if(refresh!= null) refresh(); }));
                  },
                )
                    : SizedBox(),
              ]
          ),
        ),
        if(pu.filesMap.isNotEmpty)
          Container(
            height: 32,
            padding: EdgeInsets.only(left: 6, bottom: 6),
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Container(
                        child: Wrap(
                          runSpacing: 6 * 2, spacing: 6 * 2,
                          children: [
                            for(int i = 0; i < pu.filesMap.length; i++)
                              InkWell(
                                  onTap: () async {
                                    var downloadUrl = pu.filesMap.values.elementAt(i);
                                    var fileName = pu.filesMap.keys.elementAt(i);
                                    PdfManager.OpenPdf(downloadUrl, fileName);
                                  },
                                  child: Container(
                                      color: Colors.grey.withOpacity(0.15),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          WidgetT.iconMini(Icons.cloud_done, size: 24),
                                          WidgetT.text(pu.filesMap.keys.elementAt(i), size: 10),
                                          SizedBox(width: 6,)
                                        ],
                                      ))
                              ),
                          ],
                        ),)),
                ]
            ),
          ),
      ],
    );
    return w;
  }
}