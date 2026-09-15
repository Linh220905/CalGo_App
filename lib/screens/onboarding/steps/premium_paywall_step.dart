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
import '../../../utils/payment_platform.dart';
import '../../../l10n/generated/app_localizations.dart';
import 'post_premium_quiz_dialog.dart';
import 'spin_wheel_dialog.dart';

const _kInk = Color(0xFF111111);
const _kMuted = Color(0xFF7A7A7A);
const _kBorder = Color(0xFFE6E6E6);
const _kAccent = Color(0xFFFF6A3D);

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
  final bool _enableFreeTrial = true;
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
    final s = context.read<AppSettingsProvider>().strings;
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
            content: Text(paymentCopyForPlatform(s.paymentVerificationFailed)),
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
        final s = context.read<AppSettingsProvider>().strings;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.profileSaveFailed),
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
      setState(() => _hasShownDownsell = true);
      SpinWheelDialog.show(
        context,
        onDismiss: _proceedClose,
      );
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
    final s = context.read<AppSettingsProvider>().strings;
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
                s.winbackExclusiveOffer,
                style: _f(
                  10.5,
                  weight: FontWeight.w800,
                  color: Colors.redAccent,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              s.winbackStayTitle(winback.recurringPrice),
              textAlign: TextAlign.center,
              style: _f(18, weight: FontWeight.w800, letterSpacing: -0.3),
            ),
            const SizedBox(height: 8),
            Text(
              s.winbackDisclaimer,
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
                  s.winbackSubscribeButton(winback.recurringPrice),
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
                s.winbackDismissButton,
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
              final s = context.read<AppSettingsProvider>().strings;
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
                  error = provider.error ?? s.signInFailed;
                });
                return;
              }
              await context.read<OnboardingProvider>().setAccountMethod(method);
              if (sheetContext.mounted) Navigator.pop(sheetContext, true);
            }

            final showApple =
                defaultTargetPlatform == TargetPlatform.iOS ||
                defaultTargetPlatform == TargetPlatform.macOS;
            final s = context.read<AppSettingsProvider>().strings;
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
                      s.savePremiumToAccountTitle,
                      textAlign: TextAlign.center,
                      style: _f(21, weight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      s.savePremiumToAccountDesc,
                      textAlign: TextAlign.center,
                      style: _f(12.5, color: _kMuted, height: 1.4),
                    ),
                    const SizedBox(height: 20),
                    SocialAuthButton(
                      type: SocialAuthType.google,
                      label: s.continueWithGoogle,
                      isLoading: googleBusy,
                      onTap: () => signIn('google'),
                    ),
                    if (showApple) ...[
                      const SizedBox(height: 12),
                      SocialAuthButton(
                        type: SocialAuthType.apple,
                        label: s.continueWithApple,
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
                      child: Text(s.cancel),
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
    final s = context.read<AppSettingsProvider>().strings;
    const testing = AppBuildConfig.isTesting;

    if (testing) {
      await _triggerPostPurchaseQuiz();
      return;
    }

    if (!await _ensureAuthenticated() || !mounted) return;

    final plan = _toPremiumPlan(_selectedPlan);
    final preferTrial =
        selectedOffer?.hasFreeTrial ??
        (_enableFreeTrial && payment.hasTrialOffer(plan));
    final started = await payment.buyPremium(
      plan,
      preferFreeTrial: preferTrial,
      selectedOffer: selectedOffer,
    );
    if (!mounted) return;

    if (started) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(paymentCopyForPlatform(s.paymentProcessing))),
      );
    } else {
      final errorMsg = paymentCopyForPlatform(s.paymentVerificationFailed);
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

  int _currentTrialDays(PaymentProvider payment) {
    if (!_enableFreeTrial) return 0;
    if (AppBuildConfig.isTesting) {
      return _selectedPlan == _Plan.annual ? 3 : 0;
    }
    final storeDays = payment
        .premiumOffer(_toPremiumPlan(_selectedPlan), preferFreeTrial: true)
        ?.trialDays;
    if (storeDays != null && storeDays > 0) return storeDays;
    return 0;
  }

  String _getButtonLabel(
    PaymentProvider payment,
    AppLocalizations s,
  ) {
    const testing = AppBuildConfig.isTesting;
    if (testing) return s.continueFreePremium;

    if (_selectedPlan == _Plan.annual) {
      final days = _currentTrialDays(payment);
      if (_enableFreeTrial && days > 0) {
        return s.tryFreeNow; // "Dùng miễn phí ngay" / "Try free now"
      }
      return s.tryFreeNow;
    }

    // Weekly & Monthly: "Thay đổi bản thân ngay" / "Transform your body now"
    return s.changeYourselfNow;
  }

  @override
  Widget build(BuildContext context) {
    const testing = AppBuildConfig.isTesting;
    final s = context.watch<AppSettingsProvider>().strings;
    final payment = context.watch<PaymentProvider>();
    final onboarding = context.watch<OnboardingProvider>();
    final auth = context.watch<AuthProvider>();

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

    // Nutrition values from Onboarding or User model
    final user = auth.user;
    final kcal = (user?.dailyCalorieTarget ?? onboarding.data.targetCaloriesPerDay)
        .round();
    final targetKcal = kcal > 0 ? kcal : 1850;
    final targetProtein = (user?.proteinGrams ?? onboarding.data.targetProteinG)
        .round();
    final proteinVal = targetProtein > 0 ? targetProtein : 125;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar with Close [X] Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AnimatedOpacity(
                    opacity: _showClose ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !_showClose,
                      child: GestureDetector(
                        onTap: _handleClose,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: _kInk,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 4),

                    // Mascot
                    Image.asset(
                      'assets/images/apple_mascot/apple_hello.png',
                      height: 82,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 12),

                    // Headline
                    Text(
                      s.analysisPlanReady, // "Your plan is ready!"
                      textAlign: TextAlign.center,
                      style: _f(26, weight: FontWeight.w800, letterSpacing: -0.5),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.planReadySubtitle, // "Stay on track to reach your goal"
                      textAlign: TextAlign.center,
                      style: _f(14, color: _kMuted, weight: FontWeight.w500),
                    ),
                    const SizedBox(height: 14),

                    // Calorie & Macro Target Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: _kAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$targetKcal kcal',
                            style: _f(13, weight: FontWeight.w700),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: _kMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Icon(
                            Icons.fitness_center_rounded,
                            color: Color(0xFF3B82F6),
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${proteinVal}g protein',
                            style: _f(13, weight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Feature Checklist
                    const _BenefitChecklist(),
                    const SizedBox(height: 24),

                    // Vertical Stack of 3 Pricing Cards
                    _VerticalPricingList(
                      selectedPlan: _selectedPlan,
                      onChanged: (p) => setState(() => _selectedPlan = p),
                      testing: testing,
                    ),
                    const SizedBox(height: 20),

                    // CTA Button
                    PremiumButton(
                      label: buying
                          ? s.processingShort
                          : activated && widget.onboardingMode
                          ? (_quizCompleted ? s.completeSetup : s.premiumActivated)
                          : _getButtonLabel(payment, s),
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

                    // Terms Note
                    Text(
                      s.premiumAutoRenewNote,
                      textAlign: TextAlign.center,
                      style: _f(11, color: _kMuted, weight: FontWeight.w500),
                    ),
                    const SizedBox(height: 12),

                    // Footer Links
                    const _FooterLinks(showBilling: !testing),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// BENEFIT CHECKLIST
// ═══════════════════════════════════════════════════════════════

class _BenefitChecklist extends StatelessWidget {
  const _BenefitChecklist();

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final benefits = [
      s.planBenefitScans,
      s.planBenefitSuggestions,
      s.planBenefitMacros,
      s.planBenefitProgress,
    ];

    return Column(
      children: benefits.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: _kInk,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 13,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: _f(13.5, weight: FontWeight.w600, color: _kInk),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// VERTICAL PRICING LIST
// ═══════════════════════════════════════════════════════════════

class _VerticalPricingList extends StatelessWidget {
  final _Plan selectedPlan;
  final ValueChanged<_Plan> onChanged;
  final bool testing;

  const _VerticalPricingList({
    required this.selectedPlan,
    required this.onChanged,
    required this.testing,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final payment = context.watch<PaymentProvider>();
    final loading = payment.initializing;

    final weeklyOffer = payment.premiumOffer(PremiumPlan.weekly, preferFreeTrial: false);
    final annualOffer = payment.premiumOffer(PremiumPlan.annual, preferFreeTrial: true);
    final monthlyOffer = payment.premiumOffer(PremiumPlan.monthly, preferFreeTrial: false);

    // Formatted raw recurring price from Store
    String formatRecurring(PremiumOffer? offer, String testingFallback) {
      if (testing) return testingFallback;
      if (loading) return '...';
      if (offer != null && offer.recurringPrice.isNotEmpty) {
        return offer.recurringPrice;
      }
      return testingFallback;
    }

    // Monthly breakdown price (e.g. 39.000d / $1.66)
    String formatMonthly(PremiumOffer? offer, String testingFallback) {
      if (testing) return testingFallback;
      if (loading) return '...';
      if (offer?.monthlyPrice != null && offer!.monthlyPrice!.isNotEmpty) {
        return offer.monthlyPrice!;
      }
      return testingFallback;
    }

    final weekPrice = formatRecurring(weeklyOffer, '29.000đ');
    final annualTotal = formatRecurring(annualOffer, '469.000đ');
    final annualMonthly = formatMonthly(annualOffer, '39.000đ');
    final monthPrice = formatRecurring(monthlyOffer, '59.000đ');

    return Column(
      children: [
        // 1. Week Plan
        _VerticalPlanCard(
          title: s.planWeek,
          subtitle: null,
          priceText: weekPrice,
          unitText: '/ ${s.perWeekText.replaceAll('per ', '').replaceAll('mỗi ', '')}',
          selected: selectedPlan == _Plan.weekly,
          badge: null,
          onTap: () => onChanged(_Plan.weekly),
        ),
        const SizedBox(height: 12),

        // 2. Year Plan (Highlighted / Selected by default)
        _VerticalPlanCard(
          title: s.planYear,
          subtitle: s.planMonthsNote(12, annualTotal),
          priceText: annualMonthly,
          unitText: '/ ${s.perMonthText.replaceAll('per ', '').replaceAll('mỗi ', '')}',
          selected: selectedPlan == _Plan.annual,
          badge: s.popularMost,
          onTap: () => onChanged(_Plan.annual),
        ),
        const SizedBox(height: 12),

        // 3. Month Plan
        _VerticalPlanCard(
          title: s.planMonth,
          subtitle: s.planMonthsNote(1, monthPrice),
          priceText: monthPrice,
          unitText: '/ ${s.perMonthText.replaceAll('per ', '').replaceAll('mỗi ', '')}',
          selected: selectedPlan == _Plan.monthly,
          badge: null,
          onTap: () => onChanged(_Plan.monthly),
        ),
      ],
    );
  }
}

class _VerticalPlanCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String priceText;
  final String unitText;
  final bool selected;
  final String? badge;
  final VoidCallback onTap;

  const _VerticalPlanCard({
    required this.title,
    this.subtitle,
    required this.priceText,
    required this.unitText,
    required this.selected,
    this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? _kInk : _kBorder,
                width: selected ? 2 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: _kInk.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                // Left Column: Plan name & subtitle note
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: _f(16, weight: FontWeight.w800, color: _kInk),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: _f(
                            12.5,
                            color: _kMuted,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Right Column: Big Price + Unit
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      priceText,
                      style: _f(
                        16.5,
                        weight: FontWeight.w800,
                        color: _kInk,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Text(
                      unitText,
                      style: _f(11.5, color: _kMuted, weight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(width: 14),

                // Radio Circle
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? _kInk : const Color(0xFFCBD5E1),
                      width: selected ? 6.5 : 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Top badge (e.g. "Most popular" / "Phổ biến nhất") — Orange Accent
          if (badge != null)
            Positioned(
              top: -10,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                decoration: BoxDecoration(
                  color: _kAccent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge!,
                  style: _f(10.5, weight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FOOTER
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
      10.5,
      color: _kMuted,
      weight: FontWeight.w500,
    ).copyWith(decoration: TextDecoration.underline, decorationColor: _kMuted);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 4,
      children: [
        if (showBilling) ...[
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
                    backgroundColor: restored ? _kInk : Colors.redAccent,
                  ),
                );
              } catch (_) {
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(paymentCopyForPlatform(s.restoreFailed)),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: Text(s.restorePurchases, style: style),
          ),
          Text('•', style: _f(10, color: _kMuted)),
        ],
        GestureDetector(
          onTap: () => _openLegalPage('terms'),
          child: Text(s.termsOfService, style: style),
        ),
        Text('•', style: _f(10, color: _kMuted)),
        GestureDetector(
          onTap: () => _openLegalPage('privacy'),
          child: Text(s.privacyPolicy, style: style),
        ),
      ],
    );
  }
}
