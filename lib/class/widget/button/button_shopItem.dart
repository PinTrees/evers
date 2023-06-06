import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/widget/youtube/meta_data_section.dart';
import 'package:evers/helper/interfaceUI.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../helper/style.dart';
import '../../database/article.dart';
import '../text.dart';

/// 이 위젯은 이미지 버튼을 생성하기 위한 위젯 클래스 입니다.
/// 이미지는 URL 로 제공되어야 합니다.




class ButtonImageStyle {
  final String imageUrl;
  final double? height;
  final double? width;
  final BoxFit? fit;
  final Alignment alignment;
  final double paddingAll;

  ButtonImageStyle({
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.height,
    this.paddingAll = 6,
    this.width,
  });
}




/// YouTube 동영상을 재생하는 컨테이너 위젯입니다.
class ButtonShopItem extends StatefulWidget {
  final ButtonImageStyle? style;
  final ShopArticle shopItem;
  Function? onTap;

  /// 생성자입니다.
  ///
  /// [style]: YouTube 동영상의 스타일을 설정하는 매개변수입니다.
  /// [params]: YouTube 동영상을 재생하기 위한 파라미터를 설정하는 매개변수입니다.
  ButtonShopItem({
    required this.shopItem, this.onTap,
    this.style, });

  @override
  _ButtonShopItemState createState() => _ButtonShopItemState();
}

/// YoutubeContainer 위젯의 상태관리 클래스 입니다.
class _ButtonShopItemState extends State<ButtonShopItem> {

  ShopArticle shopItem = ShopArticle.fromDatabase({});

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    shopItem = widget.shopItem;
    setState(() {});
  }

  Widget buildMain({required ButtonImageStyle style, }) {
    var w = InkWell(
      onTap: () async {
        var url = Uri.base.toString().split('home').first + 'shopItem/${shopItem.id}';
        await launchUrl( Uri.parse(url), webOnlyWindowName: true ? '_blank' : '_self',);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Material(
            elevation: 150,
            shadowColor: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.all(Radius.circular(0)),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(0)),
              child: Container(
                width: 250, height: 250,
                color: Colors.grey.withOpacity(0.3),
                padding: EdgeInsets.all(0.7),
                child:CachedNetworkImage(imageUrl: shopItem.thumbnail.first ?? "", fit: BoxFit.cover),
              ),
            ),
          ),
          Container(
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 6 * 2,),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () async {
                          if(shopItem.storeUrl == "") {
                            WidgetT.showSnackBar(context, text: "제품 스토어를 만드는 중이에요.");
                            return;
                          }
                          await launchUrl( Uri.parse(shopItem.storeUrl),   webOnlyWindowName: true ? '_blank' : '_self', );
                        },
                        style: StyleT.buttonStyleNone(
                          padding: 18,
                          color: Colors.grey.withOpacity(0.3)
                        ),
                        child: TextT.Lit(text: "제품 구매", size: 12, bold: true, color: Colors.black),
                      )
                    ),
                    Expanded(
                        child: TextButton(
                          onPressed: () async {
                            if(shopItem.naveStoreUrl == "") {
                              WidgetT.showSnackBar(context, text: "네이버 스토어를 만드는 중이에요.");
                              return;
                            }
                            await launchUrl( Uri.parse(shopItem.naveStoreUrl),   webOnlyWindowName: true ? '_blank' : '_self', );
                          },
                          style: StyleT.buttonStyleNone(
                              padding: 18,
                              color: Colors.green.withOpacity(0.5)
                          ),
                          child: TextT.Lit(text: "네이버 스토어", size: 12, bold: true, color: Colors.black),
                        )
                    ),
                  ],
                ),
                SizedBox(height: 6,),
                TextT.Lit(text: shopItem.name, size: 16, color: Colors.black, bold: true),
                SizedBox(height: 3 * 1,),
                TextT.Lit(text: StyleT.krwInt(shopItem.price) + "원", size: 18, color: Colors.red, bold: true),
              ],
            ),
          ),
          SizedBox(height: 6,),
        ],
      ),
    );

    return w;
  }

  @override
  Widget build(BuildContext context) {
    return buildMain(
      style: widget.style ?? ButtonImageStyle(imageUrl: ""),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
