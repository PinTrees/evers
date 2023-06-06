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
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
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
import '../../../info/menu.dart';


class ViewShopItem extends StatefulWidget {
  ViewShopItem() { }

  @override
  _ViewShopItemState createState() => _ViewShopItemState();
}

class _ViewShopItemState extends State<ViewShopItem> {
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
    article = await DatabaseM.getPageArticle(HomeSubMenu.freezeDrying.code);
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
                    child: CachedNetworkImage(imageUrl:'https://raw.githubusercontent.com/PinTrees/evers/main/sever/234321234.jpg', fit: BoxFit.cover),
                  )
              )
            ]
        ),
        Positioned(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextT.Lit(text: "우리의 기술", color: Colors.white, bold: true, size: 20),
              SizedBox(height: 6 * 4,),
              TextT.Lit(text: "최첨단 기술 및 설비", color: Colors.white, size: 28),
            ],
          ),
        )
      ],
    );

    var viewWidget = Container(
      padding: EdgeInsets.all(padding),
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
