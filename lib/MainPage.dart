import 'dart:html';

import 'package:evers/class/widget/button/button_menu_expand.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/page.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/page/view/home/view_freezedrying.dart';
import 'package:evers/page/view/home/view_greetings.dart';
import 'package:evers/page/view/home/view_history.dart';
import 'package:evers/page/view/home/view_home.dart';
import 'package:evers/page/view/home/view_meokkun_story.dart';
import 'package:evers/page/view/home/view_news.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'class/version.dart';
import 'class/widget/button.dart';
import 'class/widget/button/button_image_web.dart';
import 'class/widget/youtube.dart';
import 'core/context_data.dart';
import 'helper/interfaceUI.dart';
import 'helper/style.dart';
import 'info/menu.dart';
import 'page/view/home/view_meogkkun.dart';

class HomePage extends StatefulWidget {
  String url = "";
  String subUrl = "";
  HomePage({ this.url = "", this.subUrl = "", super.key,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeMainMenu currentMenu = HomeMainMenu.home;
  HomeSubMenu currentSubMenu = HomeSubMenu.greetings;

  Widget drawer = SizedBox();
  Widget main = SizedBox();

  bool isExpanded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }

  dynamic initAsync() async {
    /// 메디아 쿼리값 오류 제거
    await Future.delayed(const Duration(milliseconds: 2), () {});
    ContextData(context: context);

    if(widget.url != "") {
      currentMenu = HomeMainMenu.getByCode(widget.url);
      if(widget.subUrl != "") currentSubMenu = HomeSubMenu.getByCode(widget.subUrl);
      else currentSubMenu = currentMenu.subMenus.first;
    }

    setState(() {});
  }

  void refreshPage(HomeMainMenu m, HomeSubMenu s) async {
    if(!Version.checkVersion()) {
      var url = Uri.base.toString().split('home').first + 'home/${currentMenu.code}/${currentSubMenu.code}';
      await launchUrl( Uri.parse(url),   webOnlyWindowName: '_self', );
    } else {
      widget.url = m.code;
      widget.subUrl = s.code;
      context.replace("/home/${widget.url}/${widget.subUrl}", extra: true);
      setState(() {});
    }
  }


  Widget mainBuild() {
    print("mainBuild");
    ContextData.Init();

    if(isExpanded) { drawer = buildSideNavigation(); }
    else { drawer = const SizedBox(); }
    
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
      main = PageWidget.Home(
          children: [
            ViewHome(),
          ],
          bottomWidget: bottomWidget
      );
    }
    else if(currentMenu == HomeMainMenu.info) {
      if(currentSubMenu == HomeSubMenu.greetings) {
        main = PageWidget.Home(
          children: [
            ViewGreetings(),
          ],
          bottomWidget: bottomWidget
        );
      }
      else if(currentSubMenu == HomeSubMenu.history) {
        main = PageWidget.Home(
            children: [
              ViewHistory(),
            ],
            bottomWidget: bottomWidget
        );
      }
    }
    else if(currentMenu == HomeMainMenu.community) {
      if(currentSubMenu == HomeSubMenu.news) {
        main = PageWidget.Home(
            children: [
              ViewNews(),
            ],
            bottomWidget: bottomWidget
        );
      }
      else if(currentSubMenu == HomeSubMenu.eversStory) {
        main = PageWidget.Home(
            children: [
              ViewStory(),
            ],
            bottomWidget: bottomWidget
        );
      }
    }
    else if(currentMenu == HomeMainMenu.technology) {
      if(currentSubMenu == HomeSubMenu.freezeDrying) {
        main = PageWidget.Home(
            children: [
              ViewFreezeDrying(),
            ],
            bottomWidget: bottomWidget
        );
      }
    }
    else if(currentMenu == HomeMainMenu.product) {
      if(currentSubMenu == HomeSubMenu.meogkkun) {
        main = PageWidget.Home(
            children: [
              ViewMeogkkun(),
            ],
            bottomWidget: bottomWidget
        );
      }
    }

    return main;
  }


