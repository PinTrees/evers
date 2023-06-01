import 'package:evers/class/database/article.dart';
import 'package:evers/class/system/state.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/page/view/home/view_article.dart';
import 'package:flutter/material.dart';
import '../../helper/style.dart';



/// ArticleStyle 클래스는 기사 스타일을 정의하는 데 사용됩니다.
/// 주석 클래스 내부 작성
class ArticleStyle {
  final Color backgroundColor;
  final Color titleColor;
  final Color textColor;

  final double width;
  final double height;

  final double titleSize;
  final double textSize;

  final double dateTextSize;
  final Color dateTextColor;

  final bool expand;

  /// ArticleStyle의 생성자입니다.
  ///
  /// [backgroundColor] 기사의 배경색을 지정합니다. 기본값은 투명(transparent)입니다.
  /// [titleColor] 기사 제목의 색상을 지정합니다. 기본값은 검정(black)입니다.
  /// [textColor] 기사 텍스트의 색상을 지정합니다. 기본값은 검정(black)입니다.
  /// [width] 기사 컨테이너의 너비를 지정합니다. 기본값은 200입니다.
  /// [height] 기사 컨테이너의 높이를 지정합니다. 기본값은 300입니다.
  /// [titleSize] 기사 제목의 글꼴 크기를 지정합니다. 기본값은 18입니다.
  /// [textSize] 기사 텍스트의 글꼴 크기를 지정합니다. 기본값은 14입니다.
  /// [dateTextSize] 기사 날짜 텍스트의 글꼴 크기를 지정합니다. 기본값은 14입니다.
  /// [dateTextColor] 기사 날짜 텍스트의 색상을 지정합니다. 기본값은 회색(grey)입니다.
  /// [expand] 텍스트 필드가 확장되어 가로 공간을 채울지 여부를 지정합니다. 기본값은 false입니다.
  ArticleStyle({
    this.backgroundColor = Colors.transparent,
    this.titleColor = Colors.black,
    this.textColor = Colors.black54,
    this.dateTextColor = Colors.grey,
    this.width = 200,
    this.height = 128,
    this.expand = false,
    this.titleSize = 16,
    this.textSize = 14,
    this.dateTextSize = 14,
  });
}




class ArticleParams {
  Article? article;

  ArticleParams({
    required this.article,
  });
}




/// ArticleWidget 은 기사를 표시하는 위젯입니다.
class ArticleWidget extends StatefulWidget {
  /// ArticleStyle 을 저장하는 변수입니다.
  var style = ArticleStyle();

  /// ArticleParams 를 저장하는 변수입니다.
  var params = ArticleParams(article: null);

  /// ArticleWidget 의 생성자입니다.
  ///
  /// [style] 기사 스타일을 설정하기 위한 매개변수입니다.
  /// [params] 기사 파라미터를 설정하기 위한 매개변수입니다.
  ArticleWidget({required this.style, required this.params});

  @override
  _ArticleParamsState createState() => _ArticleParamsState();
}


/// _ArticleParamsState 는 ArticleWidget 의 상태를 관리하는 클래스입니다.
class _ArticleParamsState extends State<ArticleWidget> {
  @override
  void initState() {
    super.initState();
    print("Initialized");
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 주어진 기사 파라미터와 스타일을 사용하여 메인 위젯을 생성합니다.
  Widget buildMain(ArticleParams params, ArticleStyle style) {
    if (params.article == null) return Container();

    Widget w = InkWell(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (s) => ViewArticle(article: params.article!)));
      },
      child: Container(
        color: style.backgroundColor,
        height: style.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextT.Lit(
              text: params.article!.title,
              size: style.titleSize,
              color: style.titleColor,
              bold: true,
              maxLine: 2,
            ),
            TextT.Lit(
              text: StyleT.dateFormatYYMMDD(params.article!.createAt),
              size: style.dateTextSize,
              color: style.dateTextColor,
              bold: false,
              maxLine: 1,
            ),
            TextT.Lit(
              text: params.article!.desc,
              size: style.textSize,
              color: style.textColor,
              bold: false,
              maxLine: 1,
            ),
          ],
        ),
      ),
    );

    if (style.expand) w = Expanded(child: w);
    return w;
  }

  @override
  Widget build(BuildContext context) {
    return buildMain(widget.params, widget.style);
  }
}
