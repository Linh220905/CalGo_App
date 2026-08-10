import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../config/app_build_config.dart';

/// A production-only banner slot. The testing flavor returns no widget and
/// never initializes the ads SDK. Production loads a real ad only when both
/// AdMob IDs were supplied at build time.
class CalGoAdBanner extends StatefulWidget {
  const CalGoAdBanner({super.key});

  @override
  State<CalGoAdBanner> createState() => _CalGoAdBannerState();
}

class _CalGoAdBannerState extends State<CalGoAdBanner> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (AppBuildConfig.adsEnabled) {
      _loadBanner();
    }
  }

  Future<void> _loadBanner() async {
    await MobileAds.instance.initialize();
    if (!mounted) return;

    final banner = BannerAd(
      adUnitId: AppBuildConfig.admobBannerUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) return;
          setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, _) {
          ad.dispose();
          if (mounted) setState(() => _loaded = false);
        },
      ),
    );
    _banner = banner;
    await banner.load();
  }

  @override
  void dispose() {
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!AppBuildConfig.adsEnabled || !_loaded || _banner == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: _banner!.size.width.toDouble(),
      height: _banner!.size.height.toDouble(),
      child: AdWidget(ad: _banner!),
    );
  }
}
