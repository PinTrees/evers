import 'dart:developer';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/youtube/meta_data_section.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// video_list_page
import '../youtube/play_pause_button_bar.dart';
import '../youtube/player_state_section.dart';
import '../youtube/source_input_section.dart';
import '../youtube/video_list_page.dart';

/// 애니메이션 시스템 추가 및 개선 필요

import 'package:flutter/material.dart';

/// 이 위젯 클래스는 확장메뉴를 가지는 버튼을 생성합니다.


/// ButtonMenu 에 대한 스타일 구성을 나타냅니다.
class ButtonMenuStyle {
  final String title;
  final double titleSize;
  final Color titleColor;
  final double width;
  final double height;
  final double menuHeight;
  final double menuTextSize;
  final Color menuTextColor;

  final bool expand;
  final IconData expandIcon;
  final IconData closeIcon;
  final double iconSize;

  /// ButtonMenuStyle을 생성합니다.
  ///
  /// [title] 버튼 옆에 표시될 제목 텍스트입니다.
  /// [titleSize] 제목 텍스트의 글꼴 크기입니다.
  /// [titleColor] 제목 텍스트의 색상입니다.
  /// [width] 버튼 메뉴의 너비입니다.
  /// [height] 버튼 메뉴의 높이입니다.
  /// [menuTextSize] 메뉴 버튼의 글꼴 크기입니다.
  /// [menuTextColor] 메뉴 버튼의 텍스트 색상입니다.
  ButtonMenuStyle({
    required this.title,
    this.titleSize = 15.0,
    this.titleColor = Colors.black,
    this.width = double.maxFinite,
    this.height = 55.0,
    this.menuHeight = 38.0,
    this.menuTextSize = 14.0,
    this.menuTextColor = Colors.grey,
    this.expandIcon = Icons.add,
    this.closeIcon = Icons.close,
    this.iconSize = 22,
    this.expand = true,
  });
}




/// ButtonMenu 에 전달되는 파라미터를 나타냅니다.
///
/// [T] 메뉴 아이템의 타입입니다.
class ButtonMenuParams<T> {
  final List<T> menu;
  final Function(T)? onSelected;
  final String Function(T)? displayText;

  /// ButtonMenuParams를 생성합니다.
  ///
  /// [menu] 메뉴 아이템의 목록입니다.
  /// [onSelected] 메뉴 아이템이 선택됐을 때 호출되는 콜백 함수입니다.
  /// [displayText] 메뉴 아이템을 표시할 때 사용되는 텍스트를 반환하는 함수입니다.
  ButtonMenuParams({
    required this.menu,
    this.onSelected,
    this.displayText,
  });
}




/// 버튼을 클릭하여 메뉴를 확장하거나 축소하는 기능을 제공하는 위젯 클래스입니다.
///
/// [T] 메뉴 아이템의 타입입니다.
class ButtonMenuExpand<T> extends StatefulWidget {
  /// 버튼 메뉴의 스타일을 지정합니다.
  final ButtonMenuStyle? style;

  /// 버튼 메뉴의 파라미터를 지정합니다.
  final ButtonMenuParams<T>? params;

  /// ButtonMenuExpand를 생성합니다.
  ///
  /// [style] 버튼 메뉴의 스타일을 지정합니다.
  /// [params] 버튼 메뉴의 파라미터를 지정합니다.
  ButtonMenuExpand({this.style, this.params});

  @override
  _ButtonMenuExpandState<T> createState() => _ButtonMenuExpandState();
}


/// ButtonMenuExpand<T> 클래스의 상태관리 클래스 입니다.
class _ButtonMenuExpandState<T> extends State<ButtonMenuExpand<T>> {
  var isExpanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.params == null) return;
    initAsync();
  }


  Future<void> initAsync() async {
    setState(() {});
  }


  /// 메인 위젯을 빌드합니다.
  ///
  /// [style] 버튼 메뉴의 스타일입니다.
  /// [params] 버튼 메뉴의 파라미터입니다.
  Widget buildMain({required ButtonMenuStyle style, required ButtonMenuParams<T>? params}) {
    if (params == null) return SizedBox();

    Widget w = const SizedBox();

    /// 제목 위젯
    var titleWidget = Container(
      height: style.height,
      width: style.width,
      child: Row(
        children: [
          InkWell(
            onTap: () {},
            child: TextT.Lit(
              text: style.title,
              size: style.titleSize,
              color: style.titleColor,
              bold: true,
            ),
          ),
          if (style.expand) Expanded(child: const SizedBox()),
          InkWell(
            onTap: () {
              isExpanded = !isExpanded;
              setState(() {});
            },
            child: Container(
              padding: EdgeInsets.all(6 * 2),
              child: Icon(
                isExpanded ? style.closeIcon : style.expandIcon,
                size: style.iconSize,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );

    /// 메뉴 버튼 위젯 리스트
    List<Widget> menuWidgetList = [];
    params.menu.forEach((value) {
      menuWidgetList.add(buildMenuButton(value: value, height: style.height));
    });

    /// 확장된 상태인 경우 메뉴 버튼을 포함한 컬럼 위젯을 반환합니다.
    if (isExpanded) {
      w = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          SizedBox(height: 12),
          for (var w in menuWidgetList) w,
          SizedBox(height: 12),
        ],
      );
    }
    /// 축소된 상태인 경우 제목 위젯만을 반환합니다.
    else {
      w = titleWidget;
    }

    return w;
  }


  /// 메뉴 버튼을 빌드합니다.
  ///
  /// [value] 메뉴 아이템의 값입니다.
  /// [height] 메뉴 버튼의 높이입니다.
  Widget buildMenuButton({required T value, required double height}) {
    var displayText = "";
    if (widget.params!.displayText != null) displayText = widget.params!.displayText!(value);

    Widget w = InkWell(
      onTap: () {
        if (widget.params!.onSelected != null) widget.params!.onSelected!(value);
        setState(() {});
      },
      child: Container(
        height: widget.style!.menuHeight,
        width: widget.style!.expand ? double.maxFinite : null,
        alignment: Alignment.centerLeft,
        child: TextT.Lit(text: displayText, size: widget.style!.menuTextSize),
      ),
    );

    return w;
  }


  @override
  Widget build(BuildContext context) {
    return buildMain(
      style: widget.style ?? ButtonMenuStyle(title: ""),
      params: widget.params,


      //Icons.shopping_bag;
      //Icons.facebook;
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
