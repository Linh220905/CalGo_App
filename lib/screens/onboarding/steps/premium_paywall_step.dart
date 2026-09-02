import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/app_build_config.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../widgets/social_auth_button.dart';
import '../../../widgets/premium_ui.dart';
import '../../../services/trial_notification_service.dart';
import '../../../services/analytics_service.dart';
import '../../../services/revenuecat_service.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../utils/payment_platform.dart';
import 'post_premium_quiz_dialog.dart';

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

// Font riêng cho toàn màn hình — khác với font hệ thống mặc định
TextStyle _f(
  double size, {
  FontWeight weight = FontWeight.w500,
  Color color = _kInk,
  double? height,
  double? letterSpacing,
}) => GoogleFonts.plusJakartaSans(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: letterSpacing,
);

enum _Plan { weekly, annual, monthly }

class PremiumPaywallStep extends StatefulWidget {
  final bool onboardingMode;
  final String source;

  const PremiumPaywallStep({
    super.key,
    this.onboardingMode = true,
    this.source = 'onboarding',
  });

  @override
  State<PremiumPaywallStep> createState() => _PremiumPaywallStepState();
}

class _PremiumPaywallStepState extends State<PremiumPaywallStep> {
  _Plan _selectedPlan = _Plan.annual;
  bool _enableFreeTrial = true;
  bool _showClose = false;
  bool _hasShownDownsell = false;
  Timer? _closeTimer;
  PaymentProvider? _payment;
  bool _handledPremiumSuccess = false;
  bool _finishingPurchase = false;
  bool _quizCompleted = false;
  bool _trialNotificationScheduled = false;
  String? _lastShownPaymentError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.canPop(context)) {
        setState(() => _showClose = true);
      }
      if (mounted) {
        // This is deliberately best-effort. Before AccountStep there is no
        // auth token yet, so AnalyticsService queues the event and flushes it
        // immediately after the user signs in.
        final analytics = context.read<AnalyticsService?>();
        if (analytics != null) {
          unawaited(analytics.trackPaywallViewed(source: widget.source));
        }
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
    if (!mounted) return;
    final paymentError = _payment?.error;
    final state = _payment?.purchaseStates.values
        .where((value) => value == PurchaseState.error)
        .isNotEmpty;
    if (state == true &&
        paymentError != null &&
        paymentError != _lastShownPaymentError) {
      _lastShownPaymentError = paymentError;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              paymentCopyForPlatform(
                'Google Play đã nhận giao dịch nhưng máy chủ chưa xác minh được. '
                'Vui lòng thử Khôi phục giao dịch sau khi cập nhật máy chủ.',
              ),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      });
    }
    if (_handledPremiumSuccess) return;
    final plan =
        _payment?.activePremiumOffer?.plan ?? _toPremiumPlan(_selectedPlan);
    if (_payment?.purchaseStates[PaymentProvider.productIdForPremiumPlan(
          plan,
        )] !=
        PurchaseState.purchased) {
      return;
    }
    _handledPremiumSuccess = true;
    unawaited(_handlePremiumSuccess());
  }

  Future<void> _handlePremiumSuccess() async {
    if (_finishingPurchase) return;
    setState(() => _finishingPurchase = true);
    final auth = context.read<AuthProvider>();
    final payment = context.read<PaymentProvider>();

    final verification = payment.lastSubscriptionVerification;
    final offer = payment.activePremiumOffer;
    final analytics = context.read<AnalyticsService?>();
    if (analytics != null && verification?['is_restored'] != true) {
      unawaited(
        analytics.trackPremiumPurchased(
          source: widget.source,
          productId:
              verification?['product_id'] as String? ??
              offer?.product.id ??
              PaymentProvider.productIdForPremiumPlan(
                offer?.plan ?? _toPremiumPlan(_selectedPlan),
              ),
          plan: (offer?.plan ?? _toPremiumPlan(_selectedPlan)).name,
          price: offer?.product.rawPrice,
          currency: offer?.product.currencyCode,
        ),
      );
    }
    final isTrial = verification?['is_trial'] == true;
    final verifiedTrialDays = (verification?['trial_days'] as num?)?.toInt();
    final trialDays =
        verifiedTrialDays ?? payment.activePremiumOffer?.trialDays ?? 0;
    final rawTrialEnd = verification?['trial_end'];
    final trialEnd = rawTrialEnd is DateTime
        ? rawTrialEnd
        : rawTrialEnd is String
        ? DateTime.tryParse(rawTrialEnd)
        : null;
    if (isTrial && trialDays > 0 && !_trialNotificationScheduled) {
      await TrialNotificationService.instance.scheduleTrialSequence(
        trialDays: trialDays,
        trialEnd: trialEnd,
      );
      _trialNotificationScheduled = true;
    }

    if (!mounted) return;
    if (!_quizCompleted) {
      // Purchase updates can be replayed whenever the Premium page is opened.
      // Do not show the personalization quiz again after it was completed on
      // this device/account.
      _quizCompleted = true;
      final accountId = auth.user?.id;
      final alreadyCompleted = await context
          .read<OnboardingProvider>()
          .hasPremiumCustomization(accountId: accountId);
      if (!alreadyCompleted) {
        await _triggerPostPurchaseQuiz();
      }
    }
    if (!mounted) return;

    if (widget.onboardingMode) {
      final onboarding = context.read<OnboardingProvider>();
      final home = context.read<HomeProvider>();
      final saved = await onboarding.completeOnboarding(
        authProvider: auth,
        homeProvider: home,
      );
      if (!mounted) return;
      if (!saved) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể lưu hồ sơ. Vui lòng thử lại.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        setState(() => _finishingPurchase = false);
        return;
      }
      await home.loadToday(forceRefresh: true);
      if (mounted) context.go('/home');
      return;
    }

    if (Navigator.canPop(context)) Navigator.pop(context);
  }

  void _handleClose() {
    if (!_hasShownDownsell) {
      _showWinbackDownsellDialog();
      return;
    }
    _proceedClose();
  }

  void _proceedClose() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      try {
        context.read<OnboardingProvider>().nextStep();
      } catch (_) {}
    }
  }

  void _showWinbackDownsellDialog() {
    setState(() => _hasShownDownsell = true);
    final payment = context.read<PaymentProvider>();
    final winback = payment.premiumOfferWithTag(PremiumPlan.annual, 'winback');
    if (winback == null) {
      _proceedClose();
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(22),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '🔥 ƯU ĐÃI DÀNH RIÊNG',
                style: _f(
                  10.5,
                  weight: FontWeight.w800,
                  color: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Chờ chút! Tiếp tục với gói ${winback.recurringPrice}/năm',
              textAlign: TextAlign.center,
              style: _f(18, weight: FontWeight.w800, letterSpacing: -0.3),
            ),
            const SizedBox(height: 8),
            Text(
              'Mức giá và điều kiện ưu đãi được xác nhận trực tiếp bởi cửa hàng.',
              textAlign: TextAlign.center,
              style: _f(12.5, color: _kMuted, height: 1.35),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _selectedPlan = _Plan.annual;
                    _enableFreeTrial = winback.hasFreeTrial;
                  });
                  _handlePrimaryAction(selectedOffer: winback);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kAccent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Đăng ký ${winback.recurringPrice}/năm',
                  style: _f(14, weight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                _proceedClose();
              },
              child: Text(
                'Bỏ qua ưu đãi',
                style: _f(12, color: _kMuted, weight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerPostPurchaseQuiz() {
    return PostPremiumQuizDialog.show(context, onCompleted: () async {});
  }

  Future<bool> _ensureAuthenticated() async {
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated) return true;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        var googleBusy = false;
        var appleBusy = false;
        String? error;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Future<void> signIn(String method) async {
              if (googleBusy || appleBusy) return;
              setSheetState(() {
                if (method == 'google') {
                  googleBusy = true;
                } else {
                  appleBusy = true;
                }
                error = null;
              });
              final provider = context.read<AuthProvider>();
              final success = method == 'google'
                  ? await provider.signInWithGoogle()
                  : await provider.signInWithApple();
              if (!sheetContext.mounted) return;
              if (!success) {
                setSheetState(() {
                  if (method == 'google') {
                    googleBusy = false;
                  } else {
                    appleBusy = false;
                  }
                  error = provider.error ?? 'Đăng nhập không thành công.';
                });
                return;
              }
              await context.read<OnboardingProvider>().setAccountMethod(method);
              if (sheetContext.mounted) Navigator.pop(sheetContext, true);
            }

            final showApple =
                defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS;
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  22,
                  18,
                  22,
                  MediaQuery.of(context).viewInsets.bottom + 22,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lưu Premium vào tài khoản của bạn',
                      textAlign: TextAlign.center,
                      style: _f(21, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Đăng nhập một lần để xác minh giao dịch và đồng bộ kế hoạch cá nhân hóa.',
                      textAlign: TextAlign.center,
                      style: _f(12.5, color: _kMuted, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    SocialAuthButton(
                      type: SocialAuthType.google,
                      label: 'Tiếp tục với Google',
                      isLoading: googleBusy,
                      onTap: () => signIn('google'),
                    ),
                    if (showApple) ...[
                      const SizedBox(height: 12),
                      SocialAuthButton(
                        type: SocialAuthType.apple,
                        label: 'Tiếp tục với Apple',
                        isLoading: appleBusy,
                        onTap: () => signIn('apple'),
                      ),
                    ],
                    if (error != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        error!,
                        textAlign: TextAlign.center,
                        style: _f(11.5, color: Colors.redAccent),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: googleBusy || appleBusy
                          ? null
                          : () => Navigator.pop(sheetContext, false),
                      child: const Text('Để sau'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (!mounted) return false;
    return result == true && auth.isAuthenticated;
  }

  Future<void> _handlePrimaryAction({PremiumOffer? selectedOffer}) async {
    final payment = context.read<PaymentProvider>();
    final auth = context.read<AuthProvider>();
    final s = context.read<AppSettingsProvider>().strings;
    const testing = AppBuildConfig.isTesting;

    if (testing) {
      await _triggerPostPurchaseQuiz();
      return;
    }

    if (!await _ensureAuthenticated() || !mounted) return;

    // Try RevenueCat purchase first
    try {
      final offerings = await RevenueCatService.getOfferings();
      final currentOffering = offerings?.current;
      if (currentOffering != null && currentOffering.availablePackages.isNotEmpty) {
        Package? pkg;
        if (_selectedPlan == _Plan.weekly) {
          pkg = currentOffering.weekly ?? currentOffering.availablePackages.firstWhere(
            (p) => p.packageType == PackageType.weekly,
            orElse: () => currentOffering.availablePackages.first,
          );
        } else if (_selectedPlan == _Plan.monthly) {
          pkg = currentOffering.monthly ?? currentOffering.availablePackages.firstWhere(
            (p) => p.packageType == PackageType.monthly,
            orElse: () => currentOffering.availablePackages.first,
          );
        } else {
          pkg = currentOffering.annual ?? currentOffering.availablePackages.firstWhere(
            (p) => p.packageType == PackageType.annual,
            orElse: () => currentOffering.availablePackages.first,
          );
        }

        final success = await RevenueCatService.purchasePackage(pkg);
        if (!mounted) return;
        if (success) {
          await _handlePremiumSuccess();
          return;
        }
      }
    } catch (e) {
      debugPrint('[Paywall] RevenueCat purchase error: $e');
    }

    final plan = _toPremiumPlan(_selectedPlan);
    final preferTrial =
        selectedOffer?.hasFreeTrial ??
        (_enableFreeTrial && payment.hasTrialOffer(plan));
    final started = await payment.buyPremium(
      plan,
      preferFreeTrial: preferTrial,
      selectedOffer: selectedOffer,
      applicationUserName: auth.user?.id,
    );
    if (!mounted) return;

    if (started) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(paymentCopyForPlatform(s.paymentProcessing))),
      );
    } else {
      final errorMsg = payment.error ?? s.premiumPaymentFailed;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg), backgroundColor: Colors.redAccent),
      );
    }
  }

  PremiumPlan _toPremiumPlan(_Plan plan) => switch (plan) {
    _Plan.weekly => PremiumPlan.weekly,
    _Plan.monthly => PremiumPlan.monthly,
    _Plan.annual => PremiumPlan.annual,
  };

  /// Known trial days per plan for the QA/testing build only.
  static int _knownTrialDays(_Plan plan) => switch (plan) {
    _Plan.weekly => 0, // Weekly never has a trial
    _Plan.monthly => 3,
    _Plan.annual => 7,
  };

  int _currentTrialDays(PaymentProvider payment) {
    if (!_enableFreeTrial) return 0;
    if (AppBuildConfig.isTesting) {
      return _knownTrialDays(_selectedPlan);
    }
    // The Store is authoritative. Never promise a trial until the platform
    // product metadata confirms that the user can actually redeem it.
    final storeDays = payment
        .premiumOffer(_toPremiumPlan(_selectedPlan), preferFreeTrial: true)
        ?.trialDays;
    if (storeDays != null && storeDays > 0) return storeDays;
    return 0;
  }

  String _getButtonLabel(
    String fallback,
    String testingLabel,
    PaymentProvider payment,
  ) {
    const testing = AppBuildConfig.isTesting;
    if (testing) return testingLabel;
    if (_selectedPlan == _Plan.weekly) {
      return 'Thay đổi bản thân ngay';
    }
    final days = _currentTrialDays(payment);
    if (_enableFreeTrial && days > 0) {
      return 'Dùng miễn phí ngay';
    }
    return 'Thay đổi bản thân ngay';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    const testing = AppBuildConfig.isTesting;
    final s = context.watch<AppSettingsProvider>().strings;
    final payment = context.watch<PaymentProvider>();
    final premiumState =
        payment.purchaseStates[PaymentProvider.productIdForPremiumPlan(
          _toPremiumPlan(_selectedPlan),
        )];
    final buying =
        _finishingPurchase ||
        payment.purchaseInProgress ||
        premiumState == PurchaseState.loading ||
        premiumState == PurchaseState.pending ||
        premiumState == PurchaseState.verifying;
    final activated = testing || premiumState == PurchaseState.purchased;
    final trialDays = _currentTrialDays(payment);
    // Weekly plan never has a trial. Monthly and annual show the toggle only
    // when the Store has confirmed an eligible introductory offer.
    final trialAvailable = testing || _selectedPlan != _Plan.weekly;
    final trialEnabled = _enableFreeTrial && trialAvailable && trialDays > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: (screenHeight * 0.26).clamp(190.0, 240.0),
                child: _HeroSection(
                  showClose: _showClose,
                  onClose: _handleClose,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                child: Column(
                  children: [
                    const _Headline(),
                    const SizedBox(height: 12),
                    const _ExperienceRow(),
                    const SizedBox(height: 14),

                    // Free Trial Toggle Row
                    if (trialAvailable) ...[
                      _FreeTrialToggleRow(
                        enabled: trialEnabled,
                        onChanged: (v) => setState(() => _enableFreeTrial = v),
                        trialDays: trialDays,
                      ),
                      const SizedBox(height: 12),
                    ],

                    _PricingRow(
                      selectedPlan: _selectedPlan,
                      enableFreeTrial: _enableFreeTrial,
                      onChanged: (p) => setState(() => _selectedPlan = p),
                      testing: testing,
                    ),

                    if (trialEnabled) ...[
                      const SizedBox(height: 14),
                      _VisualPaymentTimeline(trialDays: trialDays),
                    ],

                    const SizedBox(height: 16),
                    PremiumButton(
                      label: widget.onboardingMode
                          ? testing
                                ? s.continueFreePremium
                                : activated
                                ? _quizCompleted
                                      ? 'Hoàn tất thiết lập'
                                      : s.premiumActivated
                                : buying
                                ? s.processingShort
                                : _getButtonLabel(
                                    s.continueLabel,
                                    s.continueFreePremium,
                                    payment,
                                  )
                          : testing
                          ? s.premiumFreeUnlocked
                          : activated
                          ? s.premiumActivated
                          : buying
                          ? s.processingShort
                          : _getButtonLabel(
                              s.subscribePremium,
                              s.premiumFreeUnlocked,
                              payment,
                            ),
                      loading: buying,
                      onPressed: buying
                          ? null
                          : activated && widget.onboardingMode
                          ? _handlePremiumSuccess
                          : activated
                          ? null
                          : () => _handlePrimaryAction(),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      testing
                          ? s.premiumTestingNote
                          : trialEnabled
                          ? paymentCopyForPlatform(
                              'Không tính phí hôm nay. Hủy bất kỳ lúc nào trong cài đặt App Store / Google Play.',
                            )
                          : s.premiumAutoRenewNote,
                      textAlign: TextAlign.center,
                      style: _f(11, color: _kMuted, weight: FontWeight.w500),
                    ),
                    const SizedBox(height: 10),
                    const _FooterLinks(showBilling: !testing),
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
                      type: _IconType.image,
                      color: _kMuted,
                      size: 30,
                    ),
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
                        0.0,
                      ), // Start white fade from transparent
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
                      1.0,
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
                            size: 12,
                          ),
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
              Text(
                s.premiumHeadlineBefore,
                style: _f(28, weight: FontWeight.w800, letterSpacing: -0.4),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _kAccent,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  s.todayLower,
                  style: _f(
                    28,
                    weight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
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
            style: _f(
              16,
              weight: FontWeight.w800,
              height: 1.15,
              letterSpacing: -0.3,
            ),
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
                            color: _kAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: _VecIcon(
                              type: _IconType.check,
                              color: Colors.white,
                              size: 8,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t,
                            style: _f(
                              11.5,
                              weight: FontWeight.w600,
                              height: 1.25,
                            ),
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
  final bool enableFreeTrial;
  final ValueChanged<_Plan> onChanged;
  final bool testing;

  const _PricingRow({
    required this.selectedPlan,
    required this.enableFreeTrial,
    required this.onChanged,
    required this.testing,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final payment = context.watch<PaymentProvider>();
    final loading = payment.initializing;
    final weeklyOffer = payment.premiumOffer(
      PremiumPlan.weekly,
      preferFreeTrial:
          enableFreeTrial && payment.hasTrialOffer(PremiumPlan.weekly),
    );
    final monthlyOffer = payment.premiumOffer(
      PremiumPlan.monthly,
      preferFreeTrial:
          enableFreeTrial && payment.hasTrialOffer(PremiumPlan.monthly),
    );
    final annualOffer = payment.premiumOffer(
      PremiumPlan.annual,
      preferFreeTrial:
          enableFreeTrial && payment.hasTrialOffer(PremiumPlan.annual),
    );

    String priceOf(PremiumOffer? offer) {
      if (testing) return s.free;
      if (loading) return '...';
      if (offer != null && offer.recurringPrice.isNotEmpty) {
        return offer.recurringPrice;
      }
      return 'Không khả dụng';
    }

    String trialNote(PremiumOffer? offer, String paidNote) {
      if (testing) return s.testingAccess;
      if (enableFreeTrial && offer?.hasFreeTrial == true) {
        return 'Thử ${offer!.trialDays} ngày \$0';
      }
      return paidNote;
    }

    String weeklyOf(PremiumOffer? offer, _Plan plan) {
      if (testing) {
        return switch (plan) {
          _Plan.weekly => '~29k / tuần',
          _Plan.monthly => '~11k / tuần',
          _Plan.annual => '~9k / tuần',
        };
      }
      return offer?.weeklyPrice != null ? '${offer!.weeklyPrice} / tuần' : '';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: _PriceCard(
            title: s.planWeek,
            price: priceOf(weeklyOffer),
            note: trialNote(weeklyOffer, s.weeklyPayment),
            weeklyLabel: weeklyOf(weeklyOffer, _Plan.weekly),
            selected: selectedPlan == _Plan.weekly,
            highlighted: false,
            onTap: () => onChanged(_Plan.weekly),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PriceCard(
            title: s.planYear,
            price: priceOf(annualOffer),
            note: trialNote(annualOffer, 'Thanh toán mỗi năm'),
            weeklyLabel: weeklyOf(annualOffer, _Plan.annual),
            selected: selectedPlan == _Plan.annual,
            highlighted: true,
            badge:
                enableFreeTrial &&
                    (annualOffer?.hasFreeTrial == true || testing)
                ? 'THỬ ${testing ? 7 : annualOffer!.trialDays} NGÀY \$0'
                : s.popularMost,
            onTap: () => onChanged(_Plan.annual),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PriceCard(
            title: s.planMonth,
            price: priceOf(monthlyOffer),
            note: trialNote(monthlyOffer, 'Thanh toán mỗi tháng'),
            weeklyLabel: weeklyOf(monthlyOffer, _Plan.monthly),
            selected: selectedPlan == _Plan.monthly,
            highlighted: false,
            badge: enableFreeTrial && monthlyOffer?.hasFreeTrial == true
                ? 'THỬ ${monthlyOffer!.trialDays} NGÀY \$0'
                : null,
            onTap: () => onChanged(_Plan.monthly),
          ),
        ),
      ],
    );
  }
}

class _FreeTrialToggleRow extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;
  final int trialDays;

  const _FreeTrialToggleRow({
    required this.enabled,
    required this.onChanged,
    required this.trialDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: enabled ? _kAccentSoft : _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled ? _kAccent.withOpacity(0.4) : _kBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: enabled ? _kAccent : _kMuted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  enabled
                      ? 'Dùng thử $trialDays ngày miễn phí'
                      : 'Bật thử miễn phí $trialDays ngày',
                  style: _f(13, weight: FontWeight.w700, color: _kInk),
                ),
                Text(
                  enabled
                      ? 'Không mất tiền hôm nay, nhắc trước 24h'
                      : 'Thanh toán trực tiếp ngay khi đăng ký',
                  style: _f(10.5, color: _kMuted),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
            activeColor: _kAccent,
          ),
        ],
      ),
    );
  }
}

