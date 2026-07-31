import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum TaoExpression {
  hello,
  happy,
  thinking,
  analyzing,
  sympathetic,
  excited,
  playful,
}

class TaoWidget extends StatelessWidget {
  final TaoExpression expression;
  final double size;

  const TaoWidget({
    super.key,
    this.expression = TaoExpression.hello,
    this.size = 120,
  });

  String get _assetPath {
    switch (expression) {
      case TaoExpression.hello:
        return 'assets/images/tao/tao_hello.svg';
      case TaoExpression.happy:
        return 'assets/images/tao/tao_happy.svg';
      case TaoExpression.thinking:
        return 'assets/images/tao/tao_thinking.svg';
      case TaoExpression.analyzing:
        return 'assets/images/tao/tao_analyzing.svg';
      case TaoExpression.sympathetic:
        return 'assets/images/tao/tao_sympathetic.svg';
      case TaoExpression.excited:
        return 'assets/images/tao/tao_excited.svg';
      case TaoExpression.playful:
        return 'assets/images/tao/tao_playful.svg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      _assetPath,
      width: size,
      height: size,
      placeholderBuilder: (ctx) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E5E5),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(Icons.apple, size: size * 0.5, color: Colors.red.shade400),
      ),
    );
  }
}
