import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/database/article.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
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

class WindowPageACreate extends WindowBaseMDI {
  Function refresh;
  String path;

  WindowPageACreate({ required this.path, required this.refresh, }) { }

  @override
  _WindowArticleCreateState createState() => _WindowArticleCreateState();
}

class _WindowArticleCreateState extends State<WindowPageACreate> {
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
    article = await DatabaseM.getPageArticle(widget.path);
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
          QuillToolbar.basic(controller: _controller,
            embedButtons: FlutterQuillEmbeds.buttons(
              showImageButton: true,
              onImagePickCallback: _onImagePickCallback,
              webImagePickImpl: _webImagePickImpl,
            ),
          ),
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
          /// action
          buildAction(),
        ],
      ),
    );
  }


  Widget buildAction() {
    var saveAction = ButtonT.Action(context, "페이지 수정",
      icon: Icons.edit,
      altText: "페이지 정보를 수정하시겠습니까? 수정후 즉시 게시됩니다.",
      onTap: () async {
        var json = jsonEncode(_controller.document.toDelta().toJson());
        await article.update(code: widget.path, json: json);
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
