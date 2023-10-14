import 'dart:math' as math;

import 'package:flexible_sheet/snap_configuration/snap_configuration.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

part 'custom_draggable_extent.dart';
part 'custom_scroll_controller.dart';
part 'custom_scroll_position.dart';
part 'custom_scrollable_controller.dart';
part 'custom_snap_simulation.dart';

typedef ScrollableWidgetBuilder = Widget Function(
  BuildContext context,
  ScrollController scrollController,
);

class CustomDraggableScrollableSheet extends StatefulWidget {
  const CustomDraggableScrollableSheet({
    super.key,
    this.initialChildSize,
    this.onScrollChanged,
    required this.snapConfiguration,
    this.snapAnimationDuration,
    this.controller,
    required this.builder,
  }) : assert(snapAnimationDuration == null || snapAnimationDuration > Duration.zero);

  final double? initialChildSize;

  final void Function(ScrollController scrollController)? onScrollChanged;

  final PreparedSnapConfiguration snapConfiguration;

  final Duration? snapAnimationDuration;

  final CustomDraggableScrollableController? controller;

  final ScrollableWidgetBuilder builder;

  @override
  State<CustomDraggableScrollableSheet> createState() => _CustomDraggableScrollableSheetState();
}

class _CustomDraggableScrollableSheetState extends State<CustomDraggableScrollableSheet> {
  late _CustomDraggableScrollableSheetScrollController _scrollController;
  late _DraggableSheetExtent _extent;

  @override
  void initState() {
    super.initState();
    _extent = _DraggableSheetExtent(
      context: context,
      snapConfiguration: widget.snapConfiguration,
      snapAnimationDuration: widget.snapAnimationDuration,
      initialSize: widget.initialChildSize,
    );
    _scrollController = _CustomDraggableScrollableSheetScrollController(extent: _extent);
    widget.onScrollChanged?.call(_scrollController);
    widget.controller?._attach(_scrollController);
  }

  @override
  void didUpdateWidget(covariant CustomDraggableScrollableSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._detach();
      widget.onScrollChanged?.call(_scrollController);
      widget.controller?._attach(_scrollController);
    }
    _replaceExtent(oldWidget);
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<double>(
        valueListenable: _extent._currentSize,
        builder: (context, currentSize, child) {
          _extent.availablePixels = MediaQuery.sizeOf(context).height;
          return FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: currentSize,
            child: child,
          );
        },
        child: widget.builder(context, _scrollController),
      );

  @override
  void dispose() {
    widget.controller?._detach(disposeExtent: true);
    _scrollController.dispose();
    super.dispose();
  }

  void _replaceExtent(covariant CustomDraggableScrollableSheet oldWidget) {
    final previousExtent = _extent;
    _extent = previousExtent.copyWith(
      snapConfiguration: widget.snapConfiguration,
      snapAnimationDuration: widget.snapAnimationDuration,
      initialSize: widget.initialChildSize,
    );

    _scrollController.extent = _extent;

    widget.controller?._onExtentReplaced(previousExtent);
    previousExtent.dispose();
  }
}
