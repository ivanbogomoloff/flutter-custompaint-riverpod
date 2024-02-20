import 'dart:async';
import 'dart:typed_data';

import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soboltest1/MyPainter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:soboltest1/PainterState.dart';

part 'main.g.dart';

@riverpod
class PainterStateNotifier extends _$PainterStateNotifier {
  final PainterState ps = PainterState();
  int resourceLoadedCounter = 0;
  final resources = {
    'cursor': 'assets/images/cursor.png',
    'ellipse': 'assets/images/ellipse.png'
  };

  @override
  PainterState build()  {
    loadAssets();
    return ps;
  }

  loadAssets() {
    if(ps.resourcesLoaded) return;

    resources.entries.forEach((mapEntry) {
      rootBundle.load(mapEntry.value).then((byteData) {
        loadImage(byteData.buffer.asUint8List()).then((img) {
          resourceLoadedCounter++;
          if(mapEntry.key == 'cursor') {
            ps.cursorImage = img;
          }
          if(mapEntry.key == 'ellipse') {
            ps.ellipseImage = img;
          }
          print('${mapEntry.key} -> loaded resources ${resourceLoadedCounter}');
          if(resourceLoadedCounter >= resources.length) {
            ps.resourcesLoaded = true;
          }
        });
      });
    });
  }


