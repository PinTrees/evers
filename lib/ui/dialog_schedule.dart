import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_ct.dart';
import 'package:evers/page/window/window_sch_create.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../class/Customer.dart';
import '../class/contract.dart';
import '../class/purchase.dart';
import '../class/schedule.dart';
import '../class/system.dart';
import '../class/system/state.dart';
import '../class/transaction.dart';
import '../helper/aes.dart';
import '../helper/dialog.dart';
import '../helper/firebaseCore.dart';
import '../helper/interfaceUI.dart';
import '../helper/pdfx.dart';
import 'dialog_contract.dart';
import 'dl.dart';
import 'package:http/http.dart' as http;

import 'ip.dart';
import 'ux.dart';

class DialogSHC extends StatelessWidget {

  static dynamic showSCHInfo(BuildContext context, List<Schedule> events, DateTime date) async {
    var dividHeight = 6.0;

    var title = StyleT.dateFormat(date);

    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: true,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };

              var chW = [];
              for(var e in events) {
                Widget ctLink = SizedBox();
                var ct = SystemT.getCt(e.ctUid);
                if(e.ctUid != '') {
                  if(ct == null) continue;

                  ctLink = Row(
                    children: [
                      WidgetT.text('계약 ', size: 10),
                      WidgetT.title((ct == null) ? '삭제된계약' : ct.ctName,),
                      WidgetT.iconMini(Icons.link),
                      SizedBox(width: 6,),
                    ],
                  );
                }
                var w = Container(
                  padding: EdgeInsets.only(bottom: dividHeight),
                  child: TextButton(
                      onPressed: () async {
                        if(ct == null) {
                          WidgetT.showSnackBar(context, text: '연결된 정보가 없습니다.');
                          return;
                        }
                        UIState.OpenNewWindow(context, WindowCT(org_ct: ct!,));
                      },
                      style: StyleT.buttonStyleOutline(round: 0, elevation: 0, padding: 0, color: (StyleT.scheduleColor[e.type] == null) ? Colors.red : StyleT.scheduleColor[e.type]!.withOpacity(0.35), strock: 1),
                      child: Container(padding: EdgeInsets.all(0), child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(width: 6,),
                          ctLink,
                          WidgetT.text('메모 ', size: 10),
                          WidgetT.title(e.memo,),
                          TextButton(
                              onPressed: () {
                                WidgetT.showSnackBar(context, text: '일정 제거기능 개발중');
                              },
                              style: StyleT.buttonStyleNone(round: 0, elevation: 0, padding: 0, color: Colors.transparent, strock: 1),
                              child: Container( height: 28, width: 28,
                                child: WidgetT.iconMini(Icons.cancel),)
                          ),
                        ],
                      ))
                  ),
                );
                chW.add(w);
              }


              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.titleColor.withOpacity(0), width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: title, ),
                content: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.all(18),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for(var w in chW) w,
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
                            UIState.OpenNewWindow(context, WindowSchCreate(ct: null, refresh: (){}));
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.add_box),
                                  Text('스케쥴 및 메모 추가하기', style: StyleT.titleStyle(),),
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
  static dynamic showSCHEdite(BuildContext context, Schedule org,) async {
    var dividHeight = 6.0;
    Map<String, Uint8List> fileByteList = {};

    var date = DateTime.fromMicrosecondsSinceEpoch(org.date);
    var title = StyleT.dateFormat(date);

    var jsonStr = jsonEncode(org.toJson());
    var json = jsonDecode(jsonStr);
    Schedule sch = Schedule.fromDatabase(json);

    Schedule? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: true,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              FunT.setStateD = () { setStateS(() {}); };

              List<Widget> chW = [];
              chW.add(WidgetT.title('스케쥴 상세 정보', size: StyleT.subTitleSize));
              chW.add(SizedBox(height: dividHeight,));
              chW.add(WidgetUI.titleRowNone([ '', '구분', '계약', '', '' ], [ 32, 100, 250, 999, 36 ], background: true));
              Widget ctLink = SizedBox();
              var ct = SystemT.getCt(sch.ctUid);
              if(sch.ctUid != '') {
                ctLink = Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      WidgetT.excelGrid(text:(ct == null) ? '삭제된계약' : ct.ctName,),
                    ],
                  ),
                );
              }
              var w = Container(
                padding: EdgeInsets.only(bottom: dividHeight),
                child: InkWell(
                    onTap: null,
                    child: Container(
                      height: 36,
                        padding: EdgeInsets.all(0), child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(width: 32,),
                        WidgetT.dropMenu( dropMenuMaps: MetaT.schTypeName,
                            onEdite: (i, data) {
                              sch.type = data;
                            },
                            text: MetaT.schTypeName[sch.type.toString()] ?? '-', width: 100),
                        Container(width: 250, child: ctLink),
                        Expanded(child: SizedBox()),
                        InkWell(
                          onTap: () async {
                            if(!await DialogT.showAlertDl(context, text: '스케쥴을 삭제하시겠습니까?')) {
                              WidgetT.showSnackBar(context, text: '취소됨');
                              return;
                            }
                            WidgetT.loadingBottomSheet(context, text: '삭제중');
                            var data = await sch.delete();
                            Navigator.pop(context);
                            WidgetT.showSnackBar(context, text: '삭제됨');
                            Navigator.pop(context, sch);
                          },
                          child: WidgetT.iconMini(Icons.delete, size: 36),
                        ),
                      ],
                    ))
                ),
              );
              chW.add(w);


              var sw = [];
              sw.add(
                  Column(
                    children: [
                      Container(
                        decoration: StyleT.inkStyle(stroke: 0.35, color: Colors.transparent),
                        child: Row(
                          children: [
                            WidgetT.title('메모', width: 100),
                            Expanded(child: WidgetTF.textTitInput(context, '메모',  height: 64, isMultiLine: true,
                              onEdite: (i, data) { sch.memo = data; },
                              text: sch.memo,
                            ),)
                          ],
                        ),
                      ),
                      SizedBox(height: dividHeight,),
                      Container(
                          decoration: StyleT.inkStyle(stroke: 0.35, color: Colors.transparent),
                          child: IntrinsicHeight(
                            child: Row(
                              children: [
                                SizedBox(height: 32,),
                                WidgetT.text('첨부파일', width: 100),
                                Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(dividHeight),
                                      child: Wrap(
                                        runSpacing: dividHeight, spacing: dividHeight * 3,
                                        children: [
                                          for(int i = 0; i < sch.filesMap.length; i++)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                InkWell(
                                                    onTap: () async {
                                                      var downloadUrl = sch.filesMap.values.elementAt(i);
                                                      var fileName = sch.filesMap.keys.elementAt(i);
                                                      PdfManager.OpenPdf(downloadUrl, fileName);
                                                    },
                                                    child: Container(
                                                        decoration: StyleT.inkStyle(stroke: 0.35, round: 8, color: StyleT.accentLowColor.withOpacity(0.05)),
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            SizedBox(width: 6,),
                                                            WidgetT.title(sch.filesMap.keys.elementAt(i),),
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
                    ],
                  )
              );

              var divWidget = SizedBox(height: dividHeight * 4,);

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.titleColor.withOpacity(0), width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: title, ),
                content: SingleChildScrollView(
                  child: Container(
                    width: 1280,
                    padding: EdgeInsets.all(18),
                    child: Column( crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for(var w in chW) w,
                        divWidget,
                        for(var w in sw) w,
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
                            if(!await DialogT.showAlertDl(context, text: '스케쥴을 저장하시겠습니까?')) {
                              WidgetT.showSnackBar(context, text: '취소됨');
                              return;
                            }

                            WidgetT.loadingBottomSheet(context, text: '저장중');
                            var data = sch.update(files: fileByteList);
                            Navigator.pop(context);
                            WidgetT.showSnackBar(context, text: '저장됨');

                            Navigator.pop(context, sch);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.add_box),
                                  Text('스케쥴 및 메모 저장', style: StyleT.titleStyle(),),
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
