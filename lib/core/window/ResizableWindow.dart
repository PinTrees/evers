import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/style.dart';
import 'package:flutter/material.dart';


import '../../helper/interfaceUI.dart';


class ResizableWindow extends StatefulWidget {

  double startHeight = 1280, startWidth = 720;
  double currentHeight = 1280, currentWidth = 720;
  /// 창 최소 사이즈
  double defaultHeight = 250, defaultWidth = 250;
  double x;
  double y;

  bool fixedHeight=false;

  String title;
  Function()? onClicked;
  Function(double, double)? onWindowDragged;
  VoidCallback? onCloseButtonClicked;

  Widget? widget;

  ResizableWindow({
    required this.startHeight,
    required this.startWidth,
    required this.x, required this.y,
    required this.title,
  }) : super(key: UniqueKey()) {
  }

  @override
  _ResizableWindowState createState() => _ResizableWindowState();
}

class _ResizableWindowState extends State<ResizableWindow> {

  /// 창 크기변경 마우스 입력갭
  var resizeableGap = 8.0;
  /// 창 헤더 사이즈
  var _headerSize = 28.0;
  /// 창 테두리 라운드 가중치
  var _borderRadius = 8.0;
  var _strok = 0.7;
  var _strokColor = Colors.grey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.currentWidth = widget.startWidth;
    widget.currentHeight = widget.startHeight;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: () {
          widget.onClicked!();
        },
        child: Container(
          width: widget.currentWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
            boxShadow: [
              BoxShadow(
                color: Color(0x54000000),
                spreadRadius: 4,
                blurRadius: 24,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(_borderRadius)),
            child: Container(
              color: _strokColor,
              padding: EdgeInsets.all(_strok),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(_borderRadius - _strok)),
                child: Container(
                  color: Colors.white,
                  child: Stack(
                    children: [
                      Column(
                        children: [_getHeader(), _getBody()],
                      ),
                      /// 우측 화면 조절 제스쳐
                      Positioned(
                          right: 0,   top: 0,  bottom: 0,
                          child: GestureDetector(
                            onHorizontalDragUpdate: _onHorizontalDragRight,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.resizeLeftRight,
                              opaque: true,
                              child: Container(
                                width: resizeableGap,
                              ),
                            ),
                          )
                      ),
                      /// 좌측 화면 조절 제스쳐
                      Positioned(
                          left: 0,top: 0, bottom: 0,
                          child: GestureDetector(
                            onHorizontalDragUpdate: _onHorizontalDragLeft,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.resizeLeftRight,
                              opaque: true,
                              child: Container(
                                width: resizeableGap,
                              ),
                            ),
                          )
                      ),
                      /// 상단 화면 조절 제스쳐
                      Positioned(
                          left: 0,  right: 0, top: 0,
                          child: GestureDetector(
                            onHorizontalDragUpdate: _onHorizontalDragTop,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.resizeUpDown,
                              opaque: true,
                              child: Container(
                                height: resizeableGap,
                              ),
                            ),
                          )
                      ),
                      /// 하단 화면 조절 제스쳐
                      Positioned(
                          left: 0,  right: 0, bottom: 0,
                          child: GestureDetector(
                            onHorizontalDragUpdate: _onHorizontalDragBottom,
                            child: MouseRegion(
                              cursor: SystemMouseCursors.resizeUpDown,
                              opaque: true,
                              child: Container(
                                height: resizeableGap,
                              ),
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _getHeader() {
    return GestureDetector(
      onPanUpdate: (tapInfo) {
        widget.onWindowDragged!(tapInfo.delta.dx, tapInfo.delta.dy);
      },
      child: Container(
        width: widget.currentWidth,
        height: _headerSize,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                const Color(0xFF1855a5).withOpacity(0.5),
                const Color(0xFF009fdf).withOpacity(0.7),
                const Color(0xFF1855a5).withOpacity(0.5),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(1.0, 0.0),
              tileMode: TileMode.clamp),
        ),
        child: Row(
          children: [
            SizedBox(width: 12,),
            TextT.Lit(text: widget.title ?? '-', color: StyleT.titleColor, size: 12, bold: true),
            Expanded(child: SizedBox()),
            ButtonT.Icont(
              background: Colors.red.withOpacity(0.7),
              icon: Icons.close,
              onTap: (){
                widget.onCloseButtonClicked!();
              },
            )
          ],
        ),
      ),
    );
  }

  _getBody() {
    return Container(
      width: widget.currentWidth,
      height: widget.fixedHeight ? widget.currentHeight! - _headerSize : null,
      color: Colors.white,
      child: Material(color: Colors.transparent, child: widget.widget),
    );
  }




  void _onHorizontalDragLeft(DragUpdateDetails details) {
    setState(() {
      widget.currentWidth -= details.delta.dx;
      if (widget.currentWidth < widget.defaultWidth) {
        widget.currentWidth = widget.defaultWidth;
      } else {
        widget.onWindowDragged!(details.delta.dx, 0);
      }
    });
  }

  void _onHorizontalDragRight(DragUpdateDetails details) {
    setState(() {
      widget.currentWidth += details.delta.dx;
      if (widget.currentWidth < widget.defaultWidth) {
        widget.currentWidth = widget.defaultWidth;
      }
    });
  }

  void _onHorizontalDragBottom(DragUpdateDetails details) {
    setState(() {
      widget.currentHeight += details.delta.dy;
      if (widget.currentHeight < widget.defaultHeight) {
        widget.currentHeight = widget.defaultHeight;
      }
    });
  }

  void _onHorizontalDragTop(DragUpdateDetails details) {
    setState(() {
      widget.currentHeight -= details.delta.dy;
      if (widget.currentHeight < widget.defaultHeight) {
        widget.currentHeight = widget.defaultHeight;
      } else {
        widget.onWindowDragged!(0, details.delta.dy);
      }
    });
  }

  void _onHorizontalDragBottomRight(DragUpdateDetails details) {
    _onHorizontalDragRight(details);
    _onHorizontalDragBottom(details);
  }

  void _onHorizontalDragBottomLeft(DragUpdateDetails details) {
    _onHorizontalDragLeft(details);
    _onHorizontalDragBottom(details);
  }

  void _onHorizontalDragTopRight(DragUpdateDetails details) {
    _onHorizontalDragRight(details);
    _onHorizontalDragTop(details);
  }

  void _onHorizontalDragTopLeft(DragUpdateDetails details) {
    _onHorizontalDragLeft(details);
    _onHorizontalDragTop(details);
  }
}