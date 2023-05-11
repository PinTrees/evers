import 'dart:typed_data';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/helper/firebaseCore.dart';
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
import '../../ui/cs.dart';
import '../../ui/dialog_pu.dart';
import '../../ui/ux.dart';
import '../Customer.dart';
import '../contract.dart';
import '../database/item.dart';
import '../system.dart';
import '../system/state.dart';
import '../transaction.dart';
import '../widget/button.dart';
import '../widget/text.dart';





class CompPU {
  static dynamic tableHeader() {
    return WidgetUI.titleRowNone([ '', '매출일자', '품목', '단위', '수량', '단가', '공급가액',  'VAT', '합계', '메모', '', ],
        [ 28, 150, 200 + 28 * 2, 50, 50, 80 + 28, 80, 80, 80, 200, 0], lite: true, background: true );
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
        await DialogCS.showPurInCs(context, cs);
      },
      child: Container(
        height: 36 + 6,
        decoration: StyleT.inkStyleNone(color: Colors.transparent),
        child: Row(
            children: [
              ExcelT.LitGrid(text: '${ index ?? '-' }', width: 32),
              ExcelT.LitGrid(text: pu.id, width: 80, textSize: 8),
              ExcelT.LitGrid(text: StyleT.dateFormatAtEpoch(pu.purchaseAt.toString()), width: 80,),
              ExcelT.LitGrid(text: '매입', width: 50, textColor: Colors.red.withOpacity(0.5)),

              TextT.OnTap(
                enable: cs != null, expand: true,
                width: 150,
                text: cs == null ? 'ㅡ' : cs.businessName != '' ? cs.businessName : 'ㅡ',
                onTap: () {
                  if(cs == null) return;

                  var parent = UIState.mdiController!.createWindow(context);
                  var page = WindowCS(org_cs: cs, parent: parent,);
                  UIState.mdiController!.addWindow(context, widget: page, resizableWindow: parent, fixedHeight: true);
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

              InkWell(
                onTap: () async {
                  var parent = UIState.mdiController!.createWindow(context);
                  var page = WindowPUEditor(pu: pu, refresh: refresh ?? () {}, parent: parent,);
                  UIState.mdiController!.addWindow(context, widget: page, resizableWindow: parent);
                  /*var result = await DialogPU.showInfoPu(context, org: pu);*/
                },
                child: WidgetT.iconMini(Icons.create, size: 32),
              ),
              InkWell(
                onTap: () async {
                  var aa = await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?');
                  if(aa) {
                    await DatabaseM.deletePu(pu);
                    WidgetT.showSnackBar(context, text: '매입 데이터를 삭제했습니다.');
                  }
                },
                child: WidgetT.iconMini(Icons.delete, size: 32),
              ),
            ]
        ),
      ),
    );
    return w;
  }


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

