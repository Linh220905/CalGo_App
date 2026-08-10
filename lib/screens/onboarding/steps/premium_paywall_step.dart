import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // flutter pub add google_fonts
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import '../../../config/app_build_config.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../widgets/premium_ui.dart';

// ═══════════════════════════════════════════════════════════════
// CONFIG — điền link ảnh nền tại đây
// ═══════════════════════════════════════════════════════════════
class _PaywallAssets {
  /// Asset ảnh nền local dùng trong paywall
  static const String heroImageAsset = 'assets/images/background.png';
}

const _kInk = Color(0xFF111111);
const _kMuted = Color(0xFF7A7A7A);
const _kSurface = Color(0xFFF6F6F6);
const _kBorder = Color(0xFFE6E6E6);
// Một chút màu — cam ấm, dùng tiết chế cho các điểm nhấn quan trọng
const _kAccent = Color(0xFFFF6A3D);
const _kAccentSoft = Color(0xFFFFF1EC);

const _kMonthlyPerWeek = 13600;
const _kAnnualPerWeek = 8600;

String _fmt(int v) {
  final s = v.toString();
  final buf = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    final posFromEnd = s.length - i;
    buf.write(s[i]);
    if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write('.');
  }
  return buf.toString();
}

// Font riêng cho toàn màn hình — khác với font hệ thống mặc định
TextStyle _f(
  double size, {
  FontWeight weight = FontWeight.w500,
  Color color = _kInk,
  double? height,
  double? letterSpacing,
}) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );

enum _Plan { weekly, annual, monthly }

class PremiumPaywallStep extends StatefulWidget {
  final bool onboardingMode;

  const PremiumPaywallStep({
    super.key,
    this.onboardingMode = true,
  });

  @override
  State<PremiumPaywallStep> createState() => _PremiumPaywallStepState();
}

