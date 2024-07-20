import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldPin extends StatelessWidget {
  final Function(String) onChange;
  final double defaultBoxSize;
  final double selectedBoxSize;
  final BoxDecoration? defaultDecoration;
  final int codeLength;
  final TextStyle? textStyle;
  final double margin;
  final BoxDecoration? selectedDecoration;
  final bool autoFocus;
  final MainAxisAlignment alignment;
  final TextEditingController textController;

  TextFieldPin({
    Key? key,
    required this.onChange,
    required this.defaultBoxSize,
    defaultDecoration,
    selectedBoxSize,
    this.codeLength = 4,
    this.textStyle,
    this.margin = 16.0,
    this.selectedDecoration,
    this.autoFocus = true,
    this.alignment = MainAxisAlignment.center,
    textController,
  })  : textController = textController ?? TextEditingController(),
        selectedBoxSize = selectedBoxSize ?? defaultBoxSize,
        defaultDecoration = defaultDecoration ??
            BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black),
              ),
            ),
        super(key: key);

  List<Widget> getField() {
    final List<Widget> result = <Widget>[];
    for (int i = 1; i <= codeLength; i++) {
      result.add(Padding(
        padding: EdgeInsets.only(
          left: i == 1 ? 0 : margin,
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: <Widget>[
            textController.text.length <= i - 1
                ? Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: defaultBoxSize,
                      width: defaultBoxSize,
                      decoration: defaultDecoration,
                    ),
                  )
                : SizedBox.shrink(),
            textController.text.length >= i
                ? Container(
                    decoration: defaultDecoration,
                    width: selectedBoxSize,
                    height: selectedBoxSize,
                    child: Center(
                      child: Text(
                        textController.text[i - 1],
                        style: textStyle,
                      ),
                    ),
                  )
                : SizedBox.shrink(),
          ],
        ),
      ));
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          height: defaultBoxSize >= selectedBoxSize
              ? defaultBoxSize
              : selectedBoxSize,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: getField(),
          ),
        ),
        defaultTextField(),
      ],
    );
  }

  Widget defaultTextField() {
    return Opacity(
      opacity: 0,
      child: TextField(
        maxLength: codeLength,
        showCursor: false,
        enableSuggestions: false,
        autocorrect: false,
        autofocus: autoFocus,
        enableIMEPersonalizedLearning: false,
        enableInteractiveSelection: false,
        style: const TextStyle(color: Colors.transparent),
        decoration: const InputDecoration(
          fillColor: Colors.transparent,
          counterStyle: TextStyle(color: Colors.transparent),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          filled: true,
          counterText: "",
        ),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly
        ],
        keyboardType: TextInputType.phone,
        controller: textController,
        onChanged: onChange,
      ),
    );
  }
}