    var w = Column(
      children: [
        Container( height: 32,
          child: Row(
              children: [
                ExcelT.LitGrid(text: '-', width: 28),
                ExcelT.LitInput(context, 'pu.info::매출일자', width: 150, textSize: 10,
                  onEdited: (i, data) { pu.purchaseAt = StyleT.dateEpoch(data); },
                  setState: setState,
                  text: StyleT.dateInputFormatAtEpoch(pu.purchaseAt.toString()),
                ),

                ExcelT.LitInput(context, 'pu.info::품목', width: 200, textSize: 10,
                    onEdited: (i, data) {
                      var item = SystemT.getItem(pu.item);
                      if (item == null) { pu.item = data; return; }
                      if (item.name == data) { return; }
                      pu.item = data;
                    },
                    setState: setState,
                    text: SystemT.getItemName(pu.item), value: SystemT.getItemName(pu.item)),
                ButtonT.Icon(
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
                ButtonT.Icon(
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
                ExcelT.LitInput(context, 'pu.info::메모', width: 200, textSize: 10,
                  onEdited: (i, data) { pu.memo  = data ?? ''; },
                  setState: setState,
                  text: pu.memo,
                  expand: true,
                ),

                /// file
                ButtonT.Icon(
                  icon: Icons.file_copy_rounded,
                  onTap: () async {
                    FilePickerResult? result;
                    try {
                      result = await FilePicker.platform.pickFiles();
                    } catch (e) {
                      WidgetT.showSnackBar(context, text: '파일선택 오류');
                    }
                    if(result != null){
                      WidgetT.showSnackBar(context, text: '파일선택');
                      if(result.files.isNotEmpty) {
                        String fileName = result.files.first.name;
                        fileByteList[fileName] = result.files.first.bytes!;
                        print(fileByteList[fileName]!.length);
                      }
                    }
                    /// 즉시 업데이트 - 삭제시 내부에서 재거
                    if(setState != null) setState();
                  },
                ),
                /// delete
                ButtonT.Icon(
                  icon: Icons.delete_forever,
                  color: Colors.redAccent,
                  onTap: () async {
                    if(!await DialogT.showAlertDl(context, text:'삭제하시겠습니까?')) {
                      WidgetT.showSnackBar(context, text: '취소됨');
                      return;
                    }

                    WidgetT.loadingBottomSheet(context);
                    await DatabaseM.deletePu(pu);
                    Navigator.pop(context);

                    WidgetT.showSnackBar(context, text: '삭제됨');
                    Navigator.pop(context, pu);
                  },
                ),
              ]
          ),
        ),
        Container(
          height: 28,
          child: Row(
              children: [
                WidgetT.excelGrid( width: 178, label: '거래명세서 첨부파일', ),
                Expanded(
                    child: Container( padding: EdgeInsets.all(6),
                      child: Wrap(
                        runSpacing: 6, spacing: 6,
                        children: [
                          SizedBox(width: 6, height: 36,),
                          for(int i = 0; i < pu.filesMap.length; i++)
                            ButtonT.IconText(
                              icon: Icons.cloud_done,
                              text: pu.filesMap.keys.elementAt(i),
                              onTap: () async {
                                var downloadUrl = pu.filesMap.values.elementAt(i);
                                var fileName = pu.filesMap.keys.elementAt(i);
                                var ens = ENAES.fUrlAES(downloadUrl);

                                var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                print(url);
                                await launchUrl( Uri.parse(url),
                                  webOnlyWindowName: true ? '_blank' : '_self',
                                );
                              },
                              leaging: ButtonT.Icon(
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
                              leaging: ButtonT.Icon(
                                  icon: Icons.delete,
                                  onTap: () async {
                                    fileByteList.remove(fileByteList.keys.elementAt(i));
                                    if(setState != null) setState();
                                  }
                              ),
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


  static dynamic tableUIInput( BuildContext? context, TS ts, {
    int? index,
    Customer? cs,
    Function? onTap,
    Function? setState,
  }) {
    if(context == null) return Container();
    if(setState == null) return Container();

    var w = Container( height: 28,
      child: Row(
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
              setState: setState,
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
            ExcelT.LitInput(context, '$index::ts메모', width: 250, index: index,
              setState: setState, expand: true,
              onEdited: (i, data) { ts.memo = data;}, text: ts.memo,  ),
            ButtonT.Icon(
              icon: Icons.cancel,
              onTap: () async {
                ts.type = 'DEL';
                setState();
              },
            ),
          ]
      ),
    );
    return w;
  }


  static dynamic tableUI( BuildContext? context, TS ts, {
    int? index,
    Customer? cs,
    Function? onTap,
    Function? setState,
    Function? refresh,
    Function? onClose,
  }) {
    if(context == null) return Container();
    if(setState == null) return Container();

    var w = Container( height: 28,
      child: Row(
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
              onEdited: (i, data) { ts.summary = data; }, text: ts.summary,
              setState: setState,
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
            ExcelT.LitInput(context, '$index::ts.editor.금액', width: 120, index: index,
              onEdited: (i, data) {  ts.amount = int.tryParse(data) ?? 0; },
              setState: setState,
              text: StyleT.krwInt(ts.amount), value: ts.amount.toString(),),
            ExcelT.LitInput(context, '$index::ts.editor.메모', width: 250, index: index,
              setState: setState, expand: true,
              onEdited: (i, data) { ts.memo = data;}, text: ts.memo,  ),

            ButtonT.Icon(
              icon: Icons.delete_forever,
              color: Colors.redAccent,
              onTap: () async {
                if(refresh == null) { WidgetT.showSnackBar(context, text: 'refresh function is nat nullable'); return; }

                /// 현재 TS에 대한 데이터베이서 제거 요청
                var alt = await DialogT.showAlertDl(context, text: '해당 수납정보를 삭제하시겠습니까?');
                if(!alt) { WidgetT.showSnackBar(context, text: '취소됨'); return; }
                else WidgetT.showSnackBar(context, text: '삭제됨');

                await ts.delete();

                await refresh();
                if(onClose != null) onClose();
              },
            ),
          ]
      ),
    );
    return w;
  }
}