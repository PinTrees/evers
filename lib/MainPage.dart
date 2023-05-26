import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/helper/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seo/html/seo_widget.dart';
import 'package:seo_renderer/renderers/image_renderer/image_renderer_web.dart';
import 'package:url_launcher/url_launcher.dart';

import 'helper/interfaceUI.dart';
import 'helper/router.dart';
import 'helper/style.dart';
import 'route/navigator2.dart';

class HomePage extends StatefulWidget{
  const HomePage({super.key,});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

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
    // var user = FirebaseAuth.instance.currentUser;
    // if(user == null) {
    //   context.push('/login/o');
    //   setState(() {});
    // }
  }


  Widget main() {
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
                            child: CachedNetworkImage(imageUrl:'https://raw.githubusercontent.com/PinTrees/evers/main/sever/background.jpg', fit: BoxFit.cover),
                          )
                      )
                    ]
                ),
                Positioned(
                  left: 128,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      WidgetT.titleT('동결건조 전문기업 (주)에버스', size: 88, bold: true, color: Colors.white),
                      WidgetT.titleT('서브 타이틀 문구 입력 자리', size: 32, bold: false, color: Colors.white),
                    ],
                  ),
                )
              ],
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
            SizedBox(height: 6 * 2,),
            InkWell(
              onTap: () {
                WidgetT.showSnackBar(context, text: '기능을 개발중입니다.');
              },
              child: Container(
                padding: EdgeInsets.fromLTRB(18, 12, 18, 12),
                color: Colors.grey.withOpacity(0.35),
                child: WidgetT.text('더 많은 상품 보러가기', size: 14, bold: false),
              ),
            ),
            SizedBox(height: 6 * 2,),


            SizedBox(height: 6 * 4,),
            WidgetT.title('리뷰', bold: true, size: 36),
            SizedBox(height: 6 * 2,),
            Wrap(
              runSpacing: 12, spacing: 12,
              children: [
                for(int i = 0; i < 10; i++)
                  Stack(
                    children: [
                      Container(
                        color: Colors.grey.withOpacity(0.35),
                        height: 280, width: 280,
                      ),
                      Positioned(
                        bottom: 0, left: 0, right: 0,
                        child: Container(
                          padding: EdgeInsets.all(6 * 2),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              WidgetT.text('리뷰 제목', size: 16, bold:  true),
                              WidgetT.text('리뷰 내용 리뷰 내용 리뷰 내용 리뷰 내용 리뷰 내용 리뷰 내용 리뷰 내용', size: 12, bold: false),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
              ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          main(),
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              height: 80,
              child: Container(
                padding: EdgeInsets.fromLTRB(6 * 8, 0, 6 * 8, 6),
                decoration: BoxDecoration(
                  //color: Colors.transparent,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      //const Color(0xFF009fdf).withOpacity(0.7),
                      //const Color(0xFF1855a5).withOpacity(0.7),
                      Colors.black.withOpacity(0.75),
                      Colors.black.withOpacity(0.3),
                      Colors.transparent,
                      //Colors.blue,
                      //Colors.red,
                    ],
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     TextButton(
                        onPressed: () { },
                        style: StyleT.buttonStyleNone(elevation: 0, color: Colors.transparent,),
                        child: Container(height: 48, child: Image(image: AssetImage('assets/icon_txt.png'), color: Colors.white, ),)),
                    Expanded(child: SizedBox()),
                    TextButton(
                        onPressed: () { },
                        style: StyleT.buttonStyleNone(elevation: 0, color: Colors.transparent,),
                        child: Container(alignment: Alignment.center, height: 48, child: WidgetT.title('Menu', size: 18) )),
                    TextButton(
                        onPressed: () { },
                        style: StyleT.buttonStyleNone(elevation: 0, color: Colors.transparent,),
                        child: Container(alignment: Alignment.center, height: 48, child: WidgetT.title('About', size: 18) )),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
