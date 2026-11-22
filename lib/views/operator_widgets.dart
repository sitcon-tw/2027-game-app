import 'package:flutter/material.dart';

import 'package:sitcon_backend/game/game_service.dart';

import '../l10n/localization.dart';
import '../viewmodels/game_view_model.dart';
import '../widgets/cosmic_widgets.dart';

String accountRoleName(BuildContext context, AccountRole role) =>
    switch (role) {
      AccountRole.user => context.l10n.operatorRoleUser,
      AccountRole.staff => context.l10n.operatorRoleStaff,
      AccountRole.booth => context.l10n.operatorRoleBooth,
    };

String scannerModeName(BuildContext context, ScannerMode mode) =>
    switch (mode) {
      ScannerMode.user => context.l10n.operatorModeUser,
      ScannerMode.staff => context.l10n.operatorModeStaff,
      ScannerMode.booth => context.l10n.operatorModeBooth,
    };

class AccountRoleCard extends StatelessWidget {
  const AccountRoleCard({super.key, required this.vm});
  final GameViewModel vm;

  @override
  Widget build(BuildContext context) {
    final assigned = vm.booths.where((booth) => booth.id == vm.boothId);
    return Card.filled(
      key: const ValueKey('operator-account-role'),
      child: ListTile(
        key: vm.role == AccountRole.booth
            ? const ValueKey('operator-assigned-booth')
            : null,
        leading: Icon(
          vm.role == AccountRole.booth
              ? Icons.storefront_outlined
              : Icons.verified_user_outlined,
        ),
        title: Text(accountRoleName(context, vm.role)),
        subtitle: vm.role == AccountRole.booth
            ? Text(
                assigned.isEmpty
                    ? context.l10n.operatorNoBooth
                    : boothName(context, assigned.first),
              )
            : null,
      ),
    );
  }
}

/// Operator receipts deliberately do not reuse the social player screen.
class OperatorResultView extends StatelessWidget {
  const OperatorResultView({
    super.key,
    required this.vm,
    required this.result,
    required this.revision,
  });
  final GameViewModel vm;
  final ScanResult result;
  final int revision;

  @override
  Widget build(BuildContext context) => CosmicPage(
    title: result.kind == 'boothComplete'
        ? context.l10n.operatorCompletionReceipt
        : context.l10n.operatorReadOnlyResult,
    vm: vm,
    builder: (context) {
      if (vm.scannerRevision != revision) {
        return Center(
          key: const ValueKey('operator-result-revoked'),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(context.l10n.operatorPermissionChanged),
          ),
        );
      }
      final player = result.player;
      final booth = result.booth;
      final station = result.station;
      return ListView(
        key: const ValueKey('operator-result'),
        padding: const EdgeInsets.all(24),
        children: [
          if (player == null && booth == null && station == null) ...[
            const Icon(Icons.badge_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              gameText(context, result.message),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
          if (player != null) ...[
            ListTile(
              key: const ValueKey('operator-recipient'),
              leading: const Icon(Icons.badge_outlined),
              title: Text(playerName(context, player)),
            ),
            if (result.kind != 'boothComplete')
              Wrap(
                spacing: 8,
                children: [
                  for (final role in player.roles)
                    Chip(label: Text(roleName(context, role))),
                ],
              ),
          ],
          if (booth != null)
            ListTile(
              key: const ValueKey('operator-receipt-booth'),
              title: Text(context.l10n.operatorAssignedBooth),
              subtitle: Text(boothName(context, booth)),
            ),
          if (result.kind == 'boothComplete')
            Card.filled(
              child: ListTile(
                key: ValueKey(
                  result.repeated
                      ? 'operator-receipt-repeated'
                      : 'operator-receipt-completed',
                ),
                leading: Icon(
                  result.repeated ? Icons.history : Icons.check_circle_outline,
                ),
                title: Text(
                  result.repeated
                      ? context.l10n.operatorAlreadyCompleted
                      : context.l10n.operatorCompletionRecorded,
                ),
              ),
            ),
          if (station != null)
            ListTile(
              key: const ValueKey('operator-station-info'),
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(stationName(context, station)),
              subtitle: Text(
                context.l10n.socialStationDetails(
                  station.packs,
                  station.limit,
                  station.remaining,
                  station.open
                      ? context.l10n.socialOpen
                      : context.l10n.socialClosed,
                ),
              ),
            ),
          if (result.kind != 'boothComplete' && result.uid != null) ...[
            const SizedBox(height: 16),
            SelectableText(result.uid!),
          ],
          const SizedBox(height: 24),
          FilledButton(
            key: const ValueKey('operator-result-dismiss'),
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.done),
          ),
        ],
      );
    },
  );
}
