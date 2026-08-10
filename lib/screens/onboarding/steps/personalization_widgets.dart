import 'package:flutter/material.dart';

class OnboardingQuestionShell extends StatelessWidget {
  final String title;
  final String note;
  final List<Widget> children;
  final VoidCallback? onNext;
  final String nextLabel;

  const OnboardingQuestionShell({
    super.key,
    required this.title,
    required this.note,
    required this.children,
    required this.onNext,
    required this.nextLabel,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final headerHeight =
                        (constraints.maxHeight * 0.30).clamp(150.0, 190.0);
                    final compactHeader = headerHeight < 175;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: headerHeight,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 28),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/images/apple_mascot/apple_thinking.png',
                                    height: compactHeader ? 60 : 78,
                                    fit: BoxFit.contain,
                                  ),
                                  SizedBox(height: compactHeader ? 3 : 6),
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF111111),
                                      height: 1.15,
                                    ),
                                  ),
                                  if (note.isNotEmpty) ...[
                                    SizedBox(height: compactHeader ? 3 : 4),
                                    Text(
                                      note,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: compactHeader ? 11 : 12,
                                        height: 1.25,
                                        color: const Color(0xFF71717A),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              children: [
                                ...children,
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onNext == null
                          ? const Color(0xFFECECEC)
                          : const Color(0xFF111111),
                      foregroundColor: onNext == null
                          ? const Color(0xFFAAAAAA)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                    child: Text(nextLabel,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class OnboardingChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const OnboardingChoiceCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: selected ? const Color(0xFFFAFAFA) : Colors.white,
              border: Border.all(
                  color: selected
                      ? const Color(0xFF111111)
                      : const Color(0xFFECECEC),
                  width: selected ? 1.5 : 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111111))),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(subtitle,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF71717A))),
                      ],
                    ],
                  ),
                ),
                if (selected)
                  Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                        color: Color(0xFF111111), shape: BoxShape.circle),
                    child:
                        const Icon(Icons.check, color: Colors.white, size: 14),
                  ),
              ],
            ),
          ),
        ),
      );
}

class OnboardingMultiChoiceCard extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const OnboardingMultiChoiceCard({
    super.key,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: selected ? const Color(0xFFFAFAFA) : Colors.white,
              border: Border.all(
                  color: selected
                      ? const Color(0xFF111111)
                      : const Color(0xFFECECEC),
                  width: selected ? 1.5 : 1),
            ),
            child: Row(children: [
              Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111)))),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      selected ? const Color(0xFF111111) : Colors.transparent,
                  border: selected
                      ? null
                      : Border.all(color: const Color(0xFFD0D0D0), width: 2),
                ),
                child: selected
                    ? const Icon(Icons.check, color: Colors.white, size: 14)
                    : null,
              ),
            ]),
          ),
        ),
      );
}
