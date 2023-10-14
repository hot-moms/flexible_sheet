part of 'custom_draggable_sheet.dart';

class _CustomDraggableScrollableSheetScrollPosition extends ScrollPositionWithSingleContext {
  _CustomDraggableScrollableSheetScrollPosition({
    required super.physics,
    required super.context,
    super.oldPosition,
    required this.getExtent,
  });

  VoidCallback? _dragCancelCallback;
  final _DraggableSheetExtent Function() getExtent;
  final Set<AnimationController> _ballisticControllers = <AnimationController>{};
  bool get listShouldScroll => pixels > 0.0 && extent.isAtMax;

  _DraggableSheetExtent get extent => getExtent();

  @override
  void absorb(ScrollPosition other) {
    super.absorb(other);
    assert(_dragCancelCallback == null);

    if (other is! _CustomDraggableScrollableSheetScrollPosition) {
      return;
    }

    if (other._dragCancelCallback != null) {
      _dragCancelCallback = other._dragCancelCallback;
      other._dragCancelCallback = null;
    }
  }

  @override
  void beginActivity(ScrollActivity? newActivity) {
    for (final ballisticController in _ballisticControllers) {
      ballisticController.stop();
    }
    super.beginActivity(newActivity);
  }

  @override
  void applyUserOffset(double delta) {
    const slideStart = .4;

    if (!listShouldScroll &&
        (!(extent.isAtMin || extent.isAtMax) || (extent.isAtMin && delta < 0) || (extent.isAtMax && delta > 0))) {
      final (bottomPosition, topPosition) = extent.snapBounds;

      final isInTop = extent.currentPixels < topPosition;
      final isInBottom = extent.currentPixels > bottomPosition;
      final inBounds = isInTop && isInBottom;

      //TODO(hot-moms): optimize this math func
      final modifier = switch (inBounds) {
        true => 1,
        false => () {
            final topSize = slideStart - extent.pixelsToSize((extent.currentPixels - topPosition).abs());
            final bottomSize = slideStart - extent.pixelsToSize((extent.currentPixels - bottomPosition).abs());

            return (bottomPosition == topPosition)
                ? topSize
                : switch (isInTop) {
                    false => topSize,
                    true => bottomSize,
                  };
          }(),
      };

      final value = -delta * modifier;

      extent.addPixelDelta(value, context.notificationContext!);
    } else {
      super.applyUserOffset(delta);
    }
  }

  bool get _isAtSnapSize => extent.snapConfiguration.snapSizes.any(
        (snapSize) =>
            (extent.currentSize - snapSize.rawFractionalValue).abs() <=
            extent.pixelsToSize(physics.toleranceFor(this).distance),
      );

  bool get _shouldSnap => extent.hasDragged && !_isAtSnapSize;

  @override
  void dispose() {
    for (final ballisticController in _ballisticControllers) {
      ballisticController.dispose();
    }
    _ballisticControllers.clear();
    super.dispose();
  }

  @override
  void goBallistic(double velocity) {
    if ((velocity == 0.0 && !_shouldSnap) ||
        (velocity < 0.0 && listShouldScroll) ||
        (velocity > 0.0 && extent.isAtMax)) {
      super.goBallistic(velocity);
      return;
    }

    _dragCancelCallback?.call();
    _dragCancelCallback = null;
    final Simulation simulation = _SnappingSimulation(
      extent: extent,
      initialVelocity: velocity,
      tolerance: physics.toleranceFor(this),
    );

    final ballisticController = AnimationController.unbounded(
      debugLabel: objectRuntimeType(this, '_CustomDraggableScrollableSheetPosition'),
      vsync: context.vsync,
    );
    _ballisticControllers.add(ballisticController);

    var lastPosition = extent.currentPixels;
    void tick() {
      final delta = ballisticController.value - lastPosition;
      lastPosition = ballisticController.value;
      extent.addPixelDelta(delta, context.notificationContext!);
      if ((velocity > 0 && extent.isAtMax) || (velocity < 0 && extent.isAtMin)) {
        // ignore: parameter_assignments
        velocity =
            ballisticController.velocity + (physics.toleranceFor(this).velocity * ballisticController.velocity.sign);
        super.goBallistic(velocity);
        ballisticController.stop();
      } else if (ballisticController.isCompleted) {
        super.goBallistic(0);
      }
    }

    ballisticController
      ..addListener(tick)
      ..animateWith(simulation).whenCompleteOrCancel(
        () {
          if (_ballisticControllers.contains(ballisticController)) {
            _ballisticControllers.remove(ballisticController);
            ballisticController.dispose();
          }
        },
      );
  }

  @override
  Drag drag(DragStartDetails details, VoidCallback dragCancelCallback) {
    _dragCancelCallback = dragCancelCallback;
    return super.drag(details, dragCancelCallback);
  }
}
