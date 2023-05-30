import 'dart:html';
import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/textInput.dart';
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



class CompPU {
  static dynamic tableHeader() {
    return WidgetUI.titleRowNone([ '순번', '매입일자', '품목', "",  '단위', '수량', '단가', '공급가액', 'VAT', '합계', '메모', ],
        [ 28, 80, 999, 28 * 2, 50, 80, 80, 80, 80, 80, 999 ], background: true, lite: true);
  }

  static dynamic tableHeaderInput() {
    return WidgetUI.titleRowNone([ '순번', '매입일자', '품목', "",  '단위', '수량', '단가', '공급가액', 'VAT', '합계', ],
        [ 28, 80, 999, 28 * 2, 50, 80, 80, 80, 80, 80, ], background: true, lite: true);
  }

  static dynamic tableHeaderEditor() {
    return WidgetUI.titleRowNone([ '순번', '매입일자', '품목', "",  '단위', '수량', '단가', '공급가액', 'VAT', '합계', ],
        [ 28, 80, 999, 28 * 2, 50, 80, 80, 80, 80, 80, ], background: true, lite: true);
  }

  static dynamic tableHeaderMain() {
    return Container( padding: EdgeInsets.fromLTRB(6, 0, 6, 6),
      child: WidgetUI.titleRowNone([ '순번', '거래번호', '거래일', '구분', '거래처 및 계약', '품목', '단위', '수량', '단가', '공급가액', 'VAT', '합계', '' ],
          [ 32, 80, 80, 50, 999, 999, 50, 50, 80, 80, 80, 80, 64 + 32, 32 ]),);
  }


  static dynamic tableUIMain(BuildContext context, Purchase pu, {
    Contract? ct,
    int? index,
    Customer? cs,
    Function? onTap,
    Function? setState,
    Function? refresh,
  }) {
    var w = InkWell(
      onTap: () async {
        if(cs == null) return;
        /// 윈도우 창으로 변경
        UIState.OpenNewWindow(context, WindowPUEditor(pu: pu, refresh: refresh!,));
      },
      child: Container(
        height: 36 + 6,
        decoration: StyleT.inkStyleNone(color: Colors.transparent),
        child: Row(
            children: [
              ExcelT.LitGrid(text: '${ index ?? '-' }', width: 32),
              ExcelT.LitGrid(text: "P-${pu.id}", width: 80, textSize: 9, center: true),
              ExcelT.LitGrid(text: StyleT.dateFormatAtEpoch(pu.purchaseAt.toString()), width: 80, center: true),
              ExcelT.LitGrid(text: '매입', width: 50, textColor: Colors.red.withOpacity(0.5), center: true),

              TextT.OnTap(
                enable: cs != null, expand: true,
                width: 150,
                text: cs == null ? 'ㅡ' : cs.businessName != '' ? cs.businessName : 'ㅡ',
                onTap: () {
                  if(cs == null) return;
                  UIState.OpenNewWindow(context, WindowCS(org_cs: cs));
                }
              ),

              ExcelT.LitGrid(text: SystemT.getItemName(pu.item), width: 100, expand: true, bold: true),
              ExcelT.LitGrid(text: SystemT.getItem(pu.item) == null ? 'ㅡ' : SystemT.getItem(pu.item)!.unit, width: 50, ),
              ExcelT.LitGrid(text: StyleT.krwInt(pu.count), width: 50, ),
              ExcelT.LitGrid(text: StyleT.krwInt(pu.unitPrice), width: 80, ),
              ExcelT.LitGrid(text: StyleT.krwInt(pu.supplyPrice), width: 80, ),
              ExcelT.LitGrid(text: StyleT.krwInt(pu.vat), width: 80, ),
              ExcelT.LitGrid(text: StyleT.krwInt(pu.totalPrice), width: 80, ),

              if(pu.filesMap.length > 0)
                WidgetT.iconMini(Icons.file_copy_rounded, size: 32),
              if(pu.filesMap.length == 0)
                SizedBox(height: 32,width: 32,),

              ButtonT.IconAction(
                context, Icons.delete, altText: "매입 데이터를 삭제하시겠습니까?",
                onTap: () async {
                  await DatabaseM.deletePu(pu);
                  WidgetT.showSnackBar(context, text: '매입 데이터를 삭제했습니다.');
                  if(refresh != null) await refresh();
                }
              )
            ]
        ),
      ),
    );
    return w;
  }



