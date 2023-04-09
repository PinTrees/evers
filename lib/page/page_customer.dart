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

  dynamic mainW({ bool refresh = true }) async {
    if(cs == null) {
      main = Container();
      return;
    }

    var pu_amount = 0;
    List<Purchase> pur_list = await cs!.getPurchase();
    List<Widget> pu_w = [];
    for(int i = 0; i < pur_list.length; i++) {
      var pu = pur_list[i];
      pu_amount += pu.totalPrice;

      var ccs = await SystemT.getCS(pu.csUid);
      var itemName = await SystemT.getItemName(pu.item);
      var w = Container(
        height: 36,
        decoration: StyleT.inkStyleNone(color: Colors.transparent),
        child: Row(
            children: [
              WidgetT.excelGrid(textSize: 8, label: '${0 + 1}', width: 32),
              WidgetT.excelGrid(textSize: 8, textLite: true, text: pu.id, width: 120, ),
              WidgetT.excelGrid(textSize: 10, textLite: true, text: StyleT.dateFormatAtEpoch(pu.purchaseAt.toString()), width: 80, ),
              WidgetT.excelGrid(textSize: 10,textLite: false,text: '매입', width: 50, textColor: Colors.redAccent.withOpacity(0.5) ),

              Expanded(
                child: Container(
                  width: 150, alignment: Alignment.center,
                  child: (ccs!.businessName != '') ? RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: ccs.businessName,
                          style: TextStyle(color: Colors.blue, fontSize: 10, decoration: TextDecoration.underline, fontWeight: FontWeight.w900)),
                    ]),
                  ) : Text('ㅡ', style: TextStyle(fontSize: 10, color: StyleT.textColor),),
                ),
              ),
              Expanded(child: WidgetT.excelGrid(textLite: false, width: 999, text: itemName, textSize: 10)),
              WidgetT.excelGrid(textSize: 10, textLite: true, text: "", width: 50),
              WidgetT.excelGrid(textSize: 10, textLite: true,width: 50,  text: StyleT.krw(pu.count.toString()),),
              WidgetT.excelGrid(textSize: 10, textLite: true,width: 80,  text: StyleT.krw(pu.unitPrice.toString()),),
              WidgetT.excelGrid(textSize: 10, textLite: true,width: 80,  text: StyleT.krw(pu.supplyPrice.toString()),),
              WidgetT.excelGrid(textSize: 10, textLite: true,width: 80,  text: StyleT.krw(pu.vat.toString()), ),
              WidgetT.excelGrid(textSize: 10, textLite: true,width: 80, text: StyleT.krw(pu.totalPrice.toString()),),
              if(pu.filesMap.length > 0)
                WidgetT.iconMini(Icons.file_copy_rounded, size: 32),
              if(pu.filesMap.length == 0)
                SizedBox(height: 28,width: 28,),
              InkWell(
                onTap: () async {
                  await DialogRE.showInfoPu(context, org: pu);
                },
                child: WidgetT.iconMini(Icons.create, size: 32),
              ),
              InkWell(
                onTap: () async {
                  var aa = await DialogT.showAlertDl(context, text: '데이터를 삭제하시겠습니까?');
                  if(aa) {
                    await FireStoreT.deletePu(pu);
                    WidgetT.showSnackBar(context, text: '매입 데이터를 삭제했습니다.');
                  }
                },
                child: WidgetT.iconMini(Icons.delete, size: 32),
              ),
            ]
        ),
      );
      pu_w.add(w);
      pu_w.add(WidgetT.dividHorizontal(size: 0.35));
  }


    var ts_get_amount = 0;
    var ts_out_amount = 0;
    List<TS> ts_list = await cs!.getTransaction();
    for(int i = 0; i < ts_list.length; i++) {
      var ts = ts_list[i];
      ts_get_amount += ts.getAmountOnlyPu();
      ts_out_amount += ts.getAmountOnlyRE();
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
                ),
              ],
            ),
          ),

          WidgetT.title("매입 목록", size: 22, bold: true),
          SizedBox(height: 6,),

          for(var w in pu_w) w,

          SizedBox(height: 6,),
          WidgetT.title("매출 목록", size: 22, bold: true),
          SizedBox(height: 6,),

          SizedBox(height: 6,),
          WidgetT.title("수납 목록", size: 22, bold: true),
          SizedBox(height: 6,),

          WidgetT.title("미수 미지급 현황", size: 22, bold: true),
          SizedBox(height: 6,),
          WidgetT.text("총 매입금: " +  StyleT.krwInt(pu_amount), size: 18, bold: true),
          WidgetT.text("총 수납금: " +  StyleT.krwInt(ts_get_amount), size: 18, bold: true),
          WidgetT.text("총 지급금: " +  StyleT.krwInt(ts_out_amount), size: 18, bold: true),
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
      body: ListView(
        children: [
          main,
        ],
      ),
    );
  }
}
