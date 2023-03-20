import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/revenue.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/login/auth_service.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:evers/ui/dialog_transration.dart';
import 'package:evers/ui/pure.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../class/Customer.dart';
import 'package:http/http.dart' as http;

import '../class/schedule.dart';
import '../class/system.dart';
import '../class/transaction.dart';
import '../helper/aes.dart';
import '../helper/dialog.dart';
import '../helper/interfaceUI.dart';
import 'dialog_contract.dart';
import 'dl.dart';
import 'ex.dart';
import 'ip.dart';
import 'ux.dart';

class DialogCS extends StatelessWidget {

  static var strok_1 = 0.7;
  static var strok_2 = 1.4;

  static var allSize = 2700.0;
  static ScrollController titleHorizontalScroll = new ScrollController();

  static Map<String, TextEditingController> textInputs = new Map();
  static Map<String, String> textOutput = new Map();
  static Map<String, bool> editInput = {};

  static dynamic showCustomerDialog(BuildContext context, { Customer? org, bool isCreate=false }) async {
    WidgetT.loadingBottomSheet(context, text: '서버에서 데이터를 로드중입니다.');

    var dividHeight = 6.0;

    Map<String, Uint8List> fileByteList = {};
    var cs = Customer.fromDatabase({});

    if(org != null) {
      await org.update();
      var jsonString = jsonEncode(org.toJson());
      var json = jsonDecode(jsonString);
      cs = Customer.fromDatabase(json);

      if(cs.state == 'DEL') {
        Navigator.pop(context);
        WidgetT.showSnackBar(context, text: '삭제되었습니다.');
        return;
      }
    }

    List<Contract> cts = [];
    if(!isCreate) cts = await FireStoreT.getCtWithCs(cs.id);
    List<TS> tslist = [];
    if(!isCreate) tslist = await FireStoreT.getTransactionCs(cs.id);

    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };

              List<Widget> widgets = [];

              List<Widget> widgetsCt = [];
              widgetsCt.add(WidgetUI.titleRowNone([ '순번', '거래처', '계약명', '담당자', '연락처', '', ], [ 32, 250, 250, 150, 150, 999, ]));
              for(int i = 0; i < cts.length; i++) {
                if(i == 0)  widgetsCt.add(WidgetT.dividHorizontal(size: 0.7));

                var ct = cts[i];
                var csName = ct.csName; //SystemT.getCS(ct.csUid) ?? Customer.fromDatabase({});
                Widget w = SizedBox();
                w = InkWell(
                    onTap: () async {
                      await DialogCT.showInfoCt(context, ct);
                    },
                    child: Container( height: 28,
                      decoration: StyleT.inkStyleNone(color: Colors.transparent),
                      child: Row(
                          children: [
                            WidgetT.excelGrid(label: '${i + 1}', width: 32),
                            //WidgetT.dividViertical(),
                            //WidgetT.text('${ct.id}', size: 10, width: 120),
                            WidgetT.excelGrid(text: ct.csName, width: 250),
                            WidgetT.excelGrid(text: '${ct.ctName}',  width: 250),
                            WidgetT.excelGrid(text: '${ct.manager}',  width: 150),
                            WidgetT.excelGrid(text: '${ct.managerPhoneNumber}', width: 150),
                          ]
                      ),
                    ));
                widgetsCt.add(w);
                widgetsCt.add(WidgetT.dividHorizontal(size: 0.35));
              }


              var gridStyle = StyleT.inkStyle(round: 8, color: Colors.black.withOpacity(0.03), stroke: 0.7, strokeColor: StyleT.titleColor.withOpacity(0.35));
              //var gridStyle = StyleT.inkStyleNone(round: 8, color: Colors.black.withOpacity(0.03), stroke: 0.7, );

