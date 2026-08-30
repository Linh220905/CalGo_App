import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/onboarding_provider.dart';
import 'personalization_widgets.dart';

class _ChannelItem {
  final String label;
  final Object icon;
  final Color brandColor;
  final Color backgroundColor;

  const _ChannelItem(
      this.label, this.icon, this.brandColor, this.backgroundColor);
}

class ReferralStep extends StatefulWidget {
  const ReferralStep({super.key});

  @override
  State<ReferralStep> createState() => _ReferralStepState();
}

class _ReferralStepState extends State<ReferralStep> {
  static const _channelIcons = <(Object, Color, Color)>[
    (FontAwesomeIcons.tiktok, Color(0xFF000000), Color(0xFFF1F5F9)),
    (FontAwesomeIcons.facebook, Color(0xFF1877F2), Color(0xFFEFF6FF)),
    (FontAwesomeIcons.youtube, Color(0xFFFF0000), Color(0xFFFEF2F2)),
    (FontAwesomeIcons.instagram, Color(0xFFE4405F), Color(0xFFFDF2F8)),
    (FontAwesomeIcons.threads, Color(0xFF000000), Color(0xFFF8FAFC)),
    (FontAwesomeIcons.linkedin, Color(0xFF0077B5), Color(0xFFF0F9FF)),
    (FontAwesomeIcons.xTwitter, Color(0xFF1DA1F2), Color(0xFFF0F9FF)),
    (Icons.people_alt_rounded, Color(0xFF22C55E), Color(0xFFF0FDF4)),
    (Icons.more_horiz_rounded, Color(0xFF6366F1), Color(0xFFEEF2FF)),
  ];

  static const _channelNames = [
    'TikTok',
    'Facebook',
    'YouTube',
    'Instagram',
    'Threads',
    'LinkedIn'
  ];

  String? _selected;

  @override
  Widget build(BuildContext context) {
    final strings = context.watch<AppSettingsProvider>().strings;
    final names = [
      ..._channelNames,
      strings.referralX,
      strings.referralFriend,
      strings.referralOther,
    ];
    final channels = List.generate(
      names.length,
      (index) => _ChannelItem(
        names[index],
        _channelIcons[index].$1,
        _channelIcons[index].$2,
        _channelIcons[index].$3,
      ),
    );

    return OnboardingQuestionShell(
      title: strings.referralStepTitle,
      note: strings.referralStepSubtitle,
      children: channels
          .map((item) => _ReferralChoiceCard(
                item: item,
                selected: _selected == item.label,
                onTap: () => setState(() => _selected = item.label),
              ))
          .toList(),
      onNext: _selected == null
          ? null
          : () async {
              final provider = context.read<OnboardingProvider>();
              await provider.setReferralSource(_selected!);
              if (context.mounted) await provider.nextStep();
            },
      nextLabel: strings.nextStepButton,
    );
  }
}

class _ReferralChoiceCard extends StatelessWidget {
  final _ChannelItem item;
  final bool selected;
  final VoidCallback onTap;

  const _ReferralChoiceCard({
    required this.item,
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
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFAFAFA) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected
                    ? const Color(0xFF111111)
                    : const Color(0xFFECECEC),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: item.backgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: item.icon is FaIconData
                        ? FaIcon(item.icon as FaIconData,
                            color: item.brandColor, size: 18)
                        : Icon(item.icon as IconData,
                            color: item.brandColor, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.label,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111111))),
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
