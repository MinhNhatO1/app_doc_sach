import 'package:app_doc_sach/color/mycolor.dart';
import 'package:flutter/material.dart';

class TextFormGlobal extends StatefulWidget {
  const TextFormGlobal({
    Key? key,
    required this.controller,
    required this.text,
    required this.textInputType,
    required this.obscure,
    required this.icon,
    this.showPasswordToggle = false,
    this.showClearButton = false,
    this.suffix, // Thêm thuộc tính cho chức năng xóa văn bản
    this.suffixIcon,
    this.focusNode, // Thêm tham số này
  }) : super(key: key);

  final TextEditingController controller;
  final String text;
  final TextInputType textInputType;
  final bool obscure;
  final Icon icon;
  final bool showPasswordToggle;
  final bool showClearButton; // Chức năng xóa văn bản
  final Widget? suffix;
  final Widget? suffixIcon;
  final FocusNode? focusNode; // Thêm thuộc tính này
  @override
  _TextFormGlobalState createState() => _TextFormGlobalState();
}

class _TextFormGlobalState extends State<TextFormGlobal> {
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.only(top: 3, left: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 7,
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, right: 20),
            child: Icon(
              widget.icon.icon,
              color: Colors.black,
            ),
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextFormField(
                  controller: widget.controller,
                  focusNode: widget.focusNode, // Thêm dòng này
                  keyboardType: widget.textInputType,
                  obscureText: widget.obscure ? _isObscure : false,
                  decoration: InputDecoration(
                    hintText: widget.text,
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade600,
                      height: 1,
                      fontSize: 16,
                    ),
                    contentPadding: const EdgeInsets.symmetric( vertical:  20),
                    suffix: widget.suffix,
                    suffixIcon: widget.suffixIcon
                  ),
                  style: const TextStyle(fontSize: 16,color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

