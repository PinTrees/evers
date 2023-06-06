import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/interfaceUI.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/view/home/view_article.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
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
    articles = await DatabaseM.getArticleWithCode("8HGb2ghAvOJcjuEd");
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
                Padding(padding: EdgeInsets.all(48), child: CachedNetworkImage(imageUrl: "https://raw.githubusercontent.com/PinTrees/evers/main/sever/icon_hor.png", fit: BoxFit.contain,))
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

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleWidget,
          newsArticleWidget,
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return mainBuild();
  }
}

