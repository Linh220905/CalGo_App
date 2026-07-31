import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/payment_provider.dart';
import '../../services/api_service.dart';
import '../onboarding/steps/premium_paywall_step.dart';

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
  String get unitLabel =>
      '${(priceVnd ~/ (creditAmount > 0 ? creditAmount : 1)).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}₫/lượt';
}

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  bool _creatingPayment = false;

  // Credit Packages list loaded instantly
  List<CreditPackageItem> _payPacks = [
    CreditPackageItem(
        id: 'pkg_10',
        name: 'Gói 10 lượt',
        creditAmount: 10,
        priceVnd: 49000,
        popular: false),
    CreditPackageItem(
        id: 'pkg_30',
        name: 'Gói 30 lượt',
        creditAmount: 30,
        priceVnd: 119000,
        popular: true),
    CreditPackageItem(
        id: 'pkg_100',
        name: 'Gói 100 lượt',
        creditAmount: 100,
        priceVnd: 299000,
        popular: false),
  ];

  @override
  void initState() {
    super.initState();
    _fetchPackagesAsync();
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

  Future<void> _processGooglePlayPurchase(
      String packageId, CreditPackageItem pack) async {
    setState(() => _creatingPayment = true);
    try {
      final payment = context.read<PaymentProvider>();
      final ok = await payment.buyCredits(packageId);
      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đang xử lý thanh toán qua Google Play...'),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              payment.error ??
                  'Không thể mở thanh toán Google Play. Vui lòng thử lại.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}')),
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
                  'Gói lượt quét: ${pack.name}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bao gồm ${pack.creditAmount} lượt quét dinh dưỡng AI',
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
                      pack.priceLabel,
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
                      _buildBenefitRow(
                          '${pack.creditAmount} lượt quét món ăn bằng AI',
                          isDark),
                      const SizedBox(height: 10),
                      _buildBenefitRow(
                          'Phân tích chi tiết Calories, Protein, Carbs, Fats',
                          isDark),
                      const SizedBox(height: 10),
                      _buildBenefitRow(
                          'Lượt quét dùng vĩnh viễn, không giới hạn thời gian',
                          isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

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
                      _processGooglePlayPurchase(pack.id, pack);
                    },
                    icon: const Icon(Icons.smartphone_rounded,
                        color: Colors.white, size: 20),
                    label: Text(
                      'Mua qua Google Play',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Thanh toán qua Google Play / App Store',
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
                          const SnackBar(
                              content: Text(
                                  'Đã kiểm tra khôi phục giao dịch mua thành công!')),
                        );
                      } else if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              payment.error ??
                                  'Không thể khôi phục giao dịch Google Play.',
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                              content:
                                  Text('Khôi phục thất bại: ${e.toString()}')),
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

  void _openPremiumPaywallScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const PremiumPaywallStep(
          onboardingMode: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
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
                              'Mua thêm lượt quét món ăn bằng AI',
                              style: TextStyle(fontSize: 13, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── ⚡ Section Header: Credit Packages ───────────────
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.bolt_rounded,
                            color: Color(0xFF2563EB), size: 18),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        s.creditPacksTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: textDark,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 3),
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
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── ⚡ Packages Card List ────────────────────────────
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _payPacks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final pack = _payPacks[index];

                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          InkWell(
                            onTap: () => _openPackModal(pack),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: cardBgColor,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: pack.popular
                                      ? const Color(0xFF93C5FD)
                                      : (isDark
                                          ? const Color(0xFF2C2A34)
                                          : const Color(0xFFF1F5F9)),
                                  width: pack.popular ? 1.8 : 1.0,
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
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.bolt_rounded,
                                        color: Color(0xFF2563EB), size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pack.name,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: textDark,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${pack.creditAmount} lượt • ${pack.unitLabel}',
                                          style: TextStyle(
                                              fontSize: 12, color: textMuted),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        pack.priceLabel,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(Icons.chevron_right_rounded,
                                          color: textMuted, size: 20),
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
                              right: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
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
                                    fontSize: 10,
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
                  const SizedBox(height: 32),

                  // ── 👑 Premium Subscription Banner Card ─────────────
                  InkWell(
                    onTap: _openPremiumPaywallScreen,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFFBEB), Color(0xFFFEF3C7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: const Color(0xFFFDE68A), width: 1.5),
                        boxShadow: const [
                          BoxShadow(
                              color: Color(0x11F59E0B),
                              blurRadius: 16,
                              offset: Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(Icons.workspace_premium_rounded,
                                color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Text(
                                      'Gói thành viên Premium',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF78350F),
                                      ),
                                    ),
                                    SizedBox(width: 6),
                                    Icon(Icons.auto_awesome_rounded,
                                        color: Color(0xFFD97706), size: 14),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Quét calo & phân tích dinh dưỡng không giới hạn',
                                  style: TextStyle(
                                      fontSize: 12, color: Color(0xFF92400E)),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFD97706), size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
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
