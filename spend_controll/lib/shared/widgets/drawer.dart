import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DrawerWidget extends StatelessWidget {
  final List<DrawerTile> drawerTiles;

  const DrawerWidget({super.key, required this.drawerTiles});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor:
          isDark ? const Color(0XFF161616) : const Color(0XFFFFFFFF),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 20),
                child: InkWell(
                    splashFactory: NoSplash.splashFactory,
                    customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset(
                      'assets/icons/ic_close_menu.svg',
                      colorFilter: ColorFilter.mode(
                          isDark
                              ? const Color(0XFFFFFFFF)
                              : const Color(0xFF313131),
                          BlendMode.srcIn),
                    )),
              ),
              const SizedBox(height: 76),
              Column(children: drawerTiles),
              const SizedBox(height: 76),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  final Icon icon;
  final Color? iconColor;
  final String title;
  final VoidCallback func;

  const DrawerTile(
      {super.key,
      required this.icon,
      required this.title,
      this.iconColor,
      required this.func});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        ListTile(
          splashColor: Colors.transparent,
          contentPadding: const EdgeInsets.only(left: 18, right: 26),
          horizontalTitleGap: 10,
          title: Text(
            title,
            style: TextStyle(
                color:
                    isDark ? const Color(0XFFFFFFFF) : const Color(0XFF313131)),
          ),
          trailing: SvgPicture.asset('assets/icons/ic_arrow_right_small.svg',
              colorFilter: ColorFilter.mode(
                  isDark ? const Color(0XFFFFFFFF) : const Color(0xFF313131),
                  BlendMode.srcIn)),
          onTap: func,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 56, right: 16),
          child: Divider(
            height: 1,
            color: isDark ? const Color(0XFF4F514F) : const Color(0XFFC4C4C4),
          ),
        )
      ],
    );
  }
}
