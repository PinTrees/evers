import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:internet_file/internet_file.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

import '../helper/interfaceUI.dart';
import '../helper/style.dart';

class WidgetFX extends StatelessWidget {

  static dynamic showPDFtoDialog(BuildContext context, { String? path='', String? name='', Uint8List? data}) async {
    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.0),
        barrierDismissible: true,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                scrollable: true,
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: StyleT.titleColor.withOpacity(0.9), width: 0.7),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: Column(
                  children: [
                    SizedBox(height: 8,),
                    WidgetT.text('pdf viewer system'),
                    Container(child: Text('${name}', style: StyleT.titleStyle(bold: true))),
                    SizedBox(height: 8,),
                    WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                  ],
                ),
                content: SingleChildScrollView(
                    child: Container(
                      width: 600, height: 600,
                      child: PdfViewer.openData(data!),
                    )
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
                                  style: StyleT.buttonStyleOutline(padding: 0, strock: 1.4, elevation: 8, round: 0,
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

    if(aa == null) aa = false;
    return aa;
  }
  static dynamic showFileWithURL(BuildContext context, { String path='', String? name='', Uint8List? data}) async {
    bool aa = false;
    var mode = path.split('.').last;
    if(mode == 'pdf') {
      aa = await showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.0),
          barrierDismissible: true,
          builder: (BuildContext context) {
            return  StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  scrollable: true,
                  backgroundColor: StyleT.white.withOpacity(1),
                  elevation: 36,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: StyleT.titleColor.withOpacity(0.9), width: 0.7),
                      borderRadius: BorderRadius.circular(0)),
                  titlePadding: EdgeInsets.zero,
                  contentPadding: EdgeInsets.zero,
                  title: Column(
                    children: [
                      SizedBox(height: 8,),
                      WidgetT.text('pdf viewer system'),
                      Container(child: Text('${name}', style: StyleT.titleStyle(bold: true))),
                      SizedBox(height: 8,),
                      WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                    ],
                  ),
                  content: SingleChildScrollView(
                      child: Container(
                        width: 600, height: 600,
                        child: PdfViewer.openData(data!),
                      )
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
                                    style: StyleT.buttonStyleOutline(padding: 0, strock: 1.4, elevation: 8, round: 0,
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
    }
    else if(mode == 'jpg' || mode == 'png') {
      aa = await showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.0),
          barrierDismissible: true,
          builder: (BuildContext context) {
            return  StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  scrollable: true,
                  backgroundColor: StyleT.white.withOpacity(1),
                  elevation: 36,
                  shape: RoundedRectangleBorder(
                      side: BorderSide(color: StyleT.titleColor.withOpacity(0.9), width: 0.7),
                      borderRadius: BorderRadius.circular(0)),
                  titlePadding: EdgeInsets.zero,
                  contentPadding: EdgeInsets.zero,
                  title: Column(
                    children: [
                      SizedBox(height: 8,),
                      WidgetT.text('pdf viewer system'),
                      Container(child: Text('${name}', style: StyleT.titleStyle(bold: true))),
                      SizedBox(height: 8,),
                      WidgetT.dividHorizontal(color: Colors.grey.withOpacity(0.5)),
                    ],
                  ),
                  content: SingleChildScrollView(
                      child: Container(
                        width: 600, height: 600,
                        child: PdfViewer.openData(data!),
                      )
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
                                    style: StyleT.buttonStyleOutline(padding: 0, strock: 1.4, elevation: 8, round: 0,
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
    }

    if(aa == null) aa = false;
    return aa;
  }

  Widget build(context) {
    return Container();
  }
}