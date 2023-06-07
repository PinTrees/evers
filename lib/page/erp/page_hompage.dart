import 'dart:convert';
import 'dart:ui';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/database/article.dart';
import 'package:evers/class/system/state.dart';
import 'package:evers/class/widget/article/article_table.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/page.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/info/menu.dart';
import 'package:evers/page/erp/view/homepage/view_shopitem.dart';
import 'package:evers/page/window/window_article_create.dart';
import 'package:evers/page/window/window_pageA_create.dart';
import 'package:evers/ui/dialog_revenue.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../class/Customer.dart';
import '../../../class/transaction.dart';
import '../../../class/widget/list.dart';
import '../../../helper/dialog.dart';
import '../../../helper/firebaseCore.dart';
import '../../../helper/interfaceUI.dart';
import '../../../helper/pdfx.dart';
import 'package:http/http.dart' as http;

import '../../../ui/ux.dart';

class PageHomepage extends StatelessWidget {
  var menu = "";

  /// 수정 불가
  var board1 = "8HGb2ghAvOJcjuEd";
  List<Article> board1Articles = [];

  dynamic init() async {
    board1Articles = await DatabaseM.getArticleWithCode(board1);
  }

  var menuStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.15), );
  var menuSelectStyle = StyleT.buttonStyleNone(round: 8, elevation: 0, padding: 0, color: Colors.blueAccent.withOpacity(0.35), );
  var menuPadding = EdgeInsets.fromLTRB(6 * 4, 6 * 1, 6 * 4, 6 * 1);

  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false }) async {
    if(this.menu != menu) {
      this.menu = menu;
      await init();
    }

    List<Widget> childrenW = [];

    if(menu == ERPSubMenuInfo.pageEditor.displayName) {
      childrenW.add(buildViewHomepage(context));
    }
    else if(menu == ERPSubMenuInfo.communityEditor.displayName) {
      childrenW.add(buildViewCommunity(context));
    }
    else if(menu == ERPSubMenuInfo.shopEditor.displayName) {
      childrenW.add(ViewShopItem());
    }

    var main = PageWidget.MainPage(
      topWidget: topWidget,
      infoWidget: infoWidget,
      children: childrenW,
    );

    return main;
  }



  dynamic buildViewHomepage(BuildContext context) {
    List<Widget> widgets = [
      WidgetT.title('홈페이지 관리', size: 18),
      ButtonT.IconText(
          icon: Icons.edit, text: "인사말",
          onTap: () {
            UIState.OpenNewWindow(context, WindowPageACreate(refresh: FunT.setRefreshMain, path: HomeSubMenu.greetings.code,));
          }
      ),
      ButtonT.IconText(
          icon: Icons.edit, text: "걸어온 길",
          onTap: () {
            UIState.OpenNewWindow(context, WindowPageACreate(refresh: FunT.setRefreshMain, path: HomeSubMenu.history.code,));
          }
      ),
      ButtonT.IconText(
          icon: Icons.edit, text: "먹꾼 이야기",
          onTap: () {
            UIState.OpenNewWindow(context, WindowPageACreate(refresh: FunT.setRefreshMain, path: HomeSubMenu.eversStory.code,));
          }
      ),
      ButtonT.IconText(
          icon: Icons.edit, text: "동결건조 기술",
          onTap: () {
            UIState.OpenNewWindow(context, WindowPageACreate(refresh: FunT.setRefreshMain, path: HomeSubMenu.freezeDrying.code,));
          }
      ),
    ];



    return ListBoxT.Columns(spacing: 6 * 4, children: widgets,);
  }

  dynamic buildViewCommunity(BuildContext context) {
    List<Widget> widgets = [
      WidgetT.title('커뮤니티 관리', size: 18),

      ListBoxT.Columns(
        children: [
          WidgetT.title('새소식 게시판 관리', size: 18),
          ListBoxT.Columns(
            spacingStartEnd: 6,
            children: [
              for(var a in board1Articles)
                ArticleTable(article: a),
            ]
          ),
          ButtonT.IconText(
              icon: Icons.edit, text: "새소식 추가",
              onTap: () {
                UIState.OpenNewWindow(context, WindowArticleEditor(refresh: FunT.setRefreshMain, board: board1,));
              }
          ),
        ]
      ),
    ];
    return ListBoxT.Columns(spacing: 6 * 4, children: widgets,);
  }


  Widget build(context) {
    return Container();
  }
}
