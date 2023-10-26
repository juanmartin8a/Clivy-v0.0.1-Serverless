import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BubbleTabBarIndicator extends Decoration {
  //final double indicatorHeight;
  final Color indicatorColor;
  final double indicatorHeight;
  final double indicatorRadius;

  const BubbleTabBarIndicator({
    this.indicatorColor: Colors.black,
    this.indicatorHeight: 40,
    this.indicatorRadius: 20.0,
  });


  @override
  _CustomPainter createBoxPainter([VoidCallback onChanged]) {
    return new _CustomPainter(this, onChanged);
  }

}

class _CustomPainter extends BoxPainter {
  final BubbleTabBarIndicator decoration;


  _CustomPainter(this.decoration, VoidCallback onChanged)
      : assert(decoration != null),
        super(onChanged);

  double get indicatorHeight => decoration.indicatorHeight;
  Color get indicatorColor => decoration.indicatorColor;
  double get indicatorRadius => decoration.indicatorRadius;

  //double get indicatorHeight => decoration.indicatorHeight;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    assert(configuration != null);
    assert(configuration.size != null);

    final Rect rect = Offset(offset.dx, (configuration.size.height / 2) - indicatorHeight / 2)  & Size(configuration.size.width, indicatorHeight);
    final Paint paint = Paint();
    paint.color = indicatorColor;
    paint.style = PaintingStyle.fill;

    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(indicatorRadius)), paint);
  }

}