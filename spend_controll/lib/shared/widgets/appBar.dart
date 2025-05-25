library stara_widgets;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spend_controll/shared/widgets/colors_app.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String? pageTitle;
  final bool showReturn;
  final bool showSecondIcon;
  final bool showThirdIcon;
  final bool customLeading;
  final String? secondIcon;
  final String? thirdIcon;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final VoidCallback? secondIconFunction;
  final VoidCallback? thirdIconFunction;
  final VoidCallback? customLeadingFunction;
  final double? fontSize;

  const AppBarWidget(
      {super.key,
      this.pageTitle,
      this.showReturn = true,
      this.showSecondIcon = false,
      this.showThirdIcon = false,
      this.secondIcon,
      this.thirdIcon,
      this.bottom,
      this.secondIconFunction,
      this.thirdIconFunction,
      this.customLeading = false,
      this.customLeadingFunction,
      this.actions,
      this.fontSize});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      centerTitle: true,
      leading: showReturn
          ? IconButton(
              splashColor: Colors.transparent,
              icon: SvgPicture.asset(
                'assets/icons/ic_back.svg',
                height: 14,
                colorFilter: ColorFilter.mode(
                    AppColors.of(context).foreground1st, BlendMode.srcIn),
              ),
              onPressed: customLeading
                  ? () => customLeadingFunction!()
                  : () => Navigator.of(context).pop(),
            )
          : Container(),
      title: pageTitle != null
          ? Text(
              pageTitle!,
              style: TextStyle(
                  fontSize: fontSize ?? 13,
                  fontFamily: 'Montserrat',
                  color: isDark
                      ? const Color(0XFFFFFFFF)
                      : const Color(0XFF313131)),
            )
          : null,
      elevation: 0,
      actions: actions != null && actions!.isNotEmpty
          ? actions!
          : [
              if (showSecondIcon)
                IconButton(
                    splashColor: Colors.transparent,
                    icon: SvgPicture.asset(
                      '$secondIcon',
                      height: 24,
                      colorFilter: ColorFilter.mode(
                          isDark
                              ? const Color(0XFFFFFFFF)
                              : const Color(0xFF313131),
                          BlendMode.srcIn),
                    ),
                    onPressed: () => secondIconFunction!()),
              if (showThirdIcon)
                IconButton(
                    splashColor: Colors.transparent,
                    icon: SvgPicture.asset(
                      '$thirdIcon',
                      height: 24,
                      colorFilter: ColorFilter.mode(
                          isDark
                              ? const Color(0XFFFFFFFF)
                              : const Color(0xFF313131),
                          BlendMode.srcIn),
                    ),
                    onPressed: () => thirdIconFunction!())
            ],
      bottom: bottom,
    );
  }
}
