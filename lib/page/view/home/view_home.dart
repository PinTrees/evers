import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/database/article.dart';
import 'package:evers/class/widget/article/article.dart';
import 'package:evers/class/widget/button/button_shopItem.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/class/widget/video/video_url.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/view/home/view_meogkkun.dart';
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
import 'package:video_player/video_player.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
//import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../class/widget/youtube.dart';
import '../../../helper/interfaceUI.dart';



class ViewHome extends StatefulWidget {
  ViewHome() { }

  @override
  _ViewHomeState createState() => _ViewHomeState();
}


class _ViewHomeState extends State<ViewHome> {
  var thumbnailImageHeight = 300.0;
  var dividHeight = 6.0;
  String url =  "https://firebasestorage.googleapis.com/v0/b/evers-925f6.appspot.com/o/tmp%2Fevers_info.mp4?alt=media&token=4d14e438-6773-4233-964c-e62901d51adb";
  String youtubeUrl =  "https://www.youtube.com/watch?time_continue=1&v=wGa_89i_nuU";

  late VideoPlayerController v_controller = VideoPlayerController.network(url,);
  Widget playerWidget = SizedBox();


  /// 새소식 작성글 목록입니다.
  List<Article> articleList = [];
  /// 판매되는 상품의 목록입니다.
  List<ShopArticle> shopItemList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("init ViewHome");

    _initVideoPlayer(context);
    initAsync();
  }


  /// 비동기 초기화자 입니다. 추후 인터페이스로 재구현 되어야 합니다.
  dynamic initAsync() async {
    shopItemList = await DatabaseM.getShopItemList();
    articleList = await DatabaseM.getArticleWithCode("8HGb2ghAvOJcjuEd");
    setState(() {});
  }


  void _initVideoPlayer(context) async {
    v_controller = VideoPlayerController.network(url);
    print("video initialize");

    /// Initialize the video player
    await v_controller.initialize();
    print("video is loaded");

    v_controller.setVolume(0);
    v_controller.play();

    playerWidget = Container(
      padding: EdgeInsets.all(0),
      child: AspectRatio( aspectRatio: 16 / 9,
        child: VideoPlayer(v_controller!,

        ),
      ),
    );
    print("video widget build");
    setState(() {});
  }


  Widget buildMain() {
    print("buildMain");

    var platformPadding = MediaQuery.of(context).size.width * 0.07;
    var padding = MediaQuery.of(context).size.width * 0.2;
    var thumbnailImageHeight = this.thumbnailImageHeight + padding;

    var titleWidget = SizedBox(
      height: thumbnailImageHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: thumbnailImageHeight,
            width: double.maxFinite,
            child: ColorFiltered(
                colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.0), BlendMode.multiply,),
                child: ClipRRect(child: CachedNetworkImage(imageUrl:'https://raw.githubusercontent.com/PinTrees/evers/main/sever/DSC03001.JPG.jpg', fit: BoxFit.cover))
            ),
          ),
          Positioned(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                WidgetT.titleT('나는 먹꾼!', size: 80, bold: true, color: Colors.white),
                SizedBox(height: 24,),
                TextButton(
                  onPressed: () {
                    launchUrl(Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
                  },
                    style: TextButton.styleFrom(elevation: 12, backgroundColor: Colors.white.withOpacity(0.5)),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(80, 18, 80, 18),
                      child: TextT.Lit(text: "제품 구매", color: Colors.white, size: 18),
                    )
                ),
              ],
            ),
          ),
        ],
      ),
    );


    /// 새소식 글 위젯 목록입니다.
    List<Widget> articleWidgetList = [];
    var index = 0;
    articleList.forEach((e) {
      if(index++ > 3) return;
      articleWidgetList.add(ArticleWidget(style: ArticleStyle(width: 200, expand: true), params: ArticleParams(article: e)));
    });


    var articleWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(padding: EdgeInsets.fromLTRB(18, 0, 18, 0), child: TextT.Lit(text: "새소식", color: Colors.black, bold: true, size: 24)),
        ListBoxT.Rows(padding: EdgeInsets.all(18), spacing: 18, children: articleWidgetList),
      ],
    );



    var itemTitleWidget = Container(
      padding: EdgeInsets.fromLTRB(18, 0, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextT.Lit(text: "우리의 제품", color: Colors.black, bold: true, size: 24),
          SizedBox(height: 18,),
          TextT.Lit(text: "동결건조로 더욱 바삭한 먹태 모음", color: Colors.black, size: 18, bold: true),
        ],
      ),
    );



    var itemWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        itemTitleWidget,
        SizedBox(height: 18,),
        ListBoxT.Wraps(
          spacing: 6 * 4,
          padding: EdgeInsets.fromLTRB(platformPadding, platformPadding, platformPadding, platformPadding),
          children: [
            for(var p in shopItemList)
              ButtonShopItem(shopItem: p,
                onTap: () async {
                  await launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
                },
              ),
          ],
        ),
      ],
    );



    var infoVideo = Column(
      children: [
      /*  TextT.Lit(text: "에버스 소개", color: Colors.black, size: 24, bold: true),
        SizedBox(height: 6 * 4,),
        VideoContainer(style: VideoStyle(aspectRatio: 16 / 9),
        params: VideoParams(url: "https://github.com/PinTrees/evers/raw/main/sever/2023_05_27%2019_32.mp4"),),
      */  //YoutubeContainer(style: YoutubeStyle(padding: EdgeInsets.all(padding * 0.7)), params: YoutubeParams(url: youtubeUrl),),
      ],
    );



    return Container(
      child: ListBoxT.Columns(
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 6 * 10,
        children: [
          titleWidget,
          articleWidget,
          itemWidget,
          infoVideo,
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return buildMain();
  }
}
