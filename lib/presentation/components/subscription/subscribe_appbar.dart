import 'package:flutter/material.dart';

import '../../../constants/colors.dart';
import '../../pages/home_page.dart';

AppBar subAppBar(BuildContext context, String loginMethod){
  return AppBar(
    backgroundColor: Colors.transparent,
    iconTheme: const IconThemeData(color: Colors.white),
    leading: loginMethod.toLowerCase() == "b"
        ? Container()
        : GestureDetector(
      onTap: () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ),
              (route) => true,
        );
      },
      child: Icon(
        Icons.arrow_back_outlined,
        color: Colors.white,
      ),
    ),
  );
}