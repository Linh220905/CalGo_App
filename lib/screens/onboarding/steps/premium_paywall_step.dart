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
      if (mounted) {
        context.read<PaymentProvider>().loadProducts();
        RevenueCatService.getOfferings().then((_) {
          if (mounted) setState(() {});
        });
      }
      if (mounted) {
        final analytics = context.read<AnalyticsService?>();
        if (analytics != null) {
          unawaited(analytics.trackPaywallViewed(source: widget.source));
        }
      }
    });
    _closeTimer = Timer(const Duration(seconds: 5), () {
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
    // Do not show false error SnackBar if user is already completing purchase or active
    if (state == true &&
        paymentError != null &&
        paymentError != _lastShownPaymentError &&
        !_finishingPurchase &&
        !_handledPremiumSuccess) {
      _lastShownPaymentError = paymentError;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _finishingPurchase || _handledPremiumSuccess) return;
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
    unawaited(_handlePremiumSuccess());
  }

  Future<void> _handlePremiumSuccess() async {
    if (_handledPremiumSuccess && !widget.onboardingMode) return;
    _handledPremiumSuccess = true;
    if (mounted && !_finishingPurchase) {
      setState(() => _finishingPurchase = true);
    }
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
      if (!auth.isAuthenticated) {
        final authed = await _ensureAuthenticated();
        if (!authed || !mounted) {
          setState(() => _finishingPurchase = false);
          return;
        }
        unawaited(payment.retryPendingPurchaseVerification());
      }
      if (!mounted) return;

      if (auth.user?.id != null) {
        try {
          await RevenueCatService.logIn(auth.user!.id, apiService: auth.api);
        } catch (_) {}
      }

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
      await auth.refreshUser();
      await home.loadToday(forceRefresh: true);
      if (mounted) context.go('/home');
      return;
    }

    if (auth.user?.id != null) {
      try {
        await RevenueCatService.logIn(auth.user!.id, apiService: auth.api);
      } catch (_) {}
    }

    await auth.refreshUser();
    if (!mounted) return;
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

  void _proceedClose() async {
    if (widget.onboardingMode) {
      final auth = context.read<AuthProvider>();
      final onboarding = context.read<OnboardingProvider>();
      final home = context.read<HomeProvider>();

      // Ensure onboarding is marked completed when user exits spinner/paywall
      await onboarding.completeOnboarding(
        authProvider: auth,
        homeProvider: home,
      );
      if (mounted) {
        await home.loadToday(forceRefresh: true);
        if (mounted) context.go('/home');
      }
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      } else {
        context.go('/home');
      }
    }
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
                  if (provider.error == 'apple_auth_error') {
                    error = s.appleSignInFailed;
                  } else {
                    error = provider.error ?? s.signInFailed;
                  }
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

  Future<void> _handlePrimaryAction() async {
    final s = context.read<AppSettingsProvider>().strings;
    const testing = AppBuildConfig.isTesting;

    if (testing) {
      await _triggerPostPurchaseQuiz();
      return;
    }

    setState(() => _finishingPurchase = true);

    try {
      final offerings = await RevenueCatService.getOfferings();
      final currentOffering = offerings?.current;
      if (currentOffering != null && currentOffering.availablePackages.isNotEmpty) {
        Package? pkg;
        if (_selectedPlan == _Plan.weekly) {
          pkg = currentOffering.weekly ??
              currentOffering.availablePackages.firstWhere(
                (p) => p.packageType == PackageType.weekly,
                orElse: () => currentOffering.availablePackages.first,
              );
        } else if (_selectedPlan == _Plan.monthly) {
          pkg = currentOffering.monthly ??
              currentOffering.availablePackages.firstWhere(
                (p) => p.packageType == PackageType.monthly,
                orElse: () => currentOffering.availablePackages.first,
              );
        } else {
          pkg = currentOffering.annual ??
              currentOffering.availablePackages.firstWhere(
                (p) => p.packageType == PackageType.annual,
                orElse: () => currentOffering.availablePackages.first,
              );
        }

        final success = await RevenueCatService.purchasePackage(pkg);
        if (!mounted) return;
        if (success) {
          await _handlePremiumSuccess();
        }
        return;
      }
    } catch (e) {
      debugPrint('[Paywall] RevenueCat purchase failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(paymentCopyForPlatform(s.paymentVerificationFailed)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _finishingPurchase = false);
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
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenH = constraints.maxHeight;
            final heroHeight = (screenH * 0.36).clamp(240.0, 300.0);

            return Column(
              children: [
                // 1. Top Hero Section with background.png & Smooth Gradient Fade
                SizedBox(
                  height: heroHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/background.png',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -0.6),
                        errorBuilder: (context, error, stack) => Container(
                          color: const Color(0xFFF6F6F6),
                        ),
                      ),
                      // Smooth gradient loang mờ từ giữa ảnh xuống nền trắng
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.0, 0.45, 0.65, 0.88, 1.0],
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.30),
                              Colors.white.withValues(alpha: 0.85),
                              Colors.white,
                            ],
                          ),
                        ),
                      ),
                      // Floating Close [X] Button on Top-Right
                      Positioned(
                        top: MediaQuery.paddingOf(context).top + 10,
                        right: 18,
                        child: AnimatedOpacity(
                          opacity: _showClose ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: IgnorePointer(
                            ignoring: !_showClose,
                            child: GestureDetector(
                              onTap: _handleClose,
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.35),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Main Content (Headline, 3 Cards, CTA, Footer)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Headline + Subtitle
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              s.paywallHeroTitle,
                              textAlign: TextAlign.center,
                              style: _f(
                                22,
                                weight: FontWeight.w800,
                                letterSpacing: -0.6,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              s.paywallHeroSubtitle,
                              textAlign: TextAlign.center,
                              style: _f(
                                12.5,
                                color: _kMuted,
                                weight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),

                        // 3 Pricing Cards
                        _VerticalPricingList(
                          selectedPlan: _selectedPlan,
                          onChanged: (p) => setState(() => _selectedPlan = p),
                          testing: testing,
                        ),

                        // Bottom Actions (CTA Button, Auto-renew note, Footer Links)
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                                  : () => _handlePrimaryAction(),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              s.premiumAutoRenewNote,
                              textAlign: TextAlign.center,
                              style: _f(10.5, color: _kMuted, weight: FontWeight.w500),
                            ),
                            const SizedBox(height: 4),
                            const _FooterLinks(showBilling: !testing),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
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
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 17,
                height: 17,
                decoration: const BoxDecoration(
                  color: _kInk,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: _f(13, weight: FontWeight.w600, color: _kInk),
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
    final isVietnamese = context.watch<AppSettingsProvider>().locale.languageCode == 'vi';

    final weeklyOffer = payment.premiumOffer(PremiumPlan.weekly, preferFreeTrial: false);
    final annualOffer = payment.premiumOffer(PremiumPlan.annual, preferFreeTrial: true);
    final monthlyOffer = payment.premiumOffer(PremiumPlan.monthly, preferFreeTrial: false);

    final rcOfferings = RevenueCatService.cachedOfferings?.current;
    final rcWeekly = rcOfferings?.weekly?.storeProduct.priceString;
    final rcMonthly = rcOfferings?.monthly?.storeProduct.priceString;
    final rcAnnual = rcOfferings?.annual?.storeProduct.priceString;

    String? rcAnnualMonthly;
    final annualPriceNum = rcOfferings?.annual?.storeProduct.price;
    final currencyCode = rcOfferings?.annual?.storeProduct.currencyCode ?? '';
    if (annualPriceNum != null && annualPriceNum > 0) {
      final monthlyVal = annualPriceNum / 12.0;
      if (currencyCode.toUpperCase() == 'VND' || currencyCode == '₫') {
        final rounded = monthlyVal.round();
        final formatted = rounded.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]}.',
            );
        rcAnnualMonthly = '$formattedđ';
      } else if (currencyCode.toUpperCase() == 'USD' || currencyCode == r'$') {
        rcAnnualMonthly = '\$${monthlyVal.toStringAsFixed(2)}';
      } else if (monthlyVal >= 1000) {
        final rounded = monthlyVal.round();
        final formatted = rounded.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            );
        rcAnnualMonthly = '$formatted $currencyCode';
      } else {
        rcAnnualMonthly = '${monthlyVal.toStringAsFixed(2)} $currencyCode';
      }
    }

    // Formatted raw recurring price from Store or RevenueCat
    String formatRecurring(PremiumOffer? offer, String? rcPrice, String testingFallback) {
      if (testing) return testingFallback;
      if (rcPrice != null && rcPrice.isNotEmpty) {
        return rcPrice;
      }
      if (offer != null && offer.recurringPrice.isNotEmpty) {
        return offer.recurringPrice;
      }
      return testingFallback;
    }

    // Monthly breakdown price (e.g. 39.000d / $1.66)
    String formatMonthly(PremiumOffer? offer, String? rcMonthlyPrice, String testingFallback) {
      if (testing) return testingFallback;
      if (rcMonthlyPrice != null && rcMonthlyPrice.isNotEmpty) {
        return rcMonthlyPrice;
      }
      if (offer?.monthlyPrice != null && offer!.monthlyPrice!.isNotEmpty) {
        return offer.monthlyPrice!;
      }
      return testingFallback;
    }

    final defaultWeek = isVietnamese ? '29.000đ' : '\$1.99';
    final defaultAnnual = isVietnamese ? '469.000đ' : '\$29.99';
    final defaultAnnualMonthly = isVietnamese ? '39.000đ' : '\$2.49';
    final defaultMonth = isVietnamese ? '59.000đ' : '\$4.99';

    final weekPrice = formatRecurring(weeklyOffer, rcWeekly, defaultWeek);
    final annualTotal = formatRecurring(annualOffer, rcAnnual, defaultAnnual);
    final annualMonthly = formatMonthly(annualOffer, rcAnnualMonthly, defaultAnnualMonthly);
    final monthPrice = formatRecurring(monthlyOffer, rcMonthly, defaultMonth);

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
        const SizedBox(height: 8),

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
        const SizedBox(height: 8),

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
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFFAFBFD) : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? _kInk : _kBorder,
                width: selected ? 1.8 : 1.2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: _kInk.withValues(alpha: 0.08),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      )
                    ],
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
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: _f(
                            12,
                            color: _kMuted,
                            weight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Right Column: Big Price + Unit
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      priceText,
                      style: _f(
                        17.5,
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
                const SizedBox(width: 12),

                // Radio Circle
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? _kInk : const Color(0xFFCBD5E1),
                      width: selected ? 6 : 1.5,
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
