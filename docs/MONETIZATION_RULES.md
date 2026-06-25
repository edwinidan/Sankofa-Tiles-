# Monetization Rules

## Environment

`MonetizationConfig` separates sandbox and production identifiers. Debug builds use sandbox/test labels. Release builds default to production-shaped ids, but real store ids and ad unit ids must be configured before a production monetized release.

## Product Rules

| Product | Rule |
|---|---|
| Remove Ads | Permanent non-consumable entitlement. Suppresses forced interstitial eligibility only. |
| Starter Pack | One-time bundle. Grants Remove Ads, Cowries, boosters, and cosmetic entitlement. |
| Consumables | Granted once per transaction callback. Not restorable. |
| Cosmetics | Permanent entitlement. No gameplay advantage. |
| Restore Purchases | Restores non-consumable and cosmetic entitlements from owned product markers. |

All value grants go through centralized services. UI code does not directly write Cowries, boosters, or entitlements.

## Rewarded Ads

Rewarded placements:

- Double completion Cowries.
- Free Hint.
- Free rescue Shuffle.
- Bonus daily chest.
- Small Shop reward.
- Retry assistance.

Rules:

- Explain the reward before the user acts.
- Grant only after successful completion callback.
- Store callback markers to prevent duplicate rewards.
- Do not deduct inventory if ad fails, is cancelled, or is unavailable.
- Keep rewarded ads voluntary.
- Allow rewarded ads for Remove Ads owners.

## Interstitial Ads

Eligibility rules:

| Rule | Current value |
|---|---:|
| Minimum completed levels | 2 |
| Completed-level frequency | 3 |
| Time cooldown | 8 minutes |
| Rewarded-ad cooldown | 2 minutes |
| Session cap | 2 |

Interstitials are ineligible:

- During gameplay.
- During tutorial or first-session protection.
- Immediately after a loss.
- During rewarded-ad cooldown.
- For Remove Ads owners.
- When frequency, cooldown, or session cap rules fail.

The current app records eligibility but does not display a live interstitial SDK surface.

## Production Blockers

- Live Google Mobile Ads SDK integration.
- Consent flow for regions and user categories that require it.
- App Store / Play Billing integration.
- Server-side receipt validation.
- Localized platform prices.
- Store product setup and test account validation.
- Published privacy policy and store declarations that match final SDK behavior.
