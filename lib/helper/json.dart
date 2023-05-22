

import 'dart:convert';

class JsonManager {
  static dynamic toJsonObject(dynamic target) {
    var jsonString = jsonEncode(target.toJson());
    return jsonDecode(jsonString);
  }
}