class _VisualPaymentTimeline extends StatelessWidget {
  final int trialDays;

  const _VisualPaymentTimeline({required this.trialDays});

  @override
  Widget build(BuildContext context) {
    final reminderDay = trialDays > 1 ? trialDays - 1 : 1;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lịch trình thanh toán dùng thử:',
            style: _f(11.5, weight: FontWeight.w700, color: _kInk),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTimelineStep(
                icon: Icons.lock_open_rounded,
                title: 'Hôm nay',
                sub: 'Mở khóa \$0',
                active: true,
              ),
              _buildConnector(),
              _buildTimelineStep(
                icon: Icons.notifications_active_rounded,
                title: 'Ngày $reminderDay',
                sub: 'Push nhắc nhở',
                active: false,
              ),
              _buildConnector(),
              _buildTimelineStep(
                icon: Icons.credit_card_rounded,
                title: 'Ngày $trialDays',
                sub: 'Bắt đầu tính phí',
                active: false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required IconData icon,
    required String title,
    required String sub,
    required bool active,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: active ? _kAccent : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: active ? _kAccent : _kBorder),
            ),
            child: Icon(icon, size: 14, color: active ? Colors.white : _kMuted),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: _f(10.5, weight: FontWeight.w700, color: _kInk),
          ),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: _f(9.5, color: _kMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildConnector() {
    return Container(
      width: 16,
      height: 1,
      margin: const EdgeInsets.only(bottom: 18),
      color: _kBorder,
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String title;
  final String price;
  final String note;
  final String weeklyLabel;
  final bool selected;
  final bool highlighted;
  final String? badge;
  final VoidCallback onTap;

  const _PriceCard({
    required this.title,
    required this.price,
    required this.note,
    required this.weeklyLabel,
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
                  style: _f(
                    9.5,
                    color: _kMuted,
                    height: 1.25,
                    weight: FontWeight.w500,
                  ),
                ),
                if (weeklyLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      weeklyLabel,
                      maxLines: 1,
                      style: _f(9, color: _kAccent, weight: FontWeight.w700),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _kAccent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: _f(8.5, weight: FontWeight.w700, color: Colors.white),
                ),
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

  Future<void> _openLegalPage(String path) {
    return launchUrl(
      Uri.parse('https://calgo.tech/$path'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;

    final style = _f(
      10,
      color: _kMuted,
      weight: FontWeight.w500,
    ).copyWith(decoration: TextDecoration.underline, decorationColor: _kMuted);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 2,
      children: [
        GestureDetector(
          onTap: () => _openLegalPage('terms'),
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
                      restored
                          ? paymentCopyForPlatform(s.restoreChecked)
                          : paymentCopyForPlatform(s.restoreFailed),
                    ),
                    backgroundColor: restored
                        ? const Color(0xFF111111)
                        : Colors.redAccent,
                  ),
                );
              } catch (e) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      paymentCopyForPlatform(s.restoreException(e.toString())),
                    ),
                  ),
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
          onTap: () => _openLegalPage('privacy'),
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
