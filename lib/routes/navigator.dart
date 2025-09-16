import 'package:device/routes/application.dart';
import 'package:fluro/fluro.dart';
import 'package:flutter/cupertino.dart';


class NavigatorUtils{
  static push(BuildContext context ,String path,{bool replace=false, bool clearStack=false}){
    Application.router?.navigateTo(context, path,
    replace: replace,
    clearStack: clearStack,
    transition: TransitionType.native);
  }

  static pushResult(BuildContext context,String path,Function(Object) function,
  {bool replace=false,bool clearStack =false}){
    Application.router?.navigateTo(context, path,
        replace: replace,
        clearStack: clearStack,
        transition: TransitionType.native).then((value) {
          if(value==null){
            return;
          }
          function(value);
    }).catchError((error){
      print("===============================> $error");
    });
  }

  static void goBack(BuildContext context)=>Navigator.pop(context);

  static void goBackWithParams(BuildContext context,result)=>Navigator.pop(context,result);
}