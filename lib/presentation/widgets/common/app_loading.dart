import 'package:flutter/material.dart';

class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.color,
    this.size = 24,
    this.strokeWidth = 2.5,
    this.value,
    this.valueColor,
  });

  final Color? color;
  final double size;
  final double strokeWidth;
  final double? value;
  final Animation<Color?>? valueColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth,
        value: value,
        valueColor: valueColor,
      ),
    );
  }
}

class AppLoadingState extends StatelessWidget {
  const AppLoadingState({
    super.key,
    this.color,
    this.size = 28,
    this.strokeWidth = 2.5,
    this.padding = EdgeInsets.zero,
  });

  final Color? color;
  final double size;
  final double strokeWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding,
        child: AppLoadingIndicator(
          color: color,
          size: size,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
