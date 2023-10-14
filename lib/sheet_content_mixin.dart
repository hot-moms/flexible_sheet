import 'package:flexible_sheet/snap_configuration/snap_configuration.dart';
import 'package:flutter/material.dart';

mixin StateSheetContentMixin on StatelessWidget {
  @override
  Key get key;

  SnapConfiguration get snapConfiguration;
}
