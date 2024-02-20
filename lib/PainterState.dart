import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';

class PainterState {
  bool resourcesLoaded = false;
  final List<Offset> points = [];
  Offset? currentStartPoint;
  Offset? targetEndPoint;
  String mode = '-';
  Image? cursorImage;
  Image? ellipseImage;

  Offset cursorImagePoint() {
      return Offset(targetEndPoint!.dx - (127/2), targetEndPoint!.dy - (127 / 2));
  }

  Offset ellipseImagePoint(Offset p) {
    return Offset(p.dx - (39 / 2),p.dy - (38 / 2));
  }

  void click(double dx, double dy) {
    if(currentStartPoint == null) {
      currentStartPoint = Offset(dx,dy);
      points.add(Offset(dx,dy));
    } else {
      targetEndPoint =  Offset(dx,dy);
      points.add(Offset(dx,dy));

      currentStartPoint = null;
    }
  }

  dragStart(double dx, double dy) {
    if(mode == 'finished') return;
    mode = 'drag';

    if(currentStartPoint == null) {
      currentStartPoint = Offset(dx,dy);
      points.add(Offset(dx,dy));
    }
  }

  dragUpdate(double dx, double dy) {
    if(mode == 'finished') return;
    mode = 'update';
    targetEndPoint =  Offset(dx,dy);
  }

  dragStop() {
    if(mode == 'finished') return;
    mode = 'update';
    if(targetEndPoint != null) {
      points.add(targetEndPoint!);
      currentStartPoint = targetEndPoint;
    }
    if(points.length >= 5) {
      mode = 'finished';
      currentStartPoint = null;
      targetEndPoint = null;
    }
  }
}

class Point {
  final Offset xy;
  final int radius;

  Point(this.xy, this.radius);
}