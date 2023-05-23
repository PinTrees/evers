



import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../helper/interfaceUI.dart';
import 'button.dart';

class PageWidget {
  static Widget Main({
    List<Widget>? children,
    Widget? topWidget,
    Widget? infoWidget,
    Widget? titleWidget,
    Function? onPageDocument,
    BuildContext? context,
  }) {
    var w = Column(
      children: [
        Stack(
          children: [
            topWidget ?? SizedBox(),
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
        Expanded(
          child: Row(
            children: [
              infoWidget ?? SizedBox(),
              Expanded(
                child: Column(
                  children: [
                    titleWidget ?? SizedBox(),
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
}