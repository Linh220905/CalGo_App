import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../widgets/premium_ui.dart';

class SocialProofStep extends StatelessWidget {
  const SocialProofStep({super.key});

  static const _reviews = [
    (
      name: 'Minh Anh',
      avatarColor: Color(0xFFE0F2FE),
      textColor: Color(0xFF0369A1),
      initials: 'MA',
      tag: 'Giảm 6.5 kg',
      time: '2 ngày trước',
      title: 'Quét đồ ăn Việt Nam cực chuẩn!',
      content:
          'Trước đây mình dùng app ngoại tra phở, bún chả rất cực. CalGo chụp ảnh nhận diện món Việt chính xác từng gram calo luôn. 10/10!',
    ),
    (
      name: 'Hoàng Nam',
      avatarColor: Color(0xFFFEF3C7),
      textColor: Color(0xFFB45309),
      initials: 'HN',
      tag: 'Tăng cơ 4 kg',
      time: '5 ngày trước',
      title: 'Giao diện mượt, tính TDEE sát thực tế',
      content:
          'Thước đo BMI và gợi ý macro rất chi tiết. Mình tập gym kết hợp theo dõi calo mỗi ngày, cơ thể săn chắc rõ rệt sau 1 tháng.',
    ),
    (
      name: 'Thu Phương',
      avatarColor: Color(0xFFFCE7F3),
      textColor: Color(0xFFBE185D),
      initials: 'TP',
      tag: 'Duy trì vóc dáng',
      time: '1 tuần trước',
      title: 'Tạo thói quen ăn uống lành mạnh',
      content:
          'Linh vật Táo nhắc nhở đáng yêu lắm. App không hề ép ăn kiêng hà khắc mà hướng dẫn cân bằng dinh dưỡng thông minh.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // ── Header ──
              Animate(
                effects: const [
                  FadeEffect(duration: Duration(milliseconds: 500)),
                  SlideEffect(
                    begin: Offset(0, -12),
                    end: Offset.zero,
                    duration: Duration(milliseconds: 500),
                  ),
                ],
                child: const Column(
                  children: [
                    Text(
                      'Cộng đồng nói gì về CalGo?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111111),
                        letterSpacing: -0.4,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Đánh giá chân thực từ người trải nghiệm',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF71717A),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── App Rating Summary Card ──
              Animate(
                effects: const [
                  FadeEffect(
                      duration: Duration(milliseconds: 500),
                      delay: Duration(milliseconds: 150)),
                  ScaleEffect(
                      begin: Offset(0.96, 0.96),
                      end: Offset(1, 1),
                      duration: Duration(milliseconds: 500)),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAFAFA),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Text(
                              '4.9',
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111111),
                                height: 1.0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (index) => const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFFFFB800),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF111111),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded,
                                color: Colors.white, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Đánh giá 5★',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ── Authentic Reviews List ──
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: List.generate(_reviews.length, (i) {
                      final item = _reviews[i];
                      return Animate(
                        effects: [
                          FadeEffect(
                            duration: const Duration(milliseconds: 500),
                            delay: Duration(milliseconds: 250 + i * 150),
                          ),
                          SlideEffect(
                            begin: const Offset(0, 16),
                            end: Offset.zero,
                            duration: const Duration(milliseconds: 500),
                            delay: Duration(milliseconds: 250 + i * 150),
                          ),
                        ],
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFEEEEEE)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User header: avatar + name + verified tag + stars
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: item.avatarColor,
                                    child: Text(
                                      item.initials,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: item.textColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF111111),
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              size: 14,
                                              color: Color(0xFF10B981),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.tag} • ${item.time}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF71717A),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      5,
                                      (s) => const Icon(
                                        Icons.star_rounded,
                                        color: Color(0xFFFFB800),
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              // Review title
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111111),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Review text
                              Text(
                                item.content,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF4B5563),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),

              // ── Continue Button ──
              Animate(
                effects: const [
                  FadeEffect(
                      duration: Duration(milliseconds: 500),
                      delay: Duration(milliseconds: 700)),
                ],
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12, top: 8),
                  child: PremiumButton(
                    label: 'Tiếp tục',
                    onPressed: () =>
                        context.read<OnboardingProvider>().nextStep(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
