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


class ViewFreezeDrying extends StatefulWidget {
  ViewFreezeDrying() { }

  @override
  _ViewFreezeDryingState createState() => _ViewFreezeDryingState();
}

class _ViewFreezeDryingState extends State<ViewFreezeDrying> {
  var dividHeight = 6.0;


  var infoText = "에버스는 건강한 식품 개발을 주된 목적사업으로 하여 태어났어요.  에버스는 지난 10년 간의 동결건조 경험을 바탕으로 CDI 방식의 동결건조 시스템 새로 구축하였고,  2018. 3. 18. 법인으로 출발하게 되었어요. 에버스는 그 동안 건강하고  행복한 식품, 스낵 개발 등을 위해 노력해 왔어요. 외주에 의한 동결건조 경험을 기초로 직접 건강한 식품, 스낵의 맛을 탐구하고 찾아내기 위해 노력하였어요."
  "\n\n지난 2년 동안  ‘세상이 없던 맛’ 시리즈 제품을 개발하였고, 브랜드 ‘나는 먹꾼’을 런칭하는 등 많은 변화가 있었죠. 우리의 방식으로 개발한 제품이 나왔을 때 소비자들은 ‘이럿 맛은 처음’이라는 환호성을 질렀어요."
  "\n\n에버스는 자꾸만 손이 가는 맛을 개발하기 위하여 수많은 테스트를 진행했어요. 맛있지만 건강한 제품을 만들겠다는 다짐으로 한 걸음 한 걸음 내디딘 결과, 기존 시장에서는 맛볼 수 없던 특별한 제품을 생산하게 되었어요."
  "\n\n앞으로 고객들의 기대에 부응하기 위해의 영양가 높고 맛과 향을 유지하는 신제품을 개발하기 위해 최선을 다하는 에버스가 되겠습니다.";
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
              TextT.Lit(text: "우리의 기술", color: Colors.white, bold: true, size: 20),
              SizedBox(height: 6 * 4,),
              TextT.Lit(text: "최첨단 기술 및 설비", color: Colors.white, size: 28),
            ],
          ),
        )
      ],
    );


    var greetingWidget = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 64,),
          TextT.Lit(text: "우리가 걸어온 길", color: Colors.black, bold: true, size: 38),
          SizedBox(height: 6 * 12,),
          Container(
            padding: EdgeInsets.only(left: 128, right: 128),
            child: TextT.Lit(text: infoText, color: StyleT.textColor, size: 16, bold: false),
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
          greetingWidget
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return mainBuild();
  }
}