class _PremiumPaywallStepState extends State<PremiumPaywallStep> {
  _Plan _selectedPlan = _Plan.annual;
  bool _showClose = false;
  Timer? _closeTimer;
  PaymentProvider? _payment;
  bool _handledPremiumSuccess = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.canPop(context)) {
        setState(() => _showClose = true);
      }
    });
    _closeTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showClose = true);
    });
  }

  @override
  void dispose() {
    _payment?.removeListener(_onPaymentChanged);
    _closeTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final payment = context.read<PaymentProvider>();
    if (_payment == payment) return;
    _payment?.removeListener(_onPaymentChanged);
    _payment = payment..addListener(_onPaymentChanged);
  }

  void _onPaymentChanged() {
    if (!mounted || widget.onboardingMode || _handledPremiumSuccess) return;
    final plan = _toPremiumPlan(_selectedPlan);
    if (_payment
            ?.purchaseStates[PaymentProvider.productIdForPremiumPlan(plan)] !=
        PurchaseState.purchased) {
      return;
    }
    _handledPremiumSuccess = true;
    context.read<AuthProvider>().refreshUser();
    final s = context.read<AppSettingsProvider>().strings;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.premiumActivatedMessage)),
    );
  }

  void _handleClose() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      try {
        context.read<OnboardingProvider>().nextStep();
      } catch (_) {}
    }
  }

  Future<void> _handlePrimaryAction() async {
    final payment = context.read<PaymentProvider>();
    final s = context.read<AppSettingsProvider>().strings;
    final started = await payment.buyPremium(_toPremiumPlan(_selectedPlan));
    if (!mounted) return;

    if (started) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.paymentProcessing)),
      );
    } else {
      // If billing isn't ready or product SKUs aren't active in Play Console yet,
      // allow user to proceed or show error details.
      final errorMsg = payment.error ?? s.premiumPaymentFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.redAccent,
          action: widget.onboardingMode
              ? SnackBarAction(
                  label: s.continueLabel,
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<OnboardingProvider>().nextStep();
                  },
                )
              : null,
        ),
      );
    }
  }

  PremiumPlan _toPremiumPlan(_Plan plan) => switch (plan) {
        _Plan.weekly => PremiumPlan.weekly,
        _Plan.monthly => PremiumPlan.monthly,
        _Plan.annual => PremiumPlan.annual,
      };

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const testing = AppBuildConfig.isTesting;
    final s = context.watch<AppSettingsProvider>().strings;
    final payment = context.watch<PaymentProvider>();
    final premiumState = payment.purchaseStates[
        PaymentProvider.productIdForPremiumPlan(_toPremiumPlan(_selectedPlan))];
    final buying =
        payment.purchaseInProgress || premiumState == PurchaseState.loading;
    final activated = testing || premiumState == PurchaseState.purchased;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: (screenHeight * 0.28).clamp(200.0, 260.0),
                child: _HeroSection(
                  showClose: _showClose,
                  onClose: _handleClose,
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                child: Column(
                  children: [
                    const _Headline(),
                    const SizedBox(height: 12),
                    const _ExperienceRow(),
                    const SizedBox(height: 14),
                    _PricingRow(
                      selectedPlan: _selectedPlan,
                      onChanged: (p) => setState(() => _selectedPlan = p),
                      testing: testing,
                    ),
                    const SizedBox(height: 16),
                    PremiumButton(
                      label: widget.onboardingMode
                          ? testing
                              ? s.continueFreePremium
                              : s.continueLabel
                          : testing
                              ? s.premiumFreeUnlocked
                              : activated
                                  ? s.premiumActivated
                                  : buying
                                      ? s.processingShort
                                      : s.subscribePremium,
                      onPressed: widget.onboardingMode
                          ? _handlePrimaryAction
                          : testing || buying || activated
                              ? () {}
                              : _handlePrimaryAction,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      testing
                          ? s.premiumTestingNote
                          : widget.onboardingMode
                              ? s.premiumNoChargeNote
                              : s.premiumAutoRenewNote,
                      style: _f(11, color: _kMuted, weight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    _FooterLinks(showBilling: !testing),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HERO
// ═══════════════════════════════════════════════════════════════

class _HeroSection extends StatelessWidget {
  final bool showClose;
  final VoidCallback onClose;

  const _HeroSection({required this.showClose, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        return ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                _PaywallAssets.heroImageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: _kSurface,
                  child: const Center(
                    child: _VecIcon(
                        type: _IconType.image, color: _kMuted, size: 30),
                  ),
                ),
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (frame == null) {
                    return Container(color: _kSurface);
                  }
                  return child;
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.0), // Start fully transparent
                      Colors.black.withOpacity(0.15), // Darken a bit
                      Colors.white.withOpacity(
                          0.0), // Start white fade from transparent
                      Colors.white.withOpacity(0.6),
                      Colors.white.withOpacity(0.9),
                      Colors.white, // End fully white
                    ],
                    stops: const [
                      0.0,
                      0.3,
                      0.4,
                      0.7,
                      0.85,
                      1.0
                    ], // More steps for smoother transition
                  ),
                ),
              ),
              Positioned(
                top: h * 0.04,
                right: w * 0.04,
                child: AnimatedOpacity(
                  opacity: showClose ? 1 : 0,
                  duration: const Duration(milliseconds: 350),
                  child: IgnorePointer(
                    ignoring: !showClose,
                    child: GestureDetector(
                      onTap: onClose,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: _kInk,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: _VecIcon(
                              type: _IconType.close,
                              color: Colors.white,
                              size: 12),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// HEADLINE — bán giá trị, tạo cảm giác hành động ngay
// ═══════════════════════════════════════════════════════════════

class _Headline extends StatelessWidget {
  const _Headline();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(s.premiumHeadlineBefore,
                  style: _f(28, weight: FontWeight.w800, letterSpacing: -0.4)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                    color: _kAccent, borderRadius: BorderRadius.circular(6)),
                child: Text(s.todayLower,
                    style: _f(28,
                        weight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.4)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TRẢI NGHIỆM CỦA BẠN + CHECKLIST
// ═══════════════════════════════════════════════════════════════

class _ExperienceRow extends StatelessWidget {
  const _ExperienceRow();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final items = [
      s.premiumBenefitCalories,
      s.premiumBenefitSuggestions,
      s.premiumBenefitDescriptions,
      s.premiumBenefitProgress,
      s.premiumBenefitSupport,
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 82,
          child: Text(
            s.yourExperience,
            style: _f(16,
                weight: FontWeight.w800, height: 1.15, letterSpacing: -0.3),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items
                .map(
                  (t) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 1),
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                              color: _kAccent, shape: BoxShape.circle),
                          child: const Center(
                            child: _VecIcon(
                                type: _IconType.check,
                                color: Colors.white,
                                size: 8),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t,
                            style:
                                _f(11.5, weight: FontWeight.w600, height: 1.25),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PRICING
// ═══════════════════════════════════════════════════════════════

class _PricingRow extends StatelessWidget {
  final _Plan selectedPlan;
  final ValueChanged<_Plan> onChanged;
  final bool testing;

  const _PricingRow({
    required this.selectedPlan,
    required this.onChanged,
    required this.testing,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final payment = context.watch<PaymentProvider>();
    final loading = payment.initializing;
    final weeklyProduct = payment.premiumProduct(PremiumPlan.weekly);
    final monthlyProduct = payment.premiumProduct(PremiumPlan.monthly);
    final annualProduct = payment.premiumProduct(PremiumPlan.annual);

    String priceOf(ProductDetails? p, String fallback) {
      if (testing) return s.free;
      if (loading) return '...';
      if (p?.price != null && p!.price.isNotEmpty) return p.price;
      return fallback;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _PriceCard(
            title: s.planWeek,
            price: priceOf(weeklyProduct, '29.000đ'),
            note: testing ? s.testingAccess : s.weeklyPayment,
            selected: selectedPlan == _Plan.weekly,
            highlighted: false,
            onTap: () => onChanged(_Plan.weekly),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PriceCard(
            title: s.planYear,
            price: priceOf(annualProduct, '449.000đ'),
            note: testing
                ? s.testingAccess
                : '${_fmt(_kAnnualPerWeek)}đ/${s.weekUnit}',
            selected: selectedPlan == _Plan.annual,
            highlighted: true,
            badge: s.popularMost,
            onTap: () => onChanged(_Plan.annual),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PriceCard(
            title: s.planMonth,
            price: priceOf(monthlyProduct, '59.000đ'),
            note: testing
                ? s.testingAccess
                : '${_fmt(_kMonthlyPerWeek)}đ/${s.weekUnit}',
            selected: selectedPlan == _Plan.monthly,
            highlighted: false,
            onTap: () => onChanged(_Plan.monthly),
          ),
        ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String title;
  final String price;
  final String note;
  final bool selected;
  final bool highlighted;
  final String? badge;
  final VoidCallback onTap;

  const _PriceCard({
    required this.title,
    required this.price,
    required this.note,
    required this.selected,
    required this.highlighted,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(8, badge != null ? 18 : 12, 8, 12),
            decoration: BoxDecoration(
              color: highlighted ? _kAccentSoft : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected ? _kAccent : _kBorder,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: _f(13, weight: FontWeight.w700)),
                const SizedBox(height: 6),
                // FittedBox đảm bảo giá luôn nằm 1 dòng, không bao giờ tràn
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    price,
                    maxLines: 1,
                    softWrap: false,
                    style: _f(17, weight: FontWeight.w800, letterSpacing: -0.3),
                  ),
                ),
                const SizedBox(height: 5),
                Container(height: 1, color: _kBorder),
                const SizedBox(height: 5),
                Text(
                  note,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: _f(9.5,
                      color: _kMuted, height: 1.25, weight: FontWeight.w500),
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: _kAccent, borderRadius: BorderRadius.circular(20)),
                child: Text(badge!,
                    style:
                        _f(8.5, weight: FontWeight.w700, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FOOTER — dùng Wrap để không bao giờ tràn ngang
// ═══════════════════════════════════════════════════════════════

class _FooterLinks extends StatelessWidget {
  final bool showBilling;

  const _FooterLinks({required this.showBilling});

  void _showInfoDialog(BuildContext context, String title, String body) {
    final s = context.read<AppSettingsProvider>().strings;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(body,
              style: const TextStyle(
                  fontSize: 13, height: 1.5, color: Color(0xFF64748B))),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.close, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;

    final style = _f(10, color: _kMuted, weight: FontWeight.w500).copyWith(
      decoration: TextDecoration.underline,
      decorationColor: _kMuted,
    );
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 2,
      children: [
        GestureDetector(
          onTap: () => _showInfoDialog(
            context,
            s.termsOfService,
            s.termsOfServiceContent,
          ),
          child: Text(s.termsOfService, style: style),
        ),
        if (showBilling) ...[
          Text('·', style: _f(10, color: _kMuted)),
          GestureDetector(
            onTap: () async {
              final messenger = ScaffoldMessenger.of(context);
              try {
                final payment = context.read<PaymentProvider>();
                final restored = await payment.restorePurchases();
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      restored ? s.restoreChecked : s.restoreFailed,
                    ),
                    backgroundColor:
                        restored ? const Color(0xFF111111) : Colors.redAccent,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(content: Text(s.restoreException(e.toString()))),
                );
              }
            },
            child: Text(s.restorePurchases, style: style),
          ),
          Text('·', style: _f(10, color: _kMuted)),
          GestureDetector(
            onTap: () async {
              final opened = await context
                  .read<PaymentProvider>()
                  .openSubscriptionManagement();
              if (!context.mounted || opened) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(s.manageSubscriptionFailed)),
              );
            },
            child: Text(s.manageSubscription, style: style),
          ),
        ],
        Text('·', style: _f(10, color: _kMuted)),
        GestureDetector(
          onTap: () => _showInfoDialog(
            context,
            s.privacyPolicy,
            s.privacyPolicyContent,
          ),
          child: Text(s.privacyPolicy, style: style),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// VECTOR ICONS — tự thiết kế, không dùng Material Icons
// ═══════════════════════════════════════════════════════════════

enum _IconType { close, check, grain, drumstick, droplet, image }

class _VecIcon extends StatelessWidget {
  final _IconType type;
  final Color color;
  final double size;

  const _VecIcon({required this.type, required this.color, this.size = 20});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _VecIconPainter(type: type, color: color),
    );
  }
}

class _VecIconPainter extends CustomPainter {
  final _IconType type;
  final Color color;

  _VecIconPainter({required this.type, required this.color});

  Paint _stroke([double w = 1.7]) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s, s);
    switch (type) {
      case _IconType.close:
        canvas.drawLine(const Offset(6, 6), const Offset(18, 18), _stroke(2));
        canvas.drawLine(const Offset(18, 6), const Offset(6, 18), _stroke(2));
        break;
      case _IconType.check:
        final p = Path()
          ..moveTo(4.5, 12.5)
          ..lineTo(9.5, 17.5)
          ..lineTo(19.5, 6.5);
        canvas.drawPath(p, _stroke(2.4));
        break;
      case _IconType.grain:
        final leaf = Path()
          ..moveTo(12, 21)
          ..cubicTo(5, 20, 3, 13, 4.5, 5)
          ..cubicTo(13, 4, 20, 8, 20, 15)
          ..cubicTo(20, 18.5, 16, 21, 12, 21)
          ..close();
        canvas.drawPath(leaf, _stroke());
        canvas.drawLine(const Offset(6, 18), const Offset(18, 6), _stroke(1.3));
        break;
      case _IconType.drumstick:
        canvas.drawCircle(const Offset(9.5, 9.5), 5, _stroke());
        final handle = Path()
          ..moveTo(13, 13)
          ..quadraticBezierTo(18, 15, 20, 20)
          ..quadraticBezierTo(20.5, 21.2, 19.2, 21.2)
          ..quadraticBezierTo(18.4, 21.2, 17.8, 20.4);
        canvas.drawPath(handle, _stroke());
        break;
      case _IconType.droplet:
        final drop = Path()
          ..moveTo(12, 3.5)
          ..cubicTo(16, 9, 19, 12.6, 19, 15.5)
          ..cubicTo(19, 19.6, 15.9, 21.5, 12, 21.5)
          ..cubicTo(8.1, 21.5, 5, 19.6, 5, 15.5)
          ..cubicTo(5, 12.6, 8, 9, 12, 3.5)
          ..close();
        canvas.drawPath(drop, _stroke());
        break;
      case _IconType.image:
        final rect = RRect.fromRectAndRadius(
          const Rect.fromLTWH(3, 4.5, 18, 15),
          const Radius.circular(3),
        );
        canvas.drawRRect(rect, _stroke());
        canvas.drawCircle(const Offset(8.5, 10), 1.8, _stroke(1.3));
        final mountains = Path()
          ..moveTo(4.5, 18)
          ..lineTo(10, 12.5)
          ..lineTo(13.5, 16)
          ..lineTo(16.5, 13)
          ..lineTo(20, 18);
        canvas.drawPath(mountains, _stroke(1.4));
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
