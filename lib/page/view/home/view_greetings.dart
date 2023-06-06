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
import 'package:evers/class/widget/youtube.dart';
import 'package:evers/core/context_data.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/info/menu.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../class/database/article.dart';
import '../../../core/quill/universal_ui.dart';
import '../../../helper/firebaseCore.dart';


class ViewGreetings extends StatefulWidget {
  ViewGreetings() { }

  @override
  _ViewGreetingsState createState() => _ViewGreetingsState();
}

class _ViewGreetingsState extends State<ViewGreetings> {
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
    article = await DatabaseM.getPageArticle(HomeSubMenu.greetings.code);
    _controller = QuillController(
      document: Document.fromJson(jsonDecode(article.json)),
      selection: TextSelection.collapsed(offset: 0),
    );

    setState(() {});
  }




  /// 이 함수는 매인 위젯 빌더입니다.
  Widget mainBuild() {
    var padding = MediaQuery.of(context).size.width * 0.07;

    var titleWidget = Stack(
      alignment: Alignment.center,
      children: [
        Row(
            children: [
              Expanded(
                  child: Container(
                    height: 380, width: double.maxFinite,
                    child: CachedNetworkImage(imageUrl:'https://raw.githubusercontent.com/PinTrees/evers/main/sever/DSC03001.JPG.jpg', fit: BoxFit.cover),
                  )
              )
            ]
        ),
        Positioned(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextT.Lit(text: "에버스 소개", color: Colors.white, bold: true, size: 20),
              SizedBox(height: 6 * 4,),
              TextT.Lit(text: "에버스, 건강과 맛을 담은 동결건조 식품의 선택!", color: Colors.white, size: 28),
            ],
          ),
        )
      ],
    );
    var greetingWidget = Container(
      padding:  ContextData.getPlatformPaddingH(context),
      child: QuillEditor.basic(
        controller: _controller,
        readOnly: true,
        embedBuilders: defaultEmbedBuildersWeb,
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        titleWidget,
        SizedBox(height: 6 * 8,),
        greetingWidget,
        SizedBox(height: 6 * 8,),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    return mainBuild();
  }
}
