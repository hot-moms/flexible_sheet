part of 'custom_draggable_sheet.dart';

class CustomDraggableScrollableController extends ChangeNotifier {
  _CustomDraggableScrollableSheetScrollController? _attachedController;
  final Set<AnimationController> _animationControllers = <AnimationController>{};

  double get size {
    _assertAttached();
    return _attachedController!.extent.currentSize;
  }

  double get pixels {
    _assertAttached();
    return _attachedController!.extent.currentPixels;
  }

  double sizeToPixels(double size) {
    _assertAttached();
    return _attachedController!.extent.sizeToPixels(size);
  }

  bool get isAttached => _attachedController != null && _attachedController!.hasClients;

  double pixelsToSize(double pixels) {
    _assertAttached();
    return _attachedController!.extent.pixelsToSize(pixels);
  }

  Future<void> animateTo(
    double size, {
    required Duration duration,
    required Curve curve,
  }) async {
    _assertAttached();
    assert(size >= 0 && size <= 1);
    assert(duration != Duration.zero);
    final animationController = AnimationController.unbounded(
      vsync: _attachedController!.position.context.vsync,
      value: _attachedController!.extent.currentSize,
    );
    _animationControllers.add(animationController);
    _attachedController!.position.goIdle();

    _attachedController!.extent.hasDragged = false;
    _attachedController!.extent.hasChanged = true;
    _attachedController!.extent.startActivity(
      onCanceled: () {
        if (animationController.isAnimating) {
          animationController.stop();
        }
      },
    );
    animationController.addListener(() {
      _attachedController!.extent.updateSize(
        animationController.value,
        _attachedController!.position.context.notificationContext!,
      );
    });
    await animationController.animateTo(
      clampDouble(size, 0, 1),
      duration: duration,
      curve: curve,
    );
  }

  void jumpTo(double size) {
    _assertAttached();
    assert(size >= 0 && size <= 1);

    _attachedController!.extent.startActivity(onCanceled: () {});
    _attachedController!.position.goIdle();
    _attachedController!.extent.hasDragged = false;
    _attachedController!.extent.hasChanged = true;
    _attachedController!.extent.updateSize(size, _attachedController!.position.context.notificationContext!);
  }

  void reset() {
    _assertAttached();
    _attachedController!.reset();
  }

  void _assertAttached() {
    assert(
      isAttached,
      'CustomDraggableScrollableController is not attached to a sheet. A CustomDraggableScrollableController '
      'must be used in a CustomDraggableScrollableSheet before any of its methods are called.',
    );
  }

  void _attach(_CustomDraggableScrollableSheetScrollController scrollController) {
    assert(_attachedController == null, 'Draggable scrollable controller is already attached to a sheet.');
    _attachedController = scrollController;
    _attachedController!.extent._currentSize.addListener(notifyListeners);
    _attachedController!.onPositionDetached = _disposeAnimationControllers;
  }

  void _onExtentReplaced(_DraggableSheetExtent previousExtent) {
    _attachedController!.extent._currentSize.addListener(notifyListeners);
    // if (previousExtent.currentSize != _attachedController!.extent.currentSize) {
    notifyListeners();
    // }
  }

  void _detach({bool disposeExtent = false}) {
    if (disposeExtent) {
      _attachedController?.extent.dispose();
    } else {
      _attachedController?.extent._currentSize.removeListener(notifyListeners);
    }
    _disposeAnimationControllers();
    _attachedController = null;
  }

  void _disposeAnimationControllers() {
    for (final animationController in _animationControllers) {
      animationController.dispose();
    }
    _animationControllers.clear();
  }
}
