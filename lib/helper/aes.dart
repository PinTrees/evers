import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import '../helper/interfaceUI.dart';
import '../helper/style.dart';
import '../ui/dl.dart';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as en;

class ENAESX {
  static String fUrlAES(String url) {
    final key=en.Key.fromUtf8('dTk2jQ2A1d5TPkp7');
    final iv=en.IV.fromLength(16);
    final encrypter =en.Encrypter(en.AES(key));
    var ens = encrypter.encrypt(url,iv: iv).base64;
    ens = ens.replaceAll('/', '&&::');
    return ens;
  }
}