import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
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
import 'package:printing/printing.dart';
import 'package:quick_notify/quick_notify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../helper/interfaceUI.dart';
import '../helper/style.dart';
import '../ui/dl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'aes.dart';




class PdfManager {
  static void OpenPdf(dynamic downloadUrl, String fileName) async {
    var ens = ENAESX.fullUrlAES(downloadUrl);
    var url = Uri.base.toString().split('/work').first + '/pdfview/$ens/$fileName/e';
    await launchUrl( Uri.parse(url),   webOnlyWindowName: true ? '_blank' : '_self', );
  }
}





class PDFX extends StatelessWidget {
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
                title: WidgetDT.dlTitle(context, title: 'PDF 뷰어 시스템', ),
                content: Row(
                  children: [
                    Expanded(
                      child: Container(
                        width: 1280,
                        height: 2048,
                        child: PdfViewer.openData(
                          data!,
                          params: PdfViewerParams(
                            layoutPages: (viewSize, pages) {
                              List<Rect> rect = [];
                              final viewWidth = viewSize.width;
                              final viewHeight = viewSize.height;
                              final maxHeight = pages.fold<double>(0.0, (maxHeight, page) => max(maxHeight, page.height));
                              final ratio = viewHeight / maxHeight;
                              var top = 0.0;
                              for (var page in pages) {
                                final width = page.width * ratio;
                                final height = page.height * ratio;
                                final left = viewWidth > viewHeight ? (viewWidth / 2) - (width / 2) : 0.0;
                                rect.add(Rect.fromLTWH(left, top, width, height));
                                top += height + 8 /* padding */;
                              }
                              return rect;
                            },
                          ),
                        ),
                      )
                    ),
                  ],
                ),
                actionsPadding: EdgeInsets.zero,
                actions: <Widget>[
                  Row(
                    children: [
                      Expanded(child:TextButton(
                          onPressed: () async {
                            await Printing.layoutPdf(onLayout: (format) async => data);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentLowColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('다운로드', style: StyleT.titleStyle(),),
                                  SizedBox(width: 6,),
                                ],
                              )
                          )
                      ),),
                      Expanded(child:TextButton(
                          onPressed: () async {
                            await Printing.layoutPdf(onLayout: (format) async => data);
                          },
                          style: StyleT.buttonStyleNone(padding: 0, round: 0, strock: 0, elevation: 8, color:Colors.white),
                          child: Container(
                              color: StyleT.accentColor.withOpacity(0.5), height: 42,
                              child: Row( mainAxisSize: MainAxisSize.max, mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  WidgetT.iconMini(Icons.check_circle),
                                  Text('인쇄', style: StyleT.titleStyle(),),
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

  Widget build(context) {
    return Container();
  }
}

class WidgetP extends StatelessWidget {

  static Map<String, TextEditingController> textInputs = {};
  static Map<String, bool> isActive = {};

  static Widget titleRowW(List<String> title, List<double> width, { Color? color,  bool isTitle=false, bool isM=false, List<Widget>? leaging }) {
    List<Widget> chW = [];

    for(int i = 0; i < title.length; i++) {
      if(i != 0) chW.add(WidgetT.dividViertical(height: 28));
      var w = WidgetT.excelGrid(label:title[i], width: width[i]);
      if(isTitle) w = WidgetT.excelGrid(text:title[i], width: null, alignment: Alignment.centerLeft);
      if(width[i] > 900 && isTitle == false) {
        w = Expanded(child: w);
      }
      chW.add(w);
    }

    var grc = [
      const Color(0xFF1855a5).withOpacity(0.35),
      const Color(0xFF000000).withOpacity(0.5),
    ];
    if(isM) grc = [
      const Color(0xFF1855a5).withOpacity(0.35),
      const Color(0xFF000000).withOpacity(0.5),
    ];

    if(isTitle || isM) {
      if(leaging != null) {
        chW.add(SizedBox(width: 18,));
        for(int i = 0; i < leaging.length; i++) {
          chW.add(leaging[i]);
          chW.add(SizedBox(width: 18,));
        }
      }
      return Column(
        children: [
          Container(
              decoration: StyleT.inkStyle(stroke: 0.35, color: Colors.transparent),
              child: Container( height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: grc,
                      begin: const FractionalOffset(0.0, 0.0),
                      end: const FractionalOffset(1.0, 0.0),
                      stops: [0.0, 1.0],
                      tileMode: TileMode.clamp),
                ),
                child: Row(
                  children: chW,
                ),
              )
          ),
          WidgetT.dividHorizontal(size: 2)
        ],
      );
    }

    return Container(
        decoration: StyleT.inkStyle(stroke: 0.35, color: StyleT.backgroundLowColor.withOpacity(0.5)),
        child: Container( height: 28,
          child: Row(
            children: chW,
          ),
        )
    );
  }

  static pw.Widget excelGrid({ String? text, bool textLite=false, String? value,
    double? width, double? height, String? label, Color? color, Color? textColor, double? textSize }) {
    var w = pw.Container(
      width: width, height: height, alignment: pw.Alignment.center,
      color: PdfColor.fromRYB(0, 0, 0, 0),
      padding: pw.EdgeInsets.all(6),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        mainAxisAlignment: pw.MainAxisAlignment.start,
        children: [
          WidgetP.text(label ?? '', size: 10,),
          if(text != null)
            pw.SizedBox(width: 4,),

          if(!textLite)
            title(text ?? '', size: textSize),
          if(textLite)
            WidgetP.text(text ?? '', size:textSize ?? 12),
        ],
      ),
    );
    return w;
  }

  static pw.Widget title(String text, { double? size, bool bold=true, double? width }) {
    var w = pw.Text(text, style: pw.TextStyle(font: StyleT.font,
        fontSize: size ?? 10, color: PdfColor.fromInt(StyleT.titleColor.value)));
    if(width != null) return pw.Container(padding: pw.EdgeInsets.zero, alignment: pw.Alignment.center, width: width, child: w,);
    return w;
  }
  static pw.Widget text(String text, { double? size, double? width }) {
    var w = pw.Text(text, style: pw.TextStyle(font: StyleT.font,
        fontSize: size ?? 10, color: PdfColor.fromInt(StyleT.titleColor.value)));
    if(width != null) return pw.Container(padding: pw.EdgeInsets.zero, alignment: pw.Alignment.center, width: width, child: w,);
    return w;
  }

  static pw.Widget dividViertical({double? height, double? size}) {
    return pw.Container(height: height, width: 1, color: PdfColor.fromHex('#333333'),);
  }
  static pw.Widget dividHorizontal({double? width, double? size}) {
    return pw.Container(height: 1, width: size, color: PdfColor.fromHex('#333333'),);
  }

  Widget build(context) {
    return Container();
  }
}
