import 'package:flexible_sheet/mixin/sheet_content_mixin.dart';
import 'package:flexible_sheet/snap_configuration/snap_configuration.dart';
import 'package:flutter/material.dart';

typedef SheetSizeState = (Widget, double);

class _PlaceholderKeyTree extends KeyedSubtree with SheetContentMixin {
  const _PlaceholderKeyTree({super.key}) : super(child: const SliverToBoxAdapter());

  @override
  Key get key => super.key!;

  @override
  SnapConfiguration get snapConfiguration => SnapConfiguration(
        snapSizes: [const SizeConfiguration.sizeFactor(0)],
      );
}

class FlexibleSheetController {
  /* Global Key */
  GlobalKey _globalKey = GlobalKey();
  GlobalKey? get globalKey => _globalKey;

  /// Calculating input controller
  late final ValueNotifier<Widget> calculatingController = ValueNotifier(_PlaceholderKeyTree(key: _globalKey))
    ..addListener(() => _globalKey = GlobalKey());

  /// Rendering output controller
  late final ValueNotifier<SheetSizeState> renderingController =
      ValueNotifier((_PlaceholderKeyTree(key: globalKey), 0));

  double get currentHeight => renderingController.value.$2;
  Widget get currentChild => renderingController.value.$1;

  Key? get currentKey => currentChild.key;
  bool get isKeysEqual => (currentKey == _globalKey) && (currentKey != null);

  double fractionalHeight(double maxHeight) => (currentHeight / maxHeight).clamp(0, 1);

  void onCalculated(Widget child, PreparedSnapConfiguration size) {
    final reportedSize = size.initialSize.rawSizingValue;
    currentSnapConfiguration = size;
    renderingController.value = (child, reportedSize);
  }

  void updateSheetContent(Widget child) {
    assert(child is SheetContentMixin, 'Any widget passed as `child` must mixin the SheetContentMixin');
    calculatingController.value = child;
  }

  PreparedSnapConfiguration currentSnapConfiguration = PreparedSnapConfiguration.empty();

  /// Return configuration from [calculatingController], not [renderingController]
  ///
  SnapConfiguration get rawSnapConfiguration => (calculatingController.value as SheetContentMixin).snapConfiguration;
}
