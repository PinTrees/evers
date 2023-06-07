import 'dart:developer';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/youtube/meta_data_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../../../helper/style.dart';
import 'excel_grid.dart';




class TableStyle {
  final double? height;
  final double? width;
  ExcelGridStyle? cellStyle;
  EdgeInsets? padding;
  EdgeInsets? margin;

  TableStyle({
    this.height,
    this.width,
    this.cellStyle,
    this.padding,
    this.margin,
  });
}




class ExcelTable extends StatefulWidget {
  final TableStyle? style;
  Function? onTap;
  List<ExcelGridText>? children;
  Widget? spacing;

  ExcelTable({this.style, this.onTap,
    this.children,
    this.spacing,
  });

  @override
  _ExcelTableState createState() => _ExcelTableState();
}

class _ExcelTableState extends State<ExcelTable> {

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    setState(() {});
  }

  Widget buildMain({required TableStyle style,}) {
    var w = Container(
      padding: style.margin,
      child: InkWell(
        onTap: () {
          if(widget.onTap != null) widget.onTap!();
        },
        child: Container(
            padding: style.padding,
            decoration: StyleT.inkStyleNone(
              color: Colors.grey.withOpacity(0.15),
              round: 8,
            ),
            height: style.height, width: style.width,
            child: ListBoxT.Rows(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              spacingWidget: widget.spacing,
              children: widget.children,
            )
        ),
      ),
    );

    return w;
  }

  @override
  Widget build(BuildContext context) {
    return buildMain(style: widget.style ?? TableStyle(),);
  }

  @override
  void dispose() {
    super.dispose();
  }
}


