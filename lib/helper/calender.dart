

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CalenderManager {
  static dynamic selectDate(BuildContext context, DateTime? startAt) async {
    var selectedDate = await showDatePicker(
      context: context,
      initialDate: startAt ?? DateTime.now(), // 초깃값
      firstDate: DateTime(2018), // 시작일
      lastDate: DateTime(2030), // 마지막일
    );

    return selectedDate;
  }
}