  /// 이 함수는 변경기록 테이블에서 사용하는 목록위젯을 생성하고 반환합니다.
  static dynamic tableUIHistory(BuildContext context, Purchase pu, {
    Contract? ct,
    int? index,
    Customer? cs,
  }) {
    var w = Container(
      height: 28,
      decoration: StyleT.inkStyleNone(color: Colors.transparent),
      child: Row(
          children: [
            ExcelT.LitGrid(text: '${ index ?? '-' }', width: 32),
            ExcelT.LitGrid(text: StyleT.dateFormatAtEpoch(pu.updateAt.toString()), width: 80, textSize: 9, center: true),
            ExcelT.LitGrid(text: StyleT.dateFormatAtEpoch(pu.purchaseAt.toString()), width: 80, center: true),
            ExcelT.LitGrid(text: '매입', width: 50, textColor: Colors.red.withOpacity(0.5), center: true),

            TextT.OnTap(
                enable: cs != null, expand: true,
                width: 150,
                text: cs == null ? 'ㅡ' : cs.businessName != '' ? cs.businessName : 'ㅡ',
                onTap: () {
                  if(cs == null) return;
                  UIState.OpenNewWindow(context, WindowCS(org_cs: cs));
                }
            ),

            ExcelT.LitGrid(text: SystemT.getItemName(pu.item), width: 100, expand: true, bold: true),
            ExcelT.LitGrid(text: SystemT.getItem(pu.item) == null ? 'ㅡ' : SystemT.getItem(pu.item)!.unit, width: 50, ),
            ExcelT.LitGrid(text: StyleT.krwInt(pu.count), width: 50, ),
            ExcelT.LitGrid(text: StyleT.krwInt(pu.unitPrice), width: 80, ),
            ExcelT.LitGrid(text: StyleT.krwInt(pu.supplyPrice), width: 80, ),
            ExcelT.LitGrid(text: StyleT.krwInt(pu.vat), width: 80, ),
            ExcelT.LitGrid(text: StyleT.krwInt(pu.totalPrice), width: 80, ),

            if(pu.filesMap.length > 0)
              WidgetT.iconMini(Icons.file_copy_rounded, size: 32),
            if(pu.filesMap.length == 0)
              SizedBox(height: 32,width: 32,),
          ]
      ),
    );
    return w;
  }




