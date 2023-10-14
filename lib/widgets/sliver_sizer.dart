import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Measure and call callback after child size changed.
class SliverSizer extends SingleChildRenderObjectWidget {
  const SliverSizer({
    required super.child,
    this.onSizeChanged,
    super.key,
  });

  /// Callback when child size changed and after layout rebuild.
  final void Function(double size, double scrollExtent)? onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) => _SliverSizerRenderObject((double size, double scroll) {
        final fn = onSizeChanged;
        if (fn != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) => fn(size, scroll));
        }
      });
}

/// Render object for [SliverSizer].
class _SliverSizerRenderObject extends RenderProxySliver {
  _SliverSizerRenderObject(
    this.onLayoutChangedCallback,
  );
  @override
  bool get sizedByParent => false;

  /// Callback when child size changed and after layout rebuild.
  final void Function(double dimension, double scrollExtent) onLayoutChangedCallback;

  @override
  void performLayout() {
    if (child == null) return;
    assert(child is RenderSliver, 'Must be a sliver');
    super.performLayout();

    final content = child;

    final newSize = content?.geometry?.paintExtent ?? content?.constraints.remainingPaintExtent;
    final scrollExtent = content?.geometry?.scrollExtent;
    if (newSize == null) return;
    onLayoutChangedCallback(newSize, scrollExtent ?? double.infinity);
  }
}
