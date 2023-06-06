import 'package:evers/class/database/article.dart';
import 'package:evers/class/system/state.dart';
import 'package:evers/class/widget/button.dart';
import 'package:evers/class/widget/messege.dart';
import 'package:evers/class/widget/text.dart';
import 'package:evers/helper/dialog.dart';
import 'package:evers/helper/function.dart';
import 'package:evers/page/view/home/view_article.dart';
import 'package:evers/page/window/window_article_create.dart';
import 'package:flutter/material.dart';
import '../../../helper/style.dart';




class ArticleTable extends StatelessWidget {

  Article article;

  ArticleTable({ required this.article});

  Widget build(context) {
    return Container(
      height: 28,
      decoration: StyleT.inkStyleNone(
        round: 8,
        color: Colors.grey.withOpacity(0.15),
      ),
      child: Row(
        children: [
          TextT.Lit(text: article.title, expand: true,),
          ButtonT.Icont(
            icon: Icons.edit,
            onTap: () {
              UIState.OpenNewWindow(context, WindowArticleCreate(article: article, board: article.board, refresh: FunT.setRefreshMain));
            }
          ),
          ButtonT.Icont(
              icon: Icons.delete,
              onTap: () async {
                var rst = await DialogT.showAlertDl(context, text: "해당 게시글을 삭제하시겠습니까?");
                if(rst) {
                  await article.delete();
                  Messege.show(context, "삭제됨");
                  return;
                }
                else {
                  Messege.show(context, "취소됨");
                }
              }
          ),
        ],
      ),
    );
  }
}

