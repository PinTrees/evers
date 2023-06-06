import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/database/article.dart';
import 'package:evers/class/widget/button/button_shopItem.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/firebaseCore.dart';
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


class ViewMeogkkun extends StatefulWidget {
  ViewMeogkkun() { }

  @override
  _ViewMeogkkunState createState() => _ViewMeogkkunState();
}


class _ViewMeogkkunState extends State<ViewMeogkkun> {
  var dividHeight = 6.0;


  var infoText = "동결건조(Freeze-drying)는 식품 및 약품 등 다양한 분야에서 사용되는 중요한 건조 방법 중 하나입니다. 이 방법은 원래 NASA의 우주 탐사용 식품 저장 방법으로 개발되었지만, 현재는 식품 및 약품 산업에서 널리 사용되고 있습니다. 동결건조은 기존의 건조 방법과 달리 제품의 영양소와 맛, 향을 보존할 수 있는 장점이 있습니다."
  "\n\n동결건조는 제품을 동결한 후 진공 상태에서 건조하는 방법입니다. 이 방법은 물을 제거하는 것이 목적으로, 제품을 동결하여 물이 얼어붙은 상태에서 진공 상태로 만들어 물을 기체로 상태로 변환시켜 제거하는 방법입니다. 동결건조은 기존의 건조 방법과 달리 제품의 구조와 영양소를 보존할 수 있습니다.";


  var infoText2 = "용융점은 고체와 액체의 상태 변화를 일으키는 온도입니다. 즉, 고체에서 액체로 변화하는 온도를 의미합니다. 용융점은 각 물질마다 고유한 값이 있으며, 이는 해당 물질의 화학적 성질과 밀접한 관련이 있습니다."
  "\n\n용융점은 건조과정에서 매우 중요한 역할을 합니다. 일반적으로, 제품 내부의 물의 상태 변화는 제품의 용융점 이상의 온도에서 발생합니다. 이는 물 분자의 열에 의한 에너지 공급으로 인해 수분이 기체상태로 변화하기 때문입니다. 따라서, 제품 내부의 온도가 용융점 이하로 내려갈 경우, 수분은 고체상태를 유지합니다. 이러한 원리를 이용하여, 용융점 이하의 온도에서 건조를 수행하는 것을 공융점 건조라고 합니다."
  "\n\n공융점 건조는 다양한 산업에서 사용되는 건조기술 중 하나입니다. 예를 들어, 식품산업에서는 과일, 채소, 육류 등의 건조에 적용됩니다. 또한, 제약산업에서는 약품 및 바이오제품의 건조에도 사용됩니다."
  "\n\n공융점 건조를 위해서는, 용융점 이하의 온도를 유지하기 위한 전용 장비가 필요합니다. 대표적인 공융점 건조 장비로는, 동결건조기계가 있습니다."
  "\n\n동결건조의 원리는 기체와 고체 간의 상호작용인 서브리메이션(Sublimation)이라는 과정을 이용합니다. 제품을 동결하고 진공 상태로 만들면, 제품 내부의 물은 서브리메이션 과정을 거쳐 기체로 상태로 변환됩니다. 이 기체는 진공 상태에서 쉽게 제거될 수 있습니다. 이 과정은 아주 느리게 진행되며, 제품의 온도와 진공 상태가 중요한 요소입니다."
  "\n\n동결건조는 높은 품질의 건조 식품을 생산하기 위해 널리 사용되는 기술 중 하나입니다. 이 기술은 제품 내의 물을 얼려서 건조시키는 방법으로, 물의 증발로 인한 제품 내의 구조 변화를 최소화하여 제품의 품질을 유지할 수 있습니다. 동결건조의 핵심 기술 중 하나는 삼중점이며, 이는 동결점, 증기압점, 그리고 융점이 서로 교차하는 지점을 의미합니다. 삼중점과 동결건조의 원리에 대해 살펴보고자 합니다.";


