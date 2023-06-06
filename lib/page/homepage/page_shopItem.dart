import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/widget/button/button_image_web.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/class/widget/youtube.dart';
import 'package:evers/core/context_data.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/interfaceUI.dart';
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


class PageShopItem extends StatefulWidget {
  String id;
  PageShopItem({ required this.id, }) { }

  @override
  _PageShopItemState createState() => _PageShopItemState();
}

class _PageShopItemState extends State<PageShopItem> {
  QuillController _controller = QuillController.basic();
  ShopArticle shopItem = ShopArticle.fromDatabase({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }
  void initAsync() async {
    shopItem = await DatabaseM.getShopItemDoc(widget.id) ?? ShopArticle.fromDatabase({});
    _controller = QuillController(
      document: Document.fromJson(jsonDecode(shopItem.json)),
      selection: TextSelection.collapsed(offset: 0),
    );

    setState(() {});
  }

  /// 이 함수는 매인 위젯 빌더입니다.
  Widget mainBuild() {

    var viewWidget = Container(
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
        SizedBox(height: 6 * 8,),
        viewWidget,
        SizedBox(height: 6 * 8,),
      ],
    );
  }




  Widget buildThumb() {
    if(shopItem == null) return const SizedBox();

    var thumb = Column(
      children: [
        Container(
          height: 500,
          width: 500,
          padding: EdgeInsets.all(1),
          color: Colors.grey.withOpacity(0.5),
          child: CachedNetworkImage(imageUrl: shopItem.thumbnail.first ?? "", fit: BoxFit.cover,),
        ),
        SizedBox(height: 6,),
        ListBoxT.Rows(
            spacing: 6,
            children: [
              for(var t in shopItem.thumbnail)
                InkWell(
                  onTap: () {

                  },
                  child: Container(
                    height: 48,
                    width: 48,
                    padding: EdgeInsets.all(1),
                    color: Colors.grey.withOpacity(0.5),
                    child: CachedNetworkImage(imageUrl: t, fit: BoxFit.cover,),
                  ),
                ),
            ]
        ),
      ],
    );

    var buyWidget = Container(
      width: 500,
      child: ListBoxT.Columns(
        children: [
          TextT.Lit(text: shopItem.name, size: 24, color: Colors.black),
          TextT.Lit(text: StyleT.krwInt(shopItem.price) + "원", size: 20, color: Colors.black),
          SizedBox(height: 6,),
          WidgetT.dividHorizontal(size: 0.7, color: Colors.grey.withOpacity(0.5)),
          SizedBox(height: 6,),
          ListBoxT.Rows(
            spacing: 6 * 2,
              children: [
                TextButton(
                    onPressed: () async {
                      if(shopItem.storeUrl == "") {
                        WidgetT.showSnackBar(context, text: "제품 스토어를 만드는 중이에요.");
                        return;
                      }
                      await launchUrl( Uri.parse(shopItem.storeUrl),   webOnlyWindowName: true ? '_blank' : '_self', );
                    },
                    style: StyleT.buttonStyleNone(color: Colors.black, padding: 18),
                    child: Container(
                      child: TextT.Lit(text: "제품 구매하기", size: 18, color: Colors.white.withOpacity(0.7)),
                    )
                ),
                TextButton(
                    onPressed: () async {
                      if(shopItem.naveStoreUrl == "") {
                        WidgetT.showSnackBar(context, text: "제품 스토어를 만드는 중이에요.");
                        return;
                      }
                      await launchUrl( Uri.parse(shopItem.naveStoreUrl),   webOnlyWindowName: true ? '_blank' : '_self', );
                    },
                    style: StyleT.buttonStyleNone(color: Colors.green.withOpacity(0.7), padding: 18),
                    child: Container(
                      child: TextT.Lit(text: "네이버 스토어", size: 18, color: Colors.black.withOpacity(0.7)),
                    )
                )
              ]
          ),
        ],
      ),
    );

    if(!ContextData.isMobile) {
      return Container(
        width: ContextData.getPlatformSize(context),
        child: ListBoxT.Rows(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              thumb,
              SizedBox(width: 6 * 4,),
              buyWidget
            ]
        ),
      );
    }
    else {
      return ListBoxT.Columns(
          children: [
            thumb,
            SizedBox(height: 6 * 4,),
            buyWidget
          ]
      );
    }
  }
  Widget buildTitleBar() {
    return Container(
      height: 48,
      color: Colors.white,
      child: Row(
        children: [

        ],
      ),
    );
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              pinned: false,
              floating: true,
              leading: SizedBox(),
              backgroundColor: Colors.white,
              elevation: 0,

              centerTitle: true,
              title: ButtonImage(style: ButtonImageStyle(height: 32, imageUrl: "https://raw.githubusercontent.com/PinTrees/evers/main/sever/icon_hor_1.jpg"),
                params: ButtonTParams(),),

              flexibleSpace: Column(
                children: [
                  SizedBox(height: 55.3,),
                  Container(
                    height: 0.7,
                    color: Colors.grey.withOpacity(0.5),
                  ),
                ],
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  Container(
                    padding: EdgeInsets.all(18),
                    child: Column(
                      children: [
                        TextT.Lit(text: "제품 상세 페이지", size: 24, color: Colors.black),
                        SizedBox(height: 6 * 4,),
                        buildThumb(),
                        mainBuild(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        )
    );
  }
}
