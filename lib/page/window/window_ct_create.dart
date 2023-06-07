import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/Customer.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/widget/button/button_file.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/json.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_ledger_revenue_create.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_re_create.dart';
import 'package:evers/page/window/window_re_create_ct.dart';
import 'package:evers/page/window/window_sch_create.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../class/contract.dart';
import '../../class/database/item.dart';
import '../../class/database/ledger.dart';
import '../../class/purchase.dart';
import '../../class/revenue.dart';
import '../../class/schedule.dart';
import '../../class/system.dart';
import '../../class/system/state.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/excel.dart';
import '../../class/widget/text.dart';
import '../../class/widget/textInput.dart';
import '../../core/window/window_base.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/pdfx.dart';
import '../../ui/dialog_revenue.dart';
import '../../ui/dialog_schedule.dart';
import '../../ui/ip.dart';
import '../../ui/ux.dart';

class WindowCtCreate extends WindowBaseMDI {
  Function refresh;
  Customer cs;

  WindowCtCreate({ required this.cs,
    required this.refresh,
  }) {}

  @override
  _WindowCtCreateState createState() => _WindowCtCreateState();
}

class _WindowCtCreateState extends State<WindowCtCreate> {
  var dividHeight = 6.0;

  Map<String, Uint8List> fileByteList = {};
  Map<String, Uint8List> ctFileByteList = {};

  Contract ct = Contract.fromDatabase({});
  Customer cs = Customer.fromDatabase({});