  /// 매입건에 대해 수정할 수 있는 위젯을 반환합니다.
  /// 개별 매입정보를 수정하려면 반드시 이 함수를 통해 이루어져야 합니다.
  static dynamic tableUIEditor(BuildContext context, Purchase pu, {
    int? index,
    Customer? cs,
    Function? onTap,
    Function? setState,
    Function? refresh,
    Map<String, Uint8List>? fileByteList,
  }) {
    var item = SystemT.getItem(pu.item);
    if(fileByteList == null) return;

    var w = ListBoxT.Columns(
      spacingStartEnd: 6,
      children: [
        Row(
            children: [
              ExcelT.LitGrid(text: '-', width: 28),
              ExcelT.LitInput(context, 'pu.info::매출일자', width: 150, textSize: 10,
                onEdited: (i, data) { pu.purchaseAt = StyleT.dateEpoch(data); },
                setState: setState,
                text: StyleT.dateInputFormatAtEpoch(pu.purchaseAt.toString()),
              ),

              ExcelT.LitInput(context, 'pu.info::품목', width: 200, textSize: 10,
                  expand: true,
                  onEdited: (i, data) {
                    var item = SystemT.getItem(pu.item);
                    if (item == null) { pu.item = data; return; }
                    if (item.name == data) { return; }
                    pu.item = data;
                  },
                  setState: setState,
                  text: SystemT.getItemName(pu.item), value: SystemT.getItemName(pu.item)),
              ButtonT.Icont(
                  icon: Icons.open_in_new_sharp,
                  onTap: () async {
                    Item? item = await DialogT.selectItem(context);
                    if(setState != null) setState();
                    if(item != null) {
                      pu.item = item.id;
                      pu.unitPrice = item.unitPrice;
                    }

                    if(setState != null) setState();
                  }
              ),

              TextButton(
                onPressed: null,
                style: StyleT.buttonStyleNone(padding: 0, round: 0, elevation: 0, color: Colors.transparent, strock: 1.4,),
                child: SizedBox(
                  height: 28, width: 28,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton2(
                      focusColor: Colors.transparent,
                      focusNode: FocusNode(),
                      autofocus: false,
                      customButton: WidgetT.iconMini(Icons.arrow_drop_down_circle_sharp),
                      items: SystemT.itemMaps.keys.map((item) => DropdownMenuItem<dynamic>(
                        value: item,
                        child: Text(
                          SystemT.getItemName(item),
                          style: StyleT.titleStyle(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      )).toList(),
                      onChanged: (value) async {
                        var item = SystemT.getItem(value);
                        if(item != null) {
                          pu.item = item.id;
                          pu.unitPrice = item.unitPrice;
                        }
                        print('select item uid: ' + value);
                        if(setState != null) setState();
                      },
                      itemHeight: 24,
                      itemPadding: const EdgeInsets.only(left: 16, right: 16),
                      dropdownWidth: 256.7,
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
                      offset: const Offset(-256 + 28, 0),
                    ),
                  ),
                ),
              ),

              ExcelT.LitGrid(text: item == null ? '-' : item.unit, width: 50, center: true),
              ExcelT.LitInput(context, 'pu.info::수량', width: 50, textSize: 10,
                  onEdited: (i, data) {
                    pu.count = int.tryParse(data) ?? 0;
                  },
                  setState: setState,
                  text: StyleT.krw(pu.count.toString()), value: pu.count.toString()),

              ExcelT.LitInput(context, 'pu.info::단가', width: 80, textSize: 10,
                onEdited: (i, data) {
                  pu.unitPrice = int.tryParse(data) ?? 0;
                },
                setState: setState,
                text: StyleT.krwInt(pu.unitPrice), value: pu.unitPrice.toString(),),
              ButtonT.Icont(
                  icon: Icons.link,
                  onTap: () async {
                    if(item == null) return;
                    pu.unitPrice = item.unitPrice;
                    if(setState != null) setState();
                  }
              ),

              ExcelT.LitInput(context, 'info.pu.supplyPrice',
                width: 80, textSize: 10,
                onEdited: (i, data) {
                  pu.supplyPrice = int.tryParse(data) ?? 0;
                  pu.fixedSup = true;
                },
                setState: setState,
                text: StyleT.krwInt(pu.supplyPrice), value: pu.supplyPrice.toString(),),
              ExcelT.LitInput(context, 'info.pu.vat',
                width: 80, textSize: 10,
                onEdited: (i, data) {
                  pu.vat = int.tryParse(data) ?? 0;
                  pu.fixedVat = true;
                },
                setState: setState,
                text: StyleT.krwInt(pu.vat), value: pu.vat.toString(),),
              ExcelT.LitGrid(text: StyleT.krw(pu.totalPrice.toString()), width: 80, center: true),
            ]
        ),
        Row(
          children: [
            TextT.Lit(text: "메모",size: 12, width: 100),
            ExcelT.LitInput(context, "${index}::pu.메모",
              index: index, setState: setState, expand: true,
              onEdited: (i, data) { pu.memo  = data ?? ''; },
              text: pu.memo,
            ),
          ],
        ),
        Row(
            children: [
              TextT.Lit(text: "첨부파일",size: 12, width: 100),
              Expanded(
                  child: Wrap(
                    runSpacing: 6, spacing: 6,
                    children: [
                      for(int i = 0; i < pu.filesMap.length; i++)
                        ButtonT.IconText(
                          icon: Icons.cloud_done,
                          text: pu.filesMap.keys.elementAt(i),
                          onTap: () async {
                            var downloadUrl = pu.filesMap.values.elementAt(i);
                            var fileName = pu.filesMap.keys.elementAt(i);
                            PdfManager.OpenPdf(downloadUrl, fileName);
                          },
                          leaging: ButtonT.Icont(
                              icon: Icons.delete,
                              onTap: () async {
                                WidgetT.showSnackBar(context, text: "개발중입니다.");
                                if(refresh != null) refresh();
                              }
                          ),
                        ),

                      for(int i = 0; i < fileByteList.length; i++)
                        ButtonT.IconText(
                          icon: Icons.file_copy_rounded,
                          text: fileByteList.keys.elementAt(i),
                          onTap: () async {
                            PDFX.showPDFtoDialog(context, data: fileByteList.values.elementAt(i), name: fileByteList.keys.elementAt(i));
                          },
                          leaging: ButtonT.Icont(
                              icon: Icons.delete,
                              onTap: () async {
                                fileByteList.remove(fileByteList.keys.elementAt(i));
                                if(setState != null) setState();
                              }
                          ),
                        ),
                    ],
                  ),
              )
            ]
        ),
      ],
    );
    return w;
  }



  /// 매입건에 대한 최초입력 위젯을 생성하고 반환합니다
  /// .
  /// required params
  ///   BuildContext? context
  ///   Purchase pu
  ///   Function setState
  ///   Map<String, Uint8List>? fileByteList
  static dynamic tableUIInput( BuildContext? context, Purchase pu, {
    int? index,
    Customer? cs,
    Function? onTap,
    Function? setState,
    Map<String, Uint8List>? fileByteList
  }) {
    if(context == null) return Container();
    if(setState == null) return Container();
    if(fileByteList == null) fileByteList = {};

    var item = SystemT.getItem(pu.item);

    var w = ListBoxT.Columns(
      spacingStartEnd: 6,
      children: [
        Row(
            children: [
              ExcelT.LitGrid(text: "${index ?? "-"}", width: 28, center: true),
              ExcelT.LitInput(context, "${index}::pu.매출일자", width: 100, index: index,
                setState: setState,
                onEdited: (i, data) { pu.purchaseAt = StyleT.dateEpoch(data); },
                text: StyleT.dateInputFormatAtEpoch(pu.purchaseAt.toString()),
              ),
              ExcelT.LitInput(context, "${index}::pu.품목", width: 200, expand: true, index: index,
                setState: setState,
                onEdited: (i, data) {
                  var item = SystemT.getItem(pu.item);
                  if (item == null) { pu.item = data; return; }
                  if (item.name == data) return;
                  pu.item = data;
                },
                text: SystemT.getItemName(pu.item),
              ),


              ButtonT.Icont(
                icon: Icons.add_box,
                onTap: () async {
                  Item? item = await DialogT.selectItem(context);
                  if(setState != null) await setState();
                  if(item != null) {
                    pu.item = item.id;
                    pu.unitPrice = item.unitPrice;
                  }
                  if(setState != null) await setState();
                },
              ),
              /// 최적화 필요
              SizedBox(
                height: 28, width: 28,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    focusColor: Colors.transparent,
                    focusNode: FocusNode(),
                    autofocus: false,
                    customButton: WidgetT.iconMini(Icons.arrow_drop_down_circle_sharp),
                    items: SystemT.itemMaps.keys.map((item) => DropdownMenuItem<dynamic>(
                      value: item,
                      child: Text(
                        SystemT.getItemName(item),
                        style: StyleT.titleStyle(),
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                    onChanged: (value) async {
                      var item = SystemT.getItem(value);
                      if(item != null) {
                        pu.item = item.id;
                        pu.unitPrice = item.unitPrice;
                      }
                      if(setState != null) await setState();
                    },
                    itemHeight: 24,
                    itemPadding: const EdgeInsets.only(left: 16, right: 16),
                    dropdownWidth: 256.7,
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
                    offset: const Offset(-256 + 28, 0),
                  ),
                ),
              ),

              ExcelT.LitGrid(text: item == null ? '-' : item.unit, width:  50, center: true),
              ExcelT.LitInput(context, "${index}::pu.수량", width: 80,index: index,
                  setState: setState,
                  onEdited: (i, data) { pu.count = int.tryParse(data) ?? 0;  },
                  text: StyleT.krw(pu.count.toString()), value: pu.count.toString()
              ),
              ExcelT.LitInput(context, "${index}::pu.단가", width: 80, index: index,
                setState: setState,
                onEdited: (i, data) { pu.unitPrice = int.tryParse(data) ?? 0;  },
                text: StyleT.krwInt(pu.unitPrice), value: pu.unitPrice.toString(),
              ),
              ButtonT.Icont(
                  icon: Icons.link,
                  onTap: () async {
                    if(item != null) pu.unitPrice = item.unitPrice;
                    if(setState != null) await setState();
                  }
              ),

              ExcelT.LitInput(context, "${index}::pu.supplyPrice", width: 80, index: index,
                setState: setState,
                onEdited: (i, data) {
                  pu.supplyPrice = int.tryParse(data) ?? 0;
                  pu.fixedSup = true;
                }, text: StyleT.krwInt(pu.supplyPrice), value: pu.supplyPrice.toString(),
              ),
              ExcelT.LitInput(context, "${index}::pu.vat", width: 80, index: index,
                setState: setState,
                onEdited: (i, data) {
                  pu.vat = int.tryParse(data) ?? 0;
                  pu.fixedVat = true;
                }, text: StyleT.krwInt(pu.vat), value: pu.vat.toString(),
              ),
              ExcelT.LitGrid(text: StyleT.krw(pu.totalPrice.toString()), width: 80, center: true),
            ]
        ),
        Row(
          children: [
            TextT.Lit(text: "메모",size: 12, width: 100),
            ExcelT.LitInput(context, "${index}::pu.메모",
              index: index, setState: setState, expand: true,
              onEdited: (i, data) { pu.memo  = data ?? ''; },
              text: pu.memo,
            ),
          ],
        ),
        Row(
            children: [
              TextT.Lit(text: "첨부파일",size: 12, width: 100),
              Expanded(child: Container( padding: EdgeInsets.all(0),  child: Wrap(
                runSpacing: 6 * 2, spacing: 6 * 2,
                children: [
                  for(int i = 0; i < pu.filesMap.length; i++)
                    ButtonT.IconText(
                        icon : Icons.file_copy_rounded,
                        text: pu.filesMap.keys.elementAt(i),
                        leaging: ButtonT.Icont(
                            icon: Icons.cancel,
                            onTap: () {
                              WidgetT.showSnackBar(context, text: "개발중");
                              setState();
                            }
                        ),
                        onTap: () async {
                          var downloadUrl = pu.filesMap.values.elementAt(i);
                          var fileName = pu.filesMap.keys.elementAt(i);
                          PdfManager.OpenPdf(downloadUrl, fileName);
                        }
                    ),
                  for(int i = 0; i < fileByteList.length; i++)
                    ButtonT.IconText(
                        icon : Icons.file_copy_rounded,
                        text: fileByteList.keys.elementAt(i),
                        leaging: ButtonT.Icont(
                            icon: Icons.cancel,
                            onTap: () {
                              fileByteList!.remove(fileByteList.keys.elementAt(i ?? 0));
                              setState();
                            }
                        ),
                        onTap: () {
                          PDFX.showPDFtoDialog(context, data: fileByteList!.values.elementAt(i), name: fileByteList!.keys.elementAt(i));
                        }
                    ),
                ],
              ),)),
            ]
        ),
        ListBoxT.Rows(
          spacing: 6,
          children: [
            ButtonT.IconText(
              icon: Icons.auto_mode,
              text: "금액 자동계산",
              onTap: () async {
                pu.fixedVat = false;
                pu.fixedSup = false;
                if(setState != null) await setState();
              },
            ),
            ButtonT.IconText(
              icon: Icons.file_copy_rounded,
              text: "파일 추가",
              onTap: () async {
                FilePickerResult? result;
                try {
                  result = await FilePicker.platform.pickFiles();
                } catch (e) {
                  WidgetT.showSnackBar(context, text: '파일선택 오류');
                  print(e);
                }

                if(setState != null) await setState();
                if(result != null){
                  WidgetT.showSnackBar(context, text: '파일선택');
                  if(result.files.isNotEmpty) {
                    String fileName = result.files.first.name;
                    fileByteList![fileName] = result.files.first.bytes!;
                  }
                }

                if(setState != null) await setState();
              },
            ),
            ButtonT.IconText(
              icon: Icons.cancel,
              text: "품목제거",
              onTap: () async {
                pu.state = "DEL";
                if(setState != null) await setState();
              },
            ),
          ], ),
      ],
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
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(pu.count),),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(pu.unitPrice),),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(pu.supplyPrice),),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(pu.vat),),
                ExcelT.LitGrid(center: true, width: 80, text: StyleT.krwInt(pu.totalPrice),),
                ExcelT.LitGrid(center: true, width: 200, text: pu.memo, expand: true),

                /// 수정
                ButtonT.Icont(
                  icon: Icons.create,
                  onTap: () async {
                    UIState.OpenNewWindow(context, WindowPUEditor(pu: pu, refresh: refresh ?? () {}));
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
                    UIState.OpenNewWindow(context, WindowItemTS(itemTS: itemTs, refresh: () { if(refresh != null) refresh(); }));
                    if(setState != null) setState();
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