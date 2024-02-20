import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soboltest1/PainterState.dart';

class MyPainter extends CustomPainter {
  final PainterState state;
  MyPainter(this.state);
  @override
  void paint(ui.Canvas canvas, ui.Size size) {
      print('REPAINT!!');
      print(this.state.points.length);





      if(state.points.length >= 2)
      {
        var i = 0;
        var fromPoint = state.points[0];
        var toPoint = null;

        while(i < state.points.length ) {
          var nextPoint = i+1;
          if(state.points.asMap().containsKey(nextPoint)) {
            toPoint = state.points[nextPoint];
          }
          if(toPoint != null) {
            canvas.drawLine(fromPoint, toPoint, linePaint());
            fromPoint = toPoint;
            toPoint = null;
          }
          i = nextPoint;
        }
      }

      state.points.forEach((point) {
        if(state.ellipseImage != null)
        {
          canvas.drawImage(state.ellipseImage!, state.ellipseImagePoint(point), ui.Paint());
        }
        else
        {
          canvas.drawCircle(point, 13, circlePaint());
        }

      });

      if(state.currentStartPoint != null && state.targetEndPoint != null) {
        canvas.drawLine(state.currentStartPoint!, state.targetEndPoint!, linePaint());
        if(state.cursorImage != null) {

          canvas.drawImage(state.cursorImage!,  state.cursorImagePoint(), ui.Paint());
        }
      }

  }

  ui.Paint linePaint() {
    final p = ui.Paint();
    p.strokeWidth = 10;
    return p;
  }

  ui.Paint circlePaint() {
    final p = ui.Paint();
    p.strokeWidth = 5;
    p.color = Color.fromRGBO(100, 0, 0, 1);

    return p;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}