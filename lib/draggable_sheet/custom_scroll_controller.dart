part of 'custom_draggable_sheet.dart';

class _CustomDraggableScrollableSheetScrollController extends ScrollController {
  _CustomDraggableScrollableSheetScrollController({
    required this.extent,
  });

  _DraggableSheetExtent extent;
  VoidCallback? onPositionDetached;

  @override
  _CustomDraggableScrollableSheetScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) =>
      _CustomDraggableScrollableSheetScrollPosition(
        physics: physics.applyTo(const AlwaysScrollableScrollPhysics()),
        context: context,
        oldPosition: oldPosition,
        getExtent: () => extent,
      );

  @override
  void debugFillDescription(List<String> description) {
    super.debugFillDescription(description);
    description.add('extent: $extent');
  }

  @override
  _CustomDraggableScrollableSheetScrollPosition get position =>
      super.position as _CustomDraggableScrollableSheetScrollPosition;

  void reset() {
    extent._cancelActivity?.call();
    extent.hasDragged = false;
    extent.hasChanged = false;

    if (offset != 0.0) {
      animateTo(
        0,
        duration: const Duration(milliseconds: 1),
        curve: Curves.linear,
      );
    }
    extent.updateSize(extent.initialSize ?? 1, position.context.notificationContext!);
  }

  @override
  void detach(ScrollPosition position) {
    onPositionDetached?.call();
    super.detach(position);
  }
}
