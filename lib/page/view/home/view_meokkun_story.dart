import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/core/context_data.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/info/menu.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../class/database/article.dart';
import '../../../core/quill/universal_ui.dart';
import '../../../helper/firebaseCore.dart';


class ViewStory extends StatefulWidget {
  ViewStory() { }

  @override
  _ViewStoryState createState() => _ViewStoryState();
}

class _ViewStoryState extends State<ViewStory> {
  var dividHeight = 6.0;

  QuillController _controller = QuillController.basic();
  PageArticle article = PageArticle.fromDatabase({});

 @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
    article = await DatabaseM.getPageArticle(HomeSubMenu.eversStory.code);
    _controller = QuillController(
      document: Document.fromJson(jsonDecode(article.json)),
      selection: TextSelection.collapsed(offset: 0),
    );
    setState(() {});
  }



  /// 이 함수는 매인 위젯 빌더입니다.
  Widget mainBuild() {
    var padding = MediaQuery.of(context).size.width * 0.1;

    var titleWidget = Stack(
      alignment: Alignment.center,
      children: [
        Row(
            children: [
              Expanded(
                  child: Container(
                    height: 380, width: double.maxFinite,
                    child: CachedNetworkImage(imageUrl:'https://raw.githubusercontent.com/PinTrees/evers/main/sever/20230526_20180.jpg', fit: BoxFit.cover),
                  )
              )
            ]
        ),
        Positioned(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextT.Lit(text: "우리의 이야기", color: Colors.white, bold: true, size: 20),
              SizedBox(height: 6 * 4,),
              TextT.Lit(text: "건강한 맛의 향연, 신제품을 향한 끊임없는 도전", color: Colors.white, size: 28),
            ],
          ),
        )
      ],
    );

    var viewWidget = Container(
      padding:  ContextData.getPlatformPaddingH(context),
      child: QuillEditor.basic(
        controller: _controller,
        readOnly: true,
        embedBuilders: defaultEmbedBuildersWeb,
      ),
    );


    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleWidget,
          viewWidget
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return mainBuild();
  }
}
