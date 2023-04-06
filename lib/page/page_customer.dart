import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/interfaceUI.dart';
import 'package:evers/helper/style.dart';
import 'package:excel/excel.dart';
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

import '../class/Customer.dart';


class CustomerPage extends StatefulWidget{
  Uint8List? data;
  String? csUid;
  CustomerPage({ Uint8List? this.data, this.csUid });

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  _CustomerPageState();

  Customer? cs;
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
      return;
    }
    initAsync();
  }

  void initAsync() async {
    WidgetT.loadingBottomSheet(context,);
    setState(() {});

    if(widget.csUid != null) {
      cs = await FireStoreT.getCustomerDoc(widget.csUid!);
      mainW();
    }

    Navigator.pop(context);
    setState(() {});
  }

  Map<String, List<List<Widget>>> data = {};
  List<String> sheetNames = [];
  int selectSheet = 0;

  dynamic mainW({ bool refresh = true }) {
    if(cs == null) {
      main = Container();
      return;
    }



    main = Container(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetT.title("거래처", size: 28, bold: true),
          WidgetT.title('${cs!.businessName}', size: 28, bold: true),

          Container(
            height: 68,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                InkWell(
                  child: Container( padding: EdgeInsets.all(12),
                      child: WidgetT.text('기초정보', size: 12, bold: true )),
                )
              ],
            ),
          ),

          WidgetT.dividHorizontal(size: 0.7),
        ],
      ),
    );

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
                Text('에버스 거래처'),
                SizedBox(width: dividSize * 4,),
                TextButton(
                  onPressed: () async {  },
                  style: StyleT.buttonStyleNone(color: Colors.transparent, padding:0, elevation: 0),
                  child: WidgetT.iconNormal(Icons.print, size: 48, color: Colors.white),
                ),
                TextButton(
                  onPressed: () { },
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
