



import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../helper/interfaceUI.dart';
import 'button.dart';

class PageWidget {
  static Widget MainPage({
    List<Widget>? children,
    Widget? topWidget,
    Widget? infoWidget,
    Widget? titleWidget,
    Widget? bottomWidget,
    Function? onPageDocument,
    BuildContext? context,
  }) {
    var w = Column(
      children: [
        Expanded(
          child: Row(
            children: [
              infoWidget ?? SizedBox(),
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 6 * 2,),
                    Stack(
                      children: [
                        Row(
                          children: [
                            topWidget ?? SizedBox(),
                            SizedBox(width: 6,),
                          ],
                        ),
                        Positioned(
                          top: 0, bottom: 0,
                          right: 0,
                          child: ButtonT.IconText(
                              icon: Icons.open_in_new_sharp,
                              text: "페이지 문서로 이동",
                              color: Colors.transparent, textColor: Colors.white.withOpacity(0.7),
                              onTap: () async {
                                if(onPageDocument != null) onPageDocument();
                                /*var url = Uri.base.toString().split('/work').first + '/documents/customer';
                    await launchUrl( Uri.parse(url), webOnlyWindowName: true ? '_blank' : '_self',);*/
                              }
                          ),
                        )
                      ],
                    ),
                    SizedBox(height: 6 * 2,),

                    titleWidget ?? const SizedBox(),
                    if(titleWidget != null)
                      WidgetT.dividHorizontal(size: 1.4, color: Colors.grey.withOpacity(0.35)),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if(children != null)
                          Expanded(
                            child: ListView.builder(
                                padding: EdgeInsets.all(12),
                                itemCount: children.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if(index >= children.length) return SizedBox();
                                  return children[index];
                                }
                            ),
                          ),
                        ],
                      ),
                    ),


                    if(titleWidget != null)
                      WidgetT.dividHorizontal(size: 1.4, color: Colors.grey.withOpacity(0.35)),
                    bottomWidget ?? const SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return w;
  }






  static Widget View({
    List<Widget>? children,
    Widget? titleWidget,
    Widget? bottomWidget,
    BuildContext? context,
  }) {
    var w = Container(
      child: Column(
        children: [
          titleWidget ?? const SizedBox(),
          if(titleWidget != null)
            WidgetT.dividHorizontal(size: 1.4, color: Colors.grey.withOpacity(0.35)),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if(children != null)
                  Expanded(
                    child: ListView.builder(
                        padding: EdgeInsets.all(12),
                        itemCount: children.length,
                        itemBuilder: (BuildContext context, int index) {
                          if(index >= children.length) return SizedBox();
                          return children[index];
                        }
                    ),
                  ),
              ],
            ),
          ),

          if(bottomWidget != null)
            WidgetT.dividHorizontal(size: 1.4, color: Colors.grey.withOpacity(0.35)),
          bottomWidget ?? const SizedBox(),
        ],
      ),
    );
    return w;
  }










  static Widget Home({
    List<Widget>? children,
    Widget? bottomWidget,
  }) {
    return ListView(
      children: [
        const SizedBox(height: 68,),
        if(children != null) for(var w in children) w,
        bottomWidget ?? const SizedBox(),
      ],
    );
  }
}