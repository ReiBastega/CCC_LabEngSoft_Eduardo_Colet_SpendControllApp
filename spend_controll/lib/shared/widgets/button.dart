library stara_widgets;

import 'package:flutter/material.dart';
import 'package:spend_controll/shared/widgets/colors_app.dart';

enum Edges { zero, appDefault, custom }

class Button extends StatelessWidget {
  final String? text;
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback onPressed;
  final Edges? paddingType;
  final bool? loading;
  final bool? isDisabled;
  final Color? color;
  final double? height;
  final double? fontSize;

  const Button(
      {super.key,
      required this.onPressed,
      this.text,
      this.child,
      this.padding,
      this.paddingType,
      this.loading,
      this.isDisabled = false,
      this.color,
      this.height,
      this.fontSize});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    if (child == null && text == null) {
      throw Exception(
          "Text (String text) or Child (Widget) are required on a Button");
    }
    if (padding == null && paddingType == Edges.custom) {
      throw Exception(
          "If you set paddingType to custom, you must set the padding value");
    }
    if (padding != null &&
        (paddingType == Edges.appDefault || paddingType == Edges.zero)) {
      throw Exception(
          "The appDefault paddingType, and zero paddingType, has its own values preseted, so you may not set the padding value by yourself");
    }
    EdgeInsetsGeometry buttonPadding;
    if (paddingType == Edges.zero || (paddingType == null && padding == null)) {
      buttonPadding = EdgeInsets.zero;
    } else if (paddingType == Edges.appDefault) {
      buttonPadding = const EdgeInsets.only(left: 16, right: 16, bottom: 18);
    } else {
      buttonPadding = padding!;
    }

    return Padding(
      padding: buttonPadding,
      child: SizedBox(
        width: screenSize.width,
        height: height ?? 48,
        child: Opacity(
          opacity: isDisabled! ? .3 : 1,
          child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize ?? 15,
                      color: const Color(0XFFFFFFFF),
                      fontFamily: 'Montserrat'),
                  backgroundColor: color ?? AppColors.of(context).primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  splashFactory: NoSplash.splashFactory),
              onPressed: isDisabled! || loading == true ? () {} : onPressed,
              child: loading == true
                  ? const SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : child ??
                      Text(
                        text!,
                        style: const TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontFamily: 'Montserrat',
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                      )),
        ),
      ),
    );
  }
}
