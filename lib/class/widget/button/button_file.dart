import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/youtube/meta_data_section.dart';
import 'package:evers/helper/pdfx.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../helper/style.dart';



Map<String, Color> fileColor = {
  "jpg": Colors.green.withOpacity(0.5),
  "png": Colors.blueAccent.withOpacity(0.5),
  "pdf": Colors.redAccent.withOpacity(0.5),
  "txt": Colors.grey.withOpacity(0.5),
  "log": Colors.grey.withOpacity(0.5),
};

class ButtonFile extends StatefulWidget {
  String fileName;
  String? fileUrl;

  Function onDelete;

  ButtonFile({ required this.fileName,
    this.fileUrl,
    required this.onDelete,
  });

  @override
  _ButtonFileState createState() => _ButtonFileState();
}

class _ButtonFileState extends State<ButtonFile> {
  @override
  void initState() {
    super.initState();

    initAsync();
  }

  Future<void> initAsync() async {
    setState(() {});
  }

  Widget buildMain() {
    Widget w = InkWell(
      onTap: () {
        if(widget.fileUrl != null) {
          PdfManager.OpenPdf(widget.fileUrl, widget.fileName);
        }
        else {
          Messege.show(context, "파일이 첨부되었습니다.");
        }
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 28,
            decoration: StyleT.inkStyleNone(round: 4, color: Colors.grey.withOpacity(0.3)),
            child: Row(
                children: [
                  SizedBox(width: 6,),
                  if(widget.fileUrl != null) Icon(Icons.cloud_done, size: 16, color: StyleT.textColor,),
                  if(widget.fileUrl != null) const SizedBox(width: 6,),

                  buildFileTage(),
                  SizedBox(width: 6,),
                  TextT.Lit(text: getFileName(), size: 12, color: StyleT.titleColor),
                  SizedBox(width: 6,),
                  InkWell(
                    onTap: () {
                      widget.onDelete();
                    },
                    child: Container(
                      height: 28, width: 28,
                      child: Icon(Icons.delete, size: 16, color: StyleT.textColor,),
                    ),
                  )
                ]
            ),
          ),
        ],
      ),
    );

    return w;
  }

  String getFileName() {
    return widget.fileName.split(".").first;
  }

  Widget buildFileTage() {
    var tag = widget.fileName.split('.').last;
    var color = fileColor[tag] ?? Colors.grey.withOpacity(0.5);

    return Container(
      padding: EdgeInsets.all(3),
      decoration: StyleT.inkStyleNone(color: color, round: 2),
      child: TextT.Lit(text: tag.toUpperCase(), color: Colors.black, bold: false, size: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildMain();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
