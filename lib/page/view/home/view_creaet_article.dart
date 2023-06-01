import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evers/class/component/comp_contract.dart';
import 'package:evers/class/component/comp_process.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/excel.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/textInput.dart';
import 'package:evers/core/window/window_base.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/interfaceUI.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_ts.dart';
import 'package:evers/ui/dialog_item.dart';
import 'package:evers/ui/ex.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:get/get.dart';

import 'package:http/http.dart' as http;
import 'package:quill_html_editor/quill_html_editor.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:flutter_quill/flutter_quill.dart' hide Text;
import '../../../class/database/article.dart';
import '../../../class/system.dart';
import '../../../info/menu.dart';
import '../../../ui/dl.dart';



class ViewCreateArticle extends StatefulWidget {
  ViewCreateArticle() { }

  @override
  _ViewCreateArticleState createState() => _ViewCreateArticleState();
}


class _ViewCreateArticleState extends State<ViewCreateArticle> {
  var dividHeight = 6.0;

  Article article = Article.fromDatabase({});
  final FocusNode focusNode = FocusNode();
  /// 게시물을 생성할 때 사용됩니다.
  Map<String, File> uploadImage = {};
  QuillController? _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = QuillController.basic();
    initAsync();
  }

  void initAsync() async {
    uploadImage.clear();
    setState(() {});
  }





  /// 이 함수는 매인 위젯 빌더입니다.
  Widget mainBuild() {
    QuillEditorController controller = QuillEditorController();
    controller.enableEditor(false);
    var titleInputWidget = InputWidget.LitText(context, "ascdasdcasdc",
      color: Colors.white, textSize: 36, width: 1280, height: 68, expand: true, bold: true, textColor: Colors.black,
      setState: () { setState(() {}); },
      onEdited: (i, data) {
        article.title = data;
      },
      hint: "제목을 입력하세요",
      text: article.title,
    );

    Widget articleViewer = ListView(
      children: [
        titleInputWidget,
        WidgetT.dividHorizontal(size: 2, color: Colors.grey.withOpacity(0.3)),
        QuillToolbar.basic(
          controller: _controller!,
          embedButtons: FlutterQuillEmbeds.buttons(
            showImageButton: true,
            onImagePickCallback: _onImagePickCallback,
            webImagePickImpl: _webImagePickImpl,
          ),
        ),
        Expanded(
          child: QuillEditor.basic(
            controller: _controller!, readOnly: false,
            embedBuilders: FlutterQuillEmbeds.builders(),
          ),
        ),
      ],
    );

    return articleViewer;
  }








  Widget buildMainMenuMobile() {
    var homeWidget = InkWell(
        onTap: () {},
        child: Container(height: 38, child: Image(image: AssetImage('assets/icon_hor.png') ),));


    return Column(
      children: [
        Container(
          color: Colors.white,
          height: 68, width: double.maxFinite,
          padding: EdgeInsets.all(6),
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ButtonT.LitIcon(
                  Icons.arrow_back, size: 28,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {});
                  }
              ),
              Expanded(child: SizedBox()),
              homeWidget,
              Expanded(child: SizedBox()),
              ButtonT.Icont(
                  icon: Icons.search,
                  onTap: () {

                  }
              ),
            ],
          ),
        ),
        Container(color: Colors.white, child: WidgetT.dividHorizontal(size: 2, color: Colors.grey.withOpacity(0.3)),)
      ],
    );
  }

  Widget buildBottomBar() {
    return Container(
      child: Stack(
        children: [
          Container(
            height: 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      setState(() {});
                    },
                    style: StyleT.buttonStyleNone(elevation: 0, color: Colors.transparent,),
                    child: Container(height: 36, child: Image(image: AssetImage('assets/icon_hor.png') ),)),
                SizedBox(width: 6 * 4,),
                TextT.Lit(text: "Copyright © 에버스. All Rights Reserved.", size: 16, bold: false, color: StyleT.textColor.withOpacity(0.5)),
              ],
            ),
          )
        ],
      ),
    );
  }








  // Renders the image picked by imagePicker from local file storage
  // You can also upload the picked image to any server (eg : AWS s3
  // or Firebase) and then return the uploaded image URL.
  Future<String> _onImagePickCallback(File file) async {
    // Copies the picked file from temporary cache to applications directory
    /*final appDocDir = await getApplicationDocumentsDirectory();
    final copiedFile = await file.copy('${appDocDir.path}/${file.path.split('/').last}');
*/
    var key = await SystemT.generateRandomString(16);
    uploadImage[key] = file;

    /// 랜덤문자열을 반환합니다.
    /// 추후 맵에 키로 저장된 문자열과 파일을 경로에 저장후 해당 문자열 위치를 모두 경로로 변환하는 작업이 추가되어야 합니다.
    return file.path;
  }
  Future<String?> _webImagePickImpl(OnImagePickCallback onImagePickCallback) async {
    final result = await FilePicker.platform.pickFiles();
    if (result == null) {
      return null;
    }

    // Take first, because we don't allow picking multiple files.
    final fileName = result.files.first.name;
    final file = File(fileName);

    return onImagePickCallback(file);
  }






  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: Column(
        children: [
          buildMainMenuMobile(),
          Expanded(child: mainBuild()),
          Container(
            height: 48,
            child: ButtonT.Action(context, "저장",
                icon: Icons.save,
                //altText: "새 글을 등록하시겠습니까?",
                onTap: () async {

                  var json = jsonEncode(_controller!.document.toDelta().toJson());
                  print(json);
                  return;

                  /*String? htmlText = await controller.getText();
                          if(htmlText == null) return Messege.toReturn(context, "내용은 비워둘 수 없습니다.", false);

                          article.version = "flutter_quill:6.1.0";
                          article.desc = await controller.getPlainText();
                          article.createAt = DateTime.now().microsecondsSinceEpoch;
                          article.type = "news";
                          await article.update(data: htmlText);

                          print(htmlText);
                          Navigator.pop(context);*/
                }
            ),
          ),
        ],
      ),
    );
  }
}