  var infoText3_1 = "삼중점은 물질의 상태 변화를 나타내는 점 중 하나입니다. 삼중점은 세 가지 상태 변화의 경계가 교차하는 지점으로, 이 지점에서는 고체, 액체, 기체 상태가 모두 균형을 이룹니다. 삼중점은 대부분의 물질에 존재하며, 물의 경우 약 0.01℃, 0.006 bar의 압력에서 삼중점이 형성됩니다."
  "\n\n온도와 압력에 따라 물질의 고체, 액체, 기체의 상을 나타내는 그림을 상평형 그림이라고 합니다. 다음 그림과 같은 물의 상평형도에서 A는 증기압력 곡선, B는 융해 곡선, C는 승화 곡선이라고 하고 세 곡선이 만나는 점을 **삼중점입니다.** 물의 3중점은 0.01℃와 0.006 atm입니다.";
  var infoText3_2 = "동결건조는 제품 내부의 물을 얼려서 건조시키는 방법입니다. 먼저, 물을 얼리기 위해서는 물의 온도를 동결점보다 낮추어야 합니다. 이렇게 하면 물의 상태가 고체로 변하며, 이후 건조 과정에서 고체 물은 증발하게 됩니다. 물을 얼리는 과정에서는 냉동기 내부의 온도와 물의 증기압이 중요한 역할을 합니다. 냉동기 내부의 온도는 물의 얼어감에 영향을 미치는 요인 중 하나입니다. 냉동기 내부의 온도가 동결점보다 낮아야 물이 얼어갈 수 있습니다. 또한, 물의 증기압은 물이 고체로 변할 때와 액체로 변할 때 다릅니다. 따라서 냉동기 내부의 온도와 물의 증기압은 동결건조 과정에서 중요한 역할을 하는 또 다른 요소는 삼중점입니다. 삼중점에서는 고체, 액체, 기체 상태가 균형을 이루기 때문에, 증기압과 온도의 변화에 대해 민감합니다. 따라서, 동결건조 과정에서는 냉동기 내부의 온도와 압력을 적절하게 조절하여 삼중점 근처에서 제품을 건조시키는 것이 중요합니다."
  "\n\n또한, 동결건조 과정에서는 물의 결정화 형태도 중요합니다. 물의 결정화 형태는 물 분자들이 어떻게 배열되느냐에 따라서 제품의 품질에 영향을 미칩니다. 일반적으로, 빙결할 때는 물 분자들이 얼음의 결정구조를 형성합니다. 이러한 얼음의 결정구조는 제품 내부에서 고체상태의 물이 분포하는 방식과 관련이 있습니다."
  "\n\n동결건조는 높은 품질의 건조 식품을 생산하기 위한 중요한 기술입니다. 이러한 기술은 물의 증발로 인한 제품 내부의 구조 변화를 최소화하여 제품의 품질을 유지할 수 있습니다. 동결건조 과정에서는 냉동기 내부의 온도와 압력, 그리고 삼중점과 물의 결정화 형태 등이 중요한 역할을 합니다. 이러한 요소들을 적절하게 제어하여 높은 품질의 건조 식품을 생산할 수 있습니다. 따라서, 삼중점과 동결건조의 원리를 이해하고 이를 적용하여 실제 제조 과정에서 적절하게 활용하는 것이 중요합니다.";

  List<ShopArticle> shopItemList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
    shopItemList = await DatabaseM.getShopItemList();

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
        /*Positioned(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextT.Lit(text: "우리의 기술", color: Colors.white, bold: true, size: 20),
              SizedBox(height: 6 * 4,),
              TextT.Lit(text: "최첨단 기술 및 설비", color: Colors.white, size: 28),
            ],
          ),
        )*/
      ],
    );
    var itemWidget = Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 64,),
          TextT.Lit(text: "우리의 제품", color: Colors.black, bold: true, size: 38),
          SizedBox(height: 6 * 12,),
          TextT.Lit(text: "동결건조로 더욱 바삭한 먹태 모음", color: Colors.black, size: 26, bold: true),

          ListBoxT.Wraps(
            padding: EdgeInsets.all(6 * 8),
            spacing: 6 * 4,
            children: [
              for(var p in shopItemList)
                ButtonShopItem(shopItem: p,
                  onTap: () async {
                    await launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
                  },
                )
            ]
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
          itemWidget
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return mainBuild();
  }
}
