import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/contract.dart';
import 'package:evers/class/system.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/interfaceUI.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/document/doc_enum.dart';
import 'package:evers/page/document/page_doc_customer.dart';
import 'package:evers/system/printform.dart';
import 'package:evers/ui/ux.dart';
import 'package:excel/excel.dart';
import 'package:flutter/gestures.dart';
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

import 'package:url_launcher/url_launcher.dart';


class DocumentPage extends StatefulWidget{
  String? path;
  DocumentPage({this.path});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  _DocumentPageState();

  Map<DocumentMenuType, List<DocumentMenuType>> menu = {
    DocumentMenuType.customer : [ DocumentMenuType.dialogCustomer ],
  };

  late Widget main;

  var first = '';
  var last = '';

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
      return;
    }
    initAsync();
  }

  dynamic initAsync() async {
    //WidgetT.loadingBottomSheet(context,);  setState(() {});

    var paths = widget.path!.split('*');
    first = paths.first;
    last = paths.last;

    mainW();

    //Navigator.pop(context);
    setState(() {});
  }

  /// 위젯 빌더입니다.
  dynamic mainW({ bool refresh = true }) async {
    /// (***) 수정
    var menuW = Container(
      color: StyleT.subTabBarColor,
      height: 32,
      child: Row(  children: [  ], ),
    );
    List<Widget> infoMenuButtons = [];

    menu.forEach((key, value) {
      infoMenuButtons.add(ButtonT.InfoMenu(key.displayName, DocumentMenuIcon.Icon(key),
        onTap: () async {
          //launchUrl('', );
        },
        setState: () { mainW(); setState(() {}); }
      ));
    });

    var infoMenuW = Container(
      width: 220,
      child: ListView(
        padding: EdgeInsets.all(18),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for(var w in infoMenuButtons) w,
            ],
          ),
        ],
      ),
    );

    Widget view = SizedBox();
    if(first == DocumentMenuType.customer.code) {
      view = DocumentCustomer.build();
    }

    main = Column(
      children: [
        menuW,
        Expanded(
          child: Row(
            children: [
              infoMenuW,
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: view,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    setState(() {});
  }

  var dividSize = 6.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        automaticallyImplyLeading: false,
        centerTitle: false,
        elevation: 18,
        toolbarHeight: 68,
        title: Column(
          children: [
            Container(
                height: 68,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text('Evers ERP Documents'),
                    SizedBox(width: dividSize * 4,),
                    ButtonT.Icon(
                      icon: Icons.search,
                      onTap: () {
                        WidgetT.showSnackBar(context, text: "개발중");
                      }
                    )
                  ],
                )),
          ],
        ),
      ),
      backgroundColor: Colors.white70,
      body: main,
    );
  }
}
