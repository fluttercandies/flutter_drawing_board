import 'package:flutter/material.dart';

/// 编辑文本内容
class EditText extends StatelessWidget {
  const EditText({Key? key, this.defaultText}) : super(key: key);

  final String? defaultText;

  /// 完成编辑
  void _complate(BuildContext? context, String? text) {
    if (text != null && text.trim().isNotEmpty && text != defaultText) {
      Navigator.pop(context!, text);
    } else {
      Navigator.pop(context!);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? _contnet;

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: defaultText,
                onChanged: (String v) => _contnet = v,
                onEditingComplete: () => _complate(context, _contnet),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
