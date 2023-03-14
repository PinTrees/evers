
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

class FadePageRoute<T> extends PageRoute<T> {
  FadePageRoute(this.child, this.duration);
  @override
  Color get barrierColor => Colors.transparent;
  @override
  String? get barrierLabel => null;

  final Widget child;
  final int duration;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return FadeTransition(opacity: animation, child: child,);
  }

  @override
  bool get maintainState => true;
  @override
  Duration get transitionDuration => Duration(milliseconds: duration);
}

