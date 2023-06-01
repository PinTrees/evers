import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/json.dart';
import 'package:evers/helper/style.dart';
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
import '../../class/database/item.dart';
import '../../class/schedule.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/text.dart';
import '../../core/window/ResizableWindow.dart';
import '../../helper/aes.dart';
import '../../helper/dialog.dart';
import '../../helper/firebaseCore.dart';
import '../../helper/interfaceUI.dart';
import '../../helper/pdfx.dart';
import '../../ui/ip.dart';
import '../../ui/ux.dart';

class WindowProductPaper extends WindowBaseMDI {
  ProductD? productD;
  Function refresh;

  WindowProductPaper({ required this.refresh, this.productD }) { }

  @override
  _WindowProductPaperState createState() => _WindowProductPaperState();
}

class _WindowProductPaperState extends State<WindowProductPaper> {

  var dividHeight = 6.0;
  Map<String, Uint8List> fileByteList = {};
  var date = DateTime.now();
  ProductD productD = ProductD.fromDatabase({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    initAsync();
  }

  dynamic initAsync() async {
    productD.date = date.microsecondsSinceEpoch;
    date = DateTime.fromMicrosecondsSinceEpoch(productD.date);

    if(widget.productD != null) {
      productD = ProductD.fromDatabase(JsonManager.toJsonObject(widget.productD));
      date = DateTime.fromMicrosecondsSinceEpoch(productD.date);
    }

    setState(() {});
  }
  Widget mainBuild() {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(dividHeight * 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextT.SubTitle(text: '공장일보 상세정보',),
                      SizedBox(height: dividHeight,),
                      Row(
                        children: [
                          ButtonT.IconText(
                            icon: Icons.timelapse,
                            text: StyleT.dateFormatAll(date),
                            onTap: () async {
                              var selectedDate = await showDatePicker(
                                context: context,
                                initialDate: date, // 초깃값
                                firstDate: DateTime(2018), // 시작일
                                lastDate: DateTime(2030), // 마지막일
                              );
                              if(selectedDate != null) {
                                date = selectedDate;
                              }
                              setState(() {});
                            },
                          ),
                          SizedBox(width: dividHeight,),
                          ButtonT.IconText(
                            icon: Icons.timelapse,
                            text: '시간변경',
                            onTap: () async {
                              final TimeOfDay? timeT = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(hour: date.hour, minute: date.minute,),
                              );
                              if(timeT != null) {
                                date = DateTime(date.year, date.month, date.day, timeT.hourOfPeriod + timeT.periodOffset, timeT.minute, );
                              }
                              setState(() {    });
                            },
                          ),
                        ],
                      ),

                      SizedBox(height: 6 * 4,),
                      TextT.SubTitle(text: '내용',),
                      SizedBox(height: dividHeight,),
                      InputWidget.LitText(context, "${widget.key}::factory::paper::memo",
                        expand: true, isMultiLine: true,
                        setState: () {  setState(() {}); },
                        onEdited: (i, data) { productD.memo = data; },
                        text: productD.memo,
                      ),

                      SizedBox(height: 6 * 4,),
                      TextT.SubTitle(text: '첨부파일',),
                      SizedBox(height: dividHeight,),
                      Wrap(
                        runSpacing: dividHeight, spacing: dividHeight,
                        children: [
                          for(int i = 0; i < fileByteList.length; i++)
                            ButtonT.IconText(
                              icon: Icons.file_copy_rounded, text: fileByteList.keys.elementAt(i),
                              onTap: () async {
                                PDFX.showPDFtoDialog(context, data: fileByteList.values.elementAt(i), name: fileByteList.keys.elementAt(i));
                              },
                              leaging: ButtonT.Icont(
                                icon: Icons.delete,
                                onTap: () async {
                                  fileByteList.remove(fileByteList.keys.elementAt(i));
                                  setState(() { });
                                },
                              ),
                            ),

                          for(int i = 0; i < productD.filesMap.length; i++)
                            ButtonT.IconText(
                              icon: Icons.cloud_done, text: productD.filesMap.keys.elementAt(i),
                              onTap: () async {
                                var downloadUrl = productD.filesMap.values.elementAt(i);
                                var fileName = productD.filesMap.keys.elementAt(i);
                                PdfManager.OpenPdf(downloadUrl, fileName);
                              },
                              leaging: ButtonT.Icont(
                                icon: Icons.delete,
                                onTap: () async {
                                  if(!await DialogT.showAlertDl(context, text: '파일을 삭제하시겠습니까?')) Messege.toReturn(context, "삭제 취소됨", false);

                                  await productD.deleteFile(productD.filesMap.keys.elementAt(i));
                                  WidgetT.showSnackBar(context, text: '파일 삭제됨');

                                  setState(() {});
                                },
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: dividHeight,),
                      ButtonT.IconText(
                        icon: Icons.file_copy_rounded,
                        text: '파일선택',
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
                              Uint8List fileBytes = result.files.first.bytes!;
                              fileByteList[fileName] = fileBytes;
                            }
                          }
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          /// action
          Row(
            children: [
              Expanded(child:TextButton(
                  onPressed: () async {
                    var alert = await DialogT.showAlertDl(context, title: productD.memo ?? 'NULL');
                    if(alert == false) {
                      WidgetT.showSnackBar(context, text: '시스템에 저장을 취소했습니다.');
                      return;
                    }

                    WidgetT.loadingBottomSheet(context, text: '저장중');

                    productD.date = date.microsecondsSinceEpoch;
                    await DatabaseM.updateProductDWithFile(productD, files: fileByteList);

                    WidgetT.showSnackBar(context, text: '저장됨');
                    await widget.refresh();
                    widget.parent.onCloseButtonClicked!();
                  },
                  style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                  child: Container(
                      color: StyleT.accentColor.withOpacity(0.5), height: 42,
                      child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          WidgetT.iconMini(Icons.check_circle),
                          Text('생산일보 저장', style: StyleT.titleStyle(),),
                          SizedBox(width: 6,),
                        ],
                      )
                  )
              ),),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}
