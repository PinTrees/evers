import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
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
import '../../../../class/database/article.dart';
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

import '../../../window/window_shopitem_editor.dart';


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

  List<ShopArticle> shopItemList = [];

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  void initAsync() async {
    shopItemList = await DatabaseM.getShopItemList();
    setState(() {});
  }

  Widget mainBuild({ ERPViewParams? params }) {

    var shopItemsWidget = ListBoxT.Wraps(
      spacing: 6,
      children: [
        for(var item in shopItemList)
          InkWell(
            onTap: () {
              UIState.OpenNewWindow(context, WindowShopItemEditor(shopItem: item, refresh: () { initAsync(); }));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 128, height: 128,
                  color: Colors.grey.withOpacity(0.5),
                  padding: EdgeInsets.all(1.4),
                  child: CachedNetworkImage(imageUrl: item.thumbnail.first ?? "", fit: BoxFit.cover,),
                ),
                SizedBox(height: 6,),
                TextT.Lit(text: item.name, color: Colors.black, bold: true, size: 12,),
                SizedBox(height: 6,),
              ],
            ),
          ),
      ]
    );

    List<Widget> widgets = [
      WidgetT.title('제품관리', size: 18),
      shopItemsWidget,
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
