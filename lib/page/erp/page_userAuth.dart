import 'dart:html';

import 'package:cell_calendar/cell_calendar.dart';
import 'package:evers/class/component/comp_pu.dart';
import 'package:evers/class/component/comp_re.dart';
import 'package:evers/class/component/comp_ts.dart';
import 'package:evers/class/schedule.dart';
import 'package:evers/class/system/state.dart';
import 'package:evers/class/user.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/page.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/class/widget/widget.dart';
import 'package:evers/helper/datetime.dart';
import 'package:evers/helper/firebaseCore.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/helper/style.dart';
import 'package:evers/page/window/window_pu_create.dart';
import 'package:evers/page/window/window_re_create.dart';
import 'package:evers/page/window/window_schList_info.dart';
import 'package:evers/page/window/window_sch_create.dart';
import 'package:evers/page/window/window_sch_editor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../../../class/system.dart';
import '../../../class/widget/list.dart';
import '../../../core/xxx/xxx.dart';
import '../../../helper/interfaceUI.dart';
import '../../../ui/dialog_schedule.dart';
import '../window/window_user_create.dart';




class PageUserAuth extends StatelessWidget {
  TextEditingController searchInput = TextEditingController();
  var scrollVertController = ScrollController();
  var scrollHorController = ScrollController();
  var divideHeight = 6.0;

  var sizePrice = 80.0;
  var sizeDate = 80.0;

  List<Schedule> scheduleList = [];
  Map<String, CalendarEvent> events = {};
  List<UserData> userList = [];
  var menu = '';

  /// 검색
  bool sort = false;

  dynamic init() async {
  }

  dynamic onSearch(String search) async {
    if(search == '') {
      sort = false;
      FunT.setStateMain();
      return;
    }
    FunT.setStateMain();
  }
  dynamic initAsync() async {
    userList = await DatabaseM.getUserDataList();
  }

  Widget titleWidget = SizedBox();
  Widget bottomWidget = SizedBox();

  dynamic mainView(BuildContext context, String menu, { Widget? topWidget, Widget? infoWidget, bool refresh=false }) async {
    titleWidget = SizedBox();
    bottomWidget = SizedBox();

    if(this.menu != menu) {
      sort = false; searchInput.text = '';
    }
    if(refresh || scheduleList.length <= 0) {
      await initAsync();
    }

    this.menu = menu;


    List<Widget> widgets = [];

    if(menu == '계정현황') {
      widgets.clear();
      widgets.add(Widgets.LoadingBar());
      if(UserSystem.userData.id != XXX.databaseAdminUserUID) {
        widgets.clear();
        widgets.add(Widgets.AccessRestriction());
      }
      else widgets = authInfoWidget(context);
    }

    var main = PageWidget.MainPage(
      topWidget: topWidget,
      infoWidget: infoWidget,
      titleWidget: titleWidget,
      children: widgets,
    );
    return main;
  }


  dynamic authInfoWidget(BuildContext context) {
    List<Widget> widgets = [];
    if(menu == '계정현황') {
      widgets.clear();
      if(UserSystem.userData.id != XXX.databaseAdminUserUID) {
        widgets.add(Widgets.LoadingBar());
        return;
      };

      var titleText = TextT.Title(text: "계정목록");

      titleWidget = Row(
        children: [
          SizedBox(height: 64,),
          titleText,
          SizedBox(width: 6 * 2,),
          ButtonT.TabMenu(
              "계정추가", Icons.add_box, accent: false,
              onTap: () {
                UIState.OpenNewWindow(context, WindowUserCreate( refresh: () { FunT.setRefreshMain(); }));
              }
          ),
        ],
      );


      List<Widget> userWidgetList = [];
      userList.forEach((user) {

        var permissionString = '';
        user.permission.forEach((key, value) {
          if(!value) return;
          permissionString += PermissionType.getByCode(key).displayName + ",   ";
          //permissionString += ": " + value.toString() + ",  ";
        });

        userWidgetList.add(Container(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextT.SubTitle(text: "이름 ${user.name}" ),
                    SizedBox(height: 6,),
                    TextT.Lit(text: "EMAIL ${user.email}", size: 12),
                    SizedBox(height: 6,),
                    TextT.Lit(text: "권한정보 - ${permissionString}", size: 12),
                  ],
                ),
              ),
              ButtonT.Icont(
                  icon:Icons.create,
                  onTap: () {
                    UIState.OpenNewWindow(context, WindowUserEditor(user: user, refresh: () { FunT.setStateMain(); }));
                  }
              ),
            ],
          ),
        ));
      });

      widgets.add(ListBoxT.Columns(
        spacingWidget:WidgetT.dividHorizontal(size: 0.35),
        crossAxisAlignment:CrossAxisAlignment.start, children: userWidgetList,
      ));
    }

    return widgets;
  }

  Widget build(context) {
    return Container();
  }
}
