import 'package:flutter/material.dart';

class KeyboardDismissWrapper extends StatefulWidget {
  final Widget child;

  const KeyboardDismissWrapper({Key? key, required this.child}) : super(key: key);

  @override
  _KeyboardDismissWrapperState createState() => _KeyboardDismissWrapperState();
}

class _KeyboardDismissWrapperState extends State<KeyboardDismissWrapper> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: widget.child,
    );
  }
}