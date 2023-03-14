import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:collection/collection.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:internet_file/internet_file.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:pdf_render/pdf_render_widgets.dart';
import 'package:printing/printing.dart';
import 'package:quick_notify/quick_notify.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

import '../helper/interfaceUI.dart';
import '../helper/style.dart';
import '../ui/dl.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as en;

class ENAES {
  static String fUrlAES(String url) {
    final key=en.Key.fromUtf8('dTk2jQ2A1d5TPkp7');
    final iv=en.IV.fromLength(16);
    final encrypter =en.Encrypter(en.AES(key));
    var ens = encrypter.encrypt(url,iv: iv).base64;
    ens = ens.replaceAll('/', '&&::');
    return ens;
  }
}