import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/employee.dart';
import 'package:evers/class/purchase.dart';
import 'package:evers/class/revenue.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/login/auth_service.dart';
import 'package:evers/ui/dialog_schedule.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../class/Customer.dart';
import 'package:http/http.dart' as http;

import '../class/schedule.dart';
import '../class/system.dart';
import '../helper/dialog.dart';
import '../helper/interfaceUI.dart';
import 'dl.dart';
import 'ex.dart';
import 'ip.dart';
import 'ux.dart';

class DialogEM extends StatelessWidget {

  static var strok_1 = 0.7;
  static var strok_2 = 1.4;

  static var allSize = 2700.0;
  static ScrollController titleHorizontalScroll = new ScrollController();

  static Map<String, TextEditingController> textInputs = new Map();
  static Map<String, String> textOutput = new Map();
  static Map<String, bool> editInput = {};

  /// 사원 생성 창
  static dynamic showInfoEmployee(BuildContext context, {Employee? org}) async {
    WidgetT.loadingBottomSheet(context);

    var dividHeight = 6.0;
    //var _dragging = false;
    //List<XFile> _list = [];
    //late DropzoneViewController controller;
    Map<String, Uint8List> fileByteList = {};
    Employee employee = Employee.fromDatabase({ 'joinAt': DateTime.now().microsecondsSinceEpoch, 'payType': 'M', });
    var payType = {
      'M': '월급',
      'D': '일급',
      'H': '시급',
    };

    if(org != null) {
      var jsonString = jsonEncode(org.toJson());
      var json = jsonDecode(jsonString);
      employee = Employee.fromDatabase(json);
    }

    Navigator.pop(context);
    // ignore: use_build_context_synchronously
    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };
              FunT.setStateDT();

              var allPay = 0, allPayedAmount = 0;

