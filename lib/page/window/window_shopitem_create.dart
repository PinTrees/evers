import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/database/article.dart';
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
import '../../class/widget/text.dart';
import '../../core/quill/universal_ui.dart';
import '../../core/window/ResizableWindow.dart';
import '../../core/window/window_base.dart';
import '../../helper/dialog.dart';
import '../../helper/interfaceUI.dart';

class WindowShopItemCreate extends WindowBaseMDI {
  Function refresh;
  Article? article;
  String board;

  WindowShopItemCreate({ this.article, required this.board, required this.refresh, }) { }

  @override
  _WindowShopItemCreateState createState() => _WindowShopItemCreateState();
}

class _WindowShopItemCreateState extends State<WindowShopItemCreate> {
  var dividHeight = 6.0;

  QuillController _controller = QuillController.basic();
  Article article = Article.fromDatabase({});

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  void initAsync() async {
    if(widget.article != null)
      article = Article.fromDatabase(JsonManager.toJsonObject(widget.article));
    else article.board = widget.board;

    _controller = QuillController(
      document: Document.fromJson(jsonDecode(article.json)),
      selection: TextSelection.collapsed(offset: 0),
    );

    setState(() {});
  }

  Widget main = SizedBox();

  Widget mainBuild() {
    return main = Container(
      width: 1280,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LitInput(style: LitInputStyle(
            textSize: 24,
            hintFontSize: 24,
            hint: "제목을 입력하세요.",
            margin: EdgeInsets.all(6),
            padding: EdgeInsets.all(6)
          ),
            onEdited: (value) {
              article.title = value;
              setState(() {});
            },
            text: article.title,
          ),
          QuillToolbar.basic(controller: _controller,
            embedButtons: FlutterQuillEmbeds.buttons(
              showImageButton: true,
              onImagePickCallback: _onImagePickCallback,
              webImagePickImpl: _webImagePickImpl,
            ),
          ),
          WidgetT.dividHorizontal(size: 0.7),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(18),
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
                    article.writer = value;
                    setState(() {});
                  },
                  text: article.writer,
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
    var saveAction = ButtonT.Action(context, "작성글 저장",
      icon: Icons.edit,
      altText: "작성한 글을 저장하시겠습니까?",
      init: () {
        if(article.title == "") return Messege.toReturn(context, "제목은 비워둘 수 없습니다.", false);
        if(article.title.length < 6) return Messege.toReturn(context, "제목은 더 상세히 작성해야 합니다.", false);
        if(article.writer == "") return Messege.toReturn(context, "작성자는 비워둘 수 없습니다.", false);
        return true;
      },
      onTap: () async {
        var json = jsonEncode(_controller.document.toDelta().toJson());
        article.desc = _controller.document.getPlainText(0, 64);
        await article.update(json: json);
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




  // Renders the image picked by imagePicker from local file storage
  // You can also upload the picked image to any server (eg : AWS s3
  // or Firebase) and then return the uploaded image URL.
  Future<String> _onImagePickCallback(File file) async {
    /// 랜덤문자열을 반환합니다.
    /// 추후 맵에 키로 저장된 문자열과 파일을 경로에 저장후 해당 문자열 위치를 모두 경로로 변환하는 작업이 추가되어야 합니다.

    print(file.path);

    var key = await SystemT.generateRandomString(16);
    var url = await StorageHub.updateFile("homepage/image", "HOMEPAGE-IMG", file.readAsBytesSync(), "$key.png");
    print(url);
    return url;
  }
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
    var url = await StorageHub.updateFile("homepage/image", "HOMEPAGE-IMG",
        result.files.first.bytes!, "$key.img");
    print(url);
    return url;
  }



  @override
  Widget build(BuildContext context) {
    return Material(child: mainBuild());
  }
}
