import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:spend_controll/shared/widgets/colors_app.dart';

class FormInputAndTitle extends StatefulWidget {
  final String title;
  final String? secondTitle;
  final String hintText;
  final double? fontSize;
  final String? Function(String?) validator;
  final void Function(String?) onSaved;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final void Function()? onPressedIconRight;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final TextEditingController? controller;
  final List<TextInputFormatter> maskFormatter;
  final String? iconPath;
  final String? iconRightPath;
  final bool hasUnderline;
  final TextCapitalization textCapitalization;
  final FocusNode? focus;
  final bool obscureText;

  FormInputAndTitle({
    super.key,
    required this.title,
    required this.hintText,
    required this.validator,
    required this.onSaved,
    required this.maskFormatter,
    this.onTap,
    this.iconPath,
    this.iconRightPath,
    this.onPressedIconRight,
    this.keyboardType,
    this.textInputAction = TextInputAction.done,
    this.controller,
    this.focus,
    this.onChanged,
    this.hasUnderline = false,
    this.secondTitle,
    this.textCapitalization = TextCapitalization.none,
    this.fontSize,
    this.obscureText = false,
  }) {
    {
      assert((iconRightPath == null && onPressedIconRight == null) ||
          (iconRightPath != null && onPressedIconRight != null));
    }
  }

  @override
  State<FormInputAndTitle> createState() => _FormInputAndTitleState();
}

class _FormInputAndTitleState extends State<FormInputAndTitle> {
  bool hasFocus = false;
  @override
  void initState() {
    widget.focus?.addListener(_handleFocusChange);
    super.initState();
  }

  void _handleFocusChange() {
    if (widget.focus?.hasFocus != hasFocus) {
      setState(() {
        hasFocus = widget.focus?.hasFocus ?? false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool inputHasFocused = widget.focus?.hasFocus ?? false;
    var brightness = Theme.of(context).brightness;
    bool isDarkMode = brightness == Brightness.dark;
    final focusNode = widget.focus ?? FocusNode();
    final colors = AppColors.of(context);
    return Column(
      children: [
        InkWell(
          focusColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          splashColor: isDarkMode ? Colors.grey[900] : Colors.grey[400],
          onTap: () => focusNode.requestFocus(),
          child: Padding(
            padding: EdgeInsets.only(
                top: 5, bottom: 5, left: widget.iconPath != null ? 18 : 10),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.iconPath != null)
                      Padding(
                        padding: const EdgeInsets.only(right: 18),
                        child: SvgPicture.asset(
                          widget.iconPath!,
                          width: 20,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                              isDarkMode
                                  ? const Color(0XFFFFFFFF)
                                  : const Color(0XFF313131),
                              BlendMode.srcIn),
                        ),
                      ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                    text: widget.title,
                                    style: TextStyle(
                                        color: isDarkMode
                                            ? const Color.fromARGB(
                                                255, 255, 255, 255)
                                            : const Color.fromARGB(
                                                255, 0, 0, 0),
                                        fontSize: widget.fontSize ?? 13,
                                        fontWeight: FontWeight.w500,
                                        fontFamily: 'Montserrat'),
                                    children: <TextSpan>[
                                      TextSpan(
                                          text: widget.secondTitle == null
                                              ? null
                                              : ' '),
                                      TextSpan(
                                          text: widget.secondTitle,
                                          style: TextStyle(
                                              color: const Color.fromARGB(
                                                  255, 158, 157, 157),
                                              fontSize: widget.fontSize ?? 13,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: 'Montserrat')),
                                    ]),
                              ),
                              const SizedBox(height: 9),
                              TextFormField(
                                obscureText: widget.obscureText,
                                onTap: widget.onTap,
                                textCapitalization: widget.textCapitalization,
                                style: TextStyle(
                                    fontSize: widget.fontSize ?? 13,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: 'Montserrat'),
                                focusNode: focusNode,
                                controller: widget.controller,
                                inputFormatters: widget.maskFormatter,
                                textInputAction: widget.textInputAction,
                                decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        fontSize: widget.fontSize ?? 13,
                                        color: AppColors.of(context)
                                            .foreground1stDsbld,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w400),
                                    hintText: widget.hintText,
                                    isDense: false,
                                    isCollapsed: true,
                                    contentPadding: EdgeInsets.zero,
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    errorStyle: const TextStyle(
                                      fontSize: 11,
                                    )),
                                maxLines: 1,
                                cursorColor:
                                    const Color.fromARGB(255, 25, 59, 152),
                                keyboardType:
                                    widget.keyboardType ?? TextInputType.text,
                                validator: widget.validator,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                onSaved: widget.onSaved,
                                onChanged: widget.onChanged,
                                onFieldSubmitted: (value) {
                                  inputHasFocused = false;
                                  switch (widget.textInputAction) {
                                    case TextInputAction.next:
                                      focusNode.nextFocus();
                                      if (widget.iconRightPath != null) {
                                        focusNode.nextFocus();
                                      }
                                      break;
                                    case TextInputAction.previous:
                                      focusNode.previousFocus();
                                      break;
                                    default:
                                      break;
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    widget.iconRightPath != null
                        ? IconButton(
                            alignment: Alignment.centerRight,
                            icon: SvgPicture.asset(
                              widget.iconRightPath!,
                              width: 24,
                              height: 24,
                              colorFilter: ColorFilter.mode(
                                  isDarkMode
                                      ? const Color(0XFFFFFFFF)
                                      : const Color(0xFF313131),
                                  BlendMode.srcIn),
                            ),
                            onPressed: widget.onPressedIconRight,
                          )
                        : Container(),
                  ],
                ),
                if (widget.hasUnderline)
                  Divider(
                    color: colors.separator,
                  )
              ],
            ),
          ),
        ),
        Divider(
          thickness: inputHasFocused ? 1 : 0,
          indent: widget.iconPath == null ? 10 : 15,
          endIndent: 15,
          color: inputHasFocused
              ? const Color.fromARGB(255, 25, 59, 152)
              : Colors.grey,
        ),
      ],
    );
  }
}