              widgets.add(Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WidgetT.title('거래처 상세 정보', size: 14),
                  SizedBox(height: dividHeight,),
                  Container( decoration: gridStyle,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        children: [
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '구분',),
                                  WidgetT.dividViertical(),
                                  WidgetT.dropMenu(dropMenus: ['개인', '사업자',], width: 250,
                                    onEdite: (i, data) { cs.bsType = data; },
                                    text: cs.bsType,
                                  ),

                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '거래처분류',),
                                  WidgetT.dividViertical(),
                                  WidgetT.dropMenu(dropMenus: ['매입', '매출', '매입/매출'], width: 250,
                                    onEdite: (i, data) { cs.csType = data; },
                                    text: cs.csType,
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '상호명',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, 'cs상호명', width: 250,
                                    onEdite: (i, data) { cs.businessName = data; },
                                    text: cs.businessName,
                                  ),

                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '대표이름',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, 'cs대표이름', width: 250,
                                    onEdite: (i, data) { cs.representative = data; },
                                    text: cs.representative,
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '사업자등록번호',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '사업자등록번호1', width: 70,
                                    onEdite: (i, data) { cs.businessRegistrationNumber['0'] = data; },
                                    text: cs.businessRegistrationNumber['0'],
                                  ),
                                  WidgetT.title('ㅡ', width: 20,),
                                  WidgetT.excelInput(context, '사업자등록번호2', width: 70,
                                    onEdite: (i, data) { cs.businessRegistrationNumber['1'] = data; },
                                    text: cs.businessRegistrationNumber['1'],
                                  ),
                                  WidgetT.title('ㅡ', width: 20,),
                                  WidgetT.excelInput(context, '사업자등록번호3', width: 70,
                                    onEdite: (i, data) { cs.businessRegistrationNumber['2'] = data; },
                                    text: cs.businessRegistrationNumber['2'],
                                  ),

                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '팩스번호',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '팩스번호1', width: 70,
                                    onEdite: (i, data) { cs.faxNumber['0'] = data; },
                                    text: cs.faxNumber['0'],
                                  ),
                                  WidgetT.title('ㅡ', width: 20,),
                                  WidgetT.excelInput(context, '팩스번호2', width: 70,
                                    onEdite: (i, data) { cs.faxNumber['1'] = data; },
                                    text: cs.faxNumber['1'],
                                  ),
                                  WidgetT.title('ㅡ', width: 20,),
                                  WidgetT.excelInput(context, '팩스번호3', width: 70,
                                    onEdite: (i, data) { cs.faxNumber['2'] = data; },
                                    text: cs.faxNumber['2'],
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '담당자',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '담당자', width: 250,
                                    onEdite: (i, data) { cs.manager = data; },
                                    text: cs.manager,
                                  ),
                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '전화번호',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '전화번호1', width: 250,
                                    onEdite: (i, data) { cs.companyPhoneNumber = data; },
                                    text: cs.companyPhoneNumber,
                                  ),
                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '모바일',),
                                  WidgetT.excelInput(context, '모바일전화번호', width: 250,
                                    onEdite: (i, data) { cs.phoneNumber = data; },
                                    text: cs.phoneNumber,
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '이메일',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '담당자이메일', width: 250,
                                    onEdite: (i, data) { cs.email = data; },
                                    text: cs.email,
                                  ),
                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '홈페이지',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '홈페이지', width: 250,
                                    onEdite: (i, data) { cs.website = data; },
                                    text: cs.website,
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( padding: EdgeInsets.all(0),
                            child: IntrinsicHeight(
                              child: Row(
                                  children: [
                                    WidgetEX.excelTitle(width: 150, text: '주소',),
                                    WidgetT.dividViertical(),
                                    Expanded(child: WidgetTF.textTitInput(context, '주소', isMultiLine: true, textSize: 12,
                                      onEdite: (i, data) { cs.address = data; },
                                      text: cs.address,
                                    ),)
                                  ]
                              ),
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( padding: EdgeInsets.all(0),
                            child: IntrinsicHeight(
                              child: Row(
                                  children: [
                                    WidgetEX.excelTitle(width: 150, text: '메모',),
                                    WidgetT.dividViertical(),
                                    Expanded(child: WidgetTF.textTitInput(context, '메모', isMultiLine: true, textSize: 12,
                                      onEdite: (i, data) { cs.memo = data; },
                                      text: cs.memo,
                                    ),)
                                  ]
                              ),
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '업태',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '업태', width: 250,
                                    onEdite: (i, data) { cs.businessType = data; },
                                    text: cs.businessType,
                                  ),
                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '종목 ( , , )',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '종목', width: 400,
                                      onEdite: (i, data) { cs.businessItem = data.toString().split(','); },
                                      text: cs.businessItem.join(', '), value: cs.businessItem.join(',')
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container( height: 28,
                            child: Row(
                                children: [
                                  WidgetEX.excelTitle(width: 150, text: '은행',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '은행', width: 250,
                                    onEdite: (i, data) { cs.account['bank'] = data; },
                                    text: cs.account['bank'],
                                  ),
                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '계좌번호',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '계좌번호', width: 250,
                                    onEdite: (i, data) { cs.account['number'] = data; },
                                    text: cs.account['number'],
                                  ),

                                  WidgetT.dividViertical(),
                                  WidgetEX.excelTitle(width: 150, text: '예금주',),
                                  WidgetT.dividViertical(),
                                  WidgetT.excelInput(context, '예금주', width: 250,
                                    onEdite: (i, data) { cs.account['user'] = data; },
                                    text: cs.account['user'],
                                  ),
                                ]
                            ),
                          ),
                          WidgetT.dividHorizontal(size: 0.35),
                          Container(
                              child: IntrinsicHeight(
                                child: Row(
                                  children: [
                                    SizedBox(width: dividHeight * 2, height: 28,),
                                    WidgetT.text('첨부파일', size: 10),
                                    SizedBox(width: dividHeight,),
                                    Expanded(
                                        flex: 7,
                                        child: Container(
                                          padding: EdgeInsets.all(dividHeight),
                                          child: Wrap(
                                            runSpacing: dividHeight, spacing: dividHeight * 3,
                                            children: [
                                              for(int i = 0; i < cs.filesMap.length; i++)
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    InkWell(
                                                        onTap: () async {
                                                          var downloadUrl = cs.filesMap.values.elementAt(i);
                                                          var fileName = cs.filesMap.keys.elementAt(i);
                                                          var ens = ENAES.fUrlAES(downloadUrl);

                                                          var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                                          print(url);
                                                          await launchUrl( Uri.parse(url),
                                                            webOnlyWindowName: true ? '_blank' : '_self',
                                                          );
                                                        },
                                                        child: Container(
                                                            decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.accentLowColor.withOpacity(0.05)),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                SizedBox(width: 6,),
                                                                WidgetT.title(cs.filesMap.keys.elementAt(i),),
                                                                TextButton(
                                                                    onPressed: () {
                                                                      WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                                                                      FunT.setStateDT();
                                                                    },
                                                                    style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                                                    child: Container( height: 28, width: 28,
                                                                      child: WidgetT.iconMini(Icons.cancel),)
                                                                ),
                                                              ],
                                                            ))
                                                    ),
                                                  ],
                                                ),
                                              for(int i = 0; i < fileByteList.length; i++)
                                                Row(
                                                  children: [
                                                    SizedBox(width: dividHeight * 0.5),
                                                    InkWell(
                                                        onTap: () {
                                                          PDFX.showPDFtoDialog(context, data: fileByteList.values.elementAt(i), name: fileByteList.keys.elementAt(i));
                                                        },
                                                        child: Container(
                                                            decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.accentLowColor.withOpacity(0.05)),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                SizedBox(width: 6,),
                                                                WidgetT.title(fileByteList.keys.elementAt(i),),
                                                                TextButton(
                                                                    onPressed: () {
                                                                      fileByteList.remove(fileByteList.keys.elementAt(i));
                                                                      FunT.setStateDT();
                                                                    },
                                                                    style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                                                    child: Container( height: 28, width: 28,
                                                                      child: WidgetT.iconMini(Icons.cancel),)
                                                                ),
                                                              ],
                                                            ))
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),)),
                                  ],
                                ),
                              )
                          ),
                        ],),
                    ),),
                  SizedBox(height: dividHeight,),
                  Row(children: [
                    TextButton(onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform.pickFiles();
                      if( result != null && result.files.isNotEmpty ){
                        String fileName = result.files.first.name;
                        print(fileName);
                        Uint8List fileBytes = result.files.first.bytes!;
                        fileByteList[fileName] = fileBytes;
                        print(fileByteList[fileName]!.length);
                        FunT.setStateDT();
                      }
                    },
                      style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                      child: Container( height: 28,
                          child: Row(
                            children: [
                              WidgetT.iconMini(Icons.file_copy_rounded),
                              WidgetT.title('첨부파일추가',),
                              SizedBox(width: dividHeight,),
                            ],
                          )),),
                  ],),

                  if(!isCreate) SizedBox(height: dividHeight * 4,),
                  if(!isCreate) WidgetT.title('계약목록', size: 14),
                  if(!isCreate) SizedBox(height: dividHeight,),
                  if(!isCreate) Container( decoration: gridStyle, child: ClipRRect( borderRadius: BorderRadius.circular(8), child: Column(children: widgetsCt,))),
                ],));

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.dlColor.withOpacity(0), width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '거래처 상세 정보', onSave: () async {
                  var alert = await DialogT.showAlertDl(context, title: cs.businessName ?? 'NULL');
                  if(alert == false) {
                    WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                    return;
                  }

                  await FireStoreT.updateCustomer(cs, files: fileByteList,);
                  //original = cs;
                  WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                  Navigator.pop(context);
                },),
                content: SingleChildScrollView(
                  child: Container(
                    width: 1280,
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widgets,
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  Row(
                    children: [
                      Expanded(
                        child:TextButton(
                          onPressed: () async {
                            if(cs.businessName == '') {
                              WidgetT.showSnackBar(context, text:'상호명을 입력해 주세요.'); return;
                            }
                            
                            var alert = await DialogT.showAlertDl(context, title: cs.businessName ?? 'NULL');
                            if(alert == false) {
                              WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                              return;
                            }

                            await FireStoreT.updateCustomer(cs, files: fileByteList,);
                            //original = cs;
                            WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                            Navigator.pop(context);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('거래처 저장', style: StyleT.titleStyle(),),
                                  SizedBox(width: 6,),
                                ],
                              )
                          )
                      ),),
                    ],
                  ),
                ],
              );
            },
          );
        });

    if(aa == null) aa = false;
    return aa;
  }

  static dynamic selectCS(BuildContext context, List<Customer> customerSearch) async {
    var searchInput = TextEditingController();
    //var _dragging = false;
    //List<XFile> _list = [];
    //late DropzoneViewController controller;
    Customer? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.transparent, width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '거래처 선택', ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(12),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container( height: 36, width: 500,
                                child: TextFormField(
                                  maxLines: 1,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  textInputAction: TextInputAction.search,
                                  keyboardType: TextInputType.text,
                                  onEditingComplete: () async {
                                    customerSearch = await SystemT.searchCSMeta(searchInput.text,);
                                    FunT.setStateDT();
                                  },
                                  onChanged: (text) {
                                    FunT.setStateDT();
                                  },
                                  decoration: InputDecoration(
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(0),
                                        borderSide: BorderSide(
                                            color: StyleT.accentLowColor, width: 2)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                      borderSide: BorderSide(
                                          color: StyleT.accentColor, width: 2),),
                                    filled: true,
                                    fillColor: StyleT.accentColor.withOpacity(0.07),
                                    suffixIcon: Icon(Icons.keyboard),
                                    hintText: '',
                                    contentPadding: EdgeInsets.all(6),
                                  ),
                                  controller: searchInput,
                                ),
                              ),),
                          ],
                        ),
                        SizedBox(height: 18,),
                        for(var cs in customerSearch)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: TextButton(
                                onPressed: () {
                                  Navigator.pop(context, cs);
                                },
                                style: StyleT.buttonStyleOutline(round: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 1.4, elevation: 0, padding: 0),
                                child: Container( height: 32,
                                  child: Row(
                                      children: [
                                        WidgetT.text('${cs.id}', size: 10, width: 120),
                                        WidgetT.dividViertical(),
                                        WidgetT.title('${cs.businessName}', size: 12, width: 200),
                                        WidgetT.dividViertical(),
                                        WidgetT.title('${cs.representative}', size: 12, width: 150),
                                        WidgetT.dividViertical(),
                                        WidgetT.title('${cs.companyPhoneNumber}', size: 12, width: 100),
                                        WidgetT.dividViertical(),
                                        WidgetT.title('${cs.phoneNumber}', size: 12, width: 100),
                                      ]
                                  ),
                                )),
                          ),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                  Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        child:
                        Row(
                          children: [
                            Container( height: 28,
                              child: TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: Colors.redAccent.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.cancel),
                                      Text('닫기', style: StyleT.titleStyle(),),
                                      SizedBox(width: 12,),
                                    ],
                                  )
                              ),
                            ),
                            SizedBox(width:  8,),
                            /* Container( height: 28,
                              child: TextButton(
                                  onPressed: () async {
                                  },
                                  style: StyleT.buttonStyleOutline(padding: 0, round: 0, strock: 1.4, elevation: 8,
                                      color: StyleT.accentColor.withOpacity(0.5)),
                                  child: Row( mainAxisSize: MainAxisSize.min,
                                    children: [
                                      WidgetT.iconMini(Icons.save),
                                      Text('계약추가', style: StyleT.titleStyle(),),
                                      SizedBox(width: 12,),
                                    ],
                                  )
                              ),
                            ),*/
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              );
            },
          );
        });

    return aa;
  }

  ///고객 매입/매출 관리화면
  static dynamic showPUrRevTs(BuildContext context, Customer org ) async {
    WidgetT.loadingBottomSheet(context, text: '서버에서 데이터를 로드중입니다.');

    var dividHeight = 6.0;
    var tabDsColor =  new Color(0xff777777), tabEnColor = new Color(0xffd7d7d7);

    var menus = [ '거래처정보', '매입/매출/수납 정보' ];
    var currentMenu = menus.first;

    Map<String, Uint8List> fileByteList = {};
    var cs = Customer.fromDatabase({});

    if(org != null) {
      await org.update();
      var jsonString = jsonEncode(org.toJson());
      var json = jsonDecode(jsonString);
      cs = Customer.fromDatabase(json);

      if(cs.state == 'DEL') {
        Navigator.pop(context);
        WidgetT.showSnackBar(context, text: '삭제되었습니다.');
        return;
      }
    }

    List<Contract> cts = await FireStoreT.getCtWithCs(cs.id);
    List<TS> tslist = await FireStoreT.getTransactionCs(cs.id);
    List<Purchase> purs = await FireStoreT.getPur_withCS(cs.id);
    List<Revenue> rev = await FireStoreT.getRevenueWithCS(cs.id);


    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };

              List<Widget> widgets = [];

              List<Widget> widgetsCt = [];
              widgetsCt.add(WidgetUI.titleRowNone([ '순번', '거래처', '계약명', '담당자', '연락처', '', ], [ 32, 250, 250, 150, 150, 999, ]));
              for(int i = 0; i < cts.length; i++) {
                if(i == 0)  widgetsCt.add(WidgetT.dividHorizontal(size: 0.7));

                var ct = cts[i];
                var csName = ct.csName; //SystemT.getCS(ct.csUid) ?? Customer.fromDatabase({});
                Widget w = SizedBox();
                w = InkWell(
                    onTap: () async {
                      await DialogCT.showInfoCt(context, ct);
                    },
                    child: Container( height: 28,
                      decoration: StyleT.inkStyleNone(color: Colors.transparent),
                      child: Row(
                          children: [
                            WidgetT.excelGrid(label: '${i + 1}', width: 32),
                            //WidgetT.dividViertical(),
                            //WidgetT.text('${ct.id}', size: 10, width: 120),
                            WidgetT.excelGrid(text: ct.csName, width: 250),
                            WidgetT.excelGrid(text: '${ct.ctName}',  width: 250),
                            WidgetT.excelGrid(text: '${ct.manager}',  width: 150),
                            WidgetT.excelGrid(text: '${ct.managerPhoneNumber}', width: 150),
                          ]
                      ),
                    ));
                widgetsCt.add(w);
                widgetsCt.add(WidgetT.dividHorizontal(size: 0.35));
              }


              var gridStyle = StyleT.inkStyle(round: 8, color: Colors.black.withOpacity(0.03), stroke: 0.7, strokeColor: StyleT.titleColor.withOpacity(0.35));
              var divHeight = SizedBox(height: dividHeight * 8,);
              //var gridStyle = StyleT.inkStyleNone(round: 8, color: Colors.black.withOpacity(0.03), stroke: 0.7, );

              List<Widget> widgets_pur = [];
              widgets_pur.add(WidgetT.title('매입목록', size: StyleT.subTitleSize));
              widgets_pur.add(SizedBox(height: dividHeight,));
              widgets_pur.add(WidgetUI.titleRowNone([ '', '순번', '매입일자', '품목', '단위', '수량', '단가', '공급가액', 'VAT', '합계', '메모', ],
                  [ 28, 28, 100, 150 + 28 * 2, 50, 80, 80 + 28, 80, 80, 80, 999 ], background: true));
              for(int i = 0; i < purs.length; i++) {
                Widget w = SizedBox();
                var pu = purs[i];
                var item = SystemT.getItem(pu.item);
                var itemName = (item == null) ? pu.item : item.name;
                var itemUnit = (item == null) ? '' : item.unit;

                w = Column(
                  children: [
                    InkWell(
                      onTap: () {

                      },
                      child: Container(
                        height: 36,
                        child: Row(
                            children: [
                              InkWell(
                                onTap: () async {
                                  FunT.setStateDT();
                                },
                                child: WidgetT.iconMini(Icons.check_box_outline_blank, size: 28),
                              ),
                              WidgetT.excelGrid( width: 28, label: '${i + 1}',),
                              WidgetT.excelGrid( width: 100, text: StyleT.dateInputFormatAtEpoch(pu.purchaseAt.toString()),),
                              WidgetT.excelGrid( width: 150 + 28 * 2, text: itemName,),
                              WidgetT.excelGrid(text: itemUnit, width: 50),
                              WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(pu.count.toString()),),
                              WidgetT.excelGrid(textLite: true, width: 80 + 28, text: StyleT.krw(pu.unitPrice.toString()),),
                              WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(pu.supplyPrice.toString()),),
                              WidgetT.excelGrid(textLite: true,  width: 80, text: StyleT.krw(pu.vat.toString()), ),
                              WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(pu.totalPrice.toString()),),
                              Expanded(
                                child: WidgetT.excelGrid(textLite: true, width: 200, text: pu.memo,),
                              ),
                              InkWell(
                                onTap: () async {
                                  FilePickerResult? result;
                                  try {
                                    result = await FilePicker.platform.pickFiles();
                                  } catch (e) {
                                    WidgetT.showSnackBar(context, text: '파일선택 오류');
                                    print(e);
                                  }
                                  FunT.setStateD = () { setStateS(() {}); };
                                  if(result != null){
                                    //WidgetT.showSnackBar(context, text: '파일선택');
                                    if(result.files.isNotEmpty) {
                                      WidgetT.loadingBottomSheet(context, text: '거래명세서 파일을 시스템에 업로드 중입니다.');
                                      String fileName = result.files.first.name;
                                      print(fileName);
                                      Uint8List fileBytes = result.files.first.bytes!;
                                      await FireStoreT.updatePurchase(pu, files: { fileName: fileBytes });
                                      Navigator.pop(context);
                                    }
                                  }
                                  FunT.setStateDT();
                                },
                                child: WidgetT.iconMini(Icons.file_copy_rounded, size: 36),
                              ),
                              InkWell(
                                onTap: () async {
                                  Purchase? tmpPu = await DialogRE.showInfoPu(context, org: pu);
                                  FunT.setStateD = () { setStateS(() {}); };

                                  if(tmpPu != null) {
                                    var pu = await FireStoreT.getPurchaseDoc(tmpPu.id);
                                    purs.removeAt(i);
                                    purs.insert(0, pu);
                                    FunT.setStateDT();
                                  }
                                },
                                child: WidgetT.iconMini(Icons.create, size: 36),
                              ),
                            ]
                        ),
                      ),
                    ),
                    if(pu.filesMap.length > 0) WidgetT.dividHorizontal(size: 0.2),
                    if(pu.filesMap.length > 0)
                      Container( height: 28,
                        child: Row(
                            children: [
                              WidgetT.excelGrid( width: 150 + 28 * 2, label: '거래명세서 첨부파일', ),
                              WidgetT.dividViertical(height: 28),
                              Expanded(child: Container( padding: EdgeInsets.all(0),  child: Wrap(
                                runSpacing: dividHeight * 2, spacing: dividHeight * 2,
                                children: [
                                  for(int i = 0; i < pu.filesMap.length; i++)
                                    TextButton(
                                        onPressed: () async {
                                          var downloadUrl = pu.filesMap.values.elementAt(i);
                                          var fileName = pu.filesMap.keys.elementAt(i);
                                          print(downloadUrl);
                                          var res = await http.get(Uri.parse(downloadUrl));
                                          var bodyBytes = res.bodyBytes;
                                          print(bodyBytes.length);
                                          PDFX.showPDFtoDialog(context, data: bodyBytes, name: fileName);
                                        },
                                        style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                        child: Container(padding: EdgeInsets.all(0), child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            WidgetT.iconMini(Icons.cloud_done, size: 28),
                                            WidgetT.title(pu.filesMap.keys.elementAt(i),),
                                            TextButton(
                                                onPressed: () {
                                                  //pu.filesMap.remove(pu.filesMap.keys.elementAt(i));
                                                  //FunT.setStateDT();
                                                },
                                                style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                                child: Container( height: 28, width: 28,
                                                  child: WidgetT.iconMini(Icons.cancel),)
                                            ),
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
                widgets_pur.add(w);
                widgets_pur.add(WidgetT.dividHorizontal(size: 0.35));
              }
              widgets_pur.add(WidgetT.dividHorizontal(size: 0.35));
              widgets.add(Column( crossAxisAlignment: CrossAxisAlignment.start, children: widgets_pur,));
              widgets.add(divHeight);

              List<Widget> widgets_rev = [];
              widgets_rev.add(WidgetT.title('매출목록', size: StyleT.subTitleSize));
              widgets_rev.add(SizedBox(height: dividHeight,));
              widgets_rev.add(WidgetUI.titleRowNone([ '', '순번', '매출일자', '품목', '단위', '수량', '단가', '공급가액', 'VAT', '합계', '메모', ],
                  [ 28, 28, 100, 150 + 28 * 2, 50, 80, 80 + 28, 80, 80, 80, 999 ], background: true));
              for(int i = 0; i < rev.length; i++) {
                var revenue = rev[i];
                var item = SystemT.getItem(revenue.item);
                var itemName = (item == null) ? revenue.item : item.name;
                var itemUnit = (item == null) ? '' : item.unit;

                var w = Container(
                  height: StyleT.listHeight,
                  child: Row(
                      children: [
                        InkWell(
                            onTap: () async {

                              FunT.setStateDT();
                            },
                            child: Container(height: 28, width: 28,
                              child: WidgetT.iconMini(Icons.check_box_outline_blank),)
                        ),
                        WidgetT.excelGrid( width: 28, label: '${i + 1}',),
                        WidgetT.excelInput(context, '$i::c매출일자', width: 100,
                          /*onEdite: (i, data) async {
                            if(StyleT.dateFormatAtEpoch(revenue.revenueAt.toString()) == StyleT.dateFormatAtEpoch(StyleT.dateEpoch(data).toString())) {
                              return;
                            }
                            if(StyleT.dateEpoch(data) == 0) {
                              WidgetT.showSnackBar(context, text: '입력된 날짜 형식이 올바르지 않습니다. 다시 확인해 주세요.');
                              return;
                            }
                            if(isPop) return; isPop = true;
                            var check = await DialogT.showAlertDl(context, text: '${StyleT.dateFormatAtEpoch(StyleT.dateEpoch(data).toString())} 매입 날자를 변경 하시겠습니까?');
                            if(check) {
                              var jsStr = jsonEncode(revenue.toJson());
                              var js = jsonDecode(jsStr);
                              var org = Revenue.fromDatabase(js);
                              revenue.revenueAt = StyleT.dateEpoch(data);
                              await FireStoreT.updateRevenue(revenue, org: org);
                            }
                            isPop = false;
                          },*/
                          text: StyleT.dateInputFormatAtEpoch(revenue.revenueAt.toString()),
                        ),
                        WidgetT.excelGrid( width: 150 + 28 * 2, text: itemName,),
                        WidgetT.excelGrid(text: itemUnit, width: 50),
                        WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(revenue.count.toString()),),
                        WidgetT.excelGrid(textLite: true, width: 80 + 28, text: StyleT.krw(revenue.unitPrice.toString()),),
                        WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(revenue.supplyPrice.toString()),),
                        WidgetT.excelGrid(textLite: true,  width: 80, text: StyleT.krw(revenue.vat.toString()), ),
                        WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(revenue.totalPrice.toString()),),
                        Expanded(
                          child: WidgetT.excelInput(context, '$i::메모', width: 200, index: i,
                            onEdite: (i, data) { revenue.memo  = data ?? ''; },
                            text: revenue.memo,
                          ),
                        ),
                        //WidgetT.dividViertical(height: 28),
                        InkWell(
                            onTap: () async {
                              WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                              FunT.setStateDT();
                            },
                            child: Container( height: 32, width: 32,
                              child: WidgetT.iconMini(Icons.delete),)
                        ),
                      ]
                  ),
                );
                widgets_rev.add(w);
                widgets_rev.add(WidgetT.dividHorizontal(size: 0.35));
              }
              widgets_rev.add(WidgetT.dividHorizontal(size: 0.35));
              widgets.add(Column( crossAxisAlignment: CrossAxisAlignment.start, children: widgets_rev,));
              widgets.add(divHeight);

              List<Widget> widgetsTs= [];
              widgetsTs.add(WidgetT.title('수납목록', size: StyleT.subTitleSize));
              widgetsTs.add(SizedBox(height: dividHeight,));
              widgetsTs.add(WidgetUI.titleRowNone([ '', '순번', '거래일자', '구분', '적요', '결제', '금액', '메모', ],
                  [ 28, 28, 150, 100, 250, 180 + 28, 120, 250,], background: true ),);
              for(int i = 0; i < tslist.length; i++) {
                var ts = tslist[i];
                //allPayedAmount += tmpTs.amount;

                var w = InkWell(
                    onTap: () {

                    },
                    child: Container(
                      height: StyleT.listHeight,
                      child: Row(
                          children: [
                            WidgetT.title('', width: 28),
                            WidgetT.excelGrid(label:'${i + 1}', width: 28),
                            WidgetT.excelGrid(textLite: true, text: StyleT.dateFormatAtEpoch(ts.transactionAt.toString()), width: 150, ),
                            WidgetT.excelGrid(textLite: true, text: (ts.type != 'PU') ? '수입' : '지출', width: 100, ),
                            WidgetT.excelGrid(width: 250, text: '${ts.summary}',),
                            WidgetT.excelGrid(textLite: true, text: SystemT.getAccountName(ts.account), width: 180 + 28,),
                            WidgetT.excelGrid(text: StyleT.krwInt(ts.amount), width: 120,
                                color: (ts.type != 'PU') ? Colors.blue.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                            WidgetT.excelGrid(textLite: true, width: 250, text: ts.memo,),
                            InkWell(
                                onTap: () {

                                },
                                child: Container( height: 32, width: 32,
                                  child: WidgetT.iconMini(Icons.open_in_new),)
                            ),
                          ]
                      ),
                    ));
                widgetsTs.add(w);
                widgetsTs.add(WidgetT.dividHorizontal(size: 0.35));
              }
              widgetsTs.add(WidgetT.dividHorizontal(size: 0.35));
              widgets.add(Column( crossAxisAlignment: CrossAxisAlignment.start, children: widgetsTs,));

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.dlColor.withOpacity(0), width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '거래처 상세 정보', onSave: () async {
                  var alert = await DialogT.showAlertDl(context, title: cs.businessName ?? 'NULL');
                  if(alert == false) {
                    WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                    return;
                  }

                  await FireStoreT.updateCustomer(cs, files: fileByteList,);
                  //original = cs;
                  WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                  Navigator.pop(context);
                },),
                content: SingleChildScrollView(
                  child: Container(
                    width: 1280,
                    padding: EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widgets,
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                ],
              );
            },
          );
        });

    if(aa == null) aa = false;
    return aa;
  }

  /// 고객 매입 관리화면
  /// 매입 정렬 완료
  /// 03.08 요청사항 반영 - 지불현황에서 지급추가 버튼 활성화
  static dynamic showPurInCs(BuildContext context, Customer cs) async {
    WidgetT.loadingBottomSheet(context);
    var dividHeight = 6.0;

    ///List<Purchase> purs = await FireStoreT.getPur_withCS(cs.id);
    List<Purchase> purs = await cs.getPurchase();
    purs.sort((a, b) => b.purchaseAt.compareTo(a.purchaseAt) );

    /// 추후 toCopy Function 생성 필요
    List<TS> tslist = [];
    List<TS> tslistCr = [];

    var pageLimit = 10;
    var puIndex = 0;
    var tsIndex = 0;

    Map<dynamic, TS> tsMap = await FireStoreT.getTS_CS_PU_date(cs.id);
    tslist = tsMap.values.toList();

    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              var allPay = 0;
              var allPayedAmount = 0;

              List<Widget> puW = [];
              puW.add(WidgetUI.titleRowNone([ '', '순번', '매입일자', '품목', '단위', '수량', '단가', '공급가액', 'VAT', '합계', '메모', ],
                  [ 28, 28, 100, 150 + 28 * 2, 50, 80, 80 + 28, 80, 80, 80, 999 ], background: true));

              int startIndex = puIndex * pageLimit;
              for(int i = startIndex; i < startIndex + pageLimit; i++) {
                if(i >= purs.length) break;

                Widget w = SizedBox();
                var pu = purs[i];
                var item = SystemT.getItem(pu.item);
                var itemName = (item == null) ? pu.item : item.name;
                var itemUnit = (item == null) ? '' : item.unit;

                allPay += pu.totalPrice;
                w = Column(
                  children: [
                    InkWell(
                      onTap: () {

                      },
                      child: Container(
                        height: 36,
                        child: Row(
                            children: [
                              InkWell(
                                  onTap: () async {
                                    FunT.setStateDT();
                                  },
                                  child: WidgetT.iconMini(Icons.check_box_outline_blank, size: 28),
                              ),
                              WidgetT.excelGrid( width: 28, label: '${i + 1}',),
                              WidgetT.excelGrid( width: 100, text: StyleT.dateInputFormatAtEpoch(pu.purchaseAt.toString()),),
                              WidgetT.excelGrid( width: 150 + 28 * 2, text: itemName,),
                              WidgetT.excelGrid(text: itemUnit, width: 50),
                              WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(pu.count.toString()),),
                              WidgetT.excelGrid(textLite: true, width: 80 + 28, text: StyleT.krw(pu.unitPrice.toString()),),
                              WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(pu.supplyPrice.toString()),),
                              WidgetT.excelGrid(textLite: true,  width: 80, text: StyleT.krw(pu.vat.toString()), ),
                              WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(pu.totalPrice.toString()),),
                              Expanded(
                                child: WidgetT.excelGrid(textLite: true, width: 200, text: pu.memo,),
                              ),
                              InkWell(
                                  onTap: () async {
                                    FilePickerResult? result;
                                    try {
                                      result = await FilePicker.platform.pickFiles();
                                    } catch (e) {
                                      WidgetT.showSnackBar(context, text: '파일선택 오류');
                                      print(e);
                                    }
                                    FunT.setStateD = () { setStateS(() {}); };
                                    if(result != null){
                                      //WidgetT.showSnackBar(context, text: '파일선택');
                                      if(result.files.isNotEmpty) {
                                        WidgetT.loadingBottomSheet(context, text: '거래명세서 파일을 시스템에 업로드 중입니다.');
                                        String fileName = result.files.first.name;
                                        print(fileName);
                                        Uint8List fileBytes = result.files.first.bytes!;
                                        await FireStoreT.updatePurchase(pu, files: { fileName: fileBytes });
                                        Navigator.pop(context);
                                      }
                                    }
                                    FunT.setStateDT();
                                  },
                                  child: WidgetT.iconMini(Icons.file_copy_rounded, size: 36),
                              ),
                              InkWell(
                                onTap: () async {
                                  Purchase? tmpPu = await DialogRE.showInfoPu(context, org: pu);
                                  FunT.setStateD = () { setStateS(() {}); };

                                  if(tmpPu != null) {
                                    var pu = await FireStoreT.getPurchaseDoc(tmpPu.id);
                                    purs.removeAt(i);
                                    purs.insert(0, pu);
                                    FunT.setStateDT();
                                  }
                                },
                                child: WidgetT.iconMini(Icons.create, size: 36),
                              ),
                            ]
                        ),
                      ),
                    ),
                    if(pu.filesMap.isNotEmpty)
                      Container(
                      height: 36, padding: EdgeInsets.only(bottom: dividHeight),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              WidgetT.excelGrid( textLite: true, width: 150 + 28 * 2, text: '거래명세서 첨부파일', ),
                              Expanded(child: Container(   child: Wrap(
                                runSpacing: dividHeight * 2, spacing: dividHeight * 2,
                                children: [
                                  for(int i = 0; i < pu.filesMap.length; i++)
                                    InkWell(
                                        onTap: () async {
                                          var downloadUrl = pu.filesMap.values.elementAt(i);
                                          var fileName = pu.filesMap.keys.elementAt(i);

                                          var ens = ENAES.fUrlAES(downloadUrl);

                                          var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName';
                                          print(url);
                                          await launchUrl( Uri.parse(url),
                                            webOnlyWindowName: true ? '_blank' : '_self',
                                          );
                                          FunT.setStateMain();
                                        },
                                        child: Container(
                                          color: Colors.grey.withOpacity(0.15),
                                            padding: EdgeInsets.all(0), 
                                            child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            WidgetT.iconMini(Icons.cloud_done, size: 28),
                                            WidgetT.text(pu.filesMap.keys.elementAt(i), size: 12),
                                            SizedBox(width: dividHeight,)
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
                puW.add(w);
                puW.add(WidgetT.dividHorizontal(size: 0.35));
              }
              puW.add(SizedBox(height: dividHeight,));
              puW.add(
                Row(
                  children: [
                    for(int i = 0; i < (purs.length / pageLimit).ceil(); i++)
                      Container(
                        padding: EdgeInsets.only(left: dividHeight),
                        child: InkWell(
                          onTap: () {
                            puIndex = i;
                            FunT.setStateDT();
                          },
                          child: Container(
                            width: 32, height: 32,
                            alignment: Alignment.center,
                            color: Colors.grey.withOpacity(0.15),
                            child: WidgetT.title('${i + 1}'),
                          ),
                        ),
                      )
                  ],
                )
              );

              List<Widget> tsW = [];
              tsW.add(WidgetUI.titleRowNone([ '', '순번', '거래일자', '구분', '적요', '결재', '금액', '메모', ], [ 28, 28, 100, 100, 200, 150 + 28, 100, 999,], background: true),);
              startIndex = tsIndex * pageLimit;
              for(int i = startIndex; i < startIndex + pageLimit; i++) {
                if(i >= tslist.length) break;

                var tmpTs = tslist[i];
                allPayedAmount += tmpTs.amount;
                var w = InkWell(
                  onTap: () async {
                    TS? ts = await DialogTS.showInfoTs(context, org: tmpTs);
                    if(ts != null) tmpTs = TS.fromDatabase(ts.toJson());
                    FunT.setStateD = () { setStateS(() {}); };
                    FunT.setStateDT();
                  },
                  child: Container( height: 36,
                    child: Row(
                        children: [
                          WidgetT.excelGrid( label: '', width: 28),
                          WidgetT.excelGrid(label: '${i + 1}', width: 28),
                          WidgetT.excelGrid(textLite: true, text: StyleT.dateFormatAtEpoch(tmpTs.transactionAt.toString()), width: 100, ),
                          WidgetT.excelGrid(textLite: true, text: (tmpTs.type != 'PU') ? '수입' : '지출', width: 100, ),
                          WidgetT.excelGrid(width: 200, text: '${tmpTs.summary}',),
                          WidgetT.excelGrid(textLite: true, text: SystemT.getAccountName(tmpTs.account), width: 150 + 28, ),
                          WidgetT.excelGrid(text: StyleT.krwInt(tmpTs.amount), width: 100,
                              textColor: (tmpTs.type != 'PU') ? Colors.blue.withOpacity(0.5) : Colors.red.withOpacity(0.5)),
                          Expanded(child: WidgetT.excelGrid(textLite: true, width: 250, text: tmpTs.memo,)),
                          InkWell(
                              onTap: () async {
                                TS? ts = await DialogTS.showInfoTs(context, org: tmpTs);
                                if(ts != null) tmpTs = TS.fromDatabase(ts.toJson());
                                FunT.setStateD = () { setStateS(() {}); };
                                FunT.setStateDT();
                              },
                              child:WidgetT.iconMini(Icons.create, size: 36),
                          ),
                        ]
                    ),
                  ),
                );
                tsW.add(w);
                tsW.add(WidgetT.dividHorizontal(size: 0.35));
              }
              tsW.add(SizedBox(height: dividHeight,));
              tsW.add(
                  Row(
                    children: [
                      for(int i = 0; i < (tslist.length / pageLimit).ceil(); i++)
                        Container(
                          padding: EdgeInsets.only(left: dividHeight),
                          child: InkWell(
                            onTap: () {
                              tsIndex = i;
                              FunT.setStateDT();
                            },
                            child: Container(
                              width: 32, height: 32,
                              alignment: Alignment.center,
                              color: Colors.grey.withOpacity(0.15),
                              child: WidgetT.title('${i + 1}'),
                            ),
                          ),
                        )
                    ],
                  )
              );

              List<Widget> tsCW = [];
              for(int i = 0; i < tslistCr.length; i++) {
                var tmpTs = tslistCr[i];

                var w = TextButton(
                    onPressed: null,
                    style: StyleT.buttonStyleOutline(round: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.35, elevation: 0, padding: 0),
                    child: Container( height: 28,
                      child: Row(
                          children: [
                            TextButton(
                                onPressed: () async {
                                  tslistCr.removeAt(i);
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                child: Container( height: 28, width: 28,
                                  child: WidgetT.iconMini(Icons.cancel),)
                            ),
                            WidgetT.dividViertical(),
                            WidgetT.title('${i + 1}', width: 28),
                            WidgetT.dividViertical(),
                            WidgetT.excelInput(context, '$i::ts거래일자', width: 150, label: '거래일자',
                              onEdite: (i, data) { tmpTs.transactionAt = StyleT.dateEpoch(data); },
                              text: StyleT.dateInputFormatAtEpoch(tmpTs.transactionAt.toString()),
                            ),
                            WidgetT.dividViertical(),
                            WidgetT.excelGrid(text: (tmpTs.type != 'PU') ? '수입' : '지출', width: 100, label: '구분'),
                            WidgetT.dividViertical(),
                            WidgetT.excelInput(context, '$i::ts적요', width: 250, index: i, label: '적요',
                              onEdite: (i, data) { tmpTs.summary = data; },
                              text: '${tmpTs.summary}',
                            ),
                            WidgetT.dividViertical(),
                            WidgetT.excelGrid(text:  (SystemT.accounts[tmpTs.account] != null) ? SystemT.accounts[tmpTs.account]!.name : 'NULL', width: 180, label: '결제'),
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
                                    items: SystemT.accounts.keys.map((item) => DropdownMenuItem<dynamic>(
                                      value: item,
                                      child: Text(
                                        (SystemT.accounts[item] != null) ? SystemT.accounts[item]!.name : 'NULL',
                                        style: StyleT.titleStyle(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )).toList(),
                                    onChanged: (value) async {
                                      tmpTs.account = value;
                                      await FunT.setStateDT();
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
                            ),
                            WidgetT.dividViertical(),
                            WidgetT.excelInput(context, '$i::ts금액', width: 120, label: '금액',
                              onEdite: (i, data) {
                                tmpTs.amount = int.tryParse(data) ?? 0;
                              },
                              text: StyleT.krwInt(tmpTs.amount), value: tmpTs.amount.toString(),),
                            WidgetT.dividViertical(),
                            WidgetT.excelInput(context, '$i::ts메모', width: 250, index: i, label: '메모',
                              onEdite: (i, data) { tmpTs.memo = data;},
                              text: tmpTs.memo,
                            ),
                            WidgetT.dividViertical(),
                            TextButton(
                                onPressed: () {

                                },
                                style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                child: Container( height: 28, width: 28,
                                  child: WidgetT.iconMini(Icons.open_in_new),)
                            ),
                          ]
                      ),
                    ));
                tsCW.add(w);
              }

              List<Widget> tsAllW = [];
              tsAllW.add(WidgetUI.titleRowNone([ '총매입금액', '총지급금액', '총미지급금액', ], [ 250, 250, 250, ]),);
              tsAllW.add(WidgetT.dividHorizontal(size: 0.7));
              tsAllW.add( Container( height: 36,
                child: Row(
                    children: [
                      WidgetT.excelGrid(text: StyleT.krwInt(allPay), width: 250),
                      WidgetT.excelGrid(width: 250,text: StyleT.krwInt(allPayedAmount), ),
                      WidgetT.excelGrid( width: 250, text: StyleT.krwInt(allPay - allPayedAmount),),
                    ]
                ),
              ));

              var dividCol = SizedBox(height: dividHeight * 8,);
              var btnStyle = StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 2);
              var gridStyle = StyleT.inkStyle(round: 8, color: Colors.black.withOpacity(0.03), stroke: 0.7, strokeColor: StyleT.titleColor.withOpacity(0.35));

              return AlertDialog(
                  backgroundColor: StyleT.white,
                  elevation: 36,
                  shape: RoundedRectangleBorder(side: BorderSide(color: StyleT.dlColor.withOpacity(0), width: 0.01), borderRadius: BorderRadius.circular(0)),
                  titlePadding: EdgeInsets.zero,
                  contentPadding: EdgeInsets.zero,
                  title: WidgetDT.dlTitle(context, title: '거래처 (고객) 정보', onSave: () async {
                    var alert = await DialogT.showAlertDl(context, title: 'NULL');
                    if(alert == false) {
                      WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                      return;
                    }

                    for(var t in tslistCr) {
                      t.csUid = cs.id;
                      await t.update();
                    }
                    //await FireStoreT.updateContract(ct, files: fileByteList, ctFiles: ctFileByteList);
                    //original.fromJson(ct.toJson());
                    WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                    Navigator.pop(context);
                  },),
                  content: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(dividHeight * 3),
                      child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          WidgetT.title('거래처', size: 14), SizedBox(height: dividHeight,),
                          Container( height: 36,
                              decoration: gridStyle,
                              child: Row( mainAxisSize: MainAxisSize.min,
                                children: [
                                  WidgetT.title(cs.businessName ?? '', width: 250),
                                ],
                              )
                          ),

                          dividCol,
                          WidgetT.title('매입목록', size: StyleT.subTitleSize),
                          SizedBox(height: dividHeight,),
                          Container(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: puW,)),

                          dividCol,
                          WidgetT.title('지불현황', size: StyleT.subTitleSize),
                          SizedBox(height: dividHeight,),
                          Container(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: tsW,)),

                          if(tslistCr.length > 0)
                            SizedBox(height: dividHeight,),
                          if(tslistCr.length > 0)
                            Column(
                              children: [
                                TextButton(
                                  onPressed: null,
                                  style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 0.35),
                                  child: Column(
                                    children: [
                                      for(var w in tsCW) w,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: dividHeight,),
                          Row(
                            children: [
                              TextButton(
                                  onPressed: () async {
                                    // 03.08 요청사항 반영 --------
                                    // 지불현황에서 지급추가 버튼 활성화 - 신규 창에서 처리
                                    // tslistCr.add(TS.fromDatabase({ 'transactionAt': DateTime.now().microsecondsSinceEpoch, 'type': 'PU' }));
                                    var tsCreate = await WidgetPR.showCreateTS(context);
                                    if(tsCreate != null) {
                                      // 신규 거래 추가됨
                                      // 데이터베이스 스트림
                                      // 거래기록 거래처 별 데이터 고도화 필요
                                      Map<dynamic, TS> tsMap = await FireStoreT.getTS_CS_PU_date(cs.id);
                                      // 추구 cs.getTransration() 으로 가져오도록 변경
                                      tslist = tsMap.values.toList();
                                    }
                                    // 03.08 요청사항 반영 --------
                                    
                                    FunT.setStateDT();
                                  },
                                  style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                                  child: Container(padding: EdgeInsets.all(0), child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [

                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.add_box),),
                                      WidgetT.title('지급추가' ),
                                      SizedBox(width: 6,),
                                    ],
                                  ))
                              ),
                              SizedBox(width: 6,),
                              if(tslistCr.length > 0) Container( padding: EdgeInsets.only(right: dividHeight * 2),
                                child: TextButton(
                                    onPressed: () async {
                                      FunT.setStateDT();
                                    },
                                    style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                                    child: Container(padding: EdgeInsets.all(0), child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container( height: 28, width: 28,
                                          child: WidgetT.iconMini(Icons.save),),
                                        WidgetT.title('수납저장' ),
                                        SizedBox(width: 6,),
                                      ],
                                    ))
                                ),
                              ),
                            ],
                          ),

                          dividCol,
                          WidgetT.title('금액현황', size: 14), SizedBox(height: dividHeight,),
                          Container(decoration: gridStyle, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: tsAllW,)),
                        ],
                      ),
                    ),
                  ),
                  actionsPadding: EdgeInsets.zero,
                  actions: [
                    if(tslistCr.length > 0)
                      Row(
                        children: [
                          Expanded(child:TextButton(
                              onPressed: () async {
                                var alert = await DialogT.showAlertDl(context, text: '거래처 매입내역 변경사항을 저장하시겠습니까?');
                                if(alert == false) {
                                  WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                                  return;
                                }

                                for(var t in tslistCr) {
                                  t.csUid = cs.id;
                                  await t.update();
                                }
                                //await FireStoreT.updateContract(ct, files: fileByteList, ctFiles: ctFileByteList);
                                //original.fromJson(ct.toJson());
                                WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                                Navigator.pop(context);
                              },
                              style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                              child: Container(
                                  color: StyleT.accentColor.withOpacity(0.5), height: 42,
                                  child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      WidgetT.iconMini(Icons.check_circle),
                                      Text('변경사항 저장하기', style: StyleT.titleStyle(),),
                                      SizedBox(width: 6,),
                                    ],
                                  )
                              )
                          ),),
                        ],
                      ),
                  ]
              );
            },
          );
        });

    if(aa == null) aa = false;
    return aa;
  }
  ///고객 매출 관리화면
  static dynamic showRevInCs(BuildContext context, Customer cs) async {
    WidgetT.loadingBottomSheet(context);
    var dividHeight = 6.0;

    var vatTypeList = [ 0, 1, ];
    var vatTypeNameList = [ '포함', '미포함', ];
    var currentVatType = 0;

    List<Revenue> rev = await FireStoreT.getRevenueWithCS(cs.id);
    //await original.update();
    //var jsonString = jsonEncode(purchase.toJson());
    //var json = jsonDecode(jsonString);

    /// 추후 toCopy Function 생성 필요
    List<TS> tslist = [];
    List<TS> tslistCr = [];
    List<Schedule> schedule = [];

    bool isPop = false;

    Map<dynamic, TS> tsMap = await FireStoreT.getTransactionQr_CsReDt(cs.id);
    tslist = tsMap.values.toList();
    //schedule = await FireStoreT.getSCH_CT(ct.id);

    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              var allPay = 0;
              var allPayedAmount = 0;

              List<Widget> revW = [];
              revW.add(WidgetT.title('매입목록', size: 14));
              revW.add(SizedBox(height: dividHeight,));
              revW.add(WidgetUI.titleRowNone([ '', '순번', '매출일자', '품목', '단위', '수량', '단가', '공급가액', 'VAT', '합계', '메모', ],
                  [ 28, 28, 100, 150 + 28 * 2, 50, 80, 80 + 28, 80, 80, 80, 999 ]));
              revW.add(WidgetT.dividHorizontal(size: 0.7));
              for(int i = 0; i < rev.length; i++) {
                Widget w = SizedBox();
                var revenue = rev[i];
                var item = SystemT.getItem(revenue.item);
                var itemName = (item == null) ? revenue.item : item.name;
                var itemUnit = (item == null) ? '' : item.unit;

                allPay += revenue.totalPrice;
                w = Column(
                  children: [
                    Container( height: 28,
                      child: Row(
                          children: [
                            TextButton(
                                onPressed: () async {

                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                child: Container(height: 28, width: 28,
                                  child: WidgetT.iconMini(Icons.check_box_outline_blank),)
                            ),
                            //WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid( width: 28, label: '${i + 1}',),
                            //WidgetT.dividViertical(height: 28),
                            WidgetT.excelInput(context, '$i::c매출일자', width: 100,
                              /*onEdite: (i, data) async {
                                if(StyleT.dateFormatAtEpoch(revenue.revenueAt.toString()) == StyleT.dateFormatAtEpoch(StyleT.dateEpoch(data).toString())) {
                                  return;
                                }
                                if(StyleT.dateEpoch(data) == 0) {
                                  WidgetT.showSnackBar(context, text: '입력된 날짜 형식이 올바르지 않습니다. 다시 확인해 주세요.');
                                  return;
                                }
                                if(isPop) return; isPop = true;
                                var check = await DialogT.showAlertDl(context, text: '${StyleT.dateFormatAtEpoch(StyleT.dateEpoch(data).toString())} 매입 날자를 변경 하시겠습니까?');
                                if(check) {
                                  var jsStr = jsonEncode(revenue.toJson());
                                  var js = jsonDecode(jsStr);
                                  var org = Revenue.fromDatabase(js);
                                  revenue.revenueAt = StyleT.dateEpoch(data);
                                  await FireStoreT.updateRevenue(revenue, org: org);
                                }
                                isPop = false;
                              },*/
                              text: StyleT.dateInputFormatAtEpoch(revenue.revenueAt.toString()),
                            ),
                            //WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid( width: 150 + 28 * 2, text: itemName,),
                            //WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid(text: itemUnit, width: 50),
                            //WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(revenue.count.toString()),),
                            //WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid(textLite: true, width: 80 + 28, text: StyleT.krw(revenue.unitPrice.toString()),),
                            //WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(revenue.supplyPrice.toString()),),
                            //WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid(textLite: true,  width: 80, text: StyleT.krw(revenue.vat.toString()), ),
                            //WidgetT.dividViertical(height: 28),
                            WidgetT.excelGrid(textLite: true, width: 80, text: StyleT.krw(revenue.totalPrice.toString()),),
                            //WidgetT.dividViertical(height: 28),
                            Expanded(
                              child: WidgetT.excelInput(context, '$i::메모', width: 200, index: i,
                                onEdite: (i, data) { revenue.memo  = data ?? ''; },
                                text: revenue.memo,
                              ),
                            ),
                            //WidgetT.dividViertical(height: 28),
                            TextButton(
                                onPressed: () async {
                                  WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                child: Container( height: 28, width: 28,
                                  child: WidgetT.iconMini(Icons.delete),)
                            ),
                          ]
                      ),
                    ),
                  ],
                );
                revW.add(w);
                revW.add(WidgetT.dividHorizontal(size: 0.35));
              }

              List<Widget> tsW = [];
              tsW.add(WidgetT.title('수금현황', size: 14));
              tsW.add(WidgetUI.titleRowNone([ '', '순번', '거래일자', '구분', '적요', '결재', '금액', '메모', ], [ 28, 28, 100, 100, 200, 150 + 28, 100, 999,]),);
              tsW.add(WidgetT.dividHorizontal(size: 0.7));
              for(int i = 0; i < tslist.length; i++) {
                var tmpTs = tslist[i];
                allPayedAmount += tmpTs.amount;
                var w = Container( height: 28,
                  child: Row(
                      children: [
                        WidgetT.excelGrid( label: '', width: 28),
                        WidgetT.excelGrid(label: '${i + 1}', width: 28),
                        WidgetT.excelGrid(textLite: true, text: StyleT.dateFormatAtEpoch(tmpTs.transactionAt.toString()), width: 100, ),
                        WidgetT.excelGrid(textLite: true, text: (tmpTs.type != 'PU') ? '수입' : '지출', width: 100, ),
                        WidgetT.excelGrid(width: 200, text: '${tmpTs.summary}',),
                        WidgetT.excelGrid(textLite: true, text: SystemT.getAccountName(tmpTs.account), width: 150 + 28, ),
                        WidgetT.excelGrid(text: StyleT.krwInt(tmpTs.amount), width: 100,
                            color: (tmpTs.type != 'PU') ? Colors.blue.withOpacity(0.2) : Colors.red.withOpacity(0.2)),
                        Expanded(child: WidgetT.excelGrid(textLite: true, width: 250, text: tmpTs.memo,)),
                        TextButton(
                            onPressed: () {

                            },
                            style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                            child: Container( height: 28, width: 28,
                              child: WidgetT.iconMini(Icons.open_in_new),)
                        ),
                      ]
                  ),
                );
                tsW.add(w);
                tsW.add(WidgetT.dividHorizontal(size: 0.35));
              }

              List<Widget> tsCW = [];
              for(int i = 0; i < tslistCr.length; i++) {
                var tmpTs = tslistCr[i];

                var w = TextButton(
                    onPressed: null,
                    style: StyleT.buttonStyleOutline(round: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.35, elevation: 0, padding: 0),
                    child: Container( height: 28,
                      child: Row(
                          children: [
                            TextButton(
                                onPressed: () async {
                                  tslistCr.removeAt(i);
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                child: Container( height: 28, width: 28,
                                  child: WidgetT.iconMini(Icons.cancel),)
                            ),
                            WidgetT.dividViertical(),
                            WidgetT.title('${i + 1}', width: 28),
                            WidgetT.dividViertical(),
                            WidgetT.excelInput(context, '$i::ts거래일자', width: 150, label: '거래일자',
                              onEdite: (i, data) { tmpTs.transactionAt = StyleT.dateEpoch(data); },
                              text: StyleT.dateInputFormatAtEpoch(tmpTs.transactionAt.toString()),
                            ),
                            WidgetT.dividViertical(),
                            WidgetT.excelGrid(text: (tmpTs.type != 'PU') ? '수입' : '지출', width: 100, label: '구분'),
                            WidgetT.dividViertical(),
                            WidgetT.excelInput(context, '$i::ts적요', width: 250, index: i, label: '적요',
                              onEdite: (i, data) { tmpTs.summary = data; },
                              text: '${tmpTs.summary}',
                            ),
                            WidgetT.dividViertical(),
                            WidgetT.excelGrid(text:  (SystemT.accounts[tmpTs.account] != null) ? SystemT.accounts[tmpTs.account]!.name : 'NULL', width: 180, label: '결제'),
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
                                    items: SystemT.accounts.keys.map((item) => DropdownMenuItem<dynamic>(
                                      value: item,
                                      child: Text(
                                        (SystemT.accounts[item] != null) ? SystemT.accounts[item]!.name : 'NULL',
                                        style: StyleT.titleStyle(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )).toList(),
                                    onChanged: (value) async {
                                      tmpTs.account = value;
                                      await FunT.setStateDT();
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
                            ),
                            WidgetT.dividViertical(),
                            WidgetT.excelInput(context, '$i::ts금액', width: 120, label: '금액',
                              onEdite: (i, data) {
                                tmpTs.amount = int.tryParse(data) ?? 0;
                              },
                              text: StyleT.krwInt(tmpTs.amount), value: tmpTs.amount.toString(),),
                            WidgetT.dividViertical(),
                            WidgetT.excelInput(context, '$i::ts메모', width: 250, index: i, label: '메모',
                              onEdite: (i, data) { tmpTs.memo = data;},
                              text: tmpTs.memo,
                            ),
                            WidgetT.dividViertical(),
                            TextButton(
                                onPressed: () {

                                },
                                style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                                child: Container( height: 28, width: 28,
                                  child: WidgetT.iconMini(Icons.open_in_new),)
                            ),
                          ]
                      ),
                    ));
                tsCW.add(w);
              }

              List<Widget> tsAllW = [];
              tsAllW.add( WidgetT.titleRowW([ '금액현황', ], [ 999,], isTitle: true,));
              tsAllW.add( WidgetT.titleRowW([ '총매입금액', '총지급금액', '총미지급금액', ], [ 250, 250, 250, ]),);
              tsAllW.add( TextButton(
                  onPressed: null,
                  style: StyleT.buttonStyleOutline(round: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.35, elevation: 0, padding: 0),
                  child: Container( height: 28,
                    child: Row(
                        children: [
                          WidgetT.excelGrid(text: StyleT.krwInt(allPay), width: 250),
                          WidgetT.dividViertical(),
                          WidgetT.excelGrid(width: 250,text: StyleT.krwInt(allPayedAmount), ),
                          WidgetT.dividViertical(),
                          WidgetT.excelGrid( width: 250, text: StyleT.krwInt(allPay - allPayedAmount),),
                        ]
                    ),
                  )),);

              var dividCol = Column(
                children: [
                  SizedBox(height: dividHeight * 4,),
                  //WidgetT.dividHorizontal(size: 0.7),
                  SizedBox(height: dividHeight * 4,),
                ],
              );
              var btnStyle = StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 2);
              return AlertDialog(
                  backgroundColor: StyleT.white,
                  elevation: 36,
                  shape: RoundedRectangleBorder(side: BorderSide(color: StyleT.dlColor, width: 0.35), borderRadius: BorderRadius.circular(0)),
                  titlePadding: EdgeInsets.zero,
                  contentPadding: EdgeInsets.zero,
                  title: WidgetDT.dlTitle(context, title: '거래처 (고객) 정보', onSave: () async {
                    var alert = await DialogT.showAlertDl(context, title: 'NULL');
                    if(alert == false) {
                      WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                      return;
                    }

                    for(var t in tslistCr) {
                      t.csUid = cs.id;
                      await t.update();
                    }
                    //await FireStoreT.updateContract(ct, files: fileByteList, ctFiles: ctFileByteList);
                    //original.fromJson(ct.toJson());
                    WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                    Navigator.pop(context);
                  },),
                  content: SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(dividHeight * 3),
                      child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              WidgetT.title('거래처', width: 100),
                              TextButton(
                                onPressed: null,
                                style: StyleT.buttonStyleOutline(padding: 0, round: 0, elevation: 0, strock: 0.7, color: StyleT.backgroundColor.withOpacity(0.5)),
                                child: Container( height: 28, alignment: Alignment.center,
                                    child: Row( mainAxisSize: MainAxisSize.min,
                                      children: [
                                        //WidgetT.text('${ct.csUid}', size: 10, width: 120),
                                        //WidgetT.dividViertical(height: 28),
                                        WidgetT.title(cs.businessName ?? '', width: 250),
                                      ],
                                    )),),
                            ],
                          ),

                          dividCol,
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: revW,),

                          dividCol,
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: tsW,),

                          if(tslistCr.length > 0)
                            SizedBox(height: dividHeight,),
                          if(tslistCr.length > 0)
                            Column(
                              children: [
                                TextButton(
                                  onPressed: null,
                                  style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 0.35),
                                  child: Column(
                                    children: [
                                      for(var w in tsCW) w,
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          SizedBox(height: dividHeight,),
                          Row(
                            children: [
                              TextButton(
                                  onPressed: () async {
                                    tslistCr.add(TS.fromDatabase({ 'transactionAt': DateTime.now().microsecondsSinceEpoch, 'type': 'PU' }));
                                    FunT.setStateDT();
                                  },
                                  style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                                  child: Container(padding: EdgeInsets.all(0), child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [

                                      Container( height: 28, width: 28,
                                        child: WidgetT.iconMini(Icons.add_box),),
                                      WidgetT.title('지급추가' ),
                                      SizedBox(width: 6,),
                                    ],
                                  ))
                              ),
                              SizedBox(width: 6,),
                              if(tslistCr.length > 0) Container( padding: EdgeInsets.only(right: dividHeight * 2),
                                child: TextButton(
                                    onPressed: () async {
                                      FunT.setStateDT();
                                    },
                                    style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                                    child: Container(padding: EdgeInsets.all(0), child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container( height: 28, width: 28,
                                          child: WidgetT.iconMini(Icons.save),),
                                        WidgetT.title('수납저장' ),
                                        SizedBox(width: 6,),
                                      ],
                                    ))
                                ),
                              ),
                            ],
                          ),

                          dividCol,
                          TextButton(
                            onPressed: null, style: btnStyle,
                            child: Column(
                              children: tsAllW,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actionsPadding: EdgeInsets.zero,
                  actions: [
                    if(tslistCr.length > 0)
                      Row(
                        children: [
                          Expanded(child:TextButton(
                              onPressed: () async {
                                var alert = await DialogT.showAlertDl(context, text: '거래처 매입내역 변경사항을 저장하시겠습니까?');
                                if(alert == false) {
                                  WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                                  return;
                                }

                                for(var t in tslistCr) {
                                  t.csUid = cs.id;
                                  await t.update();
                                }
                                //await FireStoreT.updateContract(ct, files: fileByteList, ctFiles: ctFileByteList);
                                //original.fromJson(ct.toJson());
                                WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                                Navigator.pop(context);
                              },
                              style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                              child: Container(
                                  color: StyleT.accentColor.withOpacity(0.5), height: 42,
                                  child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      WidgetT.iconMini(Icons.check_circle),
                                      Text('변경사항 저장하기', style: StyleT.titleStyle(),),
                                      SizedBox(width: 6,),
                                    ],
                                  )
                              )
                          ),),
                        ],
                      ),
                  ]
              );
            },
          );
        });

    if(aa == null) aa = false;
    return aa;
  }

  Widget build(context) {
    return Container();
  }
}
