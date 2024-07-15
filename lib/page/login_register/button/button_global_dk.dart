import 'package:app_doc_sach/color/mycolor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../service/auth_service.dart';

class ButtonGlobal_DK extends StatefulWidget {
  //định nghĩa constructor cho widget
  //key dùng để xác định widget này duy nhất trong widget
  const ButtonGlobal_DK({super.key, required this.text, required this.onPressed});

  final String text;
  final VoidCallback onPressed;

  @override
  State<ButtonGlobal_DK> createState() => _ButtonGlobal_DKState();
}

class _ButtonGlobal_DKState extends State<ButtonGlobal_DK> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      child: Container(
        alignment: Alignment.center,
        height: 55,
        decoration: BoxDecoration(
          color: MyColor.primaryColor,
          borderRadius: BorderRadius.circular(6),
          boxShadow: [ BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
          )
          ],
        ),
        child: Text(widget.text,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 18),),
      ),
    );

  }
}