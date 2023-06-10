import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:adaptive_scrollbar/adaptive_scrollbar.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_cs.dart';
import 'package:evers/class/database/article.dart';
import 'package:evers/class/user.dart';
import 'package:evers/class/version.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/widget.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/info/menu.dart';
import 'package:evers/page/window/window_article_create.dart';
import 'package:evers/page/window/window_cs.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
import '../../../class/widget/page.dart';
import '../../../class/widget/textInput.dart';
import '../../../helper/dialog.dart';
import '../../../helper/firebaseCore.dart';
import '../../../helper/interfaceUI.dart';
import 'package:http/http.dart' as http;

import '../../../ui/ux.dart';
import '../../core/quill/universal_ui.dart';

/// 고객및 계약 시스템

class PageSettingInfo extends StatefulWidget {
  Widget? topWidget;
  String menu;
  Widget? infoWidget;
  PageSettingInfo({ required this.menu,
    this.topWidget,
    this.infoWidget,
  }) { }

  @override
  _PageSettingInfoState createState() => _PageSettingInfoState();
}

class _PageSettingInfoState extends State<PageSettingInfo>  {
  TextEditingController searchInput = TextEditingController();

  var devUid = "j5NTk10lQZVsTvYTv7BSmTGG50A2";

  /// 정렬 상태 변수
  bool sort = false;
  String menu = "";
  List<Article> articles = [];
  Article currentArticle = Article.fromDatabase({});
  QuillController _controller = QuillController.basic();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  /// 초기화자
  dynamic initAsync() async {
    articles = await DatabaseM.getArticleWithCode("version");
    if(articles.isNotEmpty) currentArticle = articles.first;

    print(currentArticle.json);

    _controller = QuillController(
      document: Document.fromJson(jsonDecode(currentArticle.json)),
      selection: TextSelection.collapsed(offset: 0),
    );

    setState(() {});
  }


  /// 메인 위젯을 그리는 함수입니다.
  Widget mainView({ Widget? topWidget, Widget? infoWidget }) {
    Widget createWidget = const SizedBox();
    if(UserSystem.userData.id == devUid) {
      createWidget = ListBoxT.Rows(
        spacing:  6 * 2,
          children: [
            ButtonT.IconText(
                icon: Icons.refresh, text: "거래기록 검색 메타데이터 재구축",
                onTap: () async {
                  List<TS> tsList = await DatabaseM.getTransactionAll();
                  int index = 0;
                  for(var ts in tsList) {
                    var res = await ts.update();
                    Messege.show(context, "데이터 저장완료 ${index++}");
                  }
                }
            ),

            ButtonT.IconText(
                icon: Icons.add_box, text: "새 버전 추가",
                onTap: () {
                  UIState.OpenNewWindow(context, WindowArticleEditor( board: "version", refresh: () { initAsync(); }));
                }
            ),
            ButtonT.IconText(
                icon: Icons.add_box, text: "버전 수정",
                onTap: () {
                  UIState.OpenNewWindow(context, WindowArticleEditor(board: "version", article: currentArticle, refresh: () { initAsync(); }));
                }
            ),
          ]
      );
    }
    if(menu != widget.menu) {
      menu = widget.menu;
      initAsync();
      return PageWidget.MainPage(
        topWidget: topWidget,
        infoWidget: infoWidget,
        children: [ LinearProgressIndicator(minHeight: 2,) ],
      );
    }

    List<Widget> titleWidgets = [];
    List<Widget> widgets = [];

    /// 메뉴 분기
    if(menu == ERPSubMenuInfo.update.displayName) {
      titleWidgets.add(ListBoxT.Rows(
          spacing: 6 * 4,
          children: [
            TextT.Title(text: "현재 버전 : ${Version.thisVersion}"),
            TextT.Title(text: "안정 버전 : ${Version.current}"),
          ]
        ));
      titleWidgets.add(ListBoxT.Rows(
          spacing: 6,
          children: [
          TextT.SubTitle(text: "버전 기록"),
            SizedBox(width: 6 * 2,),
            for(var a in articles)
              ButtonT.Text( text: a.version, round: 8,
                  onTap: () {
                    currentArticle = a;
                    _controller = QuillController(
                      document: Document.fromJson(jsonDecode(currentArticle.json)),
                      selection: TextSelection.collapsed(offset: 0),
                    );
                    setState(() {});
                  },
              ),
          ]
      ));
      widgets.add(buildArticleListView());
    }
    else if(menu == ERPSubMenuInfo.update.displayName) {

    }

    var main = PageWidget.MainPage(
      topWidget: topWidget,
      infoWidget: infoWidget,
      titleWidget: ListBoxT.Columns(
        spacingStartEnd: 6 * 2,
        children: [
        Row(
          children: [
            TextT.Title(text: menu),
            SizedBox(width: 6 * 4,),
            createWidget,
          ],
        ),
        for(var w in titleWidgets) w,
      ],),
      children: widgets,
    );
    return main;
  }

  Widget buildArticleListView() {

    List<Widget> articleView = [
      Container(
        width: 1000,
        padding: EdgeInsets.all(18),
        child: QuillEditor.basic(
          controller: _controller,
          readOnly: true,
          embedBuilders: defaultEmbedBuildersWeb,
        ),
      ),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: articleView,);
  }

  @override
  Widget build(context) {
    return mainView(infoWidget: widget.infoWidget, topWidget: widget.topWidget);
  }
}
