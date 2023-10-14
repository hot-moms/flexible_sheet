part of 'custom_draggable_sheet.dart';

class CustomDraggableScrollableNotification extends Notification with ViewportNotificationMixin {
  CustomDraggableScrollableNotification({
    required this.extent,
    required this.minExtent,
    required this.maxExtent,
    this.initialExtent,
    required this.context,
  })  : assert(0.0 <= minExtent),
        assert(maxExtent <= 1.0),
        assert(minExtent <= extent),
        assert(extent <= maxExtent);

  final double extent;

  final double minExtent;

  final double maxExtent;

  final double? initialExtent;

  final BuildContext context;

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('minExtent: $minExtent, extent: $extent, maxExtent: $maxExtent, initialExtent: $initialExtent');
  }
}

class _DraggableSheetExtent {
  _DraggableSheetExtent({
    required this.snapConfiguration,
    required this.context,
    this.initialSize,
    this.snapAnimationDuration,
    ValueNotifier<double>? currentSize,
    bool? hasDragged,
    bool? hasChanged,
  })  : assert(0 >= 0),
        _currentSize = currentSize ?? ValueNotifier<double>(initialSize ?? 1),
        availablePixels = double.infinity,
        hasDragged = hasDragged ?? false,
        hasChanged = hasChanged ?? false;

  VoidCallback? _cancelActivity;
  final BuildContext context;

  final PreparedSnapConfiguration snapConfiguration;
  final Duration? snapAnimationDuration;
  final double? initialSize;
  final ValueNotifier<double> _currentSize;
  double availablePixels;

  bool hasDragged;

  bool hasChanged;

  bool get isAtMin => 0 >= _currentSize.value;
  bool get isAtMax => (snapConfiguration.isScrollable ? pixelsToSize(snapBounds.$2) : 1) <= _currentSize.value;

  double get currentSize => _currentSize.value;
  double get currentPixels => sizeToPixels(_currentSize.value);

  late List<double> pixelSnapSizes = snapConfiguration.mapToPixels;
  late final (double, double) snapBounds = (
    snapConfiguration.snapSizes.first.rawSizingValue,
    snapConfiguration.snapSizes.last.rawSizingValue,
  );
  void startActivity({required VoidCallback onCanceled}) {
    _cancelActivity?.call();
    _cancelActivity = onCanceled;
  }

  void addPixelDelta(double delta, BuildContext context) {
    _cancelActivity?.call();
    _cancelActivity = null;

    hasDragged = true;
    hasChanged = true;
    if (availablePixels == 0) {
      return;
    }
    updateSize(currentSize + pixelsToSize(delta), context);
  }

  void updateSize(double newSize, BuildContext context) {
    final clampedSize = clampDouble(newSize, 0, 1);
    if (_currentSize.value == clampedSize) {
      return;
    }

    _currentSize.value = clampedSize;
    CustomDraggableScrollableNotification(
      minExtent: 0,
      maxExtent: 1,
      extent: currentSize,
      initialExtent: initialSize,
      context: context,
    ).dispatch(context);
  }

  double pixelsToSize(double pixels) => pixels / availablePixels;

  double sizeToPixels(double size) => size * availablePixels;

  void dispose() {
    _currentSize.dispose();
  }

  _DraggableSheetExtent copyWith({
    required PreparedSnapConfiguration snapConfiguration,
    double? initialSize,
    Duration? snapAnimationDuration,
  }) =>
      _DraggableSheetExtent(
        context: context,
        snapConfiguration: snapConfiguration,
        snapAnimationDuration: snapAnimationDuration,
        initialSize: initialSize,
        currentSize: ValueNotifier<double>(hasChanged ? clampDouble(_currentSize.value, 0, 1) : initialSize ?? 1),
        hasDragged: hasDragged,
        hasChanged: hasChanged,
      );
}
