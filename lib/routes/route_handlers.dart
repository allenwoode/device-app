import 'package:device/views/login_page.dart';
import 'package:device/views/main_page.dart';
import 'package:device/routes/navigator.dart';
import 'package:device/routes/routes.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

var rootHandler = Handler(
  handlerFunc: (BuildContext? context,Map<String,List<String>> params)=> MainPage()
);

var loginHandler = Handler(
  handlerFunc: (BuildContext? context,Map<String,List<String>> params)=> const LoginPage()
);

