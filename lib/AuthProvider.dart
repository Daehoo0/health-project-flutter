import 'package:flutter/material.dart';

class DataLogin extends ChangeNotifier {
  String uiduser;

  DataLogin({
    this.uiduser = "",
  });
  void setuserlogin(String idne){
    this.uiduser = idne;
    notifyListeners();
  }
}