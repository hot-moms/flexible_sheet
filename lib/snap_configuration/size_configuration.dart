part of 'snap_configuration.dart';

@immutable
sealed class SizeConfiguration {
  final double value;

  const SizeConfiguration(
    this.value,
  );

  const factory SizeConfiguration.pixels(double value) = _Pixels$SizeConfiguration;
  const factory SizeConfiguration.sizeFactor(double value) = _SizeFactor$SizeConfiguration;
  const factory SizeConfiguration.widgetSize() = _WidgetSize$SizeConfiguration;

  bool get isWidgetSize => this is _WidgetSize$SizeConfiguration;

  PreparedSizeConfiguration prepareSize({double widgetSize = 0, required double maxHeight}) => when(
        pixels: (pixels) => PreparedSizeConfiguration._(pixels / maxHeight, pixels, this),
        sizeFactor: (size) => PreparedSizeConfiguration._(size, size * maxHeight, this),
        widgetSize: () => PreparedSizeConfiguration._(widgetSize / maxHeight, widgetSize, this),
      );

  T when<T extends Object?>({
    required T Function(double pixels) pixels,
    required T Function(double sizeFactor) sizeFactor,
    required T Function() widgetSize,
  }) =>
      switch (this) {
        final _Pixels$SizeConfiguration state => pixels(state.value),
        final _SizeFactor$SizeConfiguration state => sizeFactor(state.value),
        _WidgetSize$SizeConfiguration _ => widgetSize(),
      };
}

class _Pixels$SizeConfiguration extends SizeConfiguration {
  const _Pixels$SizeConfiguration(super.value);

  @override
  String toString() => 'PixelSize\$Configuration(value: $value)';
}

class _SizeFactor$SizeConfiguration extends SizeConfiguration {
  const _SizeFactor$SizeConfiguration(super.value);

  @override
  String toString() => 'SizeFactor\$SizeConfiguration(value: $value)';
}

class _WidgetSize$SizeConfiguration extends SizeConfiguration {
  const _WidgetSize$SizeConfiguration() : super(-1);

  @override
  String toString() => 'WidgetSize\$Configuration()';
}

@immutable
class PreparedSizeConfiguration {
  final double rawFractionalValue;
  final double rawSizingValue;

  final SizeConfiguration parent;

  const PreparedSizeConfiguration._(
    this.rawFractionalValue,
    this.rawSizingValue,
    this.parent,
  );

  @override
  String toString() => '$runtimeType(rawFractional: $rawFractionalValue, rawSizing: $rawSizingValue)';

  factory PreparedSizeConfiguration.empty() => const PreparedSizeConfiguration._(0, 0, SizeConfiguration.sizeFactor(0));
}
