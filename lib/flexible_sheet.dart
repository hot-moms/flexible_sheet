import 'package:flexible_sheet/draggable_sheet/custom_draggable_sheet.dart';
import 'package:flexible_sheet/flexible_sheet_controller.dart';
import 'package:flexible_sheet/mixin/sheet_content_mixin.dart';
import 'package:flexible_sheet/snap_configuration/snap_configuration.dart';
import 'package:flexible_sheet/widgets/exclude_widget.dart';
import 'package:flexible_sheet/widgets/sliver_builder.dart';
import 'package:flexible_sheet/widgets/sliver_sizer.dart';
import 'package:flutter/material.dart';

class FlexibleSheet extends StatefulWidget {
  const FlexibleSheet({
    super.key,
    required this.child,
    required this.persistentPinChild,
    required this.sheetDecoration,
    this.transitionDuration = kThemeAnimationDuration,
  }) : assert(child is SheetContentMixin, 'Any widget passed as `child` must mixin the SheetContentMixin');

  final Widget child;
  final Widget persistentPinChild;
  final BoxDecoration sheetDecoration;
  final Duration transitionDuration;

  @override
  State<FlexibleSheet> createState() => _FlexibleSheetState();
}

class _FlexibleSheetState extends State<FlexibleSheet> with SingleTickerProviderStateMixin {
  final draggableController = CustomDraggableScrollableController();

  late final _fadeController = AnimationController(vsync: this, value: 1, duration: widget.transitionDuration);
  late final sizeController = FlexibleSheetController()
    ..renderingController.addListener(() => _fadeController.forward())
    ..updateSheetContent(widget.child);

  ScrollController? _scrollController;

  @override
  void didUpdateWidget(covariant FlexibleSheet oldWidget) {
    if (oldWidget.child.key != widget.child.key) {
      sizeController.updateSheetContent(widget.child);
    }
    super.didUpdateWidget(oldWidget);
  }

  Future<void> onSizeReported(PreparedSnapConfiguration size) async {
    await _fadeController.reverse();

    sizeController.onCalculated(
      KeyedSubtree(
        key: sizeController.globalKey,
        child: sizeController.calculatingController.value,
      ),
      size,
    );

    if (_scrollController?.hasClients ?? false) {
      await draggableController.animateTo(
        size.initialSize.rawFractionalValue,
        duration: kThemeAnimationDuration,
        curve: Curves.ease,
      );
    }
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            _CompositionLayer(
              topChild: widget.persistentPinChild,
              onSizeChanged: onSizeReported,
              sizeController: sizeController,
            ),
            _RenderingLayer(
              topChild: widget.persistentPinChild,
              onScrollChanged: (scrollController) => _scrollController = scrollController,
              draggableController: draggableController,
              fadeController: _fadeController,
              sheetDecoration: widget.sheetDecoration,
              sizeController: sizeController,
            ),
          ],
        ),
      );
}

class _RenderingLayer extends StatelessWidget {
  const _RenderingLayer({
    required this.sizeController,
    required this.draggableController,
    required AnimationController fadeController,
    required this.sheetDecoration,
    required this.onScrollChanged,
    required this.topChild,
  }) : _fadeController = fadeController;

  final FlexibleSheetController sizeController;
  final CustomDraggableScrollableController draggableController;
  final AnimationController _fadeController;
  final BoxDecoration sheetDecoration;
  final void Function(ScrollController scrollController) onScrollChanged;
  final Widget topChild;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: sizeController.renderingController,
        builder: (context, _) => CustomDraggableScrollableSheet(
          snapConfiguration: sizeController.currentSnapConfiguration,
          initialChildSize: sizeController.currentSnapConfiguration.initialSize.rawFractionalValue,
          onScrollChanged: onScrollChanged,
          controller: draggableController,
          builder: (context, scrollController) => DecoratedBox(
            decoration: sheetDecoration,
            child: FadeTransition(
              opacity: _fadeController,
              child: ClipRRect(
                borderRadius: sheetDecoration.borderRadius ?? BorderRadius.zero,
                child: SliverSingleBuilder(
                  topChild: topChild,
                  scrollController: scrollController,
                  child: sizeController.currentChild,
                ),
              ),
            ),
          ),
        ),
      );
}

class _CompositionLayer extends StatelessWidget {
  const _CompositionLayer({
    required this.sizeController,
    required this.onSizeChanged,
    required this.topChild,
  });

  final FlexibleSheetController sizeController;
  final void Function(PreparedSnapConfiguration size) onSizeChanged;
  final Widget topChild;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height;

    return ListenableBuilder(
      listenable: sizeController.calculatingController,
      builder: (context, _) => ListenableBuilder(
        listenable: sizeController.renderingController,
        builder: (context, __) {
          // No need to calculate size, just let it prepare already
          if (!sizeController.rawSnapConfiguration.containsWidgetSize && !sizeController.isKeysEqual) {
            onSizeChanged(
              sizeController.rawSnapConfiguration.prepareConfiguration(maxHeight),
            );
          }
          return sizeController.isKeysEqual
              ? const SizedBox()
              : ExcludeWidget(
                  child: SliverSingleBuilder(
                    topChild: topChild,
                    child: SliverSizer(
                      onSizeChanged: (size, scroll) => onSizeChanged(
                        sizeController.rawSnapConfiguration.prepareConfiguration(
                          maxHeight,
                          widgetSize: size,
                          scrollExtent: scroll,
                        ),
                      ),
                      child: KeyedSubtree(
                        key: sizeController.globalKey,
                        child: sizeController.calculatingController.value,
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}
