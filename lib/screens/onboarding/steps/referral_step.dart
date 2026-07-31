import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';

class _ChannelItem {
  final String label;
  final IconData icon;
  final Color brandColor;
  final Color bgColor;

  const _ChannelItem(this.label, this.icon, this.brandColor, this.bgColor);
}

class ReferralStep extends StatelessWidget {
  const ReferralStep({super.key});

  static const _channels = <_ChannelItem>[
    _ChannelItem('TikTok', FontAwesomeIcons.tiktok, Color(0xFF000000),
        Color(0xFFF1F5F9)),
    _ChannelItem('Facebook', FontAwesomeIcons.facebook, Color(0xFF1877F2),
        Color(0xFFEFF6FF)),
    _ChannelItem('YouTube', FontAwesomeIcons.youtube, Color(0xFFFF0000),
        Color(0xFFFEF2F2)),
    _ChannelItem('Instagram', FontAwesomeIcons.instagram, Color(0xFFE4405F),
        Color(0xFFFDF2F8)),
    _ChannelItem('Threads', FontAwesomeIcons.threads, Color(0xFF000000),
        Color(0xFFF8FAFC)),
    _ChannelItem('LinkedIn', FontAwesomeIcons.linkedin, Color(0xFF0077B5),
        Color(0xFFF0F9FF)),
    _ChannelItem('X (Twitter)', FontAwesomeIcons.xTwitter, Color(0xFF1DA1F2),
        Color(0xFFF0F9FF)),
    _ChannelItem('Bạn bè giới thiệu', Icons.people_alt_rounded,
        Color(0xFF22C55E), Color(0xFFF0FDF4)),
    _ChannelItem(
        'Khác', Icons.more_horiz_rounded, Color(0xFF6366F1), Color(0xFFEEF2FF)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      const Text(
                        'Bạn biết đến CalGo từ đâu?',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Giúp chúng mình thấu hiểu hành trình của bạn',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 28),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.35,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _channels.length,
                        itemBuilder: (ctx, i) {
                          final item = _channels[i];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                context
                                    .read<OnboardingProvider>()
                                    .setReferralSource(item.label);
                                context.read<OnboardingProvider>().nextStep();
                              },
                              borderRadius: BorderRadius.circular(18),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                      color: const Color(0xFFF1F5F9),
                                      width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.03),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: item.bgColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: FaIcon(
                                          item.icon,
                                          size: 22,
                                          color: item.brandColor,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      item.label,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
