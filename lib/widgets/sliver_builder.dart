import 'package:flutter/material.dart';

class SliverSingleBuilder extends StatelessWidget {
  const SliverSingleBuilder({
    super.key,
    required this.child,
    this.scrollController,
    this.topChild,
  });

  final Widget child;
  final Widget? topChild;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => Scrollable(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        viewportBuilder: (context, viewportOffset) => Viewport(
          offset: viewportOffset,
          slivers: [
            if (topChild != null) topChild!,
            child,
          ],
        ),
      );
}
