

import 'package:encrypt/encrypt.dart';
import 'package:evers/class/system.dart';

import '../../helper/aes.dart';

class XXX {
  static var acsKey = "a";
  static var databaseAdminUserUID = "YaYFJ4xAoYfjnw1aVjpbiscZwzc2";


  static bool init() {
    acsKey = SystemT.generateRandomString(16);
    databaseAdminUserUID = ENAESX.databaseAES("YaYFJ4xAoYfjnw1aVjpbiscZwzc2", acsKey);
    return true;
  }
}