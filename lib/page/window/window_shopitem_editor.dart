import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/database/article.dart';
import 'package:evers/class/widget/button/button_image_web.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/class/widget/textinput_lit.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/json.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/embeds/embed_types.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;

import '../../class/Customer.dart';
import '../../class/system.dart';
import '../../class/transaction.dart';
import '../../class/widget/button.dart';
import '../../class/widget/list.dart';
import '../../class/widget/text.dart';
import '../../core/quill/universal_ui.dart';
import '../../core/window/ResizableWindow.dart';
import '../../core/window/window_base.dart';
import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';

class WindowShopItemEditor extends WindowBaseMDI {
  Function refresh;
  ShopArticle shopItem;

  WindowShopItemEditor({ required this.shopItem, required this.refresh, }) { }

  @override
  _WindowShopItemEditorState createState() => _WindowShopItemEditorState();
}

class _WindowShopItemEditorState extends State<WindowShopItemEditor> {
  QuillController _controller = QuillController.basic();
  ShopArticle shopItem = ShopArticle.fromDatabase({});
  int selectThumbIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
    shopItem = ShopArticle.fromDatabase(JsonManager.toJsonObject(widget.shopItem));

    _controller = QuillController(
      document: Document.fromJson(jsonDecode(shopItem.json)),
      selection: TextSelection.collapsed(offset: 0),
    );

