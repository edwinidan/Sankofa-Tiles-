# Economy Balance

## Goal

Keep the full 50-level campaign playable without purchases while making optional rewards and purchases useful rather than mandatory.

## Earned Cowries

| Source | Reward | Farming control |
|---|---:|---|
| First clear | 40 | Once per level |
| Star improvement | 12 per newly earned star | Only improved stars |
| Chapter complete | 120 | Once per chapter-final level |
| Daily rewards | 40, 55, 75, 120 across the cycle | Once per local date |
| Achievements | 50-300 depending on milestone | Claim-once |
| Rewarded double | Equal to earned level Cowries | Optional callback-gated grant |
| Shop gift | 25 | Optional rewarded grant |

Baseline full-campaign first-clear income is 2,000 Cowries before stars, chapters, daily rewards, achievements, or rewarded ads. Five chapter rewards add up to 600 Cowries. A perfect first pass can add up to 1,800 Cowries from star improvements.

## Booster Supply

| Source | Boosters |
|---|---|
| Daily rewards | Hints, Shuffles, Open Path on selected days |
| Achievements | Hint and Open Path milestone rewards |
| Rewarded placements | Free Hint, free Shuffle, retry Shuffle |
| Starter Pack / packs | Sandbox purchase grants |

Hint, Shuffle, and Open Path are helpful but not mandatory. The board generator and auto-shuffle behavior must keep progression possible without inventory.

## Rewarded Ad Value

Rewarded grants are intentionally modest:

- Double completion Cowries scales with earned level rewards.
- Free Hint and free Shuffle remove short-term friction without advancing progress directly.
- Bonus daily chest gives 30 Cowries and 1 Hint.
- Shop gift gives 25 Cowries.
- Retry assistance gives 1 Shuffle.

Rewarded ads remain voluntary and available to Remove Ads owners.

## Product Bundle Value

| Product | Value role |
|---|---|
| Remove Ads | Convenience entitlement only; does not affect fairness. |
| Starter Pack | Best one-time bundle: Remove Ads, 300 Cowries, boosters, cosmetic. |
| Booster packs | Convenience for players who want more assistance. |
| Cowrie packs | Soft-currency acceleration. |
| Cosmetic tile back | No gameplay advantage. |

Production prices are not hard-coded. The current sandbox UI displays placeholder labels until live billing returns localized prices.

## Balance Risks

- Daily rewards are local-date based and can be clock-tampered without server validation.
- Purchase verification is local-only in the sandbox implementation.
- Booster shop spending with Cowries is not implemented yet, so paid and rewarded boosters are the only shop booster acquisition paths beyond gameplay rewards.
- Cosmetic ownership exists, but cosmetic selection/rendering is deferred.

## Recommendation

Proceed to production monetization only after live billing, server-side validation, localized prices, and consent handling are added. The free-to-play campaign loop is viable with the current reward economy.
