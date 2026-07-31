import 'package:flutter/material.dart';

class StepContainer extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? mascot;
  final Widget child;
  final Widget? bottomWidget;
  final EdgeInsetsGeometry padding;

  const StepContainer({
    super.key,
    this.title,
    this.subtitle,
    this.mascot,
    required this.child,
    this.bottomWidget,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          const Spacer(flex: 1),
          if (mascot != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: mascot!,
            ),
          if (title != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(title!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111111)),
                  textAlign: TextAlign.center),
            ),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 24, right: 24),
              child: Text(subtitle!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: const Color(0xFF64748B)),
                  textAlign: TextAlign.center),
            ),
          Padding(padding: padding, child: child),
          const Spacer(flex: 2),
          if (bottomWidget != null)
            Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: bottomWidget!),
        ],
      ),
    );
  }
}
