import 'dart:html';

import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/page.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/page/view/home/view_freezedrying.dart';
import 'package:evers/page/view/home/view_greetings.dart';
import 'package:evers/page/view/home/view_history.dart';
import 'package:evers/page/view/home/view_home.dart';
import 'package:evers/page/view/home/view_news.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'class/widget/button.dart';
import 'helper/interfaceUI.dart';
import 'helper/style.dart';
import 'info/menu.dart';
import 'page/view/home/view_meogkkun.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeMainMenu currentMenu = HomeMainMenu.home;
  HomeSubMenu currentSubMenu = HomeSubMenu.greetings;

  Widget drawer = SizedBox();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }
  void initAsync() async {
    setState(() {});
  }


  Widget main() {
    var bottomWidget = Column(
      children: [
        WidgetT.dividHorizontal(size: 1.4, color: Colors.grey.withOpacity(0.3)),

        SizedBox(height: 64,),
        buildBottomMenu(),
        SizedBox(height: 64,),

        WidgetT.dividHorizontal(size: 1.4, color: Colors.grey.withOpacity(0.3)),
        buildBottomBar(),
      ],
    );

    if(currentMenu == HomeMainMenu.home) {
      return PageWidget.Home(
          children: [
            ViewHome(),
          ],
          bottomWidget: bottomWidget
      );
    }
    else if(currentMenu == HomeMainMenu.info) {
      if(currentSubMenu == HomeSubMenu.greetings) {
        return PageWidget.Home(
          children: [
            ViewGreetings(),
          ],
          bottomWidget: bottomWidget
        );
      }
      else if(currentSubMenu == HomeSubMenu.history) {
        return PageWidget.Home(
            children: [
              ViewHistory(),
            ],
            bottomWidget: bottomWidget
        );
      }
    }
    else if(currentMenu == HomeMainMenu.community) {
      if(currentSubMenu == HomeSubMenu.news) {
        return PageWidget.Home(
            children: [
              ViewNews(),
            ],
            bottomWidget: bottomWidget
        );
      }
      else if(currentSubMenu == HomeSubMenu.eversStore) {
        return PageWidget.Home(
            children: [
              ViewHistory(),
            ],
            bottomWidget: bottomWidget
        );
      }
    }
    else if(currentMenu == HomeMainMenu.technology) {
      if(currentSubMenu == HomeSubMenu.freezeDrying) {
        return PageWidget.Home(
            children: [
              ViewFreezeDrying(),
            ],
            bottomWidget: bottomWidget
        );
      }
    }
    else if(currentMenu == HomeMainMenu.product) {
      if(currentSubMenu == HomeSubMenu.meogkkun) {
        return PageWidget.Home(
            children: [
              ViewMeogkkun(),
            ],
            bottomWidget: bottomWidget
        );
      }
    }

    return SizedBox();
  }


  Widget buildBottomMenu() {
    List<Widget> menuWidgets = [];
    for(var m in HomeMainMenu.values) {
      if(m.subMenus.isEmpty) continue;
      List<Widget> subMenuWidgets = [];
      subMenuWidgets.add(ButtonT.Text(text: m.displayName, textSize: 16, bold: true, color: Colors.transparent));
      subMenuWidgets.add(SizedBox(height: 6,));
      for(var s in m.subMenus) {
        subMenuWidgets.add(ButtonT.Text(text: s.displayName, textSize: 14, bold: true, color: Colors.transparent, textColor: StyleT.textColor.withOpacity(0.5),
            onTap: () {
              if(s == HomeSubMenu.store) {
                launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
              } else if(s == HomeSubMenu.naverStore) {
                launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
              } else {
                currentMenu = m;
                currentSubMenu = s;
              }
              setState(() {});
            }
        ));
      }
      menuWidgets.add(Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subMenuWidgets,));
    }

    return Container(
      padding: EdgeInsets.only(left: 28, right: 28),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: menuWidgets,
          ),
          SizedBox(height: 6 * 8,),
          ListBoxT.Wraps(
            spacing: 6 * 12, colSpacing: 6,
            children: [
              ButtonT.IconText(text: "개인정보 처리방침", icon: Icons.info, textSize: 16, bold: true, color: Colors.transparent, textColor: Colors.indigo,
                onTap: () {
                  launchUrl( Uri.parse("https://eversfood.cafe24.com/member/privacy.html"),   webOnlyWindowName: true ? '_blank' : '_self', );
                }
              ),

              ButtonT.IconText(text: "라이센스", icon: Icons.open_in_new_sharp, textSize: 16, bold: true, color: Colors.transparent,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LicensePage()));
                  }
              ),

              ButtonT.IconText(text: "제품 스토어", icon: Icons.open_in_new_sharp, textSize: 16, bold: true, color: Colors.transparent,
                  onTap: () {
                    launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
                  },
              ),

              ButtonT.IconText(text: "스마트 스토어", icon: Icons.open_in_new_sharp, textSize: 16, bold: true, color: Colors.transparent,
                  onTap: () {
                    launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
                  }
              ),
            ],
          )
        ],
      ),
    );
  }
  Widget buildBottomBar() {
    Container(
      height: 256,
      width:  double.maxFinite,
      alignment: Alignment.center,
      color: Colors.white,
      child: Text(
        'ABOUT US | AGREEMENT | PRIVACY POLICY | GUIDE'
            '\n\nCOMPANY : 에버스 | OWNER : 이재구| 사업자등록번호 : 741-87-02231 [사업자정보확인]| 통신판매업신고번호 : -'
            '\nADDRESS : 강원도 원주시 시청로 160-1, 401호(무실동)| CS CENTER : -| 개인정보관리책임자 : -'
            '\n\n\nCOPYRIGHT © 에버스. ALL RIGHTS RESERVED.'
            '\nHOSTING BY Firebase',
      ),
    );


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
                      currentMenu = HomeMainMenu.home;
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


  Widget buildSubMenu() {
    List<Widget> menus = [];

    for(var m in HomeMainMenu.values) {
      if(m.subMenus.isEmpty) continue;

      List<Widget> subMenus = [];
      for(var s in m.subMenus) {
        subMenus.add(ButtonT.Text(
          textSize: 14, bold: true, textColor: currentSubMenu == s ? StyleT.titleColor : StyleT.textColor.withOpacity(0.5),
          text: s.displayName, /*icon: s.icon,*/
          color: Colors.transparent,
          onTap: () {
            if(s == HomeSubMenu.store) {
              launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
              return;
            }
            if(s == HomeSubMenu.naverStore) {
              launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
              return;
            }

            currentMenu = m;
            currentSubMenu = s;

            setState(() {});
          }
        ));
      }
      menus.add(Column(children: subMenus,));
    }

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(height: 6 * 2,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 128,),
              Expanded(child: SizedBox()),
              ListBoxT.Rows(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 6 * 8, children: menus, ),
              Expanded(child: SizedBox()),
              SizedBox(width: 128,),
            ],
          ),
          SizedBox(height: 68,),
          WidgetT.dividHorizontal(size: 2, color: Colors.grey.withOpacity(0.3)),
        ],
      ),
    );
  }
  Widget buildMainMenu() {
    List<Widget> mainWidgets = [];

    for(var m in HomeMainMenu.values) {
      if(m.subMenus.isEmpty) continue;
      mainWidgets.add( ButtonT.Title(
        text: m.displayName,
        onTap: () {
          if(m == HomeMainMenu.store) {
            currentMenu = HomeMainMenu.product;
            currentSubMenu = currentMenu.subMenus.first;
            setState(() {});
            return;
          }

          currentMenu = m;
          currentSubMenu = m.subMenus.first;
          setState(() {});
        }
      ),);
    }

    return Container(
      color: Colors.white,
      height: 68,
      padding: EdgeInsets.all(6),
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                currentMenu = HomeMainMenu.home;
                currentSubMenu = HomeSubMenu.greetings;
                setState(() {});
              },
              style: StyleT.buttonStyleNone(elevation: 0, color: Colors.transparent,),
              child: Container(height: 64, child: Image(image: AssetImage('assets/icon_hor.png') ),)),
          Expanded(child: SizedBox()),
          ListBoxT.Rows( spacing: 6 * 10, children: mainWidgets ),
          Expanded(child: SizedBox()),
          SizedBox(width: 128,),
          ButtonT.Icont(
              icon: Icons.search,
              onTap: () {

              }
          ),
        ],
      ),
    );
  }

  Widget buildMainMenuMobile() {
    List<Widget> mainWidgets = [];
    for(var m in HomeMainMenu.values) {
      if(m.subMenus.isEmpty) continue;
      mainWidgets.add( ButtonT.Title(
          text: m.displayName,
          onTap: () {
            if(m == HomeMainMenu.store) {
              currentMenu = HomeMainMenu.product;
              currentSubMenu = currentMenu.subMenus.first;
              setState(() {});
              return;
            }

            currentMenu = m;
            currentSubMenu = m.subMenus.first;
            setState(() {});
          }
      ),);
    }


    var homeWidget = InkWell(
        onTap: () {
          currentMenu = HomeMainMenu.home;
          currentSubMenu = HomeSubMenu.greetings;
          setState(() {});
        },
        child: Container(height: 38, child: Image(image: AssetImage('assets/icon_hor.png') ),));

    return Container(
      color: Colors.white,
      height: 68,
      padding: EdgeInsets.all(6),
      alignment: Alignment.centerLeft,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ButtonT.Icont(
            icon: Icons.menu,
            onTap: () {

              List<Widget> menuWidgets = [];
              for(var m in HomeMainMenu.values) {
                if(m.subMenus.isEmpty) continue;
                List<Widget> subMenuWidgets = [];
                subMenuWidgets.add(ButtonT.Text(text: m.displayName, textSize: 16, bold: true, color: Colors.transparent));
                subMenuWidgets.add(SizedBox(height: 6,));
                for(var s in m.subMenus) {
                  subMenuWidgets.add(ButtonT.Text(text: s.displayName, textSize: 14, bold: true, color: Colors.transparent, textColor: StyleT.textColor.withOpacity(0.5),
                      onTap: () {
                        if(s == HomeSubMenu.store) {
                          launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
                        } else if(s == HomeSubMenu.naverStore) {
                          launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
                        } else {
                          currentMenu = m;
                          currentSubMenu = s;
                        }

                        drawer = SizedBox();
                        setState(() {});
                      }
                  ));
                }
                menuWidgets.add(Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: subMenuWidgets,));
              }

              drawer = Row(
                children: [
                  Container(
                    width: 400,
                    color: Colors.white,
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        Container(
                          height: 68,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ButtonT.LitIcon(
                                Icons.close, size: 32,
                                onTap: () {
                                  drawer = SizedBox();
                                  setState(() {});
                                }
                              ),
                              homeWidget,

                              SizedBox(width: 48,),
                            ],
                          ),
                        ),
                        SizedBox(height: 6 * 4,),

                        ListBoxT.Columns(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 6 * 4,
                          children: menuWidgets,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        drawer = SizedBox();
                        setState(() {});
                      },
                      child: Container(
                        height: double.maxFinite,
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  )
                ],
              );
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
    );
  }


  Widget buildTitleBar() {
    if (MediaQuery.of(context).size.width < 800) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildMainMenuMobile(),
          Container(color: Colors.white, child: WidgetT.dividHorizontal(size: 2, color: Colors.grey.withOpacity(0.3)),),
          //if (isMouseOver) buildSubMenu(),
        ],
      );
    }
    else {
      return MouseRegion(
        onHover: (event) {
          isMouseOver = true;
          setState(() {});
        },
        onExit: (event) {
          isMouseOver = false;
          setState(() {});
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildMainMenu(),
            Container(
              color: Colors.white,
              child: WidgetT.dividHorizontal(size: 2, color: Colors.grey.withOpacity(0.3)),),
            if (isMouseOver) buildSubMenu(),
          ],
        ),
      );
    }
  }

  bool isMouseOver = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          main(),
          Positioned(
            top: 0, left: 0, right: 0,
            child: buildTitleBar(),
          ),
          Positioned(
            top: 0, left: 0, bottom: 0, right: 0,
            child: drawer,
          )
        ],
      ),
    );
  }
}
