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
import 'package:evers/page/window/window_shopitem_create.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../class/Customer.dart';
import '../../../../class/contract.dart';
import '../../../../class/purchase.dart';
import '../../../../class/revenue.dart';
import '../../../../class/schedule.dart';
import '../../../../class/system.dart';
import '../../../../class/system/search.dart';
import '../../../../class/system/state.dart';
import '../../../../class/transaction.dart';
import '../../../../class/widget/button.dart';
import '../../../../class/widget/textInput.dart';
import '../../../../helper/dialog.dart';
import '../../../../helper/firebaseCore.dart';
import '../../../../helper/interfaceUI.dart';
import '../../../../helper/pdfx.dart';
import '../../../../system/system_date.dart';
import 'package:http/http.dart' as http;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../ui/ux.dart';
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



class ViewShopItem extends StatefulWidget {
  ViewShopItem();

  @override
  _ViewShopItemState createState() => _ViewShopItemState();
}

class _ViewShopItemState extends State<ViewShopItem> {
  TextEditingController searchInput = TextEditingController();
  var divideHeight = 6.0;

  var title = "일계표";


  @override
  void initState() {
    super.initState();
    initAsync();
  }

  int currentDaily = 1;


  void initAsync() async {
    setState(() {});
  }

  Widget mainBuild({ ERPViewParams? params }) {
    List<Widget> widgets = [
      WidgetT.title('제품관리', size: 18),
      ButtonT.IconText(
        icon: Icons.add_box, text: "제품추가",
        onTap: () {
          UIState.OpenNewWindow(context, WindowShopItemCreate(board: "", refresh: () { initAsync(); }));
        }
      )
    ];
    return ListBoxT.Columns(spacing: 6 * 4, children: widgets,);
  }


  @override
  Widget build(context) {
    return mainBuild();
  }
}
