import 'package:flutter/material.dart';
import 'dart:math';

class Dial extends StatefulWidget {
  final Widget child;
  final Function updateWeight;
  Dial({ Key key, this.child, this.updateWeight}) : super(key: key);

  @override
  DialState createState() => DialState();
}

class DialState extends State<Dial> {
  Size _screenSize = Size(0.0, 0.0);
  double _angle = 0.0;

  void setAngleFromValue(value) {
    double percentage = value / 999.99;
    setState(() {
      _angle = toDeg(pi + 1) * percentage;
    });
  }

  void _setAngleFromPosition(pos) {
    Offset position = Offset(pos.dx, pos.dy - 60); // adjust y by 60 because of AppBar height
    double dx = _screenSize.width / 2 - position.dx;
    double dy = _screenSize.height / 2 - position.dy;
    double adj = dx.abs();
    double hyp = sqrt(pow(dx, 2) + pow(dy, 2));
    double theta = acos(adj / hyp);
    if (position.dx <= _screenSize.width / 2) {
      if (position.dy <= _screenSize.height / 2) {
        // QUAD 2
        theta += 0.5;
      } else if (position.dy > _screenSize.height / 2) {
        // QUAD 3
        theta *= -1;
        theta += 0.5;
      }
    } else if (position.dx > _screenSize.width / 2) {
      if (position.dy <= _screenSize.height / 2) {
        // QUAD 1
        theta = pi - theta + 0.5;
      } else if (position.dy > _screenSize.height / 2) {
        // QUAD 4
        theta = pi + theta + 0.5;
      }
    }
    double percentage = theta / (pi + 1);
    // Give a min and max to the percentage
    percentage = percentage > 1 ? 1.0 : percentage;
    percentage = percentage < 0 ? 0.0 : percentage;

    // Update parent, and global state w/ callback
    widget.updateWeight(999.99 * percentage);
    // Update local state
    setState(() {
      _angle = toDeg(pi + 1) * percentage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_screenSize != MediaQuery.of(context).size) {
      setState(() {
        _screenSize = MediaQuery.of(context).size;
      });
    }
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        _setAngleFromPosition(details.globalPosition);
      },
      onPanStart: (DragStartDetails details) {
        _setAngleFromPosition(details.globalPosition);
      },
      onPanUpdate: (DragUpdateDetails details) {
        _setAngleFromPosition(details.globalPosition);
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: CustomPaint(
          painter: DialPainter(angle: _angle),
          child: widget.child,
        ),
      ),
    );
  }
}

class DialPainter extends CustomPainter {
  double angle;
  DialPainter({this.angle});

  final startAngle = pi - 0.5;
  final endAngle = pi + 1;

  Paint getDialPaint() {
    Paint paint = Paint();
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 14.0;
    paint.strokeCap = StrokeCap.round;
    return paint;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var rect = Offset(15.0, 15.0) & Size.square(size.width - 30.0);
    Paint paint = getDialPaint();
    paint.color = Color.fromARGB(60, 60, 60, 100);
    canvas.drawArc(rect, startAngle, endAngle, false, paint);
    paint.color = Colors.blue;
    canvas.drawArc(rect, startAngle, toRad(angle), false, paint);
  }

  @override
  bool shouldRepaint(DialPainter oldDelegate) => oldDelegate.angle != this.angle;
}

double toRad(deg) {
  return (deg / 180) * pi;
}

double toDeg(rad) {
  return (rad / pi) * 180;
}