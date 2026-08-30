import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/app_build_config.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/payment_provider.dart';
import '../../services/api_service.dart';
import '../../utils/payment_platform.dart';

class CreditPackageItem {
  final String id;
  final String name;
  final int creditAmount;
  final int priceVnd;
  final bool popular;

  CreditPackageItem({
    required this.id,
    required this.name,
    required this.creditAmount,
    required this.priceVnd,
    this.popular = false,
  });

  factory CreditPackageItem.fromJson(Map<String, dynamic> json, int index) {
    return CreditPackageItem(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      creditAmount: json['credit_amount'] as int? ?? 10,
      priceVnd: json['price_vnd'] as int? ?? 49000,
      popular: index == 1,
    );
  }

  String get priceLabel =>
      '${priceVnd.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}₫';
  String get unitPriceLabel =>
      '${(priceVnd ~/ (creditAmount > 0 ? creditAmount : 1)).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}₫';
}

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool _creatingPayment = false;
  PaymentProvider? _payment;
  String? _lastPurchaseMessage;

  // Credit Packages list loaded instantly matching web backend
  late List<CreditPackageItem> _payPacks;

  String _storePriceLabel(CreditPackageItem pack) {
    return context.read<PaymentProvider>().formattedPriceForCreditAmount(
              pack.creditAmount,
            ) ??
        pack.priceLabel;
  }

  @override
  void initState() {
    super.initState();
    final s = context.read<AppSettingsProvider>().strings;
    _payPacks = [
      CreditPackageItem(
          id: '9568d78d-9a8f-4ac7-94d0-ea3a7dc2d04d',
          name: s.packBasic,
          creditAmount: 10,
          priceVnd: 10000,
          popular: false),
      CreditPackageItem(
          id: 'f49d9e33-f605-496a-a0b7-5aed663068a7',
          name: s.packPopular,
          creditAmount: 25,
          priceVnd: 20000,
          popular: true),
      CreditPackageItem(
          id: '68d6aec7-ab65-4b96-a34a-4765e8e4a367',
          name: s.packPremium,
          creditAmount: 100,
          priceVnd: 50000,
          popular: false),
    ];
    _fetchPackagesAsync();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final payment = context.read<PaymentProvider>();
    if (_payment == payment) return;
    _payment?.removeListener(_onPaymentChanged);
    _payment = payment..addListener(_onPaymentChanged);
  }

  @override
  void dispose() {
    _payment?.removeListener(_onPaymentChanged);
    super.dispose();
  }

  void _onPaymentChanged() {
    if (!mounted) return;
    final payment = _payment;
    if (payment == null) return;
    final creditStates = payment.purchaseStates.entries.where(
      (entry) => entry.key.startsWith('credit_'),
    );
    final purchased =
        creditStates.any((entry) => entry.value == PurchaseState.purchased);
    final failed =
        creditStates.any((entry) => entry.value == PurchaseState.error);
    final message = purchased
        ? 'Đã xác minh và cộng lượt quét vào tài khoản.'
        : failed
            ? 'Cửa hàng đã nhận giao dịch nhưng máy chủ chưa cộng lượt. Vui lòng thử Khôi phục giao dịch sau khi cập nhật backend.'
            : null;
    if (message == null || message == _lastPurchaseMessage) return;
    _lastPurchaseMessage = message;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: failed ? Colors.redAccent : null,
        ),
      );
    });
  }

  Future<void> _fetchPackagesAsync() async {
    final api = context.read<ApiService>();
    try {
      final res = await api
          .get('/payments/packages')
          .timeout(const Duration(seconds: 4));
      if (mounted && res is List && res.isNotEmpty) {
        setState(() {
          _payPacks = res
              .asMap()
              .entries
              .map((e) => CreditPackageItem.fromJson(
                  e.value as Map<String, dynamic>, e.key))
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _processStorePurchase(
      String packageId, CreditPackageItem pack) async {
    final s = context.read<AppSettingsProvider>().strings;
    setState(() => _creatingPayment = true);
    try {
      final payment = context.read<PaymentProvider>();
      final ok = await payment.buyCredits(
        packageId,
        creditAmount: pack.creditAmount,
      );
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(paymentCopyForPlatform(s.paymentProcessing)),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              paymentCopyForPlatform(s.paymentOpenFailed),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.errorWithDetails(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _creatingPayment = false);
    }
  }

  void _openPackModal(CreditPackageItem pack) {
    final settings = context.read<AppSettingsProvider>();
    final isDark = settings.isDarkMode;
    final s = settings.strings;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.88,
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF212027) : const Color(0xFFFAFAFB),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Bolt Icon Header
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFDBEAFE), Color(0xFFBFDBFE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.bolt_rounded,
                      color: Color(0xFF2563EB), size: 30),
                ),
                const SizedBox(height: 14),

                // Title & Credits Info
                Text(
                  '${s.creditPacksTitle}: ${pack.name}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  s.packIncludes(pack.creditAmount),
                  style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF8E8D9A)
                          : const Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),

                // Price Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _storePriceLabel(pack),
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Feature List
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF18171C) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF2C2A34)
                          : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildBenefitRow(s.moreScanCredits, isDark),
                      const SizedBox(height: 10),
                      _buildBenefitRow(s.nutritionTitle, isDark),
                      const SizedBox(height: 10),
                      _buildBenefitRow(s.permanentCredits, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (AppBuildConfig.isTesting) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF202B24)
                          : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      paymentCopyForPlatform(s.testingFreeCredits),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, height: 1.35),
                    ),
                  ),
                ] else ...[
                  // ── Google Play Pay Button ─────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _processStorePurchase(pack.id, pack);
                      },
                      icon: const Icon(Icons.smartphone_rounded,
                          color: Colors.white, size: 20),
                      label: Text(
                        s.payButton,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    paymentCopyForPlatform(s.paymentMethods),
                    style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? const Color(0xFF8E8D9A)
                            : const Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      try {
                        final payment = context.read<PaymentProvider>();
                        final restored = await payment.restorePurchases();
                        if (mounted && restored) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                  paymentCopyForPlatform(s.restoreSuccess)),
                            ),
                          );
                        } else if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                paymentCopyForPlatform(s.restoreFailed),
                              ),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                                content: Text(paymentCopyForPlatform(
                                    s.restoreFailedWithDetails(e.toString())))),
                          );
                        }
                      }
                    },
                    child: Text(
                      s.restorePurchases,
                      style: TextStyle(
                          fontSize: 12,
                          decoration: TextDecoration.underline,
                          color: isDark
                              ? const Color(0xFF8E8D9A)
                              : const Color(0xFF64748B)),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitRow(String text, bool isDark) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded,
            color: Color(0xFF22C55E), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    // Rebuild prices when Google Play product discovery completes. The store
    // price is authoritative; backend VND values are only the offline UI
    // fallback before Billing returns ProductDetails.
    final payment = context.watch<PaymentProvider>();
    final isDark = settings.isDarkMode;
    final s = settings.strings;

    final bgColor = isDark ? const Color(0xFF141318) : const Color(0xFFFAFAFB);
    final cardBgColor = isDark ? const Color(0xFF212027) : Colors.white;
    final textDark = isDark ? Colors.white : const Color(0xFF0F172A);
    final textMuted =
        isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Header Row ──────────────────────────────────
                  Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: cardBgColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2C2A34)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Icon(Icons.arrow_back_rounded,
                              color: textDark, size: 20),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.pricingTitle,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            Text(
                              s.moreScanCredits,
                              style: TextStyle(fontSize: 13, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── ⚡ Section Header: Credit Packages ───────────────
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final icon = Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFF2563EB),
                          size: 18,
                        ),
                      );
                      final title = Text(
                        s.creditPacksTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      );
                      final badge = Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          s.noExpiryBadge,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      );
                      if (constraints.maxWidth < 340) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                icon,
                                const SizedBox(width: 8),
                                Expanded(child: title),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Align(
                                alignment: Alignment.centerRight, child: badge),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          icon,
                          const SizedBox(width: 8),
                          Expanded(child: title),
                          const SizedBox(width: 8),
                          Flexible(child: badge),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── ⚡ Packages Card List ────────────────────────────
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _payPacks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 18),
                    itemBuilder: (context, index) {
                      final pack = _payPacks[index];

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          InkWell(
                            onTap: () => _openPackModal(pack),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 20),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: pack.popular
                                      ? const Color(0xFF93C5FD)
                                      : (isDark
                                          ? const Color(0xFF2C2A34)
                                          : const Color(0xFFF1F5F9)),
                                  width: pack.popular ? 2.0 : 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: pack.popular
                                        ? const Color(0x1A2563EB)
                                        : (isDark
                                            ? const Color(0x22000000)
                                            : const Color(0x060F172A)),
                                    blurRadius: pack.popular ? 16 : 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.bolt_rounded,
                                        color: Color(0xFF2563EB), size: 26),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pack.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          s.creditPackageSummary(
                                              pack.creditAmount,
                                              '${pack.unitPriceLabel}${s.perScan}'),
                                          style: TextStyle(
                                              fontSize: 13, color: textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        payment.formattedPriceForCreditAmount(
                                              pack.creditAmount,
                                            ) ??
                                            pack.priceLabel,
                                        style: const TextStyle(
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.chevron_right_rounded,
                                          color: textMuted, size: 22),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Floating Popular Badge (-top-2.5 right-4)
                          if (pack.popular)
                            Positioned(
                              top: -10,
                              right: 20,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF2563EB),
                                      Color(0xFF1D4ED8)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: const [
                                    BoxShadow(
                                        color: Color(0x332563EB),
                                        blurRadius: 6,
                                        offset: Offset(0, 2)),
                                  ],
                                ),
                                child: Text(
                                  s.popularBadge,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Loading Overlay during payment creation
            if (_creatingPayment)
              Container(
                color: Colors.black45,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
