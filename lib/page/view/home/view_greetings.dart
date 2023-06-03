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
import 'package:youtube_player_iframe/youtube_player_iframe.dart';


class ViewGreetings extends StatefulWidget {
  ViewGreetings() { }

  @override
  _ViewGreetingsState createState() => _ViewGreetingsState();
}

class _ViewGreetingsState extends State<ViewGreetings> {
  var dividHeight = 6.0;

  var _controller;

  var infoText = "안녕하세요"
  "\n\n에버스는 동결건조 전문 회사로서, 동결건조 식품 제조, 스낵류, 조미건어포 등을 제조하고 있습니다."
  "\n동결건조식품은 냉동보관을 통한 공간, 전기 등의 에너지 낭비를 줄일 수 있습니다. 에버스는 농산물 생산 촉진을 위해 지역 농민들과 협력합니다. 이를 통해 지역 노동력도 활용되며 지역 사회의 건강한 발전을 돕고 있습니다."
  "\n저희 회사는 영양소가 최대한 보존되는 동결건조 방법으로 건조한 제품을 원료로 한 건강한 식품 개발을 위해 노력하고 있습니다. 제조 공정은 고객들이 안전하게 건강하면서도 맛있는 제품을 즐길 수 있도록 하기 위하여 철저한 품질관리를 통해 다양한 맛과 영양소를 유지하는데 특화되어 있습니다."
  "\n우리 회사는 고객의 건강을 최우선으로 생각합니다. 회사에서 제품을 만들때는 최고급 원료를 사용하여 제품의 품질을 보장합니다. 동결건조 제품은 다양한 맛과 영양소를 유지할 수 있습니다."
  "\n\n우리 회사의 제품은 건강하고 맛있는 음식을 좋아하는 분들을 위해 디자인되었습니다. 저희 제품은 여러분이 행복하고 건강하게 지내도록 돕기 위해 만들어졌습니다. 또한, 우리 회사는 항상 더 나은 제품을 만들기 위해 노력하고 있습니다. 최신 기술을 도입하여 제품을 개발하고, 다양한 맛을 제공하기 위해 노력하고 있습니다. 우리 회사의 제품은 고객의 다양한 요구에 부합하며, 건강한 식습관을 유지하며 맛있는 음식을 즐길 수 있도록 노력하고 있습니다."
  "\n또한, 회사는 지속가능한 생산을 추구하며, 친환경적인 제조 과정을 적용하고 있습니다. 우리 회사는 제품을 만들기 위해 최소한의 에너지와 자원을 사용하며, 친환경적인 재료를 사용하여 제품을 만듭니다. 우리 회사는 지속적으로 환경 보호에 노력하고 있으며, 이는 우리 회사의 사회적 책임입니다."
  "\n\n주)에버스의 제품은 매일 많은 소비자들에게 사랑받고 있으며, 앞으로도 고객 만족을 위해 노력할 것입니다. 우리는 수많은 연구를 거쳐 최고의 제품을 만들고자 노력하고 있습니다."
  "\n우리의 제품은 다양한 종류가 있습니다. 우리는 고객의 맛에 대한 취향과 관심사를 고려하여 제품을 개발하고 있습니다. 우리의 제품은 다양한 기능과 효과를 제공합니다. 예를 들어, 야외나 가정에서 간단하게 추가적인 요리 없이 섭취할 수 있고, 냉동하지 않고도 오랜 기간 상온에서 보관할 수 있습니다. 영양성분을 최대한 유지하는 가공법으로 다이어트, 체력보강 등 다양한 수요에 부응하고 있습니다."
  "\n에버스는 고객이 안심하고 사용할 수 있는 제품을 만들기 위해 최선을 다하고 있습니다."
  "\n에버스는 유통 비용을 최대한 줄여 소비자에게 혜택을 돌려주기 위해 직접 온라인, 오프라인 판매를 하고 있습니다. 또한, 건강한 식품 문화를 확산시키기 위해 유튜브 영상 채널을 운영하고 있습니다. 이를 통해 고객들은 에버스의 제품에 대한 자세한 정보를 얻을 수 있으며 건강한 식습관을 형성할 수 있습니다.";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }
  void initAsync() async {
    _controller = YoutubePlayerController.fromVideoId(
      videoId: 'wGa_89i_nuU',
      autoPlay: true,
      params: const YoutubePlayerParams(showFullscreenButton: true, mute: true),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 64,),
          TextT.Lit(text: "인사말", color: Colors.black, bold: true, size: 38),
          SizedBox(height: 6 * 12,),
          TextT.Lit(text: "동결건조로 완성한 신선한 맛", color: Colors.black, size: 26, bold: true),
          SizedBox(height: 6 * 8,),


          Container(
            padding: EdgeInsets.only(left: padding, right: padding),
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
          greetingWidget,
          SizedBox(height: 6 * 12,),

          YoutubeContainer(),
          Padding(
            padding: EdgeInsets.all(padding * 1.5),
            child: YoutubePlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return mainBuild();
  }
}
