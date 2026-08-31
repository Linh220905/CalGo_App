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

    final bgColor = isDark ? const Color(0xFF141318) : const Color(0xFFF7F7F5);
    final cardBgColor = isDark ? const Color(0xFF212027) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF111318);
    final mutedColor = isDark
        ? const Color(0xFFA7A5B0)
        : const Color(0xFF747780);
    final borderColor = isDark
        ? const Color(0xFF34313D)
        : const Color(0xFFEDEDEB);
    const accentColor = Color(0xFFFF6B35);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.settingsEyebrow.toUpperCase(),
                style: TextStyle(
                  color: mutedColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.8,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s.profileHeading,
                style: TextStyle(
                  color: textColor,
                  fontSize: 36,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.1,
                ),
              ),
              const SizedBox(height: 26),

              _buildAccountCard(
                user: user,
                isDark: isDark,
                cardBgColor: cardBgColor,
                textColor: textColor,
                mutedColor: mutedColor,
                accentColor: accentColor,
                premiumLabel:
                    !AppBuildConfig.isTesting && user?.hasPremiumAccess == true
                    ? s.premiumActivated
                    : s.free,
                defaultName: s.defaultProfileName,
              ),
              const SizedBox(height: 28),

              _buildSectionLabel(s.accountSection, mutedColor),
              const SizedBox(height: 9),
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

              _buildSectionLabel(s.trackingSection, mutedColor),
              const SizedBox(height: 9),
              _buildSectionCard(
                cardBgColor: cardBgColor,
                borderColor: borderColor,
                isDark: isDark,
                children: [
                  _buildMenuItem(
                    icon: Icons.track_changes_outlined,
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
                    icon: Icons.notifications_outlined,
                    label: s.notifications,
                    textColor: textColor,
                    borderColor: borderColor,
                    isDark: isDark,
                    isLast: true,
                    onTap: () => _showNotificationInfoDialog(context, isDark),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildSectionLabel(s.preferencesSection, mutedColor),
              const SizedBox(height: 9),
              _buildSectionCard(
                cardBgColor: cardBgColor,
                borderColor: borderColor,
                isDark: isDark,
                children: [
                  _buildSwitchItem(
                    label: s.darkMode,
                    icon: Icons.dark_mode_outlined,
                    value: isDark,
                    isDark: isDark,
                    textColor: textColor,
                    borderColor: borderColor,
                    onChanged: settings.toggleTheme,
                  ),
                  _buildMenuItem(
                    icon: Icons.language_outlined,
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

              _buildSectionLabel(s.supportSection, mutedColor),
              const SizedBox(height: 9),
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
                    isLast: true,
                    onTap: () => _showSupportDialog(context, isDark),
                  ),
                ],
              ),

              const SizedBox(height: 24),

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
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF451A1A)
                          : const Color(0xFFFECACA),
                    ),
                    backgroundColor: isDark
                        ? const Color(0xFF2C1517)
                        : const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildMenuItem(
                icon: Icons.delete_forever_outlined,
                label: s.deleteAccount,
                textColor: const Color(0xFFEF4444),
                borderColor: Colors.transparent,
                isDark: isDark,
                isLast: true,
                onTap: () =>
                    _showDeleteAccountDialog(context, authProvider, s, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        color: color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.2,
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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x18000000) : const Color(0x07111418),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }

  Widget _buildAccountCard({
    required User? user,
    required bool isDark,
    required Color cardBgColor,
    required Color textColor,
    required Color mutedColor,
    required Color accentColor,
    required String premiumLabel,
    required String defaultName,
  }) {
    final name = user?.name?.isNotEmpty == true ? user!.name! : defaultName;
    final avatarLetter = name.trim().isNotEmpty
        ? name.trim()[0].toUpperCase()
        : '?';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF34313D) : const Color(0xFFECECE9),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x22000000) : const Color(0x0D111318),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            clipBehavior: Clip.antiAlias,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF25C6B8), Color(0xFF209BEA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: user?.avatar != null
                ? Image.network(
                    user!.avatar!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Text(
                      avatarLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : Text(
                    avatarLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: accentColor,
                      size: 16,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        premiumLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (user?.email != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    user!.email!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: mutedColor, fontSize: 14),
                  ),
                ],
              ],
            ),
          ),
        ],
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
  }) {
    final iconBgColor = isDark
        ? const Color(0xFF2C2A34)
        : const Color(0xFFF1F3F2);
    final iconColor = isDark
        ? const Color(0xFFD4D1DB)
        : const Color(0xFF41454D);

    return Column(
      children: [
        InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Switch.adaptive(
                  value: value,
                  activeColor: Colors.white,
                  activeTrackColor: const Color(0xFFFF6B35),
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
        Divider(height: 1, indent: 72, color: borderColor),
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
        ? const Color(0xFF2C2A34)
        : const Color(0xFFF1F3F2);
    final iconColor = isDark
        ? const Color(0xFFD4D1DB)
        : const Color(0xFF41454D);

    return Column(
      children: [
        Semantics(
          button: onTap != null,
          label: label,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 11),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 150),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isSpecialBadge
                              ? (isDark
                                    ? const Color(0xFF3B2A10)
                                    : const Color(0xFFFFF1E8))
                              : (isDark
                                    ? const Color(0xFF2C2A34)
                                    : const Color(0xFFF1F3F2)),
                          borderRadius: BorderRadius.circular(9),
                          border: isSpecialBadge
                              ? Border.all(
                                  color: isDark
                                      ? const Color(0xFF8A5A20)
                                      : const Color(0xFFFFD1B8),
                                  width: 0.8,
                                )
                              : null,
                        ),
                        child: Text(
                          badge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSpecialBadge
                                ? const Color(0xFFE85B2A)
                                : (isDark
                                      ? const Color(0xFFA7A5B0)
                                      : const Color(0xFF70747A)),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 7),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? const Color(0xFF777482)
                        : const Color(0xFFB4B5B5),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast) Divider(height: 1, indent: 71, color: borderColor),
      ],
    );
  }
}
