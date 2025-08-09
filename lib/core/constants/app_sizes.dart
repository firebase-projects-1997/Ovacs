import 'package:flutter/material.dart'
    show EdgeInsets, BuildContext, MediaQuery;
import 'package:provider/provider.dart';

import '../../common/providers/workspace_provider.dart';

class AppSizes {
  static EdgeInsets defaultPadding(BuildContext context) {
    final workspaceProvider = Provider.of<WorkspaceProvider>(
      context,
      listen: false,
    );
    return EdgeInsets.only(
      left: 20,
      top: workspaceProvider.isPersonalMode
          ? MediaQuery.paddingOf(context).top + 20
          : 20,
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
