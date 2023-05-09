import 'package:flutter/material.dart';

import 'MdiController.dart';

class MdiManager extends StatefulWidget {

  final MdiController mdiController;

  const MdiManager({super.key,  required this.mdiController});

  @override
  _MdiManagerState createState() => _MdiManagerState();
}

class _MdiManagerState extends State<MdiManager> {

  @override
  Widget build(BuildContext context) {
    return Stack(
        children: widget.mdiController.windows.map((e){
          return Positioned(
            left: e.x,
            top: e.y,
            child: e,
            key: e.key,
          );
        }).toList()
    );
  }
}