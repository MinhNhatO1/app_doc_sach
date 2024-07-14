import 'package:app_doc_sach/color/mycolor.dart';
import 'package:flutter/material.dart';

class ButtonGlobal extends StatefulWidget {
  const ButtonGlobal({super.key, required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  State<ButtonGlobal> createState() => _ButtonGlobalState();
}

class _ButtonGlobalState extends State<ButtonGlobal> {
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