    setState(() {});
  }

  Widget main = SizedBox();

  Widget mainBuild() {
    var toolbar = QuillToolbar.basic(controller: _controller,
      showAlignmentButtons: false,
      showBoldButton: false,
      showCenterAlignment: false,
      showBackgroundColorButton: false,
      showClearFormat: false,
      showCodeBlock: false,
      showColorButton: false,
      showDirection: false,
      showDividers: false,
      showFontFamily: false,
      showFontSize: false,
      showHeaderStyle: false,
      showIndent: false,
      showInlineCode: false,
      showItalicButton: false,
      showJustifyAlignment: false,
      showLeftAlignment: false,
      showLink: false,
      showListBullets: false,
      showListCheck: false,
      showListNumbers: false,
      showQuote: false,
      showRightAlignment: false,
      showSearchButton: false,
      showSmallButton: false,
      showStrikeThrough: false,
      showUnderLineButton: false,
      embedButtons: FlutterQuillEmbeds.buttons(
        showImageButton: true,
        showCameraButton: false,
        showFormulaButton: false,
        onImagePickCallback: _onImagePickCallback,
        webImagePickImpl: _webImagePickImpl,
      ),
    );

    var thumb = "";
    if(shopItem.thumbnail.length > selectThumbIndex) {
      thumb = shopItem.thumbnail[selectThumbIndex];
    }

    return main = Container(
      width: 1280,
      child: Column(
        children: [
          ListBoxT.Rows(
            padding: EdgeInsets.all(6 * 2),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 150, height: 150, color: Colors.grey.withOpacity(0.15),
                child: CachedNetworkImage(imageUrl: thumb, fit: BoxFit.cover,),
              ),
              SizedBox(width: 6 * 2,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LitTextInput(style: LitTextFieldStyle(),
                      params: LitTextParams(
                        expand: true,
                        label: "제품이름",
                        onEdited: (data) {
                          shopItem.name = data;
                          setState(() {});
                        },
                        text: shopItem.name,
                      ),
                    ),
                    SizedBox(height: 6,),
                    LitTextInput(style: LitTextFieldStyle(
                    ),
                      params: LitTextParams(
                        label: "제품설명",
                        expand: true,
                        isMultiLine: true,
                        onEdited: (data) {
                          shopItem.desc = data;
                          setState(() {});
                        },
                        text: shopItem.desc,
                      ),
                    ),
                    SizedBox(height: 6,),
                    ListBoxT.Rows(
                        spacing: 6 * 2,
                        children: [
                          LitTextInput(style: LitTextFieldStyle(),
                            params: LitTextParams(
                              label: "제품가격",
                              width: 100,
                              onEdited: (data) {
                                shopItem.price = int.tryParse(data) ?? 0;
                                setState(() {});
                              },
                              text: StyleT.krwInt(shopItem.price),
                              value: shopItem.price.toString(),
                            ),
                          ),
                          LitTextInput(style: LitTextFieldStyle(),
                            params: LitTextParams(
                              label: "제품 분류",
                              width: 100,
                              onEdited: (data) {
                                shopItem.group = data;
                                setState(() {});
                              },
                              text: shopItem.group,
                            ),
                          ),
                          LitTextInput(style: LitTextFieldStyle(),
                            params: LitTextParams(
                              label: "최대구매수량",
                              width: 100,
                              onEdited: (data) {
                                shopItem.maxBuyCount = int.tryParse(data) ?? 0;
                                setState(() {});
                              },
                              text: StyleT.krwInt(shopItem.maxBuyCount),
                              value: shopItem.maxBuyCount.toString(),
                            ),
                          ),
                        ]
                    ),
                    SizedBox(height: 6,),
                    ListBoxT.Rows(
                        spacing: 6,
                        children: [
                          LitTextInput(style: LitTextFieldStyle(),
                            params: LitTextParams(
                              label: "상품스토어 URL",
                              width: 300,
                              onEdited: (data) {
                                shopItem.storeUrl = data;
                                setState(() {});
                              },
                              text: shopItem.storeUrl,
                            ),
                          ),
                          LitTextInput(style: LitTextFieldStyle(),
                            params: LitTextParams(
                              label: "Naver 스토어 URL",
                              width: 300,
                              onEdited: (data) {
                                shopItem.naveStoreUrl = data;
                                setState(() {});
                              },
                              text: shopItem.naveStoreUrl,
                            ),
                          ),
                        ]
                    ),
                    SizedBox(height: 6,),
                    ListBoxT.Rows(
                        spacing: 6,
                        children: [
                          ButtonT.IconText(
                              icon: Icons.add_box, text: "썸네일 이미지 추가",
                              onTap: () async {
                                var thumbUrl = await thumbImagePickImpl();
                                if(thumbUrl != null) {
                                  shopItem.thumbnail.add(thumbUrl);
                                  setState(() {});
                                }
                              }
                          ),
                          for(int i = 0; i < shopItem.thumbnail.length; i++)
                            ButtonImage(
                              style: ButtonImageStyle(imageUrl: shopItem.thumbnail[i], height: 48, width: 48, paddingAll: 0),
                              params: ButtonTParams(
                                  onTap: () {
                                    selectThumbIndex = i;
                                    setState(() {});
                                  }
                              ),
                            ),
                        ]
                    ),
                  ],
                ),
              ),
            ],
          ),
          toolbar,
          WidgetT.dividHorizontal(size: 0.7),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(6 * 2),
              child: QuillEditor.basic(
                controller: _controller,
                readOnly: false,
                embedBuilders: defaultEmbedBuildersWeb,
              ),
            ),
          ),
          WidgetT.dividHorizontal(size: 0.7),
          Container(
            padding: EdgeInsets.all(6),
            child: Row(
              children: [
                TextT.Lit(text: "작성자", size: 12, bold: true, color: Colors.black, width: 100),
                LitInput(style: LitInputStyle(
                  padding: EdgeInsets.all(6)
                ),
                  width: 250,
                  onEdited: (value) {
                    shopItem.writer = value;
                    setState(() {});
                  },
                  text: shopItem.writer,
                ),
              ],
            ),
          ),
          /// action
          buildAction(),
        ],
      ),
    );
  }


  Widget buildAction() {
    var saveAction = ButtonT.Action(context, "제품 저장",
      icon: Icons.save,
      altText: "제품을 저장하시겠습니까?",
      init: () {
        if(shopItem.name == "") return Messege.toReturn(context, "이름은 비워둘 수 없습니다.", false);
        if(shopItem.name.length < 6) return Messege.toReturn(context, "제목은 더 상세히 작성해야 합니다.", false);
        if(shopItem.price < 1) return Messege.toReturn(context, "가격은 0일 수 없습니다.", false);
        if(shopItem.maxBuyCount < 1) return Messege.toReturn(context, "최대구매가능 수량은 0일 수 없습니다.", false);
        if(shopItem.writer == "") return Messege.toReturn(context, "작성자는 비워둘 수 없습니다.", false);
        if(shopItem.thumbnail.isEmpty) return Messege.toReturn(context, "썸네일을 1개 이상 추가하세요.", false);
        return true;
      },
      onTap: () async {
        var json = jsonEncode(_controller.document.toDelta().toJson());
        await shopItem.update(json: json);
        await widget.refresh();

        widget.parent.onCloseButtonClicked!();
      }
    );

    return Column(
      children: [
        Row(children: [ saveAction ],)
      ],
    );
  }




  Future<String?> thumbImagePickImpl() async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return null;
    if (result.files.first.bytes == null) return null;

    if(result.files.first.name.contains(".pdf") ||
        result.files.first.name.contains(".ai") ||
        result.files.first.name.contains(".svg")
    ) {
      Messege.show(context, "지원하지 않는 이미지 형식입니다. png, 또는 jpg로 변경후 시도하세요.");
      return null;
    }

    if(!result.files.first.name.contains(".png") && !result.files.first.name.contains(".jpg")
    ) {
      Messege.show(context, "지원하지 않는 이미지 형식입니다. png, 또는 jpg로 변경후 시도하세요.");
      return null;
    }

    var key = await SystemT.generateRandomString(16);
    var url = await StorageHub.updateFile("contents/shopItem/image", "HOMEPAGE-IMG", result.files.first.bytes!, "$key.img");
    return url;
  }






  Future<String> _onImagePickCallback(File file) async {return "url";}
  Future<String?> _webImagePickImpl(OnImagePickCallback onImagePickCallback) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) return null;
    if (result.files.first.bytes == null) return null;

    if(result.files.first.name.contains(".pdf") ||
        result.files.first.name.contains(".ai") ||
        result.files.first.name.contains(".svg")
    ) {
      Messege.show(context, "지원하지 않는 이미지 형식입니다. png, 또는 jpg로 변경후 시도하세요.");
      return null;
    }

    if(!result.files.first.name.contains(".png") && !result.files.first.name.contains(".jpg")
    ) {
      Messege.show(context, "지원하지 않는 이미지 형식입니다. png, 또는 jpg로 변경후 시도하세요.");
      return null;
    }


    var key = await SystemT.generateRandomString(16);
    var url = await StorageHub.updateFile("contents/shopItem/image", "SHOP_ITEM-IMG", result.files.first.bytes!, "$key.img");
    return url;
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}
