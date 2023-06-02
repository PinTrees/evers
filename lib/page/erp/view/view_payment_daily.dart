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
  var titlePurchase = "매입 내역";
  var titleRevenue = "매출 내역";
  var titleTransPU = "지출 내역";
  var titleTransRE = "수입 내역";

  var titleBalance = "현재 잔고";
  var titleLastBalance = "전일 잔고";
  var titleDayInfo = "날짜 범위";

  List<Purchase> purchaseList = [];
  List<Revenue> revenueList = [];
  List<TS> tsList = [];
  Map<String, int> account = {};
  int balance = 0;

  DateTime? startDate;
  DateTime? lastDate;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  int currentDaily = 1;


  void initAsync() async {
    lastDate = DateTime.now();
    startDate = DateTime(lastDate!.year, lastDate!.month, lastDate!.day - currentDaily);

    purchaseList = await DatabaseM.getPurchase(startDate: startDate?.microsecondsSinceEpoch, lastDate: lastDate?.microsecondsSinceEpoch);
    revenueList = await DatabaseM.getRevenue(startDate: startDate?.microsecondsSinceEpoch, lastDate: lastDate?.microsecondsSinceEpoch);
    tsList = await DatabaseM.getTransaction(startDate: startDate?.microsecondsSinceEpoch, lastDate: lastDate?.microsecondsSinceEpoch);

    balance = 0;
    for(var a in SystemT.accounts.values) {
      var amount = await DatabaseM.getAmountAccount(a.id,);
      Account acc = SystemT.getAccount(a.id) ?? Account.fromDatabase({});
      account[a.id] = amount + acc.balanceStartAt;
    }
    account.forEach((key, value) { balance += value; });

    setState(() {});
  }


  Widget mainBuild({ ERPViewParams? params }) {
    int index = 0;

    Widget titleWidget = ListBoxT.Rows(
      children: [
        SizedBox(height: 64,),
        TextT.TitleMain(text: title,),
        SizedBox(width: 6 * 4,),

        ButtonT.TabMenu("금일", Icons.view_day,
            onTap: () {
              currentDaily = 1;
              initAsync();
            }
        ),
        SizedBox(width: 6,),
        ButtonT.TabMenu("1 주일", Icons.calendar_view_week,
            onTap: () {
              currentDaily = 7;
              initAsync();
            }
        ),
        SizedBox(width: 6,),
        ButtonT.TabMenu("1 개월", Icons.calendar_month,
            onTap: () {
              currentDaily = DateTime.now().day - 1;
              initAsync();
            }
        ),
      ],
    );
    Widget bottomWidget = SizedBox();



    List<Widget> dayInfoWidget = [
      TextT.SubTitle(text: StyleT.dateFormatYYMMDD(startDate!.microsecondsSinceEpoch)),
      SizedBox(width: 6 * 2,),
      TextT.SubTitle(text: "~"),
      SizedBox(width: 6 * 2,),
      TextT.SubTitle(text: StyleT.dateFormatYYMMDD(lastDate!.microsecondsSinceEpoch)),
    ];


    List<Widget> purchaseWidgets = [
      TextT.SubTitle(text: titlePurchase),
      SizedBox(height: 6,),
      CompPU.tableHeader(),
    ];

    index = 1;
    for(var pu in purchaseList) {
      purchaseWidgets.add(CompPU.tableUI(context, pu, index: index++));
      purchaseWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }


    List<Widget> revenueWidgets = [
      TextT.SubTitle(text: titleRevenue),
      SizedBox(height: 6,),
      CompPU.tableHeader(),
    ];

    index = 1;
    for(var re in revenueList) {
      purchaseWidgets.add(CompRE.tableUI(context, re, index: index++));
      purchaseWidgets.add(WidgetT.dividHorizontal(size: 0.35));
    }


    List<Widget> tsPuWidgets = [
      TextT.SubTitle(text: titleTransPU),
      SizedBox(height: 6,),
      CompTS.tableHeader(),
    ];
    List<Widget> tsReWidgets = [
      TextT.SubTitle(text: titleTransRE),
      SizedBox(height: 6,),
      CompTS.tableHeader(),
    ];

    for(var ts in tsList) {
      if(ts.type == "RE") {
        tsReWidgets.add(CompTS.tableUIMain(context: context, ts, index: (tsReWidgets.length / 2).toInt()));
        tsReWidgets.add(WidgetT.dividHorizontal(size: 0.35));
      }
      else if(ts.type == "PU") {
        tsPuWidgets.add(CompTS.tableUIMain(context: context, ts, index: (tsPuWidgets.length / 2).toInt()));
        tsPuWidgets.add(WidgetT.dividHorizontal(size: 0.35));
      }
    }





    int dailyAmount = 0;
    for(var ts in tsList) {
      dailyAmount += ts.amount;
    }

    List<Widget> balanceCurrWidgets = [
      TextT.SubTitle(text: titleBalance),
      SizedBox(height: 6,),
      TextT.SubTitle(text: StyleT.krwInt(balance)),
    ];
    List<Widget> balanceLastWidgets = [
      TextT.SubTitle(text: titleLastBalance),
      SizedBox(height: 6,),
      TextT.SubTitle(text: StyleT.krwInt(balance - dailyAmount)),
    ];




    return ListBoxT.Columns(
      spacing: 6 * 4,
      children: [
        titleWidget,

        ListBoxT.Columns(
          children: [
            TextT.SubTitle(text: titleDayInfo) ,
            SizedBox(height: 6,),
            ListBoxT.Rows(children: dayInfoWidget),
          ],
        ),
        ListBoxT.Columns(children: purchaseWidgets),
        ListBoxT.Columns(children: revenueWidgets),
        ListBoxT.Columns(children: tsPuWidgets),
        ListBoxT.Columns(children: tsReWidgets),
        ListBoxT.Columns(children: balanceCurrWidgets),
        ListBoxT.Columns(children: balanceLastWidgets),
        bottomWidget,
        //ListBoxT.Columns(children: revenueWidgets),
        //ListBoxT.Columns(children: revenueWidgets),
      ],
    );
  }


  @override
  Widget build(context) {
    return mainBuild();
  }
}
