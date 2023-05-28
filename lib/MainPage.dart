import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/class/widget/list.dart';
import 'package:evers/class/widget/page.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seo/html/seo_widget.dart';
import 'package:seo_renderer/renderers/image_renderer/image_renderer_web.dart';
import 'package:url_launcher/url_launcher.dart';

import 'class/widget/button.dart';
import 'helper/interfaceUI.dart';
import 'helper/router.dart';
import 'helper/style.dart';
import 'info/menu.dart';
import 'route/navigator2.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {


  HomeMainMenu currentMenu = HomeMainMenu.info;
  HomeSubMenu currentSubMenu = HomeSubMenu.greetings;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAsync();
  }
  void initAsync() async {
  }

  @override
  void didChangeDependencies() {
  }


  Widget main() {
    var bottomWidget = Column(
      children: [
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
        ),
      ],
    );

    if(currentMenu == HomeMainMenu.home) {
      return ListView(
        children: [
          Column(
            children: [
              // 홈페이지 수정부분 - 추후 수정 / 03.16
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                      children: [
                        Expanded(
                            child: Container(
                              height: 900, width: double.maxFinite,
                              child: CachedNetworkImage(imageUrl:'https://raw.githubusercontent.com/PinTrees/evers/main/sever/DSC02914.JPG.jpg', fit: BoxFit.cover),
                            )
                        )
                      ]
                  ),
                  Positioned(
                    left: 128,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetT.titleT('동결건조로 완성한 신선한 맛', size: 68, bold: true, color: Colors.white),
                        Container(
                          width: 500,
                          child: WidgetT.titleT('오랫동안 연구를 통해 개발한 동결건조 기술을 건강하고 신선한 원재료와 접목시켰습니다.', size: 32, bold: false, color: Colors.white),
                        )
                      ],
                    ),
                  )
                ],
              ),

              Container(
                padding: EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 128,),
                    TextT.Lit(text: '에버스가 걸어온 길', size: 48, bold: true, color: StyleT.titleColor),
                    SizedBox(height: 6,),
                    TextT.Lit(text: '에버스는 건강한 식품 개발을 주된 목적사업으로 하여 태어났어요.  에버스는 지난 10년 간의 동결건조 경험을 바탕으로 CDI 방식의 동결건조 시스템 새로 구축하였고,  2018. 3. 18. 법인으로 출발하게 되었어요. 에버스는 그 동안 건강하고  행복한 식품, 스낵 개발 등을 위해 노력해 왔어요. 외주에 의한 동결건조 경험을 기초로 직접 건강한 식품, 스낵의 맛을 탐구하고 찾아내기 위해 노력하였어요.'
                        '\n지난 2년 동안  ‘세상이 없던 맛’ 시리즈 제품을 개발하였고, 브랜드 ‘나는 먹꾼’을 런칭하는 등 많은 변화가 있었죠. 우리의 방식으로 개발한 제품이 나왔을 때 소비자들은 ‘이럿 맛은 처음’이라는 환호성을 질렀어요.'
                        '\n에버스는 자꾸만 손이 가는 맛을 개발하기 위하여 수많은 테스트를 진행했어요. 맛있지만 건강한 제품을 만들겠다는 다짐으로 한 걸음 한 걸음 내디딘 결과, 기존 시장에서는 맛볼 수 없던 특별한 제품을 생산하게 되었어요.'
                        '\n앞으로 고객들의 기대에 부응하기 위해의 영양가 높고 맛과 향을 유지하는 신제품을 개발하기 위해 최선을 다하는 에버스가 되겠습니다.', size: 18),
                    SizedBox(height: 128,),
                  ],
                ),
              ),

              Container(
                height: 640,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for(int i = 0; i < 3; i++)
                      Container(
                        height: 640, width: 640,
                        child: Column(
                          children: [
                            Container(height: 460, width: 640, color: Colors.grey.withOpacity(0.35), alignment: Alignment.center,
                              child: WidgetT.text('상품 이미지', bold: true),),
                            Container(height: 180, width: 640, color: Colors.white,
                                padding: EdgeInsets.all(6 * 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WidgetT.text('상품명', size: 24, bold: true),
                                    RichText(
                                      text: TextSpan(
                                          children: [
                                            TextSpan(
                                                text: '${ StyleT.krwInt(1012390) }',
                                                style: TextStyle(color: Colors.grey,
                                                    fontSize: 24, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.w900)),
                                            TextSpan(
                                                text: '원  ',
                                                style: TextStyle(color: Colors.grey,
                                                    fontSize: 24, fontWeight: FontWeight.w900)),
                                            TextSpan(
                                                text: '${ StyleT.krwInt(77751) }원 할인 ',
                                                style: TextStyle(color: Colors.black.withOpacity(0.7),
                                                    fontSize: 24, fontWeight: FontWeight.w900)),

                                          ]),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        WidgetT.text(StyleT.krwInt(101230) + '원', size: 54, bold: true),
                                        InkWell(
                                          onTap: () async {
                                            WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');

                                            var url = Uri.base.toString() + 'shopping/aaaa';
                                            print(url);
                                            await launchUrl( Uri.parse(url),
                                              webOnlyWindowName: true ? '_blank' : '_self',
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(6 * 3),
                                            color: Colors.grey.withOpacity(0.35),
                                            child: WidgetT.text('구매하기', size: 24, bold: true),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                            )
                          ],
                        ),
                      )
                  ],
                ),
              ),
              SizedBox(height: 6 * 8,),

            ],
          )
        ],
      );
    }
    else if(currentMenu == HomeMainMenu.info) {
      if(currentSubMenu == HomeSubMenu.greetings) {
        return PageWidget.Home(
          bottomWidget: bottomWidget
        );
      }
      return ListView(
        children: [
          Column(
            children: [
              // 홈페이지 수정부분 - 추후 수정 / 03.16
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                      children: [
                        Expanded(
                            child: Container(
                              height: 900, width: double.maxFinite,
                              child: CachedNetworkImage(imageUrl:'https://raw.githubusercontent.com/PinTrees/evers/main/sever/DSC02914.JPG.jpg', fit: BoxFit.cover),
                            )
                        )
                      ]
                  ),
                  Positioned(
                    left: 128,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        WidgetT.titleT('동결건조로 완성한 신선한 맛', size: 68, bold: true, color: Colors.white),
                        Container(
                          width: 500,
                          child: WidgetT.titleT('오랫동안 연구를 통해 개발한 동결건조 기술을 건강하고 신선한 원재료와 접목시켰습니다.', size: 32, bold: false, color: Colors.white),
                        )
                      ],
                    ),
                  )
                ],
              ),

              Container(
                padding: EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 128,),
                    TextT.Lit(text: '에버스가 걸어온 길', size: 48, bold: true, color: StyleT.titleColor),
                    SizedBox(height: 6,),
                    TextT.Lit(text: '에버스는 건강한 식품 개발을 주된 목적사업으로 하여 태어났어요.  에버스는 지난 10년 간의 동결건조 경험을 바탕으로 CDI 방식의 동결건조 시스템 새로 구축하였고,  2018. 3. 18. 법인으로 출발하게 되었어요. 에버스는 그 동안 건강하고  행복한 식품, 스낵 개발 등을 위해 노력해 왔어요. 외주에 의한 동결건조 경험을 기초로 직접 건강한 식품, 스낵의 맛을 탐구하고 찾아내기 위해 노력하였어요.'
                        '\n지난 2년 동안  ‘세상이 없던 맛’ 시리즈 제품을 개발하였고, 브랜드 ‘나는 먹꾼’을 런칭하는 등 많은 변화가 있었죠. 우리의 방식으로 개발한 제품이 나왔을 때 소비자들은 ‘이럿 맛은 처음’이라는 환호성을 질렀어요.'
                        '\n에버스는 자꾸만 손이 가는 맛을 개발하기 위하여 수많은 테스트를 진행했어요. 맛있지만 건강한 제품을 만들겠다는 다짐으로 한 걸음 한 걸음 내디딘 결과, 기존 시장에서는 맛볼 수 없던 특별한 제품을 생산하게 되었어요.'
                        '\n앞으로 고객들의 기대에 부응하기 위해의 영양가 높고 맛과 향을 유지하는 신제품을 개발하기 위해 최선을 다하는 에버스가 되겠습니다.', size: 18),
                    SizedBox(height: 128,),
                  ],
                ),
              ),

              Container(
                height: 640,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for(int i = 0; i < 3; i++)
                      Container(
                        height: 640, width: 640,
                        child: Column(
                          children: [
                            Container(height: 460, width: 640, color: Colors.grey.withOpacity(0.35), alignment: Alignment.center,
                              child: WidgetT.text('상품 이미지', bold: true),),
                            Container(height: 180, width: 640, color: Colors.white,
                                padding: EdgeInsets.all(6 * 2),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    WidgetT.text('상품명', size: 24, bold: true),
                                    RichText(
                                      text: TextSpan(
                                          children: [
                                            TextSpan(
                                                text: '${ StyleT.krwInt(1012390) }',
                                                style: TextStyle(color: Colors.grey,
                                                    fontSize: 24, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.w900)),
                                            TextSpan(
                                                text: '원  ',
                                                style: TextStyle(color: Colors.grey,
                                                    fontSize: 24, fontWeight: FontWeight.w900)),
                                            TextSpan(
                                                text: '${ StyleT.krwInt(77751) }원 할인 ',
                                                style: TextStyle(color: Colors.black.withOpacity(0.7),
                                                    fontSize: 24, fontWeight: FontWeight.w900)),

                                          ]),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        WidgetT.text(StyleT.krwInt(101230) + '원', size: 54, bold: true),
                                        InkWell(
                                          onTap: () async {
                                            WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');

                                            var url = Uri.base.toString() + 'shopping/aaaa';
                                            print(url);
                                            await launchUrl( Uri.parse(url),
                                              webOnlyWindowName: true ? '_blank' : '_self',
                                            );
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(6 * 3),
                                            color: Colors.grey.withOpacity(0.35),
                                            child: WidgetT.text('구매하기', size: 24, bold: true),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                )
                            )
                          ],
                        ),
                      )
                  ],
                ),
              ),
              SizedBox(height: 6 * 8,),
              Container(
                height: 256,
                width:  double.maxFinite,
                alignment: Alignment.center,
                color: Color(0xFF1855a5).withOpacity(0.7),
                //color: Color(0xFF009fdf).withOpacity(0.7),
                child: Text(
                  'ABOUT US | AGREEMENT | PRIVACY POLICY | GUIDE'
                      '\n\nCOMPANY : 에버스 | OWNER : 이재구| 사업자등록번호 : 741-87-02231 [사업자정보확인]| 통신판매업신고번호 : -'
                      '\nADDRESS : 강원도 원주시 시청로 160-1, 401호(무실동)| CS CENTER : -| 개인정보관리책임자 : -'
                      '\n\n\nCOPYRIGHT © 에버스. ALL RIGHTS RESERVED.'
                      '\nHOSTING BY Firebase',
                ),
              )
            ],
          )
        ],
      );
    }
    return ListView(
      children: [
        Column(
          children: [
            // 홈페이지 수정부분 - 추후 수정 / 03.16
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                    children: [
                      Expanded(
                          child: Container(
                            height: 900, width: double.maxFinite,
                            child: CachedNetworkImage(imageUrl:'https://raw.githubusercontent.com/PinTrees/evers/main/sever/DSC02914.JPG.jpg', fit: BoxFit.cover),
                          )
                      )
                    ]
                ),
                Positioned(
                  left: 128,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetT.titleT('동결건조로 완성한 신선한 맛', size: 68, bold: true, color: Colors.white),
                      Container(
                        width: 500,
                        child: WidgetT.titleT('오랫동안 연구를 통해 개발한 동결건조 기술을 건강하고 신선한 원재료와 접목시켰습니다.', size: 32, bold: false, color: Colors.white),
                      )
                    ],
                  ),
                )
              ],
            ),

            Container(
              padding: EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 128,),
                  TextT.Lit(text: '에버스가 걸어온 길', size: 48, bold: true, color: StyleT.titleColor),
                  SizedBox(height: 6,),
                  TextT.Lit(text: '에버스는 건강한 식품 개발을 주된 목적사업으로 하여 태어났어요.  에버스는 지난 10년 간의 동결건조 경험을 바탕으로 CDI 방식의 동결건조 시스템 새로 구축하였고,  2018. 3. 18. 법인으로 출발하게 되었어요. 에버스는 그 동안 건강하고  행복한 식품, 스낵 개발 등을 위해 노력해 왔어요. 외주에 의한 동결건조 경험을 기초로 직접 건강한 식품, 스낵의 맛을 탐구하고 찾아내기 위해 노력하였어요.'
                      '\n지난 2년 동안  ‘세상이 없던 맛’ 시리즈 제품을 개발하였고, 브랜드 ‘나는 먹꾼’을 런칭하는 등 많은 변화가 있었죠. 우리의 방식으로 개발한 제품이 나왔을 때 소비자들은 ‘이럿 맛은 처음’이라는 환호성을 질렀어요.'
                      '\n에버스는 자꾸만 손이 가는 맛을 개발하기 위하여 수많은 테스트를 진행했어요. 맛있지만 건강한 제품을 만들겠다는 다짐으로 한 걸음 한 걸음 내디딘 결과, 기존 시장에서는 맛볼 수 없던 특별한 제품을 생산하게 되었어요.'
                      '\n앞으로 고객들의 기대에 부응하기 위해의 영양가 높고 맛과 향을 유지하는 신제품을 개발하기 위해 최선을 다하는 에버스가 되겠습니다.', size: 18),
                  SizedBox(height: 128,),
                ],
              ),
            ),

            Container(
              height: 640,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for(int i = 0; i < 3; i++)
                    Container(
                      height: 640, width: 640,
                      child: Column(
                        children: [
                          Container(height: 460, width: 640, color: Colors.grey.withOpacity(0.35), alignment: Alignment.center,
                            child: WidgetT.text('상품 이미지', bold: true),),
                          Container(height: 180, width: 640, color: Colors.white,
                              padding: EdgeInsets.all(6 * 2),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  WidgetT.text('상품명', size: 24, bold: true),
                                  RichText(
                                    text: TextSpan(
                                        children: [
                                          TextSpan(
                                              text: '${ StyleT.krwInt(1012390) }',
                                              style: TextStyle(color: Colors.grey,
                                                  fontSize: 24, decoration: TextDecoration.lineThrough, fontWeight: FontWeight.w900)),
                                          TextSpan(
                                              text: '원  ',
                                              style: TextStyle(color: Colors.grey,
                                                  fontSize: 24, fontWeight: FontWeight.w900)),
                                          TextSpan(
                                              text: '${ StyleT.krwInt(77751) }원 할인 ',
                                              style: TextStyle(color: Colors.black.withOpacity(0.7),
                                                  fontSize: 24, fontWeight: FontWeight.w900)),

                                        ]),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      WidgetT.text(StyleT.krwInt(101230) + '원', size: 54, bold: true),
                                      InkWell(
                                        onTap: () async {
                                          WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');

                                          var url = Uri.base.toString() + 'shopping/aaaa';
                                          print(url);
                                          await launchUrl( Uri.parse(url),
                                            webOnlyWindowName: true ? '_blank' : '_self',
                                          );
                                        },
                                        child: Container(
                                          padding: EdgeInsets.all(6 * 3),
                                          color: Colors.grey.withOpacity(0.35),
                                          child: WidgetT.text('구매하기', size: 24, bold: true),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                          )
                        ],
                      ),
                    )
                ],
              ),
            ),
            SizedBox(height: 6 * 8,),
            Container(
              height: 256,
              width:  double.maxFinite,
              alignment: Alignment.center,
              color: Color(0xFF1855a5).withOpacity(0.7),
              //color: Color(0xFF009fdf).withOpacity(0.7),
              child: Text(
                'ABOUT US | AGREEMENT | PRIVACY POLICY | GUIDE'
                    '\n\nCOMPANY : 에버스 | OWNER : 이재구| 사업자등록번호 : 741-87-02231 [사업자정보확인]| 통신판매업신고번호 : -'
                    '\nADDRESS : 강원도 원주시 시청로 160-1, 401호(무실동)| CS CENTER : -| 개인정보관리책임자 : -'
                    '\n\n\nCOPYRIGHT © 에버스. ALL RIGHTS RESERVED.'
                    '\nHOSTING BY Firebase',
              ),
            )
          ],
        )
      ],
    );
  }



  Widget buildSubMenu() {
    List<Widget> menus = [];

    for(var m in HomeMainMenu.values) {
      if(m.subMenus.isEmpty) continue;

      List<Widget> subMenus = [];
      for(var s in m.subMenus) {
        subMenus.add(ButtonT.Text(
          textSize: 14, bold: true, textColor: StyleT.textColor.withOpacity(0.5),
          text: s.displayName, /*icon: s.icon,*/
          color: Colors.transparent,
          onTap: () {
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
              onPressed: () { },
              style: StyleT.buttonStyleNone(elevation: 0, color: Colors.transparent,),
              child: Container(height: 64, child: Image(image: AssetImage('assets/icon_hor.png') ),)),
          Expanded(child: SizedBox()),
          ListBoxT.Rows(  spacing: 6 * 8, children: mainWidgets ),
          Expanded(child: SizedBox()),
          SizedBox(width: 128,),
          ButtonT.Icon(
              icon: Icons.search,
              onTap: () {

              }
          ),
        ],
      ),
    );
  }

  bool isMouseOver = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Expanded(child: main()),
          Positioned(
            top: 0, left: 0, right: 0,
            child: MouseRegion(
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
            ),
          ),
        ],
      ),
    );
  }
}