  Widget buildBottomMenu() {
    List<Widget> menuWidgets = [];
    for(var m in HomeMainMenu.values) {
      if(m.subMenus.isEmpty) continue;
      List<Widget> subMenuWidgets = [];
      subMenuWidgets.add(ButtonT.Text(text: m.displayName, textColor: Colors.black, textSize: 16, bold: true, color: Colors.transparent));
      subMenuWidgets.add(SizedBox(height: 6,));
      for(var s in m.subMenus) {
        subMenuWidgets.add(ButtonT.Text(text: s.displayName, textSize: 14, bold: false, color: Colors.transparent,
            textColor: Colors.grey,
            onTap: () async {
              if(s == HomeSubMenu.store) {
                launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
              } else if(s == HomeSubMenu.naverStore) {
                launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
              } else {
                currentMenu = m;
                currentSubMenu = s;
                refreshPage(currentMenu, currentSubMenu);
              }
            }
        ));
      }
      menuWidgets.add(Column(mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: subMenuWidgets,));
    }

    Widget w = const SizedBox();

    if(ContextData.isMobile) { w = buildBottomMenuMobile(); }
    else { w = Container(
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
    ); }

    return w;
  }
  Widget buildBottomMenuMobile() {
    List<Widget> menuWidgets = [];
    for(var m in HomeMainMenu.values) {
      if(m.subMenus.isEmpty) continue;

      var buttonExpand = ButtonMenuExpand<HomeSubMenu>(
        style: ButtonMenuStyle(
          title: m.displayName,
        ),
        params: ButtonMenuParams<HomeSubMenu>(
          menu: m.subMenus,
          onSelected: (value) {
            if(value == HomeSubMenu.store) {
              launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
            } else if(value == HomeSubMenu.naverStore) {
              launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
            } else {
              currentMenu = m;
              currentSubMenu = value;
              refreshPage(currentMenu, currentSubMenu);
            }
          },
          displayText: (value) { return value.displayName; }
        ),
      );

      menuWidgets.add(buttonExpand);
    }

    return Container(
      padding: EdgeInsets.only(left: 28, right: 28),
      child: Column(
        children: [
          ListBoxT.Columns(children: menuWidgets),
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





  Widget buildSideNavigation() {
    List<Widget> menuWidgets = [];
    for(var m in HomeMainMenu.values) {
      if(m.subMenus.isEmpty) continue;

      var buttonExpand = ButtonMenuExpand<HomeSubMenu>(
        style: ButtonMenuStyle(
          title: m.displayName,
        ),
        params: ButtonMenuParams<HomeSubMenu>(
            menu: m.subMenus,
            onSelected: (value) {
              if(value == HomeSubMenu.store) {
                launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
              } else if(value == HomeSubMenu.naverStore) {
                launchUrl( Uri.parse("https://eversfood.cafe24.com/#"),   webOnlyWindowName: true ? '_blank' : '_self', );
              } else {
                currentMenu = m;
                currentSubMenu = value;
                refreshPage(currentMenu, currentSubMenu);
              }
              isExpanded = false;
              setState(() {});
            },
            displayText: (value) { return value.displayName; }
        ),
      );

      menuWidgets.add(buttonExpand);
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(18, 6, 18, 12),
          width: ContextData.width * 0.7,
          color: Colors.white,
          child: ListBoxT.Columns(
            spacingWidget: WidgetT.dividHorizontal(size: 2, color: Colors.grey.withOpacity(0.3)),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ButtonT.Icont(
                      icon: Icons.close,
                      onTap: () {
                        isExpanded = false;
                        setState(() {});
                      }
                  ),
                  TextButton(
                      onPressed: () async {
                        currentMenu = HomeMainMenu.home;
                        currentSubMenu = HomeSubMenu.greetings;
                        isExpanded = false;
                        setState(() {});
                      },
                      style: StyleT.buttonStyleNone(elevation: 0, color: Colors.transparent,),
                      child: Container(height: 28, child: Image(image: AssetImage('assets/icon_hor.png') ),)),
                  SizedBox(width: 64, height: 68,),
                ],
              ),
              for(var w in menuWidgets) w,
            ],
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () {
              isExpanded = false;
              setState(() {});
            },
            child: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              color: Colors.black.withOpacity(0.75),
            )
          ),
        )
      ],
    );
  }


  Widget buildBottomBar() {
    return Container(
      child: Stack(
        children: [
          Container(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ButtonImage(style: ButtonImageStyle(imageUrl: "https://raw.githubusercontent.com/PinTrees/evers/main/sever/icon_hor.png", height: 28), params: ButtonTParams(
                  onTap: () async {
                    currentMenu = HomeMainMenu.home;
                    setState(() {});
                  }
                ),),
                SizedBox(width: 6 * 4,),
                TextT.Lit(text: "Copyright © 에버스. All Rights Reserved.", size: 14, bold: false, color: StyleT.textColor.withOpacity(0.5)),
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
          textSize: 14, bold: currentSubMenu == s , textColor: currentSubMenu == s ? StyleT.titleColor : Colors.grey,
          text: s.displayName,
          color: Colors.transparent,
          onTap: () async {
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
            refreshPage(currentMenu, currentSubMenu);
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
        onTap: () async {
          if(m == HomeMainMenu.store) {
            currentMenu = HomeMainMenu.product;
            currentSubMenu = currentMenu.subMenus.first;
          }
          else {
            currentMenu = m;
            currentSubMenu = m.subMenus.first;
          }
          refreshPage(currentMenu, currentSubMenu);
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
          ButtonImage(style: ButtonImageStyle(imageUrl: "https://raw.githubusercontent.com/PinTrees/evers/main/sever/icon_hor.png", height: 28), params: ButtonTParams(
              onTap: () async {
                currentMenu = HomeMainMenu.home;
                setState(() {});
              }
          ),),
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
          onTap: () async {
            if(m == HomeMainMenu.store) {
              currentMenu = HomeMainMenu.product;
              currentSubMenu = currentMenu.subMenus.first;
            }
            else {
              currentMenu = m;
              currentSubMenu = m.subMenus.first;
            }
            refreshPage(currentMenu, currentSubMenu);
          }
      ),);
    }

    return Container(
      color: Colors.white,
      height: 68,
      padding: EdgeInsets.all(6),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ButtonT.Icont(
            icon: Icons.menu,
            onTap: () {
              isExpanded = true;
             setState(() {});
            }
          ),

          ButtonImage(style: ButtonImageStyle(imageUrl: "https://raw.githubusercontent.com/PinTrees/evers/main/sever/icon_hor.png", height: 28), params: ButtonTParams(
              onTap: () async {
                currentMenu = HomeMainMenu.home;
                setState(() {});
              }
          ),),

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
    if (ContextData.isMobile) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildMainMenuMobile(),
          Container(color: Colors.white, child: WidgetT.dividHorizontal(size: 2, color: Colors.grey.withOpacity(0.3)),),
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
            Container(color: Colors.white, child: WidgetT.dividHorizontal(size: 1.4, color: Colors.grey.withOpacity(0.3)),),
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
          mainBuild(),
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
