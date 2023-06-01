import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/system.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/interfaceUI.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/view/home/view_article.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_quill/flutter_quill.dart' hide Text;

import '../../../class/database/article.dart';
import '../../../ui/dl.dart';



class ViewNews extends StatefulWidget {
  ViewNews() { }

  @override
  _ViewNewsState createState() => _ViewNewsState();
}


class _ViewNewsState extends State<ViewNews> {
  var dividHeight = 6.0;

  Map<String, Widget> thumbnail = {};
  List<Article> articles = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }
  void initAsync() async {
    CollectionReference coll = await FirebaseFirestore.instance.collection('contents/news/article');
    await coll.orderBy('createAt', descending: true).limit(20).get().then((value) async {
      if(value.docs.isEmpty) return false;

      for(var e in value.docs) {
        if(e.data() == null) continue;
        var art = Article.fromDatabase(e.data() as Map);
        articles.add(art);
      }
    });

    setState(() {});
  }




  /// 이 함수는 매인 위젯 빌더입니다.
  Widget mainBuild() {
    var titleWidget = Stack(
      alignment: Alignment.center,
      children: [
        Row(
            children: [
              Expanded(
                  child: Container(
                    height: 380, width: double.maxFinite,
                    child: CachedNetworkImage(imageUrl:'https://raw.githubusercontent.com/PinTrees/evers/main/sever/df405229-585f-4a6c-9d9a-1ebf33cde99c.png', fit: BoxFit.cover),
                  )
              )
            ]
        ),

      ],
    );


    List<Widget> newsArticleWidgetList = [];
    articles.forEach((e) {
      newsArticleWidgetList.add(
        InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (ss) => ViewArticle(article: e)));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 350, height: 200,
                padding: EdgeInsets.all(1.4),
                color: Colors.grey.withOpacity(0.3),
                child: e.thumbnail == '' ?
                Padding(padding: EdgeInsets.all(48),  child: CachedNetworkImage(imageUrl: "https://raw.githubusercontent.com/PinTrees/evers/main/sever/icon_hor.png", fit: BoxFit.contain,))
                 : CachedNetworkImage(imageUrl: e.thumbnail, fit: BoxFit.cover,),
              ),
              SizedBox(height: 6 * 2,),
              Container(
                height: 150, width: 350,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextT.Lit(text: e.title, size: 18, bold: true, color: Colors.black, maxLine: 2),
                    SizedBox(height: 6 * 2,),
                    TextT.Lit(text: e.desc.replaceAll('\n', ''), size: 14, maxLine: 2),
                    SizedBox(height: 6 * 3,),
                    TextT.Lit(text: StyleT.dateFormatYYMMDD(e.createAt), size: 14,),
                  ],
                ),
              )
            ],
          ),
        )
      );
    });

    var newsArticleWidget = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 64,),
          ListBoxT.Wraps(
            spacing: 6 * 4,
            children: newsArticleWidgetList,
          ),
          SizedBox(height: 64,),
        ],
      ),
    );


    var createArticleWidget = ButtonT.IconText(
        icon: Icons.add_box, text: "공지사항 추가",
        onTap: () {
          showCreatePage(context);
        }
    );

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleWidget,
          newsArticleWidget,
          if(FirebaseAuth.instance.currentUser != null)
            createArticleWidget,
        ],
      ),
    );
  }







  dynamic showCreatePage(BuildContext context, { String? type }) async {
    Article article = Article.fromDatabase({});
    late QuillEditorController controller;

    var backgroundColor = Colors.white70;
    var editorTextStyle = const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal);
    var hintTextStyle = const TextStyle(fontSize: 18, color: Colors.black12, fontWeight: FontWeight.normal);

    controller = QuillEditorController();
    controller.onTextChanged((text) { /*debugPrint('listening to $text');*/ } );

    var editor = QuillHtmlEditor(
        text: "내용을 입력하세요.",
        hintText: 'Hint text goes here',
        controller: controller,
        //isEnabled: true,
        minHeight: 300,
        textStyle: editorTextStyle,
        hintTextStyle: hintTextStyle,
        hintTextAlign: TextAlign.start,
        padding: const EdgeInsets.only(left: 10, top: 5),
        hintTextPadding: EdgeInsets.zero,
        backgroundColor: backgroundColor,
    );
    var toolbar = ToolBar(
      toolBarColor: Colors.cyan.shade50,
      activeIconColor: Colors.green,
      padding: const EdgeInsets.all(8),
      iconSize: 20,
      controller: controller,
      customButtons: [
        InkWell(onTap: () {}, child: const Icon(Icons.favorite)),
        InkWell(onTap: () {}, child: const Icon(Icons.add_circle)),
      ],
    );
    var www = MediaQuery.of(context).size.width * 0.9;

    bool? aa = await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.15),
        barrierDismissible: false,
        builder: (BuildContext context) {
          return  StatefulBuilder(
            builder: (BuildContext context, StateSetter setStateS) {
              var titleInputWidget = InputWidget.LitText(context, "ascdasdcasdc",
                color: Colors.white, textSize: 36, width: 1280, height: 68, expand: true, bold: true, textColor: Colors.black,
                setState: () { setStateS(() {}); },
                onEdited: (i, data) {
                  article.title = data;
                },
                hint: "제목을 입력하세요",
                text: article.title,
              );

              return AlertDialog(
                backgroundColor: StyleT.white.withOpacity(1),
                elevation: 36,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey.shade700, width: 0.01),
                    borderRadius: BorderRadius.circular(0)),
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                title: WidgetDT.dlTitle(context, title: '새 공지사항 작성', ),
                content: Container(
                  padding: EdgeInsets.all(18),
                  height: MediaQuery.of(context).size.height - 300,
                  child: Column(
                    children: [
                      titleInputWidget,
                      WidgetT.dividHorizontal(size: 2, color: Colors.grey.withOpacity(0.3)),
                      toolbar,
                      Expanded(child: Container(width: www, child: editor)),
                    ],
                  ),
                ),
                actionsPadding: EdgeInsets.zero,
                actions: [
                  ButtonT.Action(context, "저장",
                      icon: Icons.save,
                      //altText: "새 글을 등록하시겠습니까?",
                      onTap: () async {
                        String? htmlText = await controller.getText();
                        if(htmlText == null) return Messege.toReturn(context, "내용은 비워둘 수 없습니다.", false);

                        article.version = "flutter_quill:6.1.0";
                        article.desc = await controller.getPlainText();
                        article.createAt = DateTime.now().microsecondsSinceEpoch;
                        article.type = "news";
                        await article.update(data: htmlText);

                        print(htmlText);
                        Navigator.pop(context);
                      }
                  ),
                ],
              );
            },
          );
        });

    if(aa == null) aa = false;
    return aa;
  }



  @override
  Widget build(BuildContext context) {
    return mainBuild();
  }
}

