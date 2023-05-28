import 'dart:html';

import 'package:cell_calendar/cell_calendar.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/schedule.dart';
import 'package:evers/class/system/state.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/page.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/datetime.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_re_create.dart';
import 'package:evers/page/window/window_schList_info.dart';
import 'package:evers/page/window/window_sch_create.dart';
import 'package:evers/page/window/window_sch_editor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../../../class/system.dart';
import '../../../class/widget/list.dart';
import '../../../helper/interfaceUI.dart';
import '../../../ui/dialog_schedule.dart';



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


enum ScheduleWeekMenu {
  sunday('sunday', '일', Icons.calendar_view_day),
  monday("monday", '월', Icons.calendar_month),
  tuesday('tuesday', '화', Icons.calendar_view_week ),
  wendsday('wendsday', '수', Icons.calendar_view_day),
  thuday('thuday', '목', Icons.calendar_view_day),
  friday('friday', '금', Icons.calendar_view_day),
  saturday('saturday', '토', Icons.calendar_view_day);

  const ScheduleWeekMenu(this.code, this.displayName, this.icon);
  final String code;
  final String displayName;
  final IconData icon;

  factory ScheduleWeekMenu.getByCode(String code){
    return ScheduleWeekMenu.values.firstWhere((value)
    => value.code == code,
        orElse: () => ScheduleWeekMenu.monday
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
  Map<String, CalendarEvent> events = {};

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
  Map<String, List<Schedule>> getWeekEvent() {
    Map<String, List<Schedule>> eventsList = {};
    DateTime now = DateTime.now();

    eventsList["Sun"] = [];
    eventsList["Mon"] = [];
    eventsList["Tue"] = [];
    eventsList["Wed"] = [];
    eventsList["Thu"] = [];
    eventsList["Fri"] = [];
    eventsList["Sat"] = [];

    /// 현재 날짜로부터 주간 날짜 정보 획득
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = now.add(Duration(days: 7 - now.weekday));

    scheduleList.forEach((value) {
      if(value.date >= startOfWeek.microsecondsSinceEpoch
      && value.date <= endOfWeek.microsecondsSinceEpoch) {
        String dayOfWeek = getDayOfWeek(DateTime.fromMicrosecondsSinceEpoch(value.date));
        eventsList[dayOfWeek]!.add(value);
      }
    });

    return eventsList;
  }


  String getDayOfWeek(DateTime date) {
    List<String> weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  dynamic refreshAsync() async {
    events.clear();
    scheduleList = await DatabaseM.getSchedule();

    for(var s in scheduleList) {
      if(s.getDate() == null) continue;
      var ev = CalendarEvent(eventName:'[${StyleT.scheduleName[s.type] ?? '알수없음'}] ${s.memo}', eventDate: s.getDate()!,
          eventBackgroundColor: Colors.transparent,
          eventTextColor: StyleT.scheduleColor[s.type] ?? Colors.red);
      events[s.id] = ev;
    }
  }


  void clear() async {
  }

  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false }) async {
    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    if(refresh || scheduleList.length <= 0) await refreshAsync();

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
          ButtonT.TabMenu(
              "일정추가", Icons.add_box, accent: false,
              onTap: () {
                UIState.OpenNewWindow(context, WindowSchCreate(ct: null, refresh: () { FunT.setRefreshMain(); }));
              }
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

      Widget calenderWidget = SizedBox();
      if(currentMenu == ScheduleMenu.month) {
        calenderWidget = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                height: 1024,
                child: CellCalendar(
                  events: events.values.toList(),
                  onCellTapped: (date){
                    print("$date is tapped !");
                      final eventsOnTheDate = SystemT.schedule.where((event) {
                      final eventDate = DateTime.fromMicrosecondsSinceEpoch(event.date);
                      return eventDate.year == date.year &&
                          eventDate.month == date.month &&
                          eventDate.day == date.day;
                    }).toList();

                      UIState.OpenNewWindow(context, WindowSchListInfo(scheduleList: eventsOnTheDate.toList(),
                          refresh: () { FunT.setStateMain(); }, date: date));
                  },
                  daysOfTheWeekBuilder: (dayIndex) {
                    /// dayIndex: 0 for Sunday, 6 for Saturday.
                    final labels = ["일", "월", "화", "수", "목", "금", "토"];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        labels[dayIndex],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                  monthYearLabelBuilder: (datetime) {
                    final year = datetime!.year.toString();
                    final month = datetime!.month.toString();
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "$year년 $month월",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                )
            )
          ],
        );
      }
      else if(currentMenu == ScheduleMenu.week) {
        var eventList = getWeekEvent();

        calenderWidget = Container(
            height: 1024,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 18,),
                TextT.TitleMain(text: "   ${ DateTime.now().month }월 ${ DateTimeManager.getWeekOfMonth() }주차"),
                SizedBox(height: 16,),

                ListBoxT.Rows(
                  children: [
                    for(var m in ScheduleWeekMenu.values)
                      Expanded(
                        child: TextT.SubTitle(text: m.displayName, expand: true ),
                      ),
                  ],
                ),
                SizedBox(height: 6,),
                WidgetT.dividHorizontal(size: 1.4, color: Colors.grey.withOpacity(0.35)),
                ListBoxT.Rows(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacingWidget: WidgetT.dividViertical(size: 1.4, height: 1024, color: Colors.grey.withOpacity(0.35)),
                  children: [
                    for(var events in eventList.values)
                      Expanded(
                        child: Container(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(height: 6,),
                              for(var sch in events)
                                ButtonT.IconTextExpaned(
                                  icon: Icons.access_alarms_sharp,
                                  text: sch.memo,
                                  onTap: () {
                                    UIState.OpenNewWindow(context, WindowSchEditor(schedule: sch, refresh: () async { await FunT.setStateMain(); }));
                                  }
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            )
        );
      }
      else if(currentMenu == ScheduleMenu.day) {

      }

      childrenW.add(Column(
        children: [
          calenderWidget,
        ],
      ));
    }

    var main = PageWidget.Main(
      topWidget: topWidget,
      infoWidget: infoWidget,
      titleWidget: titleWidget,
      children: childrenW,
    );
    return main;
  }

  Widget build(context) {
    return Container();
  }
}
