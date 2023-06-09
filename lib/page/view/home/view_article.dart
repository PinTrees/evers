import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/MainPage.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/core/context_data.dart';
import 'package:evers/helper/interfaceUI.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../class/database/article.dart';
import '../../../class/widget/button/button_image_web.dart';
import '../../../core/quill/universal_ui.dart';


class ViewArticle extends StatefulWidget {
  Article article;
  ViewArticle({ required this.article }) { }

  @override
  _ViewArticleState createState() => _ViewArticleState();
}


class _ViewArticleState extends State<ViewArticle> {
  var dividHeight = 6.0;

  var backgroundColor = Colors.white70;
  var editorTextStyle = const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.normal);
  var hintTextStyle = const TextStyle(fontSize: 18, color: Colors.black12, fontWeight: FontWeight.normal);

  QuillController _controller = QuillController.basic();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
    _controller = QuillController(
      document: Document.fromJson(jsonDecode(widget.article.json)),
      selection: TextSelection.collapsed(offset: 0),
    );

    setState(() {});
  }





  /// 이 함수는 매인 위젯 빌더입니다.
  Widget mainBuild() {
    QuillEditorController controller = QuillEditorController();
    controller.enableEditor(false);

    var www = ContextData.getPlatformPadding(context);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(left: www, right: www, ),
      child: ListView(
        children: [
          SizedBox(height: 68,),
          SizedBox(height: 6 * 4,),
          TextT.Lit(text: widget.article.type.toUpperCase(), size: 14,),
          Container(padding: EdgeInsets.all(6 * 2), child: TextT.Lit(text: widget.article.title, size: 20, color: Colors.black, bold: true)),
          TextT.Lit(text: StyleT.dateFormatYYMMDD(widget.article.createAt), size: 14,),
          SizedBox(height: 6 * 4,),
          WidgetT.dividHorizontal(size: 1.4, width: www, color: Colors.black),

          Container(
            padding: EdgeInsets.all(18),
            child: QuillEditor.basic(
              controller: _controller,
              readOnly: true,
              embedBuilders: defaultEmbedBuildersWeb,
            ),
          ),

          Container(child: WidgetT.dividHorizontal(size: 1.4, color: Colors.grey.withOpacity(0.3)),),
          buildBottomBar(),
        ],
      ),
    );
  }








  Widget buildMainMenuMobile() {
    return Column(
      children: [
        Container(
          color: Colors.white,
          height: 68, width: double.maxFinite,
          padding: EdgeInsets.all(6),
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ButtonT.LitIcon(
                  Icons.arrow_back, size: 28,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {});
                  }
              ),
              ButtonImage(style: ButtonImageStyle(imageUrl: "https://raw.githubusercontent.com/PinTrees/evers/main/sever/icon_hor.png", height: 28), params: ButtonTParams(
                  onTap: () async {
                   Navigator.push(context, MaterialPageRoute(builder: (b) => HomePage()));
                  }
              ),),
              ButtonT.Icont(
                  icon: Icons.search,
                  onTap: () {
                  }
              ),
            ],
          ),
        ),
        Container(color: Colors.white, child: WidgetT.dividHorizontal(size: 1.4, color: Colors.grey.withOpacity(0.3)),)
      ],
    );
  }











  Widget buildBottomBar() {
    return Container(
      child: Stack(
        children: [
          Container(
            height: 48,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {});
                    },
                    style: StyleT.buttonStyleNone(elevation: 0, color: Colors.transparent,),
                    child: Container(height: 24, child: Image(image: AssetImage('assets/icon_hor.png') ),)),
                SizedBox(width: 6 * 4,),
                TextT.Lit(text: "Copyright © 에버스. All Rights Reserved.", size: 12, bold: false, color: StyleT.textColor.withOpacity(0.5)),
              ],
            ),
          )
        ],
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Stack(
        children: [
          mainBuild(),
          Positioned(
            top: 0, left: 0, right: 0,
            child: buildMainMenuMobile(),
          ),
        ],
      ),
    );
  }
}

