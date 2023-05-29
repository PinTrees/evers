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
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../../helper/interfaceUI.dart';


class ViewHome extends StatefulWidget {
  ViewHome() { }

  @override
  _ViewHomeState createState() => _ViewHomeState();
}


class _ViewHomeState extends State<ViewHome> {
  var dividHeight = 6.0;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
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
                    height: 900, width: double.maxFinite,
                    child: CachedNetworkImage(imageUrl:'https://raw.githubusercontent.com/PinTrees/evers/main/sever/DSC03001.JPG.jpg', fit: BoxFit.cover),
                  )
              )
            ]
        ),
        Positioned(
          left: 128,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetT.titleT('동결건조로 완성한 신선한 맛', size: 50, bold: true, color: Colors.white),
              Container(
                width: 500,
                child: WidgetT.titleT('오랫동안 연구를 통해 개발한 동결건조 기술을 건강하고 신선한 원재료와 접목시켰습니다.', size: 28, bold: false, color: Colors.white),
              )
            ],
          ),
        ),
      ],
    );

    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          titleWidget,
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return mainBuild();
  }
}