              var dividCol = SizedBox(height: dividHeight * 8,);
              var btnStyle = StyleT.buttonStyleOutline(color: StyleT.backgroundColor.withOpacity(0.5), elevation: 0,  padding: 0, strock: 1, round: 8);
              var gridStyle = StyleT.inkStyle(round: 8, color: Colors.black.withOpacity(0.03), stroke: 0.7, strokeColor: StyleT.titleColor.withOpacity(0.35));

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.white.withOpacity(0.01), width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '사원정보',),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(dividHeight * 3),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetT.title('사원 상세정보', size: 14),
                        SizedBox(height: dividHeight,),
                        Container( decoration: gridStyle,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Column(children: [
                              Container( height: 28,
                                child: Row(
                                    children: [
                                      WidgetEX.excelTitle(width: 150, text: '이름',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'em.name', width: 250,
                                        onEdite: (i, data) { employee.name = data; },
                                        text: employee.name,
                                      ),
                                      WidgetT.dividViertical(),
                                      WidgetEX.excelTitle(width: 150, text: '부서 선택',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelGrid(width: 250, text: '',),
                                      WidgetT.dividViertical(),
                                      WidgetEX.excelTitle(width: 150, text: '직급',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'em.직급', width: 250,
                                        onEdite: (i, data) { employee.rank = data; },
                                        text: employee.rank,
                                      ),
                                    ]
                                ),
                              ),
                              WidgetT.dividHorizontal(size: 0.35),
                              Container( height: 28,
                                child: Row(
                                    children: [
                                      WidgetEX.excelTitle(width: 150, text: '주민번호',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'em.rrn-0', width: 115,
                                        onEdite: (i, data) { employee.rrn[0] = data; },
                                        text: employee.rrn[0],
                                      ),
                                      WidgetT.title('ㅡ', width: 20),
                                      WidgetT.excelInput(context, 'em.rrn-1', width: 115,
                                        onEdite: (i, data) {
                                        if(data == '') return;
                                        employee.rrn[1] = data;
                                        },
                                        text: employee.getMaskingRRN(), value: ''
                                      ),
                                      WidgetT.dividViertical(),
                                      WidgetEX.excelTitle(width: 150, text: '휴대폰번호',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'em.휴대폰번호', width: 250,
                                        onEdite: (i, data) {  employee.mobileNum = data; },
                                        text: employee.mobileNum,
                                      ),

                                      WidgetT.dividViertical(),
                                      WidgetEX.excelTitle(width: 150, text: '전화번호',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'em.전화번호', width: 250,
                                        onEdite: (i, data) {  employee.phoneNum = data; },
                                        text: employee.phoneNum,
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
                                      WidgetT.excelInput(context, 'em.이메일', width: 250,
                                        onEdite: (i, data) { employee.email = data; },
                                        text: employee.email,
                                      ),
                                      WidgetT.dividViertical(),
                                      WidgetEX.excelTitle(width: 150, text: '주소',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'em.주소', width: 400,
                                        onEdite: (i, data) {  employee.address = data; },
                                        text: employee.address,
                                      ),
                                    ]
                                ),
                              ),
                              WidgetT.dividHorizontal(size: 0.35),
                              Container( height: 28,
                                child: Row(
                                    children: [
                                      WidgetEX.excelTitle(width: 150, text: '근무유형',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'em.근무유형', width: 250,
                                        onEdite: (i, data) { employee.workType = data; },
                                        text: employee.workType,
                                      ),
                                      WidgetT.dividViertical(),
                                      WidgetEX.excelTitle(width: 150, text: '입사일',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'em.입사일', width: 250,
                                        onEdite: (i, data) { employee.joinAt = StyleT.dateEpoch(data); },
                                        text: StyleT.dateInputFormatAtEpoch(employee.joinAt.toString()),
                                      ),
                                      WidgetEX.excelTitle(width: 150, text: '퇴사일',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'em.퇴사일', width: 250,
                                        onEdite: (i, data) { employee.leaveAt = StyleT.dateEpoch(data); },
                                        text: StyleT.dateInputFormatAtEpoch(employee.leaveAt.toString()),
                                      ),

                                    ]
                                ),
                              ),
                              WidgetT.dividHorizontal(size: 0.35),
                              Container( padding: EdgeInsets.all(0),
                                child: IntrinsicHeight(
                                  child: Row(
                                      children: [
                                        WidgetEX.excelTitle(width: 150, text: '메모',),
                                        WidgetT.dividViertical(),
                                        Expanded(child: WidgetTF.textTitInput(context, 'em.메모', isMultiLine: true, textSize: 12,
                                          onEdite: (i, data) { employee.memo = data; },
                                          text: employee.memo,
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
                                        WidgetEX.excelTitle(width: 150, text: '인사기록',),
                                        WidgetT.dividViertical(),
                                        Expanded(child: WidgetTF.textTitInput(context, 'em.인사기롣', isMultiLine: true, textSize: 12,
                                          onEdite: (i, data) { employee.personnelRecord = data; },
                                          text: employee.personnelRecord,
                                        ),)
                                      ]
                                  ),
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
                                                  for(int i = 0; i < employee.filesMap.length; i++)
                                                    Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        InkWell(
                                                            onTap: () async {
                                                              var downloadUrl = employee.filesMap.values.elementAt(i);
                                                              var fileName = employee.getFileName(employee.filesMap.keys.elementAt(i));
                                                              PdfManager.OpenPdf(downloadUrl, fileName);
                                                            },
                                                            child: Container(
                                                                decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.accentLowColor.withOpacity(0.05)),
                                                                child: Row(
                                                                  mainAxisSize: MainAxisSize.min,
                                                                  children: [
                                                                    SizedBox(width: 6,),
                                                                    WidgetT.title(employee.getFileName(employee.filesMap.keys.elementAt(i)),),
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
                                                                WidgetT.title(employee.getFileName(fileByteList.keys.elementAt(i)),),
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
                                              ),)),
                                      ],
                                    ),
                                  )
                              ),
                            ],),
                          ),),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            TextButton(
                                onPressed: () async {
                                  FilePickerResult? result;
                                  try {
                                    result = await FilePicker.platform.pickFiles();
                                  } catch (e) {
                                    WidgetT.showSnackBar(context, text: '파일선택 오류');
                                    print(e);
                                  }
                                  FunT.setStateD = () { setStateS(() {}); };
                                  if(result != null){
                                    WidgetT.showSnackBar(context, text: '파일선택');
                                    if(result.files.isNotEmpty) {
                                      String fileName = SystemT.generateRandomString(8); //result.files.first.name;
                                      print(fileName);
                                      Uint8List fileBytes = result.files.first.bytes!;
                                      fileByteList[fileName] = fileBytes;
                                      employee.filesDetail[fileName] = {
                                        'date': DateTime.now().microsecondsSinceEpoch,
                                        'title': '',
                                        'name': result.files.first.name,
                                      };
                                      print(fileByteList[fileName]!.length);
                                    }
                                  }
                                  FunT.setStateDT();
                                },
                                style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                                child: Container(
                                    height: 28,
                                    child: Row(
                                      children: [
                                        WidgetT.iconMini(Icons.file_copy_rounded),
                                        WidgetT.title('파일선택',),
                                        SizedBox(width: 6,),
                                      ],
                                    ))
                            ),
                          ],
                        ),

                        dividCol,

                        WidgetT.title('사원 계좌정보', size: 14),
                        SizedBox(height: dividHeight,),
                        Container( decoration: gridStyle,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Column(children: [
                              Container( height: 28,
                                child: Row(
                                    children: [
                                      WidgetEX.excelTitle(width: 150, text: '은행',),
                                      WidgetT.dividViertical(),
                                      WidgetT.dropMenu(dropMenus: BankList.list, width: 250,
                                        onEdite: (i, data) { employee.account.bank = data; },
                                        text: employee.account.bank + '은행',
                                      ),
                                      WidgetT.dividViertical(),
                                      WidgetEX.excelTitle(width: 150, text: '예금주',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'em.예금주', width: 250,
                                        onEdite: (i, data) { employee.account.holder = data; },
                                        text: employee.account.holder,
                                      ),
                                      WidgetT.dividViertical(),
                                      WidgetEX.excelTitle(width: 150, text: '계좌번호',),
                                      WidgetT.dividViertical(),
                                      WidgetT.excelInput(context, 'em.계좌번호', width: 250,
                                        onEdite: (i, data) { employee.account.number = data; },
                                        text: employee.account.number,
                                      ),
                                    ]
                                ),
                              ),
                            ],),
                          ),),

                        dividCol,

                        WidgetT.title('급여설정', size: 14),
                        SizedBox(height: dividHeight,),
                        Row(
                          children: [
                            Container( decoration: gridStyle,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Column(children: [
                                  Container( height: 28,
                                    child: Row(
                                        children: [
                                          WidgetEX.excelTitle(width: 150, text: '금액',),
                                          WidgetT.dividViertical(),
                                          WidgetT.excelInput(context, 'em.pay', width: 250,
                                            onEdite: (i, data) {
                                            employee.setPay(int.tryParse(data) ?? 0);
                                            },
                                            text: StyleT.krwInt(employee.getPay()), value: employee.getPay().toString(),
                                          ),
                                        ]
                                    ),
                                  ),
                                ],),
                              ),),
                            SizedBox(width: dividHeight,),
                            for(var p in payType.keys)
                              Container(
                                padding: EdgeInsets.only(right:  dividHeight),
                                child: TextButton(
                                    onPressed: () {
                                      employee.payType = p;
                                      FunT.setStateDT();
                                    },
                                    style: btnStyle,
                                    child: Row(
                                      children: [
                                        if(employee.payType != p)
                                          WidgetT.iconMini(Icons.check_box_outline_blank, size: 28),
                                        if(employee.payType == p)
                                          WidgetT.iconMini(Icons.check_box, size: 28),
                                        WidgetT.text(payType[p].toString()),
                                        SizedBox(width: dividHeight,),
                                      ],
                                    )
                                ),
                              ),
                          ],
                        ),

                        dividCol,

                        WidgetT.title('보험 및 구분', size: 14),
                        SizedBox(height: dividHeight,),
                        Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  employee.insurance.isEmploymentInsurance = !employee.insurance.isEmploymentInsurance;
                                  FunT.setStateDT();
                                },
                                style: btnStyle,
                                child: Row(
                                  children: [
                                    if(!employee.insurance.isEmploymentInsurance)
                                      WidgetT.iconMini(Icons.check_box_outline_blank, size: 28),
                                    if(employee.insurance.isEmploymentInsurance)
                                      WidgetT.iconMini(Icons.check_box, size: 28),
                                    WidgetT.text('고용보험 '),
                                    SizedBox(width: dividHeight,),
                                  ],
                                )
                              ),
                              SizedBox(width: dividHeight,),
                              TextButton(
                                  onPressed: () {
                                    employee.insurance.isElderlyInsuranceReduction = !employee.insurance.isElderlyInsuranceReduction;
                                    FunT.setStateDT();
                                  },
                                  style: btnStyle,
                                  child: Row(
                                    children: [
                                      if(!employee.insurance.isElderlyInsuranceReduction)
                                        WidgetT.iconMini(Icons.check_box_outline_blank, size: 28),
                                      if(employee.insurance.isElderlyInsuranceReduction)
                                        WidgetT.iconMini(Icons.check_box, size: 28),
                                      WidgetT.text('노인보험감면 '),
                                      SizedBox(width: dividHeight,),
                                    ],
                                  )
                              ),
                              SizedBox(width: dividHeight,),
                              TextButton(
                                  onPressed: () {
                                    employee.insurance.isIncomeTax = !employee.insurance.isIncomeTax;
                                    FunT.setStateDT();
                                  },
                                  style: btnStyle,
                                  child: Row(
                                    children: [
                                      if(!employee.insurance.isIncomeTax)
                                        WidgetT.iconMini(Icons.check_box_outline_blank, size: 28),
                                      if(employee.insurance.isIncomeTax)
                                        WidgetT.iconMini(Icons.check_box, size: 28),
                                      WidgetT.text('소득세 '),
                                      SizedBox(width: dividHeight,),
                                    ],
                                  )
                              ),
                              SizedBox(width: dividHeight,),
                              TextButton(
                                  onPressed: () {
                                    employee.insurance.isJobClassification = !employee.insurance.isJobClassification;
                                    FunT.setStateDT();
                                  },
                                  style: btnStyle,
                                  child: Row(
                                    children: [
                                      if(!employee.insurance.isJobClassification)
                                        WidgetT.iconMini(Icons.check_box_outline_blank, size: 28),
                                      if(employee.insurance.isJobClassification)
                                        WidgetT.iconMini(Icons.check_box, size: 28),
                                      WidgetT.text('직종구분 '),
                                      SizedBox(width: dividHeight,),
                                    ],
                                  )
                              ),
                              SizedBox(width: dividHeight,),
                              TextButton(
                                  onPressed: () {
                                    employee.insurance.isResidenceClassification = !employee.insurance.isResidenceClassification;
                                    FunT.setStateDT();
                                  },
                                  style: btnStyle,
                                  child: Row(
                                    children: [
                                      if(!employee.insurance.isResidenceClassification)
                                        WidgetT.iconMini(Icons.check_box_outline_blank, size: 28),
                                      if(employee.insurance.isResidenceClassification)
                                        WidgetT.iconMini(Icons.check_box, size: 28),
                                      WidgetT.text('거주구분 '),
                                      SizedBox(width: dividHeight,),
                                    ],
                                  )
                              ),
                            ]
                        ),

                        dividCol,

                        WidgetT.title('지급항목 자료', size: 14),
                        SizedBox(height: dividHeight,),
                        Container( decoration: gridStyle,
                          width: 300 + 500 + 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Column(children: [
                              Row(
                                  children: [
                                    SizedBox(height: 28,),
                                    WidgetEX.excelTitle(width: 150, text: '직급수당',),
                                    WidgetT.excelInput(context, 'em.payRank', width: 250,
                                      onEdite: (i, data) {
                                        employee.payment.payRank = int.tryParse(data) ?? 0;
                                      },
                                      text: StyleT.krwInt(employee.payment.payRank), value: employee.payment.payRank.toString(),
                                    ),
                                    WidgetEX.excelTitle(width: 150, text: '만근수당',),
                                    WidgetT.excelInput(context, 'em.payLate', width: 250,
                                      onEdite: (i, data) {
                                        employee.payment.payLate = int.tryParse(data) ?? 0;
                                      },
                                      text: StyleT.krwInt(employee.payment.payLate), value: employee.payment.payLate.toString(),
                                    ),
                                  ]
                              ),
                              WidgetT.dividHorizontal(size: 0.35),
                              Row(
                                  children: [
                                    SizedBox(height: 28,),
                                    WidgetEX.excelTitle(width: 150, text: '차량지원비',),
                                    WidgetT.excelInput(context, 'em.payVehicleSp', width: 250,
                                      onEdite: (i, data) {
                                        employee.payment.payVehicleSp = int.tryParse(data) ?? 0;
                                      },
                                      text: StyleT.krwInt(employee.payment.payVehicleSp), value: employee.payment.payVehicleSp.toString(),
                                    ),
                                    WidgetEX.excelTitle(width: 150, text: '식대',),
                                    WidgetT.excelInput(context, 'em.payMeal', width: 250,
                                      onEdite: (i, data) {
                                        employee.payment.payMeal = int.tryParse(data) ?? 0;
                                      },
                                      text: StyleT.krwInt(employee.payment.payMeal), value: employee.payment.payMeal.toString(),
                                    ),
                                  ]
                              ),
                              WidgetT.dividHorizontal(size: 0.35),
                            ],),
                          ),),
                        SizedBox(height: dividHeight * 4,),
                        WidgetT.title('공제항목 자료', size: 14),
                        SizedBox(height: dividHeight,),
                        Container( decoration: gridStyle,
                          width: 300 + 500 + 2,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Column(children: [
                              Row(
                                  children: [
                                    SizedBox(height: 28,),
                                    WidgetEX.excelTitle(width: 150, text: '건강보험',),
                                    WidgetT.excelInput(context, 'em.deductionHI', width: 250,
                                      onEdite: (i, data) {
                                        employee.deductionHI = int.tryParse(data) ?? 0;
                                      },
                                      text: StyleT.krwInt(employee.deductionHI), value: employee.deductionHI.toString(),
                                    ),
                                    WidgetEX.excelTitle(width: 150, text: '국민연금',),
                                    WidgetT.excelInput(context, 'em.deductionNP', width: 250,
                                      onEdite: (i, data) {
                                        employee.deductionNP = int.tryParse(data) ?? 0;
                                      },
                                      text: StyleT.krwInt(employee.deductionNP), value: employee.deductionNP.toString(),
                                    ),
                                  ]
                              ),
                            ],),
                          ),),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: [
                  Row(
                    children: [
                      Expanded(child:TextButton(
                          onPressed: () async {
                            if(employee.name == '') {
                              WidgetT.showSnackBar(context, text: '사원 이름을 입력해 주세요.'); return;
                            }

                            var alert = await DialogT.showAlertDl(context, title: employee.name ?? 'NULL');
                            if(alert == false) {
                              WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                              return;
                            }

                            await DatabaseM.updateEmployee(employee, files: fileByteList);
                            WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                            Navigator.pop(context);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('사원정보 저장', style: StyleT.titleStyle(),),
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

  /// 출결 입력 창
  static dynamic showAttCreate(BuildContext context, { Employee? setEm, DateTime? setDate, Attendance? org }) async {
    var dividHeight = 6.0;

    var date = DateTime.now();
    Attendance att = Attendance.fromDatabase({});
    Employee? em = null;

    if(setDate != null) date = setDate;
    if(setEm != null)  {
      var jsonString = jsonEncode(setEm.toJson());
      var json = jsonDecode(jsonString);
      em = Employee.fromDatabase(json);
    }
    if(org != null)  {
      var jsonString = jsonEncode(org.toJson());
      var json = jsonDecode(jsonString);
      att = Attendance.fromDatabase(json);
    }

    Attendance? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };

              if(att.type.contains('1')) {
                if(att.startAt == 0) {
                  var start = DateTime(date.year, date.month, date.day, 8, 0, );
                  att.startAt = start.microsecondsSinceEpoch;
                }
                if(att.leaveAt == 0) {
                  var leave = DateTime(date.year, date.month, date.day, 18, 0, );
                  att.leaveAt = leave.microsecondsSinceEpoch;
                }
              }

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.dlColor.withOpacity(0), width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '근태관리', ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(18),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            WidgetT.title('근태추가', width: 100),
                            for(int i = 0; i < att.type.length; i++)
                              Container(
                                padding: EdgeInsets.only(right: dividHeight),
                                child: TextButton(
                                  onPressed: null,
                                  style: StyleT.buttonStyleNone(round: 8, padding: 0, elevation: 0, color: Colors.black.withOpacity(0.07)),
                                 child: Container(
                                   height: 28,
                                   child: Row(
                                     children: [
                                       SizedBox(width: 6,),
                                       WidgetT.title(AttendanceType.type[att.type[i]] ?? 'NULL'),
                                       TextButton(
                                           onPressed: () {
                                             att.type.removeAt(i);
                                             FunT.setStateDT();
                                           },
                                           style: StyleT.buttonStyleNone(round: 0, padding: 0, elevation: 0, color: Colors.transparent),
                                           child: WidgetT.iconMini(Icons.cancel),
                                       ),
                                     ],
                                   ),
                                 )
                                ),
                              ),
                            SizedBox(
                              width: 100, height: 28,
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton2(
                                  focusColor: Colors.transparent,
                                  focusNode: FocusNode(),
                                  autofocus: false,
                                  customButton: Container(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(child: SizedBox()),
                                        WidgetT.title(AttendanceType.type[att.type] ?? '추가 +', size: 12),
                                        Expanded(child: SizedBox()),
                                      ],
                                    ),
                                  ),
                                  items: AttendanceType.type.keys.map((item) => DropdownMenuItem<dynamic>(
                                    value: item,
                                    child: Text(
                                      AttendanceType.type[item] ?? 'NULL',
                                      style: StyleT.titleStyle(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )).toList(),
                                  onChanged: (value) async {
                                    att.type.add(value);
                                    await FunT.setStateDT();
                                  },
                                  itemHeight: 28,
                                  itemPadding: const EdgeInsets.only(left: 16, right: 16),
                                  dropdownWidth: 100,
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
                                  offset: const Offset(0, 0),
                                ),
                              ),
                        ),
                          ]
                        ),

                        SizedBox(height: dividHeight,),
                        if(att.type.contains('1')) Row(
                          children: [
                            WidgetT.title('근무시간', width: 100),
                            TextButton(
                              onPressed: () async {
                                var start = DateTime.fromMicrosecondsSinceEpoch(att.startAt);
                                final TimeOfDay? timeT = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(hour: start.hour, minute: start.minute,),
                                );
                                if(timeT != null) {
                                  start = DateTime(start.year, start.month, start.day, timeT.hourOfPeriod + timeT.periodOffset, timeT.minute, );
                                  att.startAt = start.microsecondsSinceEpoch;
                                }
                                FunT.setStateDT();
                              },
                              style: StyleT.buttonStyleOutline(round: 8, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                              child: Container( height: 28,
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.timelapse),
                                      WidgetT.title(StyleT.dateFormatAll(DateTime.fromMicrosecondsSinceEpoch(att.startAt))),
                                      SizedBox(width: 6,),
                                    ],
                                  )),),
                            WidgetT.title(' ~ ', width: 20),
                            TextButton(
                              onPressed: () async {
                                var leave = DateTime.fromMicrosecondsSinceEpoch(att.leaveAt);
                                final TimeOfDay? timeT = await showTimePicker(
                                  context: context,
                                  initialTime: TimeOfDay(hour: leave.hour, minute: leave.minute,),
                                );
                                if(timeT != null) {
                                  leave = DateTime(leave.year, leave.month, leave.day, timeT.hourOfPeriod + timeT.periodOffset, timeT.minute, );
                                  att.leaveAt = leave.microsecondsSinceEpoch;
                                }
                                FunT.setStateDT();
                              },
                              style: StyleT.buttonStyleOutline(round: 8, elevation: 0, padding: 0, color: StyleT.backgroundColor.withOpacity(0.5), strock: 0.7),
                              child: Container( height: 28,
                                  child: Row(
                                    children: [
                                      WidgetT.iconMini(Icons.timelapse),
                                      WidgetT.title(StyleT.dateFormatAll(DateTime.fromMicrosecondsSinceEpoch(att.leaveAt))),
                                      SizedBox(width: 6,),
                                    ],
                                  )),),
                          ],
                        ),
                        SizedBox(height: dividHeight,),
                      ],
                    ),
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  Row(
                    children: [
                      Expanded(child:TextButton(
                          onPressed: () async {
                            if(em == null) {
                              WidgetT.showSnackBar(context, text: '근태기록 대상자를 선택해 주세요.');
                              return;
                            }
                            if(att.type.length < 1) {
                              WidgetT.showSnackBar(context, text: '근태항목을 추가해 주세요.');
                              return;
                            }
                            var alert = await DialogT.showAlertDl(context, title: '근태관리');
                            if(alert == false) {
                              WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                              return;
                            }
                            att.uid = em.id;
                            await EmployeeSystem.updateAttendance(att, date);
                            WidgetT.showSnackBar(context, text: '시스템에 성공적으로 저장되었습니다.');
                            Navigator.pop(context, att);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('근태기록 저장', style: StyleT.titleStyle(),),
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

    return aa;
  }

  Widget build(context) {
    return Container();
  }
}