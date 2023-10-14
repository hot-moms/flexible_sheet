import 'package:flutter/material.dart';

class ExcludeWidget extends ExcludeSemantics {
  const ExcludeWidget({super.key, super.child});

  @override
  Widget? get child => ExcludeSemantics(
        child: ExcludeFocus(
          child: ExcludeFocusTraversal(
            child: IgnorePointer(
              child: Offstage(child: super.child),
            ),
          ),
        ),
      );
}
