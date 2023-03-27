import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/helper/interfaceUI.dart';
import 'package:evers/helper/style.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf_render/pdf_render_widgets.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:evers/helper/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:encrypt/encrypt.dart' as en;
import 'package:printing/printing.dart';

import 'dart:html' as html;
import 'dart:js' as js;


class PdfViewPage extends StatefulWidget{
  Uint8List? data;
  String? url;
  String? fileName;
  PdfViewPage({ Uint8List? this.data, this.url, this.fileName});

  @override
  State<PdfViewPage> createState() => _PdfViewPageState();
}

class _PdfViewPageState extends State<PdfViewPage> {
  _PdfViewPageState();
  Uint8List? byteData;
  var imageUrl;
  var type = '';
  Widget main = SizedBox();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    var user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      context.go('/login/o');
      setState(() {});
    }
    initAsync();
  }

  void initAsync() async {
    if(widget.url != null) {
      print(widget.url);
      var url = widget.url!.replaceAll('&&::', '/');

      final key=en.Key.fromUtf8('dTk2jQ2A1d5TPkp7');
      final iv=en.IV.fromLength(16);
      final encrypter= en.Encrypter(en.AES(key));
      imageUrl =encrypter.decrypt64(url, iv: iv);
      //print('-------복호화값: ${texten}');

      type = widget.fileName!.split('.').last;
      print(type);

      var res = await http.get(Uri.parse(imageUrl));
      var bodyBytes = res.bodyBytes;
      byteData = bodyBytes;
      print(bodyBytes.length);
      mainW();
    } else {
      byteData = widget.data;
      mainW();
    }
  }

  dynamic mainW() {
    if(byteData == null) {
      main = Container();
    }
    else if(type == 'pdf' || type == 'pdfx') {
      main = Container(
        color: Colors.black26,
        child: PdfViewer.openData(
          byteData!,
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
      );
    }
    else if(type == 'jpg') {
      main = ListView(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(),
              Container(
                color: Colors.black26,
                width: 768,
                child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.contain,),
              ),
            ],
          )
        ],
      );
    }
    else if(type == 'xlsx' || type == 'xls') {
      // https://pub.dev/packages/excel
      // 종속성 추가
      var excel = Excel.decodeBytes(byteData);

      for (var table in excel.tables.keys) {
        print(table); //sheet Name
        print(excel.tables[table].maxCols);
        print(excel.tables[table].maxRows);
        for (var row in excel.tables[table].rows) {
          print('$row');
        }
      }
    }
    setState(() {});
  }

  var dividSize = 6.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: StyleT.subTabBarColor,
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 18,
        title: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                Text('EVERS File Viewer System'),
                SizedBox(width: dividSize * 4,),
                TextButton(
                  onPressed: () async {
                    if(type == 'pdf' || type == 'pdfx') await Printing.layoutPdf(onLayout: (format) async => byteData!);
                    if(type == 'jpg') {
                      final doc = pw.Document();
                      final image = pw.MemoryImage(byteData!,);
                      doc.addPage(pw.Page(
                          build: (pw.Context context) {
                            return pw.Center(
                              child: pw.Image(image),
                            ); // Center
                          })); // P
                      await Printing.layoutPdf(onLayout: (format) async => doc.save());
                    }
                  },
                  style: StyleT.buttonStyleNone(color: Colors.transparent, padding:0, elevation: 0),
                  child: WidgetT.iconNormal(Icons.print, size: 48, color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    if(byteData == null) {
                      WidgetT.showSnackBar(context, text: '저장할 파일을 찾을 수 없습니다.');
                    }
                    js.context.callMethod("saveAs", <Object>[
                      html.Blob(<Object>[byteData!]),
                      widget.fileName!,
                    ]);
                  },
                  style: StyleT.buttonStyleNone(color: Colors.transparent, padding:0, elevation: 0),
                  child: WidgetT.iconNormal(Icons.save_alt, size: 48, color: Colors.white),
                )
              ],
            )),
      ),
      backgroundColor: Colors.white70,
      body: main,
    );
  }
}
