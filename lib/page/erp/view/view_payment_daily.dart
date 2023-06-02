import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/system/records.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/page.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../class/Customer.dart';
import '../../../class/contract.dart';
import '../../../class/purchase.dart';
import '../../../class/revenue.dart';
import '../../../class/schedule.dart';
import '../../../class/system.dart';
import '../../../class/system/search.dart';
import '../../../class/system/state.dart';
import '../../../class/transaction.dart';
import '../../../class/widget/button.dart';
import '../../../class/widget/textInput.dart';
import '../../../helper/dialog.dart';
import '../../../helper/firebaseCore.dart';
import '../../../helper/interfaceUI.dart';
import '../../../helper/pdfx.dart';
import '../../../system/system_date.dart';
import 'package:http/http.dart' as http;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../ui/ux.dart';
import 'dart:js' as js;
import 'dart:html' as html;


class ERPViewParams {
  final Widget topWidget;
  final Widget bottomWidget;
  final Widget navigateWidget;

  ERPViewParams({
    required this.topWidget,
    required this.bottomWidget,
    required this.navigateWidget,
  });
}




class ViewPaymentDaily extends StatefulWidget {

  ViewPaymentDaily();

  @override
  _ViewPaymentDailyState createState() => _ViewPaymentDailyState();
}

class _ViewPaymentDailyState extends State<ViewPaymentDaily> {
  TextEditingController searchInput = TextEditingController();
  var divideHeight = 6.0;


  var title = "일계표";
  var titlePurchase = "매입";
  var titleRevenue = "매출";
  var titleTransPU = "수입";
  var titleTransRE = "지출";

  List<Purchase> purchaseList = [];
  List<Revenue> revenueList = [];
  List<TS> tsList = [];


  @override
  void initState() {
    super.initState();
    initAsync();
  }



  void initAsync() async {
    var now = DateTime.now();
    var startDate = DateTime(now.year, now.month, now.day - 1);

    purchaseList = await DatabaseM.getPurchase(startDate: startDate.microsecondsSinceEpoch);
    revenueList = await DatabaseM.getRevenue(startDate: startDate.microsecondsSinceEpoch );
    tsList = await DatabaseM.getTransaction(startDate: startDate.microsecondsSinceEpoch);

    setState(() {});
  }


  Widget mainBuild({ ERPViewParams? params }) {
    Widget titleWidget = ListBoxT.Rows(
      children: [
        SizedBox(height: 64,),
        TextT.Title(text: title),
      ],
    );
    Widget bottomWidget = SizedBox();
    List<Widget> childrenW = [];



    List<Widget> purchaseWidgets = [
      TextT.Lit(text: titlePurchase),
      CompPU.tableHeader(),
    ];
    for(var pu in purchaseList) {
      purchaseWidgets.add(CompPU.tableUI(context, pu));
      purchaseWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }



    List<Widget> tras = [
      TextT.Lit(text: titlePurchase),
      CompPU.tableHeader(),
    ];
    for(var pu in purchaseList) {
      purchaseWidgets.add(CompPU.tableUI(context, pu));
      purchaseWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }







    return PageWidget.View(
      titleWidget: titleWidget,
      children: [
        ListBoxT.Columns(children: purchaseWidgets),
        //ListBoxT.Columns(children: revenueWidgets),
        //ListBoxT.Columns(children: revenueWidgets),
      ],
      bottomWidget: bottomWidget,
    );
  }


  @override
  Widget build(context) {
    return mainBuild();
  }
}
