import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/app_build_config.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../providers/app_settings_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/language_selector.dart';
import '../../utils/payment_platform.dart';
import '../onboarding/steps/premium_paywall_step.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _openLegalPage(String path) async {
    final uri = Uri.parse('https://calgo.tech/$path');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  String _legalContentForPlatform(String content) {
    return paymentCopyForPlatform(content);
  }

  void _showLanguageSelector(BuildContext context) {
    showLanguageSelectorModal(context);
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return 'DM';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return name.trim()[0].toUpperCase();
  }

  void _showPersonalInfoDialog(BuildContext context, User? user, bool isDark) {
    final s = context.read<AppSettingsProvider>().strings;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF212027) : Colors.white,
        title: Text(
          s.profileTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Tên', user?.name ?? s.defaultProfileName, isDark),
            const SizedBox(height: 10),
            _buildInfoRow('Email', user?.email ?? '—', isDark),
            const SizedBox(height: 10),
            _buildInfoRow(s.creditsLabel, '${user?.credits ?? 0}', isDark),
            const SizedBox(height: 10),
            _buildInfoRow(s.statistics, '${user?.totalScans ?? 0}', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              s.close,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? Colors.white : const Color(0xFF0F172A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _showAppleHealthDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: isDark ? const Color(0xFF212027) : Colors.white,
        title: Row(
          children: [
            const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444)),
            const SizedBox(width: 8),
            Text(
              'Apple Health',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        content: Text(
          'Đồng bộ dữ liệu calo tiêu thụ và bước chân từ Apple Health / Health Connect đang trong quá trình phát triển và sẽ sẵn sàng ở bản cập nhật tiếp theo.',
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Đã hiểu',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
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
            child: Text(
              s.close,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
            child: Text(
              s.gotIt,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
            child: Text(
              s.great,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
            child: Text(
              s.close,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(
    BuildContext context,
    AppLocalizations s,
    bool isDark,
  ) {
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
            child: Text(
              s.ok,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
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
            child: Text(
              s.ok,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(
    BuildContext context,
    AuthProvider authProvider,
    AppLocalizations s,
    bool isDark,
  ) {
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
            child: Text(
              s.cancel,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
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
                borderRadius: BorderRadius.circular(10),
              ),
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

    final bgColor = isDark ? const Color(0xFF121116) : const Color(0xFFFAFAFB);
    final cardBgColor = isDark ? const Color(0xFF1E1C24) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final mutedColor = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);
    final borderColor = isDark
        ? const Color(0xFF2C2A34)
        : const Color(0xFFF1F5F9);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.settingsEyebrow.toUpperCase(),
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                s.profileHeading,
                style: TextStyle(
                  color: textColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 20),

              // Profile Card
              _buildAccountCard(
                user: user,
                isDark: isDark,
                cardBgColor: cardBgColor,
                borderColor: borderColor,
                textColor: textColor,
                mutedColor: mutedColor,
                strings: s,
                onTap: () => _showPersonalInfoDialog(context, user, isDark),
              ),
              const SizedBox(height: 24),

              // Section: ACCOUNT
              _buildSectionLabel(s.accountSection.toUpperCase(), mutedColor),
              const SizedBox(height: 8),
              _buildSectionCard(
                cardBgColor: cardBgColor,
                borderColor: borderColor,
                isDark: isDark,
                children: [
                  _buildMenuItem(
                    icon: Icons.badge_outlined,
                    label: s.profileTitle,
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    onTap: () => _showPersonalInfoDialog(context, user, isDark),
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    label: s.preferencesSection,
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    onTap: () => _showTargetDialog(
                      context,
                      user?.dailyCalorieTarget.round() ?? 2000,
                      isDark,
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.g_translate_rounded,
                    label: s.language,
                    badge: s.languageDisplayName,
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    isLast: true,
                    onTap: () => _showLanguageSelector(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: MỤC TIÊU & THEO DÕI
              _buildSectionLabel(s.trackingSection.toUpperCase(), mutedColor),
              const SizedBox(height: 8),
              _buildSectionCard(
                cardBgColor: cardBgColor,
                borderColor: borderColor,
                isDark: isDark,
                children: [
                  _buildMenuItem(
                    icon: Icons.favorite_outline_rounded,
                    label: 'Apple Health',
                    badge: 'Chưa kết nối',
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    onTap: () => _showAppleHealthDialog(context, isDark),
                  ),
                  _buildMenuItem(
                    icon: Icons.center_focus_strong_outlined,
                    label: s.calorieTarget,
                    badge: s.guidanceDishCalories(
                      user?.dailyCalorieTarget.round() ?? 2000,
                    ),
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    onTap: () => _showTargetDialog(
                      context,
                      user?.dailyCalorieTarget.round() ?? 2000,
                      isDark,
                    ),
                  ),
                  _buildMenuItem(
                    icon: Icons.notifications_none_rounded,
                    label: s.reminderNotifications,
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    isLast: true,
                    onTap: () => _showNotificationInfoDialog(context, isDark),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: DỊCH VỤ PREMIUM & CREDIT (nếu có)
              _buildSectionLabel('DỊCH VỤ & GÓI CƯỚC', mutedColor),
              const SizedBox(height: 8),
              _buildSectionCard(
                cardBgColor: cardBgColor,
                borderColor: borderColor,
                isDark: isDark,
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
                            ),
                          ),
                        );
                      },
                    ),
                  _buildMenuItem(
                    icon: Icons.bolt_outlined,
                    label: s.buyCredits,
                    badge: s.creditsCount(user?.credits ?? 0),
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    onTap: () => context.push('/pricing'),
                  ),
                  _buildMenuItem(
                    icon: Icons.bar_chart_outlined,
                    label: s.statistics,
                    badge: '${user?.totalScans ?? 0}',
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    isLast: true,
                    onTap: () => context.push('/stats'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section: HỖ TRỢ & BẢO MẬT
              _buildSectionLabel(s.supportSection.toUpperCase(), mutedColor),
              const SizedBox(height: 8),
              _buildSectionCard(
                cardBgColor: cardBgColor,
                borderColor: borderColor,
                isDark: isDark,
                children: [
                  _buildMenuItem(
                    icon: Icons.help_outline_rounded,
                    label: s.userGuide,
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    onTap: () => _showUserGuideDialog(context, isDark),
                  ),
                  _buildMenuItem(
                    icon: Icons.security_outlined,
                    label: s.privacyPolicy,
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    onTap: () => _showPrivacyPolicyDialog(context, s, isDark),
                  ),
                  _buildMenuItem(
                    icon: Icons.description_outlined,
                    label: s.termsOfService,
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    onTap: () => _showTermsDialog(context, s, isDark),
                  ),
                  _buildMenuItem(
                    icon: Icons.mail_outline_rounded,
                    label: s.customerSupport,
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    onTap: () => _showSupportDialog(context, isDark),
                  ),
                  _buildSwitchItem(
                    label: s.darkMode,
                    icon: Icons.dark_mode_outlined,
                    value: isDark,
                    isDark: isDark,
                    textColor: textColor,
                    borderColor: borderColor,
                    isLast: true,
                    onChanged: settings.toggleTheme,
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                  label: Text(
                    s.logout,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      height: 1.2,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    side: BorderSide(color: borderColor),
                    backgroundColor: cardBgColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildDeleteAccountAction(
                context: context,
                authProvider: authProvider,
                strings: s,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
      ),
    );
  }

  Widget _buildAccountCard({
    required User? user,
    required bool isDark,
    required Color cardBgColor,
    required Color borderColor,
    required Color textColor,
    required Color mutedColor,
    required AppLocalizations strings,
    required VoidCallback onTap,
  }) {
    final name = user?.name?.isNotEmpty == true
        ? user!.name!
        : strings.defaultProfileName;
    final initials = _getInitials(name);
    final premiumLabel =
        !AppBuildConfig.isTesting && user?.hasPremiumAccess == true
        ? strings.premiumActivated
        : strings.free;
    final showsPremium =
        !AppBuildConfig.isTesting && user?.hasPremiumAccess == true;
    final email = user?.email?.isNotEmpty == true ? user!.email! : '';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x1A000000) : const Color(0x050F172A),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF14B8A6), Color(0xFF06B6D4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: user?.avatar != null
                    ? Image.network(
                        user!.avatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    : Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: showsPremium
                              ? const Color(0xFFE0533C)
                              : mutedColor,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          premiumLabel,
                          style: TextStyle(
                            color: showsPremium
                                ? const Color(0xFFE0533C)
                                : mutedColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: mutedColor, fontSize: 13.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? const Color(0xFF64748B)
                    : const Color(0xFFCBD5E1),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required Color cardBgColor,
    required Color borderColor,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x1A000000) : const Color(0x050F172A),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildDeleteAccountAction({
    required BuildContext context,
    required AuthProvider authProvider,
    required AppLocalizations strings,
    required bool isDark,
  }) {
    const danger = Color(0xFFEF4444);
    final background = isDark
        ? const Color(0xFF241719)
        : const Color(0xFFFFF8F8);
    final border = isDark ? const Color(0xFF542126) : const Color(0xFFFECACA);
    final muted = isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C);

    return Semantics(
      button: true,
      label: strings.deleteAccount,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              _showDeleteAccountDialog(context, authProvider, strings, isDark),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF3A1D21)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFEF4444),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    strings.deleteAccount,
                    style: TextStyle(
                      color: muted,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: danger,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchItem({
    required String label,
    required IconData icon,
    required bool value,
    required bool isDark,
    required Color textColor,
    required Color borderColor,
    required ValueChanged<bool> onChanged,
    bool isLast = false,
  }) {
    final iconBgColor = isDark
        ? const Color(0xFF272630)
        : const Color(0xFFF1F5F9);
    final iconColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF334155);

    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: value,
                  activeThumbColor: Colors.white,
                  activeTrackColor: const Color(0xFF63A97B),
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 68, color: borderColor),
      ],
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
    final iconBgColor = isDark
        ? const Color(0xFF272630)
        : const Color(0xFFF1F5F9);
    final iconColor = isDark
        ? const Color(0xFFCBD5E1)
        : const Color(0xFF334155);

    return Column(
      children: [
        Semantics(
          button: onTap != null,
          label: label,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 10),
                    if (isSpecialBadge)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2D261E)
                              : const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF78350F)
                                : const Color(0xFFFFEDD5),
                          ),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      )
                    else
                      Text(
                        badge,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF64748B),
                        ),
                      ),
                  ],
                  const SizedBox(width: 10),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? const Color(0xFF64748B)
                        : const Color(0xFFCBD5E1),
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 68, color: borderColor),
      ],
    );
  }
}
