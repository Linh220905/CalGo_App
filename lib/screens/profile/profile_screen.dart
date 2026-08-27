import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_build_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/language_selector.dart';
import '../onboarding/steps/premium_paywall_step.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _openLegalPage(String path) async {
    final uri = Uri.parse('https://calgo.tech/$path');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _legalContentForPlatform(String content) {
    if (defaultTargetPlatform != TargetPlatform.iOS) return content;
    return content
        .replaceAll('Google Play', 'App Store')
        .replaceAll('Android', 'iOS')
        .replaceAll(
          'https://play.google.com/store/account/subscriptions',
          'https://apps.apple.com/account/subscriptions',
        );
  }

  void _showLanguageSelector(BuildContext context) {
    showLanguageSelectorModal(context);
  }

  void _showTargetDialog(BuildContext context, int currentTarget, bool isDark) {
    final s = context.read<AppSettingsProvider>().strings;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF212027) : Colors.white,
        title: Text(
          s.dailyCalorieGoal,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          s.dailyCalorieGoalMessage(currentTarget),
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B),
          ),
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

  void _showNotificationInfoDialog(BuildContext context, bool isDark) {
    final s = context.read<AppSettingsProvider>().strings;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF212027) : Colors.white,
        title: Text(
          s.reminderNotifications,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          s.reminderNotificationsEnabled,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.gotIt, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showUserGuideDialog(BuildContext context, bool isDark) {
    final s = context.read<AppSettingsProvider>().strings;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF212027) : Colors.white,
        title: Text(
          s.userGuideTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          s.userGuideContent,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.great, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog(BuildContext context, bool isDark) {
    final s = context.read<AppSettingsProvider>().strings;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF212027) : Colors.white,
        title: Text(
          s.customerSupport,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          s.customerSupportMessage,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B),
          ),
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

  void _showPrivacyPolicyDialog(
      BuildContext context, AppLocalizations s, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF212027) : Colors.white,
        title: Text(
          s.privacyPolicy,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            _legalContentForPlatform(s.privacyPolicyContent),
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _openLegalPage('privacy'),
            child: Text(s.openOnline),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text(s.ok, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context, AppLocalizations s, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF212027) : Colors.white,
        title: Text(
          s.termsOfService,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            _legalContentForPlatform(s.termsOfServiceContent),
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _openLegalPage('terms'),
            child: Text(s.openOnline),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                Text(s.ok, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider authProvider,
      AppLocalizations s, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF212027) : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                s.deleteAccount,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFEF4444),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          '${s.deleteAccountConfirmMessage}\n\n${_legalContentForPlatform(s.deleteAccountSubscriptionWarning)}',
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF8E8D9A) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => _openLegalPage('delete-account'),
            child: Text(s.onlineGuide),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(s.cancel,
                style: const TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final deleted = await authProvider.deleteAccount();
              if (deleted && context.mounted) {
                context.go('/login');
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(authProvider.error ?? s.deleteAccountFailed),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(s.deleteAccount),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final authProvider = context.watch<AuthProvider>();
    final isDark = settings.isDarkMode;
    final user = authProvider.user;
    final s = settings.strings;

    final bgColor = isDark ? const Color(0xFF141318) : const Color(0xFFFAFAFB);
    final cardBgColor = isDark ? const Color(0xFF212027) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final borderColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFF0F0F2);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          s.profileTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
          child: Column(
            children: [
              // ── Header Gradient Card ─────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF292929), Color(0xFF0F0F0F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 24,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar Circle
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.3), width: 2),
                          ),
                          clipBehavior: Clip.antiAlias,
                          alignment: Alignment.center,
                          child: user?.avatar != null
                              ? Image.network(user!.avatar!, fit: BoxFit.cover)
                              : Text(
                                  user?.name?.isNotEmpty == true
                                      ? user!.name![0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                        if (!AppBuildConfig.isTesting &&
                            user?.hasPremiumAccess == true)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFD700),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x80FFD700),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.star,
                                size: 14,
                                color: Color(0xFF7A5C00),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user?.name ?? s.defaultProfileName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    if (user?.email != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        user!.email!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Menu List (Minimalist Clean Monochrome Design) ───
              Container(
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: isDark
                      ? Border.all(color: const Color(0xFF2C2A34))
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? const Color(0x22000000)
                          : const Color(0x0A111111),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    if (!AppBuildConfig.isTesting)
                      _buildMenuItem(
                        icon: Icons.workspace_premium_outlined,
                        label: s.premiumMembership,
                        badge: 'PRO',
                        isSpecialBadge: true,
                        textColor: textColor,
                        borderColor: borderColor,
                        isDark: isDark,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const PremiumPaywallStep(
                                      onboardingMode: false,
                                      source: 'profile',
                                    )),
                          );
                        },
                      ),

                    // Hàng 2: Mua lượt quét (Credit Topup)
                    _buildMenuItem(
                      icon: Icons.bolt_outlined,
                      label: s.buyCredits,
                      badge: s.creditsCount(user?.credits ?? 0),
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      onTap: () => context.push('/pricing'),
                    ),

                    // Thống kê
                    _buildMenuItem(
                      icon: Icons.bar_chart_outlined,
                      label: s.statistics,
                      badge: '${user?.totalScans ?? 0}',
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      onTap: () => context.push('/stats'),
                    ),

                    // Mục tiêu Calo
                    _buildMenuItem(
                      icon: Icons.track_changes_outlined,
                      label: s.calorieTarget,
                      badge: s.guidanceDishCalories(
                          user?.dailyCalorieTarget.round() ?? 2000),
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      onTap: () => _showTargetDialog(context,
                          user?.dailyCalorieTarget.round() ?? 2000, isDark),
                    ),

                    // Thông báo
                    _buildMenuItem(
                      icon: Icons.notifications_outlined,
                      label: s.notifications,
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      onTap: () => _showNotificationInfoDialog(context, isDark),
                    ),

                    // ── Chế độ tối (Switch) ─────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2C2A34)
                                  : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.dark_mode_outlined,
                              color: isDark
                                  ? const Color(0xFFCBD5E1)
                                  : const Color(0xFF334155),
                              size: 19,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              s.darkMode,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          Switch(
                            value: isDark,
                            activeColor: Colors.white,
                            activeTrackColor: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFF0F172A),
                            onChanged: (val) => settings.toggleTheme(val),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: borderColor),

                    // ── Ngôn ngữ (Modal Selector) ─────────────
                    _buildMenuItem(
                      icon: Icons.language_outlined,
                      label: s.language,
                      badge: s.languageDisplayName,
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      onTap: () => _showLanguageSelector(context),
                    ),

                    // Hướng dẫn sử dụng
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      label: s.userGuide,
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      onTap: () => _showUserGuideDialog(context, isDark),
                    ),

                    // Chính sách bảo mật
                    _buildMenuItem(
                      icon: Icons.security_outlined,
                      label: s.privacyPolicy,
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      onTap: () => _showPrivacyPolicyDialog(context, s, isDark),
                    ),

                    // Điều khoản sử dụng
                    _buildMenuItem(
                      icon: Icons.description_outlined,
                      label: s.termsOfService,
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      onTap: () => _showTermsDialog(context, s, isDark),
                    ),

                    // Hỗ trợ khách hàng
                    _buildMenuItem(
                      icon: Icons.mail_outline_rounded,
                      label: s.customerSupport,
                      textColor: textColor,
                      borderColor: borderColor,
                      isDark: isDark,
                      onTap: () => _showSupportDialog(context, isDark),
                    ),

                    // Xóa tài khoản (Bắt buộc theo App Store Guidelines 5.1.1(v))
                    _buildMenuItem(
                      icon: Icons.delete_forever_outlined,
                      label: s.deleteAccount,
                      textColor: const Color(0xFFEF4444),
                      borderColor: borderColor,
                      isDark: isDark,
                      isLast: true,
                      onTap: () => _showDeleteAccountDialog(
                          context, authProvider, s, isDark),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Logout Button ────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(Icons.logout_rounded,
                      color: Color(0xFFEF4444), size: 18),
                  label: Text(
                    s.logout,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEF4444),
                      height: 1.2,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                        color: isDark
                            ? const Color(0xFF451A1A)
                            : const Color(0xFFFECACA)),
                    backgroundColor: isDark
                        ? const Color(0xFF2C1517)
                        : const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    String? badge,
    bool isSpecialBadge = false,
    required Color textColor,
    required Color borderColor,
    required bool isDark,
    VoidCallback? onTap,
    bool isLast = false,
  }) {
    final iconBgColor =
        isDark ? const Color(0xFF2C2A34) : const Color(0xFFF1F5F9);
    final iconColor =
        isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                if (badge != null) ...[
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: isSpecialBadge
                          ? (isDark
                              ? const Color(0xFF3B2A10)
                              : const Color(0xFFFEF3C7))
                          : (isDark
                              ? const Color(0xFF2C2A34)
                              : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(8),
                      border: isSpecialBadge
                          ? Border.all(
                              color: const Color(0xFFFDE68A), width: 0.8)
                          : null,
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSpecialBadge
                            ? const Color(0xFFD97706)
                            : (isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF64748B)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFFCBD5E1),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, color: borderColor),
      ],
    );
  }
}
