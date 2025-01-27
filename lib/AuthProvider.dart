import 'package:flutter/material.dart';

class DataLogin extends ChangeNotifier {
  String uiduser;

  DataLogin({
    this.uiduser = "8gckLYOPL6h50jkJSed5k0sc4qE2",
  });
  void setuserlogin(String idne){
    this.uiduser = idne;
    notifyListeners();
  }
}