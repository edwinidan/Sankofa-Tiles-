import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../../core/monetization/monetization_models.dart';
import '../../../providers/admob_provider.dart';
import '../../../providers/monetization_provider.dart';

class SettingsBannerAd extends ConsumerStatefulWidget {
  const SettingsBannerAd({super.key});

  @override
  ConsumerState<SettingsBannerAd> createState() => _SettingsBannerAdState();
}

class _SettingsBannerAdState extends ConsumerState<SettingsBannerAd> {
  BannerAd? _ad;
  int? _loadedWidth;
  int? _loadingWidth;
  int _loadGeneration = 0;

  @override
  void dispose() {
    _loadGeneration++;
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final removeAdsActive = ref.watch(
      monetizationProvider.select((state) => state.removeAdsActive),
    );
    if (removeAdsActive) {
      _clearBanner();
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.truncate();
        if (width <= 0) return const SizedBox.shrink();

        final ad = _ad;
        if (ad != null && _loadedWidth == width) {
          return Padding(
            padding: const EdgeInsets.only(top: 28, bottom: 4),
            child: Center(
              child: SizedBox(
                width: ad.size.width.toDouble(),
                height: ad.size.height.toDouble(),
                child: AdWidget(ad: ad),
              ),
            ),
          );
        }

        if (_loadingWidth != width) {
          _clearBanner();
          unawaited(_loadBanner(width));
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<void> _loadBanner(int width) async {
    final generation = ++_loadGeneration;
    _loadingWidth = width;

    final ad =
        await ref.read(adMobServiceProvider).loadAnchoredAdaptiveBannerAd(
              placement: BannerPlacement.settingsBottom,
              width: width,
            );
    if (!mounted || generation != _loadGeneration) {
      await ad?.dispose();
      return;
    }

    setState(() {
      _ad = ad;
      _loadedWidth = ad == null ? null : width;
      _loadingWidth = null;
    });
  }

  void _clearBanner() {
    _loadGeneration++;
    _loadingWidth = null;
    _loadedWidth = null;
    _ad?.dispose();
    _ad = null;
  }
}
