import 'package:flutter/material.dart';

part 'size_configuration.dart';

class SnapConfiguration {
  final ValueChanged<BuildContext>? onSwipeDown;
  final ValueChanged<BuildContext>? onSwipeUp;

  /// Reacts to snap changing
  final ValueChanged<(SizeConfiguration previous, SizeConfiguration next)>? onSizeChanged;

  final bool? isScrollable;

  /// List of possible snap configurations for widget
  final List<SizeConfiguration> snapSizes;

  final int _initialIndex;
  SizeConfiguration get initialPosition => snapSizes[_initialIndex];

  bool get containsWidgetSize => snapSizes.any(($) => $.isWidgetSize);

  PreparedSnapConfiguration prepareConfiguration(
    double maxHeight, {
    double widgetSize = 0,
    double scrollExtent = double.infinity,
  }) {
    final preparedSnapSizes = snapSizes
        .map(
          ($) => $.prepareSize(
            maxHeight: maxHeight,
            widgetSize: widgetSize,
          ),
        )
        .toList()
      ..sort((a, b) => a.rawSizingValue.compareTo(b.rawSizingValue));

    return PreparedSnapConfiguration._(
      isScrollable: (isScrollable ?? false) && scrollExtent > preparedSnapSizes.last.rawSizingValue,
      initialSize: initialPosition.prepareSize(maxHeight: maxHeight, widgetSize: widgetSize),
      onSwipeDown: onSwipeDown,
      onSwipeUp: onSwipeUp,
      onSizeChanged: (snaps) => onSizeChanged?.call(
        (snaps.$1.parent, snaps.$2.parent),
      ),
      snapSizes: preparedSnapSizes,
    );
  }

  const SnapConfiguration({
    required this.snapSizes,
    this.onSwipeDown,
    this.isScrollable = false,
    this.onSwipeUp,
    this.onSizeChanged,
    int initialIndex = 0,
  })  : assert(snapSizes.length > 0, 'SnapPositions should contain at least 1 position'),
        assert(
          initialIndex >= 0 && initialIndex < snapSizes.length,
          'Initial index ($initialIndex) must be included in the constraints of the snapPositions',
        ),
        _initialIndex = initialIndex;
}

class PreparedSnapConfiguration {
  final ValueChanged<BuildContext>? onSwipeDown;
  final ValueChanged<BuildContext>? onSwipeUp;

  /// Reacts to snap changing
  final ValueChanged<(PreparedSizeConfiguration previous, PreparedSizeConfiguration next)>? onSizeChanged;

  /// List of possible snap configurations for widget
  final List<PreparedSizeConfiguration> snapSizes;

  final bool isScrollable;

  final PreparedSizeConfiguration initialSize;

  List<double> get mapToPixels => snapSizes.map((e) => e.rawSizingValue).toList()..sort();
  List<double> get mapToFractional => snapSizes.map((e) => e.rawFractionalValue).toList()..sort();

  const PreparedSnapConfiguration._({
    required this.snapSizes,
    required this.initialSize,
    this.onSwipeDown,
    this.onSwipeUp,
    this.isScrollable = false,
    this.onSizeChanged,
  });

  factory PreparedSnapConfiguration.empty() => PreparedSnapConfiguration._(
        initialSize: PreparedSizeConfiguration.empty(),
        snapSizes: [PreparedSizeConfiguration.empty()],
      );
}
