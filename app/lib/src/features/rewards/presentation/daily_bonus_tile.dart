import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/rewards/application/daily_bonus_claim_provider.dart';
import 'package:tipsterino/src/features/rewards/domain/daily_bonus_grant_result.dart';

class DailyBonusTile extends ConsumerWidget {
  const DailyBonusTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final state = ref.watch(dailyBonusClaimProvider);
    final notifier = ref.read(dailyBonusClaimProvider.notifier);
    final reason = state.lastResult?.reason;
    final isRunning = state.isRunning;
    final isClaimedNow = state.isClaimedNow;
    final hasError = state.lastError != null;
    final isSupabaseConfigured = ref.watch(supabaseConfigProvider).isConfigured;
    final showNotConfigured = !isSupabaseConfigured;
    final showOffline = hasError && isSupabaseConfigured;
    final isRateLimited = reason == DailyBonusReason.rateLimited;

    final bodyText = _bodyText(
      loc,
      showNotConfigured,
      showOffline,
      isClaimedNow,
      reason,
    );
    final buttonLabel = isClaimedNow
        ? loc.daily_bonus_cta_claimed
        : ((showOffline || isRateLimited)
              ? loc.daily_bonus_cta_retry
              : loc.daily_bonus_cta_claim);
    final canClaim = !isRunning &&
        !isClaimedNow &&
        !showNotConfigured &&
        reason != DailyBonusReason.disabled &&
        reason != DailyBonusReason.notVerified &&
        reason != DailyBonusReason.profileIncomplete &&
        reason != DailyBonusReason.notConfigured;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              loc.daily_bonus_title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              bodyText,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (isRunning) ...[
              const SizedBox(height: 12),
              const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: canClaim
                    ? () async {
                        final claimResult = await notifier.claim();
                        if (claimResult == null || !claimResult.granted) {
                          return;
                        }
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              loc.daily_bonus_snackbar_granted(claimResult.amount),
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _bodyText(
    AppLocalizations loc,
    bool showNotConfigured,
    bool showOffline,
    bool isClaimedNow,
    DailyBonusReason? reason,
  ) {
    if (isClaimedNow) {
      return loc.daily_bonus_body_claimed;
    }

    switch (reason) {
      case DailyBonusReason.notConfigured:
        return loc.daily_bonus_body_not_configured;
      case DailyBonusReason.disabled:
        return loc.daily_bonus_body_disabled;
      case DailyBonusReason.notVerified:
        return loc.daily_bonus_body_not_verified;
      case DailyBonusReason.profileIncomplete:
        return loc.daily_bonus_body_profile_incomplete;
      case DailyBonusReason.rateLimited:
        return loc.daily_bonus_body_offline;
      default:
        break;
    }

    if (showNotConfigured) {
      return loc.daily_bonus_body_not_configured;
    }

    if (showOffline) {
      return loc.daily_bonus_body_offline;
    }

    return loc.daily_bonus_body_available;
  }
}
