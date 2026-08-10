import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/onboarding_provider.dart';
import '../../../providers/app_settings_provider.dart';

class NameStep extends StatefulWidget {
  const NameStep({super.key});
  @override
  State<NameStep> createState() => _NameStepState();
}

class _NameStepState extends State<NameStep> {
  late TextEditingController _c;

  @override
  void initState() {
    super.initState();
    _c = TextEditingController(
        text: context.read<OnboardingProvider>().data.name ?? '');
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettingsProvider>();
    final s = settings.strings;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(children: [
                  const SizedBox(height: 8),
                  Image.asset(
                    'assets/images/apple_mascot/apple_happy.png',
                    height: 140,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 12),
                  Text(s.nameStepTitle,
                      style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111111))),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                              color: const Color(0xFFECECEC).withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 2))
                        ]),
                    child: TextField(
                      controller: _c,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                          hintText: s.nameStepHint,
                          hintStyle: const TextStyle(color: Color(0xFF7A7A7A)),
                          suffixIcon: _c.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF111111), size: 22),
                                  onPressed: () => _c.clear())
                              : null,
                          suffixIconConstraints:
                              const BoxConstraints(minWidth: 48),
                          border: InputBorder.none,
                          filled: false),
                      style: const TextStyle(
                          color: Color(0xFF111111), fontSize: 17),
                      onChanged: (v) {
                        setState(() {});
                        context.read<OnboardingProvider>().setName(v);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _c.text.trim().isNotEmpty
                      ? () => context.read<OnboardingProvider>().nextStep()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF111111),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                    disabledBackgroundColor: const Color(0xFFECECEC),
                    disabledForegroundColor: const Color(0xFFAAAAAA),
                  ),
                  child: Text(s.nextStepButton,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
