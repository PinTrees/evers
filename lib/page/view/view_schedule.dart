import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/schedule.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_re_create.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../../class/widget/list.dart';
import '../../helper/interfaceUI.dart';



enum ScheduleMenu {
  month("month", '월간', Icons.calendar_month),
  week('week', '주간', Icons.calendar_view_week ),
  day('day', '일간', Icons.calendar_view_day);

  const ScheduleMenu(this.code, this.displayName, this.icon);
  final String code;
  final String displayName;
  final IconData icon;

  factory ScheduleMenu.getByCode(String code){
    return ScheduleMenu.values.firstWhere((value)
        => value.code == code,
        orElse: () => ScheduleMenu.month
    );
  }
}




class ViewSchedule extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var scrollVertController = ScrollController();
  var scrollHorController = ScrollController();
  var divideHeight = 6.0;

  var sizePrice = 80.0;
  var sizeDate = 80.0;

  List<Schedule> scheduleList = [];

  /// 검색
  bool sort = false;

  dynamic init() async {
  }

  ScheduleMenu currentMenu = ScheduleMenu.month;
  var menu = '';

  dynamic search(String search) async {
    if(search == '') {
      sort = false;
      FunT.setStateMain();
      return;
    }
    FunT.setStateMain();
  }


  dynamic refreshAsync() async {
  }


  void clear() async {
  }

  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false }) async {
    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    if(refresh ) await refreshAsync();

    this.menu = menu;

    Widget titleWidget = SizedBox();
    Widget bottomWidget = SizedBox();

    List<Widget> childrenW = [];

    if(menu == '일정관리') {
      childrenW.clear();

      var titleText = TextT.TitleMain(text: "일정관리");

      var tabMenuWidget = ListBoxT.Rows(
        spacing: 6,
        children: [
          for(var tab in ScheduleMenu.values)
            ButtonT.TabMenu(
                tab.displayName, tab.icon,
                accent: tab.code == currentMenu.code,
                onTap: () { currentMenu = tab;
                  FunT.setStateMain(); }
            ),
        ],
      );

      titleWidget = ListBoxT.Columns(
        spacing: 6,
        children: [
          SizedBox(height: 6,),
          titleText,
          tabMenuWidget,
          SizedBox(),
        ],
      );

      childrenW.add(SizedBox());
    }

    var main = Column (
      children: [
        if(topWidget != null) topWidget,
        Expanded(
          child: Row(
            children: [
              if(infoWidget != null) infoWidget,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    titleWidget,
                    WidgetT.dividHorizontal(size: 1.4),
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.all(12),
                        children: [
                          Column(children: childrenW,),
                          SizedBox(height: 18,),
                        ],
                      ),
                    ),
                    bottomWidget,
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return main;
  }

  Widget build(context) {
    return Container();
  }
}
