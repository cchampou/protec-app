

import 'package:flutter/material.dart';

class Auth extends ChangeNotifier {
  String? _token;

  void setToken(String? token) {
    _token = token;
    notifyListeners();
  }
}
