part of 'custom_draggable_sheet.dart';

class _SnappingSimulation extends Simulation {
  _SnappingSimulation({
    required this.extent,
    required double initialVelocity,
    super.tolerance,
  }) : position = extent.currentPixels {
    _pixelSnapSize = _getSnapSize(initialVelocity, extent.snapConfiguration);
    if (extent.snapAnimationDuration != null && extent.snapAnimationDuration!.inMilliseconds > 0) {
      velocity = (_pixelSnapSize - position) * 1000 / extent.snapAnimationDuration!.inMilliseconds;
    } else if (_pixelSnapSize < position) {
      velocity = math.min(-minimumSpeed, initialVelocity);
    } else {
      velocity = math.max(minimumSpeed, initialVelocity);
    }
  }

  final double position;
  late final double velocity;
  final _DraggableSheetExtent extent;

  static const double minimumSpeed = 1600;

  late final double _pixelSnapSize;
  bool isDisabled = false;

  @override
  double dx(double time) {
    if (isDone(time)) {
      return 0;
    }
    return velocity;
  }

  @override
  bool isDone(double time) => x(time) == _pixelSnapSize;

  @override
  double x(double time) {
    final newPosition = position + (velocity * time);
    if ((velocity >= 0 && newPosition > _pixelSnapSize) || (velocity < 0 && newPosition < _pixelSnapSize)) {
      return _pixelSnapSize;
    }

    return newPosition;
  }

  double _getSnapSize(double initialVelocity, PreparedSnapConfiguration snapConfiguration) {
    const swipeGap = 0;
    // extent.availablePixels * .05;

    final pixelSnapSizes = snapConfiguration.mapToPixels;

    double handleSwipe(double result) {
      final isSwipeUp = position > pixelSnapSizes.last + swipeGap && snapConfiguration.onSwipeUp != null;
      final isSwipeDown = position < pixelSnapSizes.first - swipeGap && snapConfiguration.onSwipeDown != null;
      assert(!(isSwipeUp && isSwipeDown), 'how? ._.');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (isSwipeUp) snapConfiguration.onSwipeUp?.call(extent.context);
        if (isSwipeDown) snapConfiguration.onSwipeDown?.call(extent.context);
      });

      return isSwipeDown || isSwipeUp ? position : result;
    }

    final indexOfNextSize = pixelSnapSizes.indexWhere((size) => size >= position);
    if (pixelSnapSizes.length == 1) {
      return handleSwipe(pixelSnapSizes.first);
    }

    if (indexOfNextSize == -1) {
      return handleSwipe(pixelSnapSizes.last);
    }

    final previousIndex = (indexOfNextSize - 1).clamp(0, pixelSnapSizes.length - 1);
    final nextSize = pixelSnapSizes[indexOfNextSize];
    final previousSize = pixelSnapSizes[previousIndex];

    if (initialVelocity.abs() <= tolerance.velocity) {
      return handleSwipe((position - previousSize < nextSize - position) ? previousSize : nextSize);
    }

    if (initialVelocity < 0.0) {
      return handleSwipe(pixelSnapSizes[previousIndex]);
    }

    return handleSwipe(pixelSnapSizes[indexOfNextSize]);
  }
}
