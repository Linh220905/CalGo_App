import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../../../config/app_build_config.dart';
import '../../../config/iap_ids.dart';
import '../../../providers/app_settings_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/home_provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/payment_provider.dart';
import '../../../services/revenuecat_service.dart';
import '../../../widgets/social_auth_button.dart';
import '../../../utils/payment_platform.dart';

const _kInk = Color(0xFF111111);
const _kMuted = Color(0xFF7A7A7A);
const _kAccent = Color(0xFFFF6A3D); // Orange Accent Tag

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

class DiscountOfferPaywallStep extends StatefulWidget {
  final VoidCallback onDismiss;

  const DiscountOfferPaywallStep({super.key, required this.onDismiss});

  static Future<void> show(BuildContext context, {required VoidCallback onDismiss}) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: 'DiscountOffer',
      pageBuilder: (ctx, anim1, anim2) => DiscountOfferPaywallStep(onDismiss: onDismiss),
      transitionDuration: const Duration(milliseconds: 300),
      transitionBuilder: (ctx, anim1, anim2, child) =>
          FadeTransition(opacity: anim1, child: child),
    );
  }

  @override
  State<DiscountOfferPaywallStep> createState() => _DiscountOfferPaywallStepState();
}

class _DiscountOfferPaywallStepState extends State<DiscountOfferPaywallStep> {
  bool _buying = false;
  bool _showClose = false;
  Timer? _closeTimer;
  PaymentProvider? _payment;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        RevenueCatService.getOfferings().then((_) {
          if (mounted) setState(() {});
        });
      }
    });
    // Delay 5s before showing close [X] button on Offer screen
    _closeTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showClose = true);
    });
  }

  @override
  void dispose() {
    _closeTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final payment = context.read<PaymentProvider>();
    if (_payment == payment) return;
    _payment = payment;
  }

  Future<void> _handlePurchase() async {
    if (_buying) return;
    setState(() => _buying = true);

    final s = context.read<AppSettingsProvider>().strings;

    if (AppBuildConfig.isTesting) {
      _completeOfferFlow();
      return;
    }

    try {
      final offerings = await RevenueCatService.getOfferings();
      final discountOffering = offerings?.getOffering('annual_discount') ??
          offerings?.all['annual_discount'] ??
          offerings?.current;
      if (discountOffering != null && discountOffering.availablePackages.isNotEmpty) {
        final pkg = discountOffering.availablePackages.firstWhere(
          (p) =>
              p.storeProduct.identifier == IapIds.premiumAnnualDiscount ||
              p.identifier.toLowerCase().contains('annual_discount') ||
              p.identifier.toLowerCase().contains('discount') ||
              p.identifier.toLowerCase().contains('offer'),
          orElse: () => discountOffering.annual ??
              discountOffering.availablePackages.firstWhere(
                (p) => p.packageType == PackageType.annual,
                orElse: () => discountOffering.availablePackages.firstWhere(
                  (p) => p.storeProduct.identifier == IapIds.premiumAnnual,
                  orElse: () => discountOffering.availablePackages.first,
                ),
              ),
        );
        final success = await RevenueCatService.purchasePackage(pkg);
        if (!mounted) return;
        if (success) {
          await _completeOfferFlow();
        }
        return;
      }
    } catch (e) {
      debugPrint('[DiscountPaywall] RevenueCat purchase failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(paymentCopyForPlatform(s.paymentVerificationFailed)),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _buying = false);
    }
  }

  Future<void> _completeOfferFlow() async {
    final auth = context.read<AuthProvider>();
    final onboarding = context.read<OnboardingProvider>();
    final home = context.read<HomeProvider>();

    final saved = await onboarding.completeOnboarding(
      authProvider: auth,
      homeProvider: home,
    );
    if (!mounted) return;
    if (saved) {
      await auth.refreshUser();
      await home.loadToday(forceRefresh: true);
      if (mounted) context.go('/home');
    }
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

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final payment = context.watch<PaymentProvider>();
    final settings = context.watch<AppSettingsProvider>();

    // Determine Tier: VN locale vs Global/US
    final isVietnamese = settings.locale.languageCode == 'vi';

    // Get annual discount offer from StoreKit / Play Console
    final discountOffer = payment.premiumOffer(
      PremiumPlan.annualDiscount,
      preferFreeTrial: false,
    );

    // Dynamic store prices with fallback defaults if store not yet queried
    final discountPercent = isVietnamese ? 75 : 80;
    final fallbackYearly = isVietnamese ? '399.000đ' : '\$19.99';
    final fallbackMonthly = isVietnamese ? '33.000đ' : '\$1.66';

    final rcOfferings = RevenueCatService.cachedOfferings;
    final discountOffering = rcOfferings?.getOffering('annual_discount') ??
        rcOfferings?.all['annual_discount'] ??
        rcOfferings?.current;
    final available = discountOffering?.availablePackages ?? [];
    final rcPkg = available.isEmpty
        ? null
        : available.firstWhere(
            (p) =>
                p.storeProduct.identifier == IapIds.premiumAnnualDiscount ||
                p.identifier.toLowerCase().contains('annual_discount') ||
                p.identifier.toLowerCase().contains('discount') ||
                p.identifier.toLowerCase().contains('offer'),
            orElse: () => discountOffering?.annual ??
                available.firstWhere(
                  (p) => p.packageType == PackageType.annual,
                  orElse: () => available.firstWhere(
                    (p) => p.storeProduct.identifier == IapIds.premiumAnnual,
                    orElse: () => available.first,
                  ),
                ),
          );
    final rcYearly = rcPkg?.storeProduct.priceString;
    String? rcMonthlyPrice;
    final rcPriceNum = rcPkg?.storeProduct.price;
    final currencyCode = rcPkg?.storeProduct.currencyCode ?? '';
    if (rcPriceNum != null && rcPriceNum > 0) {
      final monthlyVal = rcPriceNum / 12.0;
      if (currencyCode.toUpperCase() == 'VND' || currencyCode == '₫') {
        final rounded = monthlyVal.round();
        final formatted = rounded.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]}.',
            );
        rcMonthlyPrice = '$formattedđ';
      } else if (currencyCode.toUpperCase() == 'USD' || currencyCode == r'$') {
        rcMonthlyPrice = '\$${monthlyVal.toStringAsFixed(2)}';
      } else if (monthlyVal >= 1000) {
        final rounded = monthlyVal.round();
        final formatted = rounded.toString().replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (m) => '${m[1]},',
            );
        rcMonthlyPrice = '$formatted $currencyCode';
      } else {
        rcMonthlyPrice = '${monthlyVal.toStringAsFixed(2)} $currencyCode';
      }
    }

    final yearlyTotal = rcYearly ?? discountOffer?.recurringPrice ?? fallbackYearly;
    final monthlyPrice = rcMonthlyPrice ?? discountOffer?.monthlyPrice ?? fallbackMonthly;
    final unitMonth = isVietnamese ? '/ tháng' : '/ mo';
    final subUnitMonth = isVietnamese ? '/ tháng' : '/ monthly';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Close [X] Button (Delayed 5s)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/apple_mascot/apple_hello.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  AnimatedOpacity(
                    opacity: _showClose ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: IgnorePointer(
                      ignoring: !_showClose,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          widget.onDismiss();
                        },
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

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Title
                    Text(
                      s.oneTimeOfferTitle, // "Your one-time offer"
                      textAlign: TextAlign.center,
                      style: _f(24, weight: FontWeight.w800, letterSpacing: -0.4),
                    ),
                    const SizedBox(height: 6),

                    // Huge Discount Header (e.g. 80% OFF / GIẢM 75%)
                    Text(
                      s.offPercentHeader(discountPercent),
                      textAlign: TextAlign.center,
                      style: _f(
                        34,
                        weight: FontWeight.w900,
                        color: _kInk,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Mascot Graphic with Gradient Glow Background (Double Size)
                    Container(
                      width: 220,
                      height: 220,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFF1F5F9),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/apple_mascot/apple_paywall.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Compact Note under Mascot
                    Text(
                      '$monthlyPrice $subUnitMonth',
                      textAlign: TextAlign.center,
                      style: _f(16, weight: FontWeight.w800, color: _kInk),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.oneTimeOfferSubtitle,
                      textAlign: TextAlign.center,
                      style: _f(11.5, color: _kMuted, weight: FontWeight.w500),
                    ),
                    const SizedBox(height: 16),

                    // Single Offer Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _kInk, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: _kInk.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Tag Top: SAVE 80% / TIẾT KIỆM 75% (Orange Badge)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: const BoxDecoration(
                              color: _kAccent,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            child: Text(
                              s.savePercentTag(discountPercent),
                              textAlign: TextAlign.center,
                              style: _f(
                                11.5,
                                weight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          // Card Body
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s.planYear,
                                        style: _f(16, weight: FontWeight.w800),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        s.planMonthsNote(12, yearlyTotal),
                                        style: _f(
                                          12.5,
                                          color: _kMuted,
                                          weight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      monthlyPrice,
                                      style: _f(
                                        18,
                                        weight: FontWeight.w800,
                                        color: _kInk,
                                      ),
                                    ),
                                    Text(
                                      unitMonth,
                                      style: _f(
                                        11,
                                        color: _kMuted,
                                        weight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Primary CTA
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _buying ? null : _handlePurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kInk,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: _buying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                s.claimOfferBtn,
                                style: _f(
                                  16,
                                  weight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Footer Links
                    _FooterOfferLinks(),
                    const SizedBox(height: 20),
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

class _FooterOfferLinks extends StatelessWidget {
  Future<void> _openLegalPage(String path) {
    return launchUrl(
      Uri.parse('https://calgo.tech/$path'),
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppSettingsProvider>().strings;
    final style = _f(10.5, color: _kMuted, weight: FontWeight.w500)
        .copyWith(decoration: TextDecoration.underline, decorationColor: _kMuted);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      children: [
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
