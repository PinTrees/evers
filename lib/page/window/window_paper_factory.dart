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

class WindowFactoryPaper extends WindowBaseMDI {
  FactoryD? factoryD;
  Function refresh;

  WindowFactoryPaper({ required this.refresh, this.factoryD }) { }

  @override
  _WindowFactoryPaperState createState() => _WindowFactoryPaperState();
}

class _WindowFactoryPaperState extends State<WindowFactoryPaper> {

  var dividHeight = 6.0;
  Map<String, Uint8List> fileByteList = {};
  var date = DateTime.now();
  FactoryD factoryD = FactoryD.fromDatabase({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  dynamic initAsync() async {
    factoryD.date = date.microsecondsSinceEpoch;
    date = DateTime.fromMicrosecondsSinceEpoch(factoryD.date);

    if(widget.factoryD != null) {
      factoryD = FactoryD.fromDatabase(JsonManager.toJsonObject(widget.factoryD));
      date = DateTime.fromMicrosecondsSinceEpoch(factoryD.date);
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
                        onEdited: (i, data) { factoryD.memo = data; },
                        text: factoryD.memo,
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

                          for(int i = 0; i < factoryD.filesMap.length; i++)
                            ButtonT.IconText(
                              icon: Icons.cloud_done, text: factoryD.filesMap.keys.elementAt(i),
                              onTap: () async {
                                var downloadUrl = factoryD.filesMap.values.elementAt(i);
                                var fileName = factoryD.filesMap.keys.elementAt(i);
                                PdfManager.OpenPdf(downloadUrl, fileName);
                              },
                              leaging: ButtonT.Icont(
                                icon: Icons.delete,
                                onTap: () async {
                                  var rst = await DialogT.showAlertDl(context, text: '파일을 삭제하시겠습니까?');
                                  if(!rst) return Messege.toReturn(context, "삭제 취소됨", false);

                                  await factoryD.deleteFile(factoryD.filesMap.keys.elementAt(i));
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
          buildAction(),
        ],
      ),
    );
  }


  Widget buildAction() {
    var saveWidget = ButtonT.Action(
        context, "공장일보 저장", icon: Icons.save,
        init: () {
          if(factoryD.memo == "") return Messege.toReturn(context, "메모를 비워둘 수 없습니다.", false);
          return true;
        },
        altText: "공장일보를 저장하시겠습니까?",
        onTap: () async {
          WidgetT.loadingBottomSheet(context, text: '저장중');

          factoryD.date = date.microsecondsSinceEpoch;
          await DatabaseM.updateFactoryDWithFile(factoryD, files: fileByteList);

          WidgetT.showSnackBar(context, text: '저장됨');
          Navigator.pop(context);

          await widget.refresh();
          widget.parent.onCloseButtonClicked!();
      }
    );

    return Row(
      children: [ saveWidget, ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}