  var vatTypeList = [ 0, 1, ];
  var vatTypeNameList = [ '포함', '별도', ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  dynamic initAsync() async {
    cs = Customer.fromDatabase(JsonManager.toJsonObject(widget.cs));
    setState(() {});
  }

  Widget main = SizedBox();


  Widget mainBuild() {
    var csWidget = ListBoxT.Columns(
      children: [
        TextT.SubTitle(text: "거래처 정보", ),
        TextT.Lit(text: cs.businessName, ),
        if(cs.businessName == "")
          ButtonT.IconText(
            icon: Icons.search, text: "거래처 선택",
            onTap: () async {
              var select = await DialogT.selectCS(context);
              if(select != null) cs = select;
              setState(() {});
            }
          )
      ]
    );

    var gridStyleT = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.03), stroke: 2, strokeColor: StyleT.titleColor.withOpacity(0.1));
    var ctInfoWidget = Container(
      decoration: gridStyleT,
      padding: EdgeInsets.only(left: 6, right: 6),
      child: ListBoxT.Columns(
        spacingStartEnd: 6,
        children: [
          InputWidget.LitText(context, 'df계약명',
            label: "계약명", width: 250,
            onEdited: (i, data) { ct.ctName = data; },
            setState: () { setState(() {}); },
            text: ct.ctName,
          ),
          ListBoxT.Rows(
            spacing: 6,
            children: [
              InputWidget.LitText(context, 'df구매부서',
                label: "구매부서", width: 250,
                setState: () { setState(() {}); },
                onEdited: (i, data) { ct.purchasingDepartment = data; },
                text: ct.purchasingDepartment,
              ),
              InputWidget.LitText(context, 'df담당자',
                label: "담당자", width: 150,
                setState: () { setState(() {}); },
                onEdited: (i, data) { ct.manager = data; },
                text: ct.manager,
              ),
              InputWidget.LitText(context, 'df연락처',
                label: "연락처",  width: 150,
                setState: () { setState(() {}); },
                onEdited: (i, data) { ct.managerPhoneNumber = data; },
                text: ct.managerPhoneNumber,
              ),
            ]
          ),
          InputWidget.LitText(context, 'df납품지주소',
            label: "납품지주소",  width: 400,
            setState: () { setState(() {}); },
            onEdited: (i, data) { ct.workSitePlace = data; },
            text: ct.workSitePlace, ),
          InputWidget.LitText(context, 'input::메모',
            label: "메모", expand: true, isMultiLine: true,
            onEdited: (i, data) { ct.memo = data; },
            setState: () { setState(() {}); },
            text: ct.memo,
          ),
          InputWidget.LitText(context, 'df계약일자',
            label: "계약일자", width: 150 ,
            setState: () { setState(() {}); },
            onEdited: (i, data) { ct.contractAt = StyleT.dateEpoch(data); },
            text: StyleT.dateInputFormatAtEpoch(ct.contractAt.toString()),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextT.SubTitle(text: '계약서 첨부파일'),
              SizedBox(height: dividHeight,),
              Wrap(
                runSpacing: dividHeight, spacing: dividHeight,
                children: [
                  for(int i = 0; i < ct.contractFiles.length; i++)
                    ButtonFile(
                      fileName: ct.contractFiles.keys.elementAt(i),
                      fileUrl: ct.contractFiles.values.elementAt(i),
                      onDelete: () { setState(() {}); },
                    ),
                  for(int i = 0; i < ctFileByteList.length; i++)
                    ButtonFile(
                      fileName: ctFileByteList.keys.elementAt(i),
                      onDelete: () {
                        ctFileByteList.remove(ctFileByteList.keys.elementAt(i));
                        setState(() {});
                      },
                    ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextT.SubTitle(text: '추가 첨부파일'),
              SizedBox(height: dividHeight,),
              Wrap(
                runSpacing: dividHeight, spacing: dividHeight,
                children: [
                  for(int i = 0; i < ct.filesMap.length; i++)
                    ButtonFile(
                      fileName: ct.getFileName(ct.filesMap.keys.elementAt(i)),
                      fileUrl:  ct.filesMap.values.elementAt(i),
                      onDelete: () {
                        WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                        setState(() {});
                      },
                    ),
                  for(int i = 0; i < fileByteList.length; i++)
                    ButtonFile(
                      fileName: ct.getFileName(fileByteList.keys.elementAt(i)),
                      onDelete: () {
                        fileByteList.remove(fileByteList.keys.elementAt(i));
                        setState(() {});
                      },
                    ),
                ],
              ),
            ],
          ),
        ],),);


 
    List<Widget> ctW = [];
    ctW.add(WidgetUI.titleRowNone([ '순번', '계약일자', '품목', '', '단위', '단가', '', '메모', "" ], [ 28, 150, 200, 80, 50, 100, 28, 999, 28 ], background: true, lite: true),);
    for(int i = 0; i < ct.contractList.length; i++) {
      Widget w = SizedBox();
      var ctl = ct.contractList[i];
      Item? item = SystemT.getItem(ctl['item'] ?? '');
      var count = int.tryParse(ctl['count'] ?? '') ?? 0;
      var unitPrice = int.tryParse(ctl['unitPrice'] ?? '') ?? 0;
      var totalPrice = 0, vat = 0, supplyPrice = 0;
      if(ct.vatType == 0) { totalPrice = unitPrice * count;  vat = (totalPrice / 11).round(); supplyPrice = totalPrice - vat; }
      if(ct.vatType == 1) { vat = ((unitPrice * count) / 10).round(); totalPrice = unitPrice * count + vat;  supplyPrice = unitPrice * count; }

      w = Container(
          padding: EdgeInsets.only(top: 6, bottom: 6),
          child: Row(
            children: [
              WidgetT.excelGrid(label:'${i + 1}', width: 28),
              ExcelT.LitInput(context, '$i::ctl.계약일자', width: 150,
                setState: () { setState(() {}); },
                onEdited: (i, data) {
                  ctl['dueAt'] = StyleT.dateEpoch(data).toString();
                },
                text: StyleT.dateInputFormatAtEpoch(ctl['dueAt'] ?? ''),
              ),
              ExcelT.LitInput(context, '$i::ctl.item', width: 200, index: i,
                setState: () { setState(() {}); },
                onEdited: (i, data) {
                  ctl['item'] = data;
                },
                text: SystemT.getItemName(ctl['item'] ?? ''),),
              ButtonT.IconText(
                icon: Icons.search, text: "품목선택",
                onTap: () async {
                  Item? select = await DialogT.selectItem(context);
                  if(select != null) {
                    ctl['item'] = select.id;
                    setState(() {});
                  }
                }
              ),
              WidgetT.excelGrid( text: SystemT.getItemUnit(ctl['item'] ?? ''), width: 50, ),
              ExcelT.LitInput(context, '$i::단가', width: 100, index: i,
                setState: () { setState(() {}); },
                onEdited: (i, data) {
                  var a = int.tryParse(data);
                  if(a == null) ctl['unitPrice'] = '';
                  else ctl['unitPrice'] = a.toString();
                },
                text: StyleT.krw(unitPrice.toString()), value: unitPrice.toString(),
              ),
              ButtonT.Icont(
                icon: Icons.link,
                onTap: () {
                  if(item == null) return;
                  ctl['unitPrice'] = item.unitPrice.toString();
                  setState(() {});
                }
              ),
              ExcelT.LitInput(context, '$i::ctl.memo', index: i,
                setState: () { setState(() {}); }, expand: true,
                onEdited: (i, data) {
                  ctl['memo'] = data;
                },
                text: ctl['memo'] ?? "", width: 200,),
              ButtonT.Icont(
                icon: Icons.delete,
                onTap: () {
                  ct.contractList.removeAt(i);
                  setState(() {});
                }
              ),
            ],
          ));
      ctW.add(w);
      ctW.add(WidgetT.dividHorizontal(size: 0.35));
    }
    ctW.add(SizedBox(height: 6,));
    ctW.add(ListBoxT.Rows(
      spacing: 6,
      children: [
        ButtonT.IconText(
          icon: Icons.add_box, text: "계약 물품 정보 추가",
          onTap: () {
            ct.contractList.add({});
            setState(() {});
          }
        ),
        ButtonT.IconText(
            icon: ct.vatType == 0 ? Icons.check_box : Icons.check_box_outline_blank, text: "부가세 포함",
            onTap: () {
              ct.vatType = 0;
              setState(() {});
            }
        ),
        ButtonT.IconText(
            icon: ct.vatType == 1 ? Icons.check_box : Icons.check_box_outline_blank, text: "부가세 별도",
            onTap: () {
              ct.vatType = 1;
              setState(() {});
            }
        ),
      ],
    ));


    return main = Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildAppbar(),
          SingleChildScrollView(
            padding: EdgeInsets.all(18),
            child: Column( crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: dividHeight,),
                csWidget,
                SizedBox(height: dividHeight * 4,),

                TextT.SubTitle(text:'계약상세 정보 입력' ),
                SizedBox(height: dividHeight,),
                ctInfoWidget,
                SizedBox(height: dividHeight,),
                Row(
                  children: [
                    ButtonT.IconText(
                        icon: Icons.file_copy_rounded,
                        text: '계약서 파일 선택',
                        onTap: () async {
                          FilePickerResult? result;
                          try {
                            result = await FilePicker.platform.pickFiles();
                          } catch (e) {
                            WidgetT.showSnackBar(context, text: '파일선택 오류');
                            print(e);
                          }
                          if(result != null){
                            WidgetT.showSnackBar(context, text: '파일선택');
                            if(result.files.isNotEmpty) {
                              String fileName = result.files.first.name;
                              print(fileName);
                              Uint8List fileBytes = result.files.first.bytes!;
                              ctFileByteList[fileName] = fileBytes;
                              print(ctFileByteList[fileName]!.length);
                            }
                          }
                          setState(() {});
                        }
                    ),
                    SizedBox(width: dividHeight,),
                    ButtonT.IconText(
                        icon: Icons.file_copy_rounded,
                        text: '파일 선택',
                        onTap: () async {
                          FilePickerResult? result;
                          try {
                            result = await FilePicker.platform.pickFiles();
                          } catch (e) {
                            WidgetT.showSnackBar(context, text: '파일선택 오류');
                            print(e);
                          }
                          if(result != null){
                            WidgetT.showSnackBar(context, text: '파일선택');
                            if(result.files.isNotEmpty) {
                              String fileName = SystemT.generateRandomString(8); //result.files.first.name;
                              print(fileName);
                              Uint8List fileBytes = result.files.first.bytes!;
                              fileByteList[fileName] = fileBytes;
                              ct.filesDetail[fileName] = {
                                'date': DateTime.now().microsecondsSinceEpoch,
                                'title': '',
                                'name': result.files.first.name,
                              };
                              print(fileByteList[fileName]!.length);
                            }
                          }
                          setState(() {});
                        }
                    ),
                  ],
                ),
                SizedBox(height: dividHeight * 4,),

                TextT.SubTitle(text:'계약 물품 정보 입력' ),
                SizedBox(height: dividHeight,),
                ListBoxT.Columns(children: ctW),
              ],
            ),
          ),
          /// action
          buildAction(),
        ],
      ),
    );
  }




  Widget buildAppbar() {
    return Container();
  }


  Widget buildAction() {
    var saveWidget = ButtonT.Action(
      context, "계약 저장",
      expend: true,
      altText: "변경된 계약 정보를 저장하시겠습니까? ",
      icon: Icons.save, backgroundColor: StyleT.accentColor.withOpacity(0.5),
      init: () {
        if(cs == null) return Messege.toReturn(context, "거래처 정보를 입력하세요.", false);
        if(cs.businessName == "") return Messege.toReturn(context, "올바른 거래처 정보를 입력하세요.", false);
        if(ct.ctName == "") return Messege.toReturn(context, "계약명을 입력하세요.", false);
        if(ct.manager == "") return Messege.toReturn(context, "담당자를 입력하세요.", false);
        if(ct.contractAt == 0) return Messege.toReturn(context, "계약일자를 입력하세요.", false);

        for(var ctl in ct.contractList) {
          if(ctl["item"]  == null) return Messege.toReturn(context, "계약 물품을 입력하세요.", false);
          if(ctl["item"] == "") return Messege.toReturn(context, "계약 물품을 입력하세요.", false);
        }
        return true;
      },
      onTap: () async {
        var data = await DatabaseM.updateContract(ct, files: fileByteList, ctFiles: ctFileByteList);
        if(data == null) return Messege.toReturn(context, "Database Error", false);

        widget.refresh();
        widget.parent.onCloseButtonClicked!();
      },
    );

    return Column(
      children: [
        Row(
          children: [
            saveWidget,
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return mainBuild();
  }
}