  Future<ui.Image> loadImage(Uint8List bytesData) async {
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(bytesData, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  click(double dx, double dy) {
    ps.click(dx, dy);
    ref.invalidateSelf();
    ref.notifyListeners();
  }

  dragStart(double dx, double dy) {
    ps.dragStart(dx, dy);
    ref.invalidateSelf();
    ref.notifyListeners();
  }

  dragUpdate(double dx, double dy) {
    ps.dragUpdate(dx, dy);
    ref.invalidateSelf();
    ref.notifyListeners();
  }

  dragStop() {
    ps.dragStop();
    ref.invalidateSelf();
    ref.notifyListeners();
  }
}

void main() {
  runApp(
    // For widgets to be able to read providers, we need to wrap the entire
    // application in a "ProviderScope" widget.
    // This is where the state of our providers will be stored.
    ProviderScope(
      child: MyApp(),
    ),
  );
}

// Extend ConsumerWidget instead of StatelessWidget, which is exposed by Riverpod
class MyApp extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final PainterState painterState = ref.watch(painterStateNotifierProvider);
    final int pointsCounter = painterState.points.length;
    return MaterialApp(
      home: Scaffold(
        extendBodyBehindAppBar: false,
        appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 0,
            backgroundColor: Colors.transparent
        ),
        body: Container(
      margin: const EdgeInsets.only(top: 0),
      decoration: const BoxDecoration(
        color: Color.fromRGBO(255, 255, 255, 1),
        image: DecorationImage(
          image: AssetImage("assets/images/bg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16, left: 8, right: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: 80,
                    maxHeight: 31
                ),
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(5.31))
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child:  IconButton(
                              onPressed: () {

                              },
                              icon: ImageIcon(AssetImage('assets/images/back_btn.png'))
                          )),
                      Expanded(child: ImageIcon(
                        AssetImage('assets/images/divider.png'),
                        size: 12,
                      )),
                      Expanded(
                          flex: 2,
                          child: IconButton(
                              onPressed: () {

                              },
                              icon: ImageIcon(AssetImage('assets/images/forward_btn.png'))
                          ))
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onHorizontalDragStart: (details) {
                ref.read(painterStateNotifierProvider.notifier).dragStart(details.localPosition.dx, details.localPosition.dy);
              },
              onVerticalDragStart: (details) {
                ref.read(painterStateNotifierProvider.notifier).dragStart(details.localPosition.dx, details.localPosition.dy);
              },
              onHorizontalDragUpdate:  (details) {
                ref.read(painterStateNotifierProvider.notifier).dragUpdate(details.localPosition.dx, details.localPosition.dy);
              },
              onVerticalDragUpdate: (details) {
                ref.read(painterStateNotifierProvider.notifier).dragUpdate(details.localPosition.dx, details.localPosition.dy);
              },
              onHorizontalDragEnd: (details) {
                ref.read(painterStateNotifierProvider.notifier).dragStop();
              },
              onVerticalDragEnd:  (details) {
                ref.read(painterStateNotifierProvider.notifier).dragStop();
              },
              dragStartBehavior: DragStartBehavior.start, // default
              behavior: HitTestBehavior.translucent,
              // onTapDown: (details) {
              //
              //   ref
              //       .read(painterStateNotifierProvider.notifier)
              //       .click(details.localPosition.dx, details.localPosition.dy);
              // },
              child: CustomPaint(
                size: Size(MediaQuery.sizeOf(context).width, MediaQuery.sizeOf(context).height,),
                painter: MyPainter(painterState),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 8, right: 8),
                    padding: EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(13))
                    ),
                    constraints: BoxConstraints(
                        minWidth: MediaQuery.sizeOf(context).width,
                        maxWidth: MediaQuery.sizeOf(context).width,
                        minHeight: 52,
                        maxHeight: 100
                    ),
                    child: Text('Нажмите на любую точку экрана, чтобы построить угол',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: 'SF Pro Text',
                            fontSize: 16,
                            color: Color.fromRGBO(0, 0, 0, 1)
                        )),
                  ),
                  Divider(height: 8, color: Colors.transparent),
                  Container(
                    margin: EdgeInsets.only(left: 8, right: 8),
                    padding: EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(13))
                    ),

                    child: Container(
                      constraints: BoxConstraints(
                          minWidth: MediaQuery.sizeOf(context).width,
                          maxWidth: MediaQuery.sizeOf(context).width,
                          minHeight: 70,
                          maxHeight: 70
                      ),
                      decoration: const BoxDecoration(
                          color: Color.fromRGBO(227, 227, 227, 1),
                          borderRadius: BorderRadius.all(Radius.circular(11))
                      ),
                      child: Column(
                        children: [
                          Expanded(
                              flex: 1,
                              child: Image.asset('assets/images/cancel_icon.png', scale: 2)
                          ),
                          Expanded(flex: 1, child: Text('Отменить действие',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'SF Pro Text',
                                  fontSize: 16,
                                  color: Color.fromRGBO(125, 125, 125, 1)
                              )),
                          )
                        ],
                      ),
                    ),
                  ),
                  Divider(height: 21, color: Colors.transparent),
                ],
              ),
            )
          ],
        ),
      ),
    ),
      ),
    );
  }

  GlobalKey key = GlobalKey();

  String dragDirection = '';
  String startDXPoint = '50';
  String startDYPoint = '50';
  String dXPoint = '';
  String dYPoint = '';
  String velocity = '';

  void _onHorizontalDragStartHandler(DragStartDetails details) {

  }

  /// Track starting point of a vertical gesture
  void _onVerticalDragStartHandler(DragStartDetails details) {
    this.dragDirection = "VERTICAL";
    this.startDXPoint = '${details.globalPosition.dx.floorToDouble()}';
    this.startDYPoint = '${details.globalPosition.dy.floorToDouble()}';

    print(this.dragDirection);
  }

  void _onDragUpdateHandler(DragUpdateDetails details) {
    this.dragDirection = "UPDATING";
    this.startDXPoint = '${details.globalPosition.dx.floorToDouble()}';
    this.startDYPoint = '${details.globalPosition.dy.floorToDouble()}';

    print(this.dragDirection);
  }

  /// Track current point of a gesture
  void _onHorizontalDragUpdateHandler(DragUpdateDetails details) {
    this.dragDirection = "HORIZONTAL UPDATING";
    this.dXPoint = '${details.globalPosition.dx.floorToDouble()}';
    this.dYPoint = '${details.globalPosition.dy.floorToDouble()}';
    this.velocity = '';

    print(this.dragDirection);
  }

  /// Track current point of a gesture
  void _onVerticalDragUpdateHandler(DragUpdateDetails details) {
    this.dragDirection = "VERTICAL UPDATING";
    this.dXPoint = '${details.globalPosition.dx.floorToDouble()}';
    this.dYPoint = '${details.globalPosition.dy.floorToDouble()}';
    this.velocity = '';

    print(this.dragDirection);
  }

  /// What should be done at the end of the gesture ?
  void _onDragEnd(DragEndDetails details) {
    double result = details.velocity.pixelsPerSecond.dx.abs().floorToDouble();
    this.velocity = '$result';

  }


}

