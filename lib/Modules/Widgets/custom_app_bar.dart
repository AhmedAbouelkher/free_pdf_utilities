import 'package:flutter/material.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/app_theme.dart';
import 'package:free_pdf_utilities/Modules/Common/Utils/constants.dart';

class CAppBar extends StatelessWidget with PreferredSizeWidget {
  final List<Widget>? actions;
  final List<Widget>? leading;
  final String? title;
  final bool? hideAppName;
  const CAppBar({
    Key? key,
    this.actions,
    this.leading,
    this.title,
    this.hideAppName = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                centerTitle: true,
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!hideAppName!)
                      Text(
                        kAppName,
                        style: TextStyle(
                          fontSize: 10,
                          color: themed(context, dark: Colors.white, light: Colors.black),
                        ),
                      ),
                    Text(
                      title ?? "",
                      style: TextStyle(
                        fontSize: 15,
                        color: themed(context, dark: Colors.white, light: Colors.black),
                      ),
                    ),
                  ],
                ),
                actions: actions,
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: leading ??
                      [
                        IconButton(
                          iconSize: 15,
                          icon: BackButtonIcon(),
                          onPressed: () => Navigator.maybePop(context),
                        )
                      ],
                ),
              ),
            ),
          ),
          Divider(height: 1),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 15.0);
}
