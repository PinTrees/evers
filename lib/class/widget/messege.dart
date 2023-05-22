

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Messege {
  static dynamic toReturn(BuildContext context, String text, bool ret) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          //width: 380,
          //elevation: 18,
          //behavior: SnackBarBehavior.floating,
          //backgroundColor: Colors.redAccent,
          content: Text(text),
          duration: Duration(seconds: 3), //올라와있는 시간
          action: SnackBarAction(
            label: 'Undo',
            onPressed: (){},
          ),
        )
    );

    return ret;
  }
}