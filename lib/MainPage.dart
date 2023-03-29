import 'package:cached_network_image/cached_network_image.dart';
import 'package:evers/helper/dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:seo/html/seo_widget.dart';
import 'package:seo_renderer/renderers/image_renderer/image_renderer_web.dart';

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
                            height: 1024, width: double.maxFinite,
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
                      WidgetT.titleT('타이틀 문구 입력 자리', size: 88, bold: true, color: Colors.white),
                      WidgetT.titleT('서브 타이틀 문구 입력 자리', size: 32, bold: false, color: Colors.white),
                    ],
                  ),
                )
              ],
            ),
            /*Seo.image(
              src: 'https://raw.githubusercontent.com/PinTrees/evers/main/sever/background.jpg',
              alt: 'Some example image',
              child: Row(
                   children: [
                    Expanded(
                        child: Container(
                          height: 512, width: double.maxFinite,
                          child: CachedNetworkImage(imageUrl:'https://raw.githubusercontent.com/PinTrees/evers/main/sever/background.jpg', fit: BoxFit.cover),
                        )
                    )
                  ]
              ),
            ),*/
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
