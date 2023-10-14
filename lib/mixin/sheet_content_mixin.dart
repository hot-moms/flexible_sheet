import 'package:flexible_sheet/snap_configuration/snap_configuration.dart';
import 'package:flutter/material.dart';

/// Base mixin for any widget that will contain entire body
/// of flexible sheet
mixin SheetContentMixin on Widget {
  /// [key] must be provided because internal mechanism of comparing widgets (for recalculating)
  /// relies on it
  @override
  Key get key;

  /// [SnapConfiguration] for current widget
  SnapConfiguration get snapConfiguration;
}
