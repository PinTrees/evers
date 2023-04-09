import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/system.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/interfaceUI.dart';
import 'package:evers/helper/style.dart';
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

import '../class/Customer.dart';
import '../class/purchase.dart';
import '../class/transaction.dart';
import '../ui/cs.dart';
import '../ui/dialog_revenue.dart';


class ShoingItemPage extends StatefulWidget{
  ShoingItemPage();

  @override
  State<ShoingItemPage> createState() => _ShoingItemPageState();
}

class _ShoingItemPageState extends State<ShoingItemPage> {
  _ShoingItemPageState();

  Widget main = SizedBox();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    /*var user = FirebaseAuth.instance.currentUser;
    if(user == null) {
      context.go('/login/o');
      setState(() {});
      return;
    }*/
    initAsync();
  }

  void initAsync() async {
    mainW();
    setState(() {});
  }

  Map<String, List<List<Widget>>> data = {};
  List<String> sheetNames = [];
  int selectSheet = 0;

  dynamic mainW({ bool refresh = true }) async {

    main = Container(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WidgetT.title("상품 상세 페이지", size: 28, bold: true),

          Container(
            height: 68,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                InkWell(
                  child: Container( padding: EdgeInsets.all(12),
                      child: WidgetT.text('기초정보', size: 12, bold: true )),
                ),
              ],
            ),
          ),

          WidgetT.title("정보", size: 22, bold: true),
          SizedBox(height: 6,),

          InkWell(
            onTap: () async {
              var res = await http.post(
                Uri.parse('https://kapi.kakao.com/v1/payment/ready'),
              encoding: Encoding.getByName('utf8'),
              headers: {
                'Authorization': 'KakaoAK ${SystemT.kakaoPayApiKey}',
                'Content-type': 'application/x-www-form-urlencoded;charset=utf-8'
              },
                body: {
                'cid' : 'TC0ONETIME',
                'partner_order_id': 'partner_order_id',
                  'partner_user_id': 'partner_user_id',
                  'item_name': '상품 이름',
                  'quantity': '1',
                  'total_amount': '222222',
                  'vat_amount': '22222',
                  'tax_free_amount': '0',
                  'approval_url': 'https://www.eversfood.com',
                  'fail_url': 'https://www.eversfood.com/error',
                  'cancel_url': 'https://www.eversfood.com/error'
                  },
              );

              var ret = json.decode(res.body);
              print(ret);
              var url = ret['next_redirect_pc_url'] + '?txn_id=' + ret['tid'];
              print(url);
              await launchUrl( Uri.parse(url),
                webOnlyWindowName: true ? '_blank' : '_self',
              );
            },
            child: WidgetT.text('카카오페이 결제 테스트 시스템', size: 24, bold: true),
          ),
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
                Text('상품 정보'),
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
      body: ListView(
        children: [
          main,
        ],
      ),
    );
  }
}
