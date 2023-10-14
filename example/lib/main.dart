import 'dart:developer';

import 'package:flexible_sheet/flexible_sheet.dart';
import 'package:flexible_sheet/mixin/sheet_content_mixin.dart';
import 'package:flexible_sheet/snap_configuration/snap_configuration.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        // etc.
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isActive = false;

  void onTap() => setState(() {
        isActive = !isActive;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        const ColoredBox(
          color: Colors.blue,
          child: SizedBox.expand(),
        ),
        FlexibleSheet(
            sheetDecoration:
                const BoxDecoration(color: Color(0xFF13181F), borderRadius: BorderRadius.all(Radius.circular(20))),
            persistentPinChild: const SliverToBoxAdapter(),
            child: isActive
                ? ScrollableWidget(
                    key: const Key('scrollable'),
                    onTap: onTap,
                  )
                : MyWidget(
                    key: const Key('container-green'),
                    tag: 'green-second',
                    onTap: onTap,
                    color: Colors.green,
                    height: 200,
                  ))
      ],
    ));
  }
}

class MyWidget extends StatefulWidget with SheetContentMixin {
  const MyWidget({
    required super.key,
    this.onTap,
    this.color = Colors.red,
    this.height = 400,
    required this.tag,
  });

  final VoidCallback? onTap;
  final Color color;
  final double height;
  final String tag;

  @override
  Key get key => super.key!;

  @override
  SnapConfiguration get snapConfiguration => SnapConfiguration(
        onSwipeUp: (_) => log('SWIPE UP'),
        onSwipeDown: (_) => log('E DOWN'),
        initialIndex: 0,
        snapSizes: const [
          // SizeConfiguration.widgetSize(),
          SizeConfiguration.sizeFactor(.5),
          // SizeConfiguration.sizeFactor(.5),
          SizeConfiguration.sizeFactor(.8),
          // SizeConfiguration.sizeFactor(1),
        ],
      );

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  void initState() {
    super.initState();
    log('inited ${widget.tag},$hashCode');
  }

  @override
  void dispose() {
    log('disposed ${widget.tag},$hashCode');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
          child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: widget.height,
          color: widget.color,
        ),
      ));
}

class ScrollableWidget extends StatelessWidget with SheetContentMixin {
  const ScrollableWidget({required super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Key get key => super.key!;

  @override
  SnapConfiguration get snapConfiguration => SnapConfiguration(
        initialIndex: 0,
        snapSizes: [
          // const SizeConfiguration.pixels(100),
          const SizeConfiguration.pixels(100),
          const SizeConfiguration.widgetSize(),
          // const SizeConfiguration.sizeFactor(.7),
        ],
        isScrollable: true,
      );

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
        itemCount: 129,
        itemBuilder: (context, index) => ListTile(
              onTap: onTap,
              title: Text(
                '$index',
                style: const TextStyle(color: Colors.white),
              ),
            ));
  }
}
