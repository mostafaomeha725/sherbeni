import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final Color? color;
  final Color? bgColor;
  final AlignmentDirectional alignment;
  final String? fontFamily;
  final FontWeight? fontWeight;
  final int? maxLines;
  final TextAlign? textAlign;
  final FontStyle? fontStyle;
  final TextOverflow? overflow;
  final TextDirection? textDirection;
  final bool isArabicText;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? textHeight;
  final TextStyle? style;
  final EdgeInsetsGeometry? textPadding;
  final EdgeInsetsGeometry? textMargin;
  final TextDecoration? decoration;

  const AppText(
    this.text, {
    super.key,
    this.fontSize,
    this.color,
    this.alignment = AlignmentDirectional.topStart,
    this.isArabicText = false,
    this.bgColor,
    this.fontFamily,
    this.fontWeight,
    this.maxLines,
    this.textAlign,
    this.fontStyle,
    this.overflow,
    this.textDirection,
    this.letterSpacing,
    this.wordSpacing,
    this.textHeight,
    this.style,
    this.textMargin,
    this.textPadding,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      color: bgColor,
      padding: textPadding,
      margin: textMargin,
      child: Text(
        text,
        key: key,
        maxLines: maxLines,
        overflow: overflow ?? TextOverflow.ellipsis,
        textAlign: textAlign,
        textDirection: textDirection,
        style: style,
      ),
    );
  }
}
