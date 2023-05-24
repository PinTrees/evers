import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../class/Customer.dart';
import '../../class/contract.dart';
import '../../class/database/item.dart';
import '../../class/database/process.dart';
import '../../class/purchase.dart';
import '../../class/system.dart';
import '../../class/system/state.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../helper/aes.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/pdfx.dart';
import '../../ui/dialog_contract.dart';
import '../../ui/dialog_pu.dart';
import '../../ui/dialog_revenue.dart';
import '../../ui/dl.dart';
import '../../ui/ip.dart';
import '../../ui/ux.dart';

class WindowCsCreate extends WindowBaseMDI {
  Function refresh;

  WindowCsCreate({ required this.refresh }) { }

  @override
  _WindowCsCreateState createState() => _WindowCsCreateState();
}

class _WindowCsCreateState extends State<WindowCsCreate> {
  var dividHeight = 6.0;

  Map<String, Uint8List> fileByteList = {};
  Customer cs = Customer.fromDatabase({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
    cs = Customer.fromDatabase({});
    setState(() {});
  }

  Widget main = SizedBox();

  /// 이 함수는 매인 위젯 빌더입니다.
  Widget mainBuild() {
    var gridStyle = StyleT.inkStyle(round: 0, color: Colors.black.withOpacity(0.03), stroke: 1.4, strokeColor: StyleT.titleColor.withOpacity(0.15));

    return main = Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: SingleChildScrollView(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextT.Title(text: '거래처 상세 정보',),
                    SizedBox(height: dividHeight,),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: gridStyle,
                      child: ListBoxT.Columns(
                        spacing: 6,
                        children: [
                          ListBoxT.Rows(
                            spacing: 6 * 4,
                            children: [
                              InputWidget.DropButton(dropMenus: ['개인', '사업자',],  width: 250,
                                label: "구분",
                                onEdite: (i, data) { cs.bsType = data; },
                                setState: () { setState(() {}); },
                                text: cs.bsType,
                              ),
                              InputWidget.DropButton(dropMenus: ['매입', '매출', '매입/매출'], width: 250,
                                label: "거래처 분류",
                                onEdite: (i, data) { cs.csType = data; },
                                setState: () { setState(() {}); },
                                text: cs.csType,
                              ),
                            ]
                          ),
                          InputWidget.Lit(context, "cs상호명",
                            lavel: "상호명", width: 250,
                            onEdited: (i, data) { cs.businessName = data; },
                            setState: () { setState(() {}); },
                            text: cs.businessName,
                          ),
                          InputWidget.Lit(context, "cs::업태::input",
                            lavel: "업태", width: 250,
                            onEdited: (i, data) { cs.businessType = data; },
                            text: cs.businessType,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.Lit(context, "cs::종목::input",
                              lavel: "종목", width: 250,
                              onEdited: (i, data) { cs.businessItem = data.toString().split(','); },
                              text: cs.businessItem.join(', '), value: cs.businessItem.join(','),
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.Lit(context, "cs대표이름",
                            lavel: "대표이름", width: 250,
                            onEdited: (i, data) { cs.representative = data; },
                            text: cs.representative,
                            setState: () { setState(() {}); },
                          ),
                          ListBoxT.Rows(
                            spacingWidget: TextT.Lit(text:'  ㅡ  ', bold: true),
                            children: [
                              InputWidget.Lit(context, "cs::사업자등록번호1::input",
                                lavel: "사업자등록번호", width: 70,
                                onEdited: (i, data) { cs.businessRegistrationNumber['0'] = data; },
                                text: cs.businessRegistrationNumber['0'],
                                setState: () { setState(() {}); },
                              ),
                              InputWidget.Lit(context, "cs::사업자등록번호2::input",
                                width: 70,
                                onEdited: (i, data) { cs.businessRegistrationNumber['1'] = data; },
                                text: cs.businessRegistrationNumber['1'],
                                setState: () { setState(() {}); },
                              ),
                              InputWidget.Lit(context, "cs::사업자등록번호3::input",
                                width: 70,
                                onEdited: (i, data) { cs.businessRegistrationNumber['2'] = data; },
                                text: cs.businessRegistrationNumber['2'],
                                setState: () { setState(() {}); },
                              ),
                            ]
                          ),
                          ListBoxT.Rows(
                              spacingWidget: TextT.Lit(text:'  ㅡ  ', bold: true),
                              children: [
                                InputWidget.Lit(context, "cs::팩스번호1::input",
                                  lavel: "팩스번호", width: 70,
                                  onEdited: (i, data) { cs.faxNumber['0'] = data; },
                                  text: cs.faxNumber['0'],
                                  setState: () { setState(() {}); },
                                ),
                                InputWidget.Lit(context, "cs::팩스번호2::input",
                                  width: 70,
                                  onEdited: (i, data) { cs.faxNumber['1'] = data; },
                                  text: cs.faxNumber['1'],
                                  setState: () { setState(() {}); },
                                ),
                                InputWidget.Lit(context, "cs::팩스번호3::input",
                                  width: 70,
                                  onEdited: (i, data) { cs.faxNumber['2'] = data; },
                                  text: cs.faxNumber['2'],
                                  setState: () { setState(() {}); },
                                ),
                              ]
                          ),
                          InputWidget.Lit(context, "cs담당자",
                            lavel: "담당자", width: 250,
                            onEdited: (i, data) { cs.manager = data; },
                            text: cs.manager,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.Lit(context, "전화번호1",
                            lavel: "전화번호", width: 250,
                            onEdited: (i, data) { cs.companyPhoneNumber = data; },
                            text: cs.companyPhoneNumber,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.Lit(context, "cs::mobile::input",
                            lavel: "모바일", width: 250,
                            onEdited: (i, data) { cs.phoneNumber = data; },
                            text: cs.phoneNumber,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.Lit(context, "cs::email::input",
                            lavel: "이메일", width: 250,
                            onEdited: (i, data) { cs.email = data; },
                            text: cs.email,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.Lit(context, "cs::homePageurl::input",
                            lavel: "홈페이지", width: 500,
                            onEdited: (i, data) { cs.website = data; },
                            text: cs.website,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.Lit(context, "cs::address::input",
                            lavel: "주소", width: 500, isMultiLine: true,
                            onEdited: (i, data) { cs.address = data; },
                            text: cs.address,
                            setState: () { setState(() {}); },
                          ),
                          InputWidget.Lit(context, "cs::memo::input",
                            lavel: "메모", width: 500, isMultiLine: true, expand: true,
                            onEdited: (i, data) { cs.memo = data; },
                            text: cs.memo,
                            setState: () { setState(() {}); },
                          ),

                          ListBoxT.Rows(
                            spacing: 6 * 4,
                            children: [
                              InputWidget.Lit(context, "cs::은행::input",
                                lavel: "은행", width: 150,
                                onEdited: (i, data) { cs.account['bank'] = data; },
                                text: cs.account['bank'],
                                setState: () { setState(() {}); },
                              ),
                              InputWidget.Lit(context, "cs::계좌번호::input",
                                lavel: "계좌번호", width: 200,
                                onEdited: (i, data) { cs.account['number'] = data; },
                                text: cs.account['number'],
                                setState: () { setState(() {}); },
                              ),
                              InputWidget.Lit(context, "cs::예금주::input",
                                lavel: "예금주", width: 150,
                                onEdited: (i, data) { cs.account['user'] = data; },
                                text: cs.account['user'],
                                setState: () { setState(() {}); },
                              ),
                            ]
                          ),
                          Container(
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    TextT.Lit(text:"첨부파일", width: 100, size: 12, bold: true),
                                    Expanded(
                                        flex: 7,
                                        child: Container(
                                          padding: EdgeInsets.all(dividHeight),
                                          child: Wrap(
                                            runSpacing: dividHeight, spacing: dividHeight,
                                            children: [
                                              for(int i = 0; i < cs.filesMap.length; i++)
                                                ButtonT.IconText(
                                                  icon: Icons.cloud_done, text: cs.filesMap.keys.elementAt(i),
                                                  onTap: () async {
                                                    var downloadUrl = cs.filesMap.values.elementAt(i);
                                                    var fileName = cs.filesMap.keys.elementAt(i);
                                                    PdfManager.OpenPdf(downloadUrl, fileName);
                                                  },
                                                  leaging: ButtonT.Icon(
                                                    icon: Icons.delete,
                                                    onTap: () {
                                                      WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                                                      setState(() {});
                                                    }
                                                  )
                                                ),
                                              for(int i = 0; i < fileByteList.length; i++)
                                                ButtonT.IconText(
                                                    icon: Icons.file_copy_rounded, text: fileByteList.keys.elementAt(i),
                                                    onTap: () async {
                                                      PDFX.showPDFtoDialog(context, data: fileByteList.values.elementAt(i), name: fileByteList.keys.elementAt(i));
                                                    },
                                                    leaging: ButtonT.Icon(
                                                        icon: Icons.delete,
                                                        onTap: () {
                                                          fileByteList.remove(fileByteList.keys.elementAt(i));
                                                          setState(() {});
                                                        }
                                                    )
                                                ),
                                            ],
                                          ),)),
                                  ],
                                ),
                              )
                          ),
                        ],),),
                    SizedBox(height: dividHeight,),
                    ButtonT.IconText(
                        icon: Icons.file_copy_rounded, text: "첨부파일추가",
                        onTap: () async {
                          FilePickerResult? result = await FilePicker.platform.pickFiles();
                          if( result != null && result.files.isNotEmpty ){
                            String fileName = result.files.first.name;
                            fileByteList[fileName] = result.files.first.bytes!;
                            setState(() {});
                          }
                        },
                    ),
                  ],)
            ),
          ),

          /// action
          actionWidgets(),
        ],
      ),
    );
  }


  Widget actionWidgets() {
    return  Column(
      children: [
        Row(
          children: [
            ButtonT.Action(
              context, "거래처 저장",
              expend: true, icon: Icons.save,
              backgroundColor: StyleT.accentColor.withOpacity(0.5),
              init: () {
                if(cs.businessName == "") return Messege.toReturn(context, "상호명은 비워둘 수 없습니다.", false);
                if(cs.representative == "") return Messege.toReturn(context, "대표는 비워둘 수 없습니다.", false);
                return true;
              },
              altText: "신규 거래처 정보를 저장하시겠습니까?",
              onTap: () async {
                var result = await DatabaseM.updateCustomer(cs, files: fileByteList,);
                if(!result) Messege.toReturn(context, "Database Error", false);
                else Messege.toReturn(context, "저장됨", false);

                widget.refresh();
                widget.parent.onCloseButtonClicked!();
              },
            ),
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
