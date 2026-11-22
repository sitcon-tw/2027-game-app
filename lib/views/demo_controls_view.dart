import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sitcon_backend/game/game_service.dart';

import '../l10n/localization.dart';
import '../viewmodels/game_view_model.dart';
import '../widgets/cosmic_widgets.dart';
import 'operator_widgets.dart';

/// Device-local capabilities only; never calls the separate admin dashboard.
class DemoControlsView extends StatefulWidget {
  const DemoControlsView({super.key, required this.vm});
  final GameViewModel vm;

  @override
  State<DemoControlsView> createState() => _DemoControlsViewState();
}

class _DemoControlsViewState extends State<DemoControlsView> {
  final _coins = TextEditingController(text: '100');
  final _packs = TextEditingController(text: '10');
  final _delivery = TextEditingController(text: 'local-delivery-1');
  final _amount = TextEditingController(text: '3');
  final _agenda = TextEditingController(text: 'slot-1');

  @override
  void dispose() {
    _coins.dispose();
    _packs.dispose();
    _delivery.dispose();
    _amount.dispose();
    _agenda.dispose();
    super.dispose();
  }

  Future<void> _apply(Future<void> Function() action) async {
    FocusScope.of(context).unfocus();
    final applied = await widget.vm.run(() async {
      await action();
      return true;
    });
    if (!mounted || applied != true) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(context.l10n.shellApplied)));
  }

  int _positive(TextEditingController controller) {
    final value = int.tryParse(controller.text);
    if (value == null || value <= 0) {
      throw GameArgumentError(const GameMessage('invalidGrant'));
    }
    return value;
  }

  String _phase(EventPhase phase) => switch (phase) {
    EventPhase.before => context.l10n.shellPhaseBefore,
    EventPhase.active => context.l10n.shellPhaseActive,
    EventPhase.ended => context.l10n.shellPhaseEnded,
  };

  Widget _grant({
    required String resource,
    required String id,
    required TextEditingController controller,
    required Future<void> Function(int) grant,
    required bool enabled,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      TextField(
        key: ValueKey('cheat-$id-amount'),
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(labelText: resource),
      ),
      const SizedBox(height: 8),
      FilledButton.icon(
        key: ValueKey('cheat-$id-add'),
        onPressed: enabled
            ? () => _apply(() => grant(_positive(controller)))
            : null,
        icon: const Icon(Icons.add),
        label: Text(context.l10n.shellAddResource(resource)),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => CosmicPage(
    title: context.l10n.shellCheats,
    vm: widget.vm,
    builder: (context) {
      final vm = widget.vm;
      final controls = vm.demoControls;
      if (!vm.isOfflineDemo || controls == null) {
        return Center(child: Text(context.l10n.shellOfflineOnly));
      }
      final available = !vm.busy;
      final rewardsEnabled =
          available && vm.checkedIn && vm.phase == EventPhase.active;
      return ListView(
        key: const ValueKey('demo-controls-list'),
        padding: const EdgeInsets.all(16),
        children: [
          if (vm.error != null)
            Text(
              gameText(context, vm.error),
              key: const ValueKey('demo-error'),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          _grant(
            resource: context.l10n.coins,
            id: 'coins',
            controller: _coins,
            grant: controls.addCoins,
            enabled: available,
          ),
          const SizedBox(height: 16),
          _grant(
            resource: context.l10n.packs,
            id: 'packs',
            controller: _packs,
            grant: controls.addPacks,
            enabled: available,
          ),
          const SizedBox(height: 16),
          Text(context.l10n.utilityPointsSeparate),
          const SizedBox(height: 16),
          ExpansionTile(
            key: const ValueKey('demo-scenarios'),
            title: Text(context.l10n.shellScenarios),
            children: [
              Text(_phase(vm.phase), key: const ValueKey('demo-status')),
              Wrap(
                spacing: 8,
                children: [
                  for (final phase in EventPhase.values)
                    ChoiceChip(
                      key: ValueKey('demo-phase-${phase.name}'),
                      label: Text(_phase(phase)),
                      selected: vm.phase == phase,
                      onSelected: available
                          ? (_) => _apply(() => controls.setMockPhase(phase))
                          : null,
                    ),
                ],
              ),
              Text(context.l10n.shellPhaseHint),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('demo-delivery-id'),
                controller: _delivery,
                decoration: InputDecoration(
                  labelText: context.l10n.shellDeliveryId,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                key: const ValueKey('demo-pack-amount'),
                controller: _amount,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(labelText: context.l10n.packs),
              ),
              FilledButton.tonalIcon(
                key: const ValueKey('demo-remote-packs'),
                onPressed: rewardsEnabled
                    ? () => _apply(
                        () => controls.simulateRemotePacks(
                          _delivery.text.trim(),
                          _positive(_amount),
                          'local-scenario',
                        ),
                      )
                    : null,
                icon: const Icon(Icons.inventory_2_outlined),
                label: Text(context.l10n.shellSimulateDelivery),
              ),
              Text(context.l10n.shellDeliveryHint),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('demo-agenda-slot'),
                controller: _agenda,
                decoration: InputDecoration(
                  labelText: context.l10n.shellAgendaId,
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    key: const ValueKey('demo-agenda'),
                    onPressed: rewardsEnabled
                        ? () => _apply(
                            () => controls.simulateAgenda(_agenda.text.trim()),
                          )
                        : null,
                    icon: const Icon(Icons.event_outlined),
                    label: Text(context.l10n.shellAgendaReward),
                  ),
                  FilledButton.tonalIcon(
                    key: const ValueKey('demo-photo'),
                    onPressed: rewardsEnabled
                        ? () => _apply(controls.simulatePhotoReward)
                        : null,
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(context.l10n.shellPhotoReward),
                  ),
                ],
              ),
              Text(context.l10n.shellScenarioLimits),
              for (final booth in vm.booths)
                ListTile(
                  title: Text(boothName(context, booth)),
                  trailing: FilledButton.tonal(
                    key: ValueKey('demo-booth-${booth.id}'),
                    onPressed: rewardsEnabled && !booth.completed
                        ? () => _apply(
                            () => controls.simulateBoothCompletion(booth.id),
                          )
                        : null,
                    child: Text(
                      booth.completed
                          ? context.l10n.done
                          : context.l10n.shellCompleteBooth,
                    ),
                  ),
                ),
              Text(context.l10n.shellBoothHint),
              const SizedBox(height: 16),
              DropdownMenu<AccountRole>(
                key: ValueKey('demo-role-${vm.role.name}'),
                label: Text(context.l10n.operatorDemoRole),
                initialSelection: vm.role,
                enabled: available,
                expandedInsets: EdgeInsets.zero,
                dropdownMenuEntries: [
                  for (final role in AccountRole.values)
                    DropdownMenuEntry(
                      value: role,
                      label: accountRoleName(context, role),
                      enabled:
                          role != AccountRole.booth || vm.booths.isNotEmpty,
                    ),
                ],
                onSelected: (role) {
                  if (role == null) return;
                  _apply(
                    () => controls.setRole(
                      role,
                      boothId: role == AccountRole.booth
                          ? vm.boothId ?? vm.booths.first.id
                          : null,
                    ),
                  );
                },
              ),
              if (vm.role == AccountRole.booth) ...[
                const SizedBox(height: 16),
                DropdownMenu<String>(
                  key: ValueKey('demo-assigned-booth-${vm.boothId}'),
                  label: Text(context.l10n.operatorAssignedBooth),
                  initialSelection: vm.boothId,
                  enabled: available,
                  expandedInsets: EdgeInsets.zero,
                  dropdownMenuEntries: [
                    for (final booth in vm.booths)
                      DropdownMenuEntry(
                        value: booth.id,
                        label: boothName(context, booth),
                      ),
                  ],
                  onSelected: (boothId) {
                    if (boothId == null) return;
                    _apply(
                      () =>
                          controls.setRole(AccountRole.booth, boothId: boothId),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      );
    },
  );
}
