import 'package:flutter/material.dart'
    show EdgeInsets, BuildContext, MediaQuery;

class AppSizes {
  static EdgeInsets defaultPadding(BuildContext context) {
    return EdgeInsets.only(
      left: 20,
      top: MediaQuery.paddingOf(context).top + 20,
      right: 20,
      bottom: MediaQuery.paddingOf(context).bottom + 20,
    );
  }
  static EdgeInsets noAppBarPadding(BuildContext context) {
    return EdgeInsets.only(
      left: 20,
      top: 20,
      right: 20,
      bottom: MediaQuery.paddingOf(context).bottom + 20,
    );
  }
}
