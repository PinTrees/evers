/*
import 'dart:convert';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_item.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/system/records.dart';
import 'package:evers/class/widget/excel/excel_grid.dart';
import 'package:evers/class/widget/excel/excel_table.dart';
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
import '../../../class/database/balance.dart';
import '../../../class/purchase.dart';
import '../../../class/revenue.dart';
import '../../../class/schedule.dart';
import '../../../class/system.dart';
import '../../../class/system/search.dart';
import '../../../class/system/state.dart';
import '../../../class/transaction.dart';
import '../../../class/widget/button.dart';
import '../../../class/widget/textInput.dart';
import '../../../helper/calender.dart';
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




class ViewCustomer extends StatefulWidget {

  ViewCustomer();

  @override
  _ViewCustomerState createState() => _ViewCustomerState();
}

class _ViewCustomerState extends State<ViewCustomer> {
  TextEditingController searchInput = TextEditingController();
  var divideHeight = 6.0;


  @override
  void initState() {
    super.initState();

    initAsync();
  }

  int currentDaily = 1;


  void initAsync() async {
    await balance.init(startAt: startDate!.microsecondsSinceEpoch, lastAt: lastDate!.microsecondsSinceEpoch);

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
              lastDate = DateTime.now();
              startDate = DateTime(lastDate!.year, lastDate!.month, lastDate!.day - 1);
              initAsync();
            }
        ),
        SizedBox(width: 6,),
        ButtonT.TabMenu("1 주일", Icons.calendar_view_week,
            onTap: () {
              lastDate = DateTime.now();
              startDate = DateTime(lastDate!.year, lastDate!.month, lastDate!.day - 7);
              initAsync();
            }
        ),
        SizedBox(width: 6,),
        ButtonT.TabMenu("1 개월", Icons.calendar_month,
            onTap: () {
              lastDate = DateTime.now();
              startDate = DateTime(lastDate!.year, lastDate!.month - 1, lastDate!.day);
              initAsync();
            }
        ),
      ],
    );
    Widget bottomWidget = SizedBox();



    List<Widget> dayInfoWidget = [
      TextT.SubTitle(text: StyleT.dateFormatYYMMDD(startDate!.microsecondsSinceEpoch)),
      ButtonT.IconText(
        icon: Icons.calendar_month, text: "시작날짜 변경",
        onTap: () async {
          var selectedDate = await CalenderManager.selectDate(context, startDate);
          if(selectedDate != null) {
            startDate = selectedDate;
            initAsync();
          }
        }
      ),
      SizedBox(width: 6 * 2,),
      TextT.SubTitle(text: "~"),
      SizedBox(width: 6 * 2,),
      TextT.SubTitle(text: StyleT.dateFormatYYMMDD(lastDate!.microsecondsSinceEpoch)),
      ButtonT.IconText(
          icon: Icons.calendar_month, text: "종료날짜 변경",
          onTap: () async {
            var selectedDate = await CalenderManager.selectDate(context, lastDate);
            if(selectedDate != null) {
              lastDate = selectedDate;
              initAsync();
            }
          }
      ),
    ];


    List<Widget> purchaseWidgets = [
      TextT.SubTitle(text: titlePurchase),
      SizedBox(height: 6,),
      Row(
        children: [
          Expanded(child: CompPU.tableHeader(),),
          SizedBox(width: 6,),
          Expanded(child: CompTS.tableHeader()),
        ],
      )
    ];

    List<Widget> revenueWidgets = [
      TextT.SubTitle(text: titleRevenueTs),
      SizedBox(height: 6,),
      Row(
        children: [
          Expanded(child: CompPU.tableHeader()),
          SizedBox(width: 6,),
          Expanded(child: CompTS.tableHeader()),
        ],
      )
    ];


    List<Widget> puTableWidget = [];
    for(var pu in balance.purchaseList) {
      puTableWidget.add(CompPU.tableUI(context, pu, index: (puTableWidget.length / 2).toInt()));
      puTableWidget.add(WidgetT.dividHorizontal(size: 0.35));
    }
    List<Widget> reTableWidget = [];
    for(var re in balance.revenueList) {
      reTableWidget.add(CompRE.tableUI(context, re, index: (reTableWidget.length / 2).toInt()));
      reTableWidget.add(WidgetT.dividHorizontal(size: 0.35));
    }

    List<Widget> tsReTableWidget = [];
    List<Widget> tsPuTableWidget = [];
    for(var ts in balance.tsList) {
      if(ts.type == "RE") {
        tsReTableWidget.add(CompTS.tableUI(context, ts, index: (tsReTableWidget.length / 2).toInt(), edite: false));
        tsReTableWidget.add(WidgetT.dividHorizontal(size: 0.35));
      }
      else if(ts.type == "PU") {
        tsPuTableWidget.add(CompTS.tableUI(context, ts, index: (tsPuTableWidget.length / 2).toInt(), edite: false));
        tsPuTableWidget.add(WidgetT.dividHorizontal(size: 0.35));
      }
    }

    purchaseWidgets.add(IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: Column(children: puTableWidget,)),
          Expanded(child: Column(children: tsPuTableWidget,)),
        ],
      ),
    ));
    purchaseWidgets.add(IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: ExcelTable(
            children: [ExcelGridText(text: StyleT.krwInt(balance.puAmount), label: "매입액",),],
          )),
          SizedBox(width: 6,),
          Expanded(child: ExcelTable(
            children: [ExcelGridText(text: StyleT.krwInt(balance.puTsAmount), label: "지출액",),],
          )),
        ],
      ),
    ));

    revenueWidgets.add(IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: Column(children: reTableWidget,)),
          Expanded(child: Column(children: tsReTableWidget,)),
        ],
      ),
    ));
    revenueWidgets.add(IntrinsicHeight(
      child: Row(
        children: [
          Expanded(child: ExcelTable(
            children: [ExcelGridText(text: StyleT.krwInt(balance.reAmount), label: "매출액",),],
          )),
          SizedBox(width: 6,),
          Expanded(child: ExcelTable(
            children: [ExcelGridText(text: StyleT.krwInt(balance.reTsAmount), label: "수금액",),],
          )),
        ],
      ),
    ));

    Widget balanceInfoWidget = ListBoxT.Columns(
      children: [
        TextT.SubTitle(text: titleBalanceDes),
        SizedBox(height: 6,),
        ExcelTable(
          children: [
            ExcelGridText(text: StyleT.krwInt(balance.reAmount), label: "매출액",),
            ExcelGridText(text: StyleT.krwInt(balance.puAmount), label: "매입액",),
            ExcelGridText(text: StyleT.krwInt(balance.reTsAmount), label: "수금액",),
            ExcelGridText(text: StyleT.krwInt(balance.puTsAmount), label: "지출액",),
            ExcelGridText(text: StyleT.krwInt(balance.getLastBalance()), label: "전일 잔액",),
            ExcelGridText(text: StyleT.krwInt(balance.allBalance), label: "현재 잔액",),
          ],
        )
      ]
    );

    Widget productInfoWidget = ListBoxT.Columns(
        children: [
          TextT.SubTitle(text: titleProduct),
          SizedBox(height: 6,),
          Row(
            children: [
              Expanded(child: CompProcess.tableHeaderOutput()),
              SizedBox(width: 6,),
              Expanded(child: CompProcess.tableHeader()),
            ],
          ),
          ExcelTable(
            children: [
            ],
          )
        ]
    );

    Widget contractInfoWidget = ListBoxT.Columns(
        children: [
          TextT.SubTitle(text: titleContract),
          SizedBox(height: 6,),
          ExcelTable(
            children: [
            ],
          )
        ]
    );


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
        balanceInfoWidget,
        ListBoxT.Columns(children: purchaseWidgets),
        ListBoxT.Columns(children: revenueWidgets),
        contractInfoWidget,
        productInfoWidget,
        bottomWidget,
      ],
    );
  }

  @override
  Widget build(context) {
    return mainBuild();
  }
}
*/
