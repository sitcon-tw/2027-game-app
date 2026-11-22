import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:sitcon_backend/game/game_service.dart';

import '../l10n/localization.dart';
import '../services/nfc/automatic_scan_controller.dart';
import '../services/nfc/ntag_reader.dart';
import '../services/nfc/scan_route_observer.dart';

import 'package:sitcon_backend/testing/test_tag_ids.dart';

import '../viewmodels/game_view_model.dart';
import '../widgets/cosmic_widgets.dart';
import 'collection_view.dart';
import 'tasks_view.dart';
import 'operator_widgets.dart';

Future<void> openBooth(
  BuildContext context,
  GameViewModel vm,
  Booth booth,
) async {
  final failure = context.l10n.socialBoothOpenError;
  try {
    final uri = Uri.parse(booth.url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      vm.reportError(failure);
    }
  } catch (e) {
    vm.reportError(e);
  }
}

class ScanView extends StatefulWidget {
  const ScanView({super.key, required this.vm, this.reader});
  final GameViewModel vm;

  /// Optional instance reader for deterministic tests; owned by this page.
  final NtagReader? reader;
  @override
  State<ScanView> createState() => _ScanViewState();
}

class _ScanViewState extends State<ScanView>
    with WidgetsBindingObserver, RouteAware {
  final uid = TextEditingController();
  late final AutomaticScanController scanner;
  ModalRoute<dynamic>? _route;
  late int _scannerRevision;
  static const _stationFixtures = {
    'station-1': 1,
    'station-2': 2,
    'station-3': 3,
    'station-4': 4,
  };

  @override
  void initState() {
    super.initState();
    _scannerRevision = widget.vm.scannerRevision;
    scanner = AutomaticScanController(
      reader:
          widget.reader ??
          createNtagReader(promptProvider: () => context.l10n.domainNfcPrompt),
      onUid: _submit,
    );
    scanner.setResumed(
      (WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed) ==
          AppLifecycleState.resumed,
    );
    scanner.setBlocked(widget.vm.busy || !widget.vm.canScan);
    scanner.addListener(_scannerChanged);
    widget.vm.addListener(_gameChanged);
    WidgetsBinding.instance.addObserver(this);
  }

  void _scannerChanged() {
    if (mounted) setState(() {});
  }

  void _gameChanged() {
    if (_scannerRevision != widget.vm.scannerRevision) {
      // Change permission context while disarmed; never briefly start the old one.
      scanner.setBlocked(true);
      _scannerRevision = widget.vm.scannerRevision;
      scanner.resetContext();
    }
    scanner.setBlocked(widget.vm.busy || !widget.vm.canScan);
  }

  @override
  void didUpdateWidget(covariant ScanView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vm != widget.vm) {
      oldWidget.vm.removeListener(_gameChanged);
      widget.vm.addListener(_gameChanged);
      _scannerRevision = -1;
      _gameChanged();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (_route != route) {
      scanRouteObserver.unsubscribe(this);
      _route = route;
      if (route != null) scanRouteObserver.subscribe(this, route);
    }
    _restoreVisibility();
  }

  void _restoreVisibility() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) scanner.setRouteVisible(_route?.isCurrent ?? false);
    });
  }

  @override
  void didPush() => _restoreVisibility();
  @override
  void didPopNext() => _restoreVisibility();
  @override
  void didPushNext() => scanner.setRouteVisible(false);
  @override
  void didPop() => scanner.setRouteVisible(false);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) =>
      scanner.setResumed(state == AppLifecycleState.resumed);

  bool get _mayPresent =>
      mounted &&
      (_route?.isCurrent ?? false) &&
      (WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed) ==
          AppLifecycleState.resumed;

  @override
  void dispose() {
    scanRouteObserver.unsubscribe(this);
    WidgetsBinding.instance.removeObserver(this);
    widget.vm.removeListener(_gameChanged);
    scanner.removeListener(_scannerChanged);
    scanner.dispose();
    uid.dispose();
    super.dispose();
  }

  Future<void> submit(String value) => scanner.submitFixture(value.trim());

  Future<void> _submit(String value) async {
    final demoStation = widget.vm.isOfflineDemo && value.startsWith('station-');
    if (!demoStation) uid.text = value;
    final revision = widget.vm.scannerRevision;
    final mode = widget.vm.scannerMode;
    final result = await widget.vm.scan(value.trim(), demoStation: demoStation);
    if (!mounted ||
        result == null ||
        !_mayPresent ||
        revision != widget.vm.scannerRevision) {
      return;
    }
    if (mode != ScannerMode.user || result.kind == 'boothComplete') {
      if (mode == ScannerMode.staff && result.kind == 'bindStation') {
        final bound = await openPage<bool>(
          context,
          StationBindingView(vm: widget.vm, uid: result.uid ?? value),
        );
        if (mounted && bound == true) scanner.resetContext();
      } else {
        await openPage(
          context,
          OperatorResultView(vm: widget.vm, result: result, revision: revision),
        );
      }
      return;
    }
    if (result case ScanResult(kind: 'attendee', player: final player?)
        when !widget.vm.canInteractWithRemotePlayer(player.id)) {
      await openPage(
        context,
        CosmicPage(
          title: playerName(context, player),
          vm: widget.vm,
          builder: (_) => ListView(
            padding: const EdgeInsets.all(20),
            children: [PlayerIdentity(player)],
          ),
        ),
      );
      return;
    }
    if (result.player != null) {
      await openPage(
        context,
        PlayerView(vm: widget.vm, player: result.player!),
      );
    } else if (result.booth != null) {
      await messageDialog(
        context,
        boothName(context, result.booth!),
        gameText(context, result.message),
      );
      if (mounted && _mayPresent) {
        await openBooth(context, widget.vm, result.booth!);
      }
    } else {
      if (result.kind == 'checkpoint') {
        final number = result.message.args['number'];
        final points = widget.vm.checkpoints.where((p) => p.number == number);
        final point = points.isEmpty ? null : points.first;
        await showDialog<void>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            icon: const Icon(Icons.location_on_outlined),
            title: Text(
              point == null
                  ? context.l10n.checkpoints
                  : context.l10n.socialCheckpointNumber(point.number),
            ),
            content: Text(
              [
                gameText(context, result.message),
                if (point != null) areaName(context, point.area),
                context.l10n.socialCheckpointProgress(widget.vm.collected),
                if (widget.vm.collected == 7)
                  context.l10n.socialPostcardUnlocked,
              ].join('\n'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  openPage(
                    context,
                    CosmicPage(
                      title: context.l10n.checkpoints,
                      vm: widget.vm,
                      builder: (_) => TasksView(vm: widget.vm, initialTab: 1),
                    ),
                  );
                },
                child: Text(context.l10n.socialViewCheckpoints),
              ),
              FilledButton(
                key: const ValueKey('scan-result-dismiss'),
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.l10n.done),
              ),
            ],
          ),
        );
      } else {
        await messageDialog(
          context,
          result.kind == 'station'
              ? context.l10n.socialStationSupply
              : context.l10n.socialScanResult,
          gameText(context, result.message),
        );
      }
      if (mounted && _mayPresent && result.openPacks && widget.vm.packs > 0) {
        await openPage(context, PackView(vm: widget.vm));
      }
    }
  }

  Widget _scannerStatus(BuildContext context) {
    final (icon, title) = switch (scanner.status) {
      AutomaticScanStatus.paused => (
        Icons.pause_circle_outline,
        context.l10n.socialScanPaused,
      ),
      AutomaticScanStatus.starting => (
        Icons.nfc,
        context.l10n.socialScanStarting,
      ),
      AutomaticScanStatus.waiting => (
        Icons.contactless_outlined,
        context.l10n.socialScanReady,
      ),
      AutomaticScanStatus.processing => (
        Icons.hourglass_top,
        context.l10n.socialScanProcessing,
      ),
      AutomaticScanStatus.cancelled => (
        Icons.cancel_outlined,
        context.l10n.socialScanCancelled,
      ),
      AutomaticScanStatus.error => (
        Icons.error_outline,
        context.l10n.socialScanError,
      ),
    };
    return Card(
      child: Padding(
        key: ValueKey('scan-state-${scanner.status.name}'),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    key: const ValueKey('scan-status'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            if (scanner.status == AutomaticScanStatus.error) ...[
              const SizedBox(height: 8),
              Text(
                gameText(context, scanner.error),
                key: const ValueKey('scan-error'),
              ),
            ],
            if (scanner.needsRetry)
              TextButton.icon(
                key: const ValueKey('scan-native-retry'),
                onPressed: scanner.processing || widget.vm.busy
                    ? null
                    : scanner.retry,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.retry),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => CosmicPage(
    title: context.l10n.scan,
    vm: widget.vm,
    builder: (context) => ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (widget.vm.role == AccountRole.booth) ...[
          AccountRoleCard(vm: widget.vm),
          const SizedBox(height: 16),
        ],
        if (widget.vm.scannerModes.length > 1) ...[
          SegmentedButton<ScannerMode>(
            key: const ValueKey('operator-scanner-modes'),
            segments: [
              for (final mode in widget.vm.scannerModes)
                ButtonSegment(
                  value: mode,
                  label: Text(
                    scannerModeName(context, mode),
                    key: ValueKey('scan-mode-${mode.name}'),
                  ),
                  enabled: !widget.vm.busy && !scanner.processing,
                ),
            ],
            selected: {widget.vm.scannerMode},
            onSelectionChanged: (selection) =>
                widget.vm.setScannerMode(selection.single),
          ),
          const SizedBox(height: 16),
        ],
        if (!widget.vm.canScan)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              widget.vm.scannerMode == ScannerMode.user
                  ? context.l10n.shellCheckInFirst
                  : context.l10n.operatorNoBooth,
            ),
          ),
        const Icon(Icons.contactless_rounded, size: 96, color: sky),
        const SizedBox(height: 16),
        Text(
          widget.vm.scannerMode == ScannerMode.booth
              ? context.l10n.operatorScanInstruction
              : context.l10n.socialScanInstruction,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 24),
        if (widget.vm.canScan) _scannerStatus(context),
        const SizedBox(height: 8),
        Text(context.l10n.socialScanDuplicateHint, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        if (widget.vm.testToolsEnabled)
          Section(
            context.l10n.socialTestScan,
            icon: Icons.science_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  key: const ValueKey('scan-uid'),
                  controller: uid,
                  autocorrect: false,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: context.l10n.socialUid,
                    hintText: '04 B0 00 00 00 00 01',
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const ValueKey('scan-submit'),
                  onPressed:
                      widget.vm.busy || scanner.processing || !widget.vm.canScan
                      ? null
                      : () => submit(uid.text),
                  child: Text(context.l10n.socialSubmitTestScan),
                ),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: Text(context.l10n.socialScanFixtures),
                  initiallyExpanded: true,
                  children: [
                    ListTile(
                      key: const ValueKey('scan-fixture-self'),
                      leading: const Icon(Icons.badge_outlined),
                      title: Text(context.l10n.socialOwnBadge),
                      onTap:
                          widget.vm.busy ||
                              scanner.processing ||
                              widget.vm.badgeUid == null
                          ? null
                          : () {
                              final boundUid = widget.vm.badgeUid;
                              if (boundUid == null) return;
                              uid.text = boundUid;
                              submit(boundUid);
                            },
                    ),
                    for (var i = 0; i < widget.vm.demoPlayers.length; i++)
                      ListTile(
                        key: ValueKey('scan-fixture-player-${i + 1}'),
                        leading: PlanetOrb(
                          widget.vm.demoPlayers[i].planet,
                          size: 40,
                        ),
                        title: Text(
                          playerName(context, widget.vm.demoPlayers[i]),
                        ),
                        subtitle: Text(
                          widget.vm.demoPlayers[i].tags
                              .map((t) => '#${tagName(context, t)}')
                              .join(' '),
                        ),
                        onTap: widget.vm.busy || scanner.processing
                            ? null
                            : () {
                                uid.text = widget.vm.demoPlayers[i].id;
                                submit(uid.text);
                              },
                      ),
                    ExpansionTile(
                      title: Text(context.l10n.socialCheckpointFixtures),
                      children: [
                        for (var i = 1; i <= 42; i++)
                          ListTile(
                            key: ValueKey('scan-fixture-checkpoint-$i'),
                            leading: const Icon(Icons.location_on_outlined),
                            title: Text(context.l10n.socialCheckpointNumber(i)),
                            onTap: widget.vm.busy || scanner.processing
                                ? null
                                : () {
                                    uid.text = TestTagIds.checkpointUid(i);
                                    submit(uid.text);
                                  },
                          ),
                      ],
                    ),
                    for (var i = 0; i < widget.vm.booths.length; i++)
                      ListTile(
                        key: ValueKey('scan-fixture-booth-${i + 1}'),
                        leading: const Icon(Icons.storefront_outlined),
                        title: Text(boothName(context, widget.vm.booths[i])),
                        onTap: widget.vm.busy || scanner.processing
                            ? null
                            : () {
                                uid.text = TestTagIds.boothUid(i + 1);
                                submit(uid.text);
                              },
                      ),
                    for (final station in widget.vm.stations)
                      if (widget.vm.isOfflineDemo ||
                          _stationFixtures.containsKey(station.id))
                        ListTile(
                          key: ValueKey(
                            'scan-fixture-station-${_stationFixtures[station.id] ?? station.id}',
                          ),
                          leading: const Icon(Icons.inventory_2_outlined),
                          title: Text(stationName(context, station)),
                          subtitle: Text(
                            context.l10n.socialStationFixture(
                              station.packs,
                              station.open
                                  ? context.l10n.socialOpen
                                  : context.l10n.socialClosed,
                              station.remaining,
                            ),
                          ),
                          onTap: widget.vm.busy || scanner.processing
                              ? null
                              : () {
                                  if (widget.vm.isOfflineDemo) {
                                    submit(station.id);
                                  } else {
                                    submit(TestTagIds.stationUid(
                                      _stationFixtures[station.id]!,
                                    ));
                                  }
                                },
                        ),
                    ListTile(
                      key: const ValueKey('scan-fixture-unknown'),
                      leading: const Icon(Icons.help_outline),
                      title: Text(context.l10n.socialUnknownTag),
                      onTap: widget.vm.busy || scanner.processing
                          ? null
                          : () {
                              uid.text = TestTagIds.unknownUid;
                              submit(uid.text);
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        const SizedBox(height: 32),
      ],
    ),
  );
}

class PlayerView extends StatefulWidget {
  const PlayerView({super.key, required this.vm, required this.player});
  final GameViewModel vm;
  final PlayerCard player;
  @override
  State<PlayerView> createState() => _PlayerViewState();
}

class _PlayerViewState extends State<PlayerView> {
  DateTime? friendDeadline;
  @override
  Widget build(BuildContext context) => CosmicPage(
    title: widget.player.id == widget.vm.me.id
        ? context.l10n.socialMyCard
        : context.l10n.socialPlayer,
    vm: widget.vm,
    builder: (context) {
      final vm = widget.vm;
      final p = widget.player;
      final friend = vm.friends.any((f) => f.id == p.id);
      final own = p.id == vm.me.id;
      final remote = vm.canInteractWithRemotePlayer(p.id);
      final incoming = remote && vm.incomingFriends.any((f) => f.id == p.id);
      final remaining = vm.secondsUntil(friendDeadline);
      final pending = remote
          ? vm.friendRequestSent(p.id)
          : friendDeadline != null && remaining > 0 && !friend;
      final blocked =
          gameTextOrNull(context, vm.battleBlocked(p)) ??
          (!vm.hasScanned(p.id)
              ? context.l10n.socialScanPlayerFirst
              : vm.cooldown > 0
              ? context.l10n.socialCooldownSeconds(vm.cooldown)
              : null);
      final matches = vm.missions
          .where((m) => p.tags.contains(m.tag) && !m.friends.contains(p.id))
          .toList();
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PlayerIdentity(own ? vm.me : p),
          const SizedBox(height: 20),
          if (!own && matches.isNotEmpty)
            Section(
              context.l10n.socialMissionProgress,
              icon: Icons.auto_awesome_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final m in matches)
                    Text(
                      context.l10n.socialMissionStep(
                        tagName(context, m.tag),
                        m.progress,
                        (m.progress + 1).clamp(0, 3).toInt(),
                      ),
                    ),
                ],
              ),
            ),
          if (friend)
            ListTile(
              leading: const Icon(Icons.check_circle_outline),
              title: Text(context.l10n.socialAlreadyFriends),
            ),
          if (!own && !friend)
            Section(
              context.l10n.socialExchangeCards,
              icon: Icons.people_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (incoming)
                    _InviteActions(
                      onRespond: vm.busy
                          ? null
                          : (accept) => vm.respondFriend(p.id, accept),
                    )
                  else
                    ReasonButton(
                      key: const ValueKey('player-friend'),
                      label: context.l10n.socialAddFriend,
                      reason: pending
                          ? remote
                                ? context.l10n.socialFriendRequestPending
                                : context.l10n.socialWaitingReciprocal
                          : vm.phase != EventPhase.active
                          ? context.l10n.socialFriendActiveOnly
                          : !vm.hasScanned(p.id)
                          ? context.l10n.socialScanPlayerFirst
                          : null,
                      icon: Icons.person_add_alt_1,
                      onPressed: vm.busy
                          ? null
                          : () async {
                              await vm.requestFriend(p.id);
                              if (!remote && vm.error == null && mounted) {
                                setState(() {
                                  friendDeadline = vm.now.add(
                                    const Duration(seconds: 30),
                                  );
                                });
                              }
                            },
                    ),
                  if (!remote && pending) ...[
                    const SizedBox(height: 16),
                    Countdown(
                      seconds: remaining,
                      total: 30,
                      label: context.l10n.socialAskReciprocal,
                    ),
                    const SizedBox(height: 12),
                    if (widget.vm.testToolsEnabled)
                      OutlinedButton(
                        key: const ValueKey('player-reciprocal'),
                        onPressed: vm.busy ? null : () => vm.reciprocal(p.id),
                        child: Text(context.l10n.socialTestAcceptFriend),
                      ),
                  ],
                  if (!remote && friendDeadline != null && !pending && !friend)
                    Text(context.l10n.socialFriendExpired),
                ],
              ),
            ),
          if (!own)
            Section(
              context.l10n.socialBattle,
              icon: Icons.bolt_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ReasonButton(
                    key: const ValueKey('player-battle'),
                    label: context.l10n.socialInviteBattle,
                    icon: Icons.bolt,
                    reason: blocked,
                    onPressed: vm.busy
                        ? null
                        : () async {
                            await vm.inviteBattle(p.id);
                            final battle = vm.battle;
                            if (vm.error == null &&
                                battle != null &&
                                battle.opponent.id == p.id &&
                                !battle.finished &&
                                context.mounted) {
                              await openPage(
                                context,
                                BattleView(vm: vm, battleId: battle.id),
                              );
                            }
                          },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.socialBattleRules(
                      vm.parameters['battleCooldownSeconds']!,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

class BattleView extends StatefulWidget {
  const BattleView({super.key, required this.vm, required this.battleId});
  final GameViewModel vm;
  final String battleId;
  @override
  State<BattleView> createState() => _BattleViewState();
}

class _BattleViewState extends State<BattleView> {
  HandCard? selected;
  HandCard? wildAs;
  DateTime? confirmPeekUntil;
  int round = -1;
  DateTime? revealUntil;
  @override
  Widget build(BuildContext context) => CosmicPage(
    title: context.l10n.socialBattle,
    vm: widget.vm,
    builder: (context) {
      final vm = widget.vm;
      final current = vm.battle;
      final battleId = widget.battleId;
      BattleRecord? record;
      for (final r in vm.history) {
        if (r.battle.id == battleId) {
          record = r;
          break;
        }
      }
      final b = current?.id == battleId ? current : record?.battle;
      if (b == null) {
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.hourglass_disabled, size: 80),
            const SizedBox(height: 20),
            Text(
              context.l10n.socialInviteCancelled,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(context.l10n.socialInviteCancelledHint),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.back),
            ),
          ],
        );
      }
      if (round != b.rounds.length) {
        selected = null;
        wildAs = null;
        confirmPeekUntil = null;
        round = b.rounds.length;
        revealUntil = b.rounds.isEmpty
            ? null
            : vm.now.add(const Duration(seconds: 2));
      }
      final seconds = vm.secondsUntil(b.deadline);
      final live = current?.id == b.id ? vm.liveBattle : null;
      final remote = live != null;
      final incoming = live?.incoming == true;
      final played = live?.played == true;
      final canChoose = !vm.busy && !played && (!remote || seconds > 0);
      final page = ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PlayerIdentity(b.opponent, compact: true),
          const SizedBox(height: 20),
          if (!b.accepted)
            Section(
              incoming
                  ? context.l10n.socialInviteReceived
                  : context.l10n.socialInviteSent,
              icon: Icons.contactless,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Countdown(
                    seconds: seconds,
                    total: 30,
                    label: !remote
                        ? context.l10n.socialAskReciprocal
                        : incoming
                        ? context.l10n.socialBattleRespond
                        : context.l10n.socialWaitingBattleAcceptance,
                  ),
                  const SizedBox(height: 16),
                  if (!remote) ...[
                    Text(context.l10n.socialBattleAcceptanceHint),
                    const SizedBox(height: 16),
                  ],
                  if (!remote && vm.testToolsEnabled)
                    FilledButton(
                      key: const ValueKey('battle-reciprocal'),
                      onPressed: vm.busy
                          ? null
                          : () => vm.reciprocal(b.opponent.id),
                      child: Text(context.l10n.socialTestAcceptBattle),
                    ),
                  if (incoming)
                    _InviteActions(
                      onRespond: vm.busy || seconds == 0
                          ? null
                          : (accept) => vm.respondBattle(b.id, accept),
                    )
                  else
                    TextButton(
                      key: const ValueKey('battle-cancel'),
                      onPressed: vm.busy ? null : () => vm.cancelBattle(b),
                      child: Text(context.l10n.cancel),
                    ),
                ],
              ),
            )
          else if (b.finished) ...[
            Text(
              resultName(context, b.result),
              style: Theme.of(context).textTheme.displaySmall,
              textAlign: TextAlign.center,
            ),
            Text(
              '${b.wins} : ${b.losses}',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _arena(b),
            Section(
              context.l10n.socialBattleRewards,
              icon: Icons.emoji_events_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.socialBattleRewardSummary(
                      record?.points ?? 0,
                      record?.coins ?? 0,
                    ),
                  ),
                  Text(
                    record?.reward == null
                        ? context.l10n.socialNoCardDraw
                        : context.l10n.socialCardDraw(
                            handName(context, record!.reward!.index),
                          ),
                  ),
                  Text(context.l10n.socialCardsUsed(b.rounds.length)),
                  Text(context.l10n.socialBattleFriendAdded),
                  const SizedBox(height: 16),
                  Countdown(
                    seconds: vm.cooldown,
                    total: vm.parameters['battleCooldownSeconds']!,
                    label: context.l10n.socialBattleCooldown,
                  ),
                ],
              ),
            ),
          ] else if (live?.waitingReady == true) ...[
            _arena(b),
            FilledButton(
              key: const ValueKey('battle-ready'),
              onPressed: vm.busy || live!.ready ? null : () => vm.readyBattle(b),
              child: Text(context.l10n.socialReady),
            ),
            if (live!.ready) Text(context.l10n.socialWaitingForReady),
            if (b.rounds.isEmpty)
              TextButton(
                onPressed: vm.busy ? null : () => vm.cancelBattle(b),
                child: Text(context.l10n.cancel),
              ),
          ] else ...[
            Text(
              context.l10n.socialRoundScore(
                b.rounds.length + 1,
                b.wins,
                b.losses,
              ),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 12),
            Countdown(
              seconds: seconds,
              total: 10,
              label: played
                  ? context.l10n.socialWaitingOpponentCard
                  : context.l10n.socialChooseCard,
            ),
            const SizedBox(height: 12),
            if (!played) Text(context.l10n.socialAutoPlayHint),
            const SizedBox(height: 20),
            _arena(b),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < 4; i++)
                  ChoiceChip(
                    key: ValueKey('battle-card-$i'),
                    avatar: Icon(handIcon(i), size: 20),
                    label: Text('${handName(context, i)} ×${vm.hand[i]}'),
                    selected: selected?.index == i,
                    onSelected: vm.hand[i] > 0 && canChoose
                        ? (_) => setState(() {
                            selected = HandCard.values[i];
                            wildAs = null;
                          })
                        : null,
                  ),
              ],
            ),
            if (selected == HandCard.wild) ...[
              const SizedBox(height: 16),
              Text(context.l10n.socialWildHint),
              Wrap(
                spacing: 8,
                children: [
                  for (var i = 0; i < 3; i++)
                    ChoiceChip(
                      key: ValueKey('battle-wild-$i'),
                      label: Text(handName(context, i)),
                      selected: wildAs?.index == i,
                      onSelected: canChoose
                          ? (_) => setState(() => wildAs = HandCard.values[i])
                          : null,
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('battle-submit'),
              onPressed:
                  selected != null &&
                      (selected != HandCard.wild || wildAs != null) &&
                      canChoose
                  ? () => vm.play(b, selected!, wildAs)
                  : null,
              icon: const Icon(Icons.send_rounded),
              label: Text(context.l10n.confirm),
            ),
            if (vm.peekCards > 0 || b.peekUsed) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const ValueKey('battle-peek'),
                onPressed: b.peekUsed || !canChoose
                    ? null
                    : () async {
                        if (vm.secondsUntil(confirmPeekUntil) > 0) {
                          await vm.peek(b);
                          if (vm.error == null && mounted) {
                            setState(() {
                              confirmPeekUntil = null;
                            });
                          }
                        } else {
                          setState(
                            () => confirmPeekUntil = vm.now.add(
                              const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.visibility_outlined),
                label: Text(
                  b.peekUsed
                      ? context.l10n.socialPeekUsed
                      : vm.secondsUntil(confirmPeekUntil) > 0
                      ? context.l10n.socialPeekConfirm(
                          vm.secondsUntil(confirmPeekUntil),
                        )
                      : context.l10n.socialPeekAction(vm.peekCards),
                ),
              ),
            ],
            if (b.peekUsed)
              Section(
                context.l10n.socialPeekResult,
                icon: Icons.visibility,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!remote) Text(context.l10n.socialPeekHint),
                    for (var i = 0; i < 4; i++)
                      Text('${handName(context, i)} ×${b.opponentHand[i]}'),
                  ],
                ),
              ),
          ],
          if (b.rounds.isNotEmpty) ...[
            const SizedBox(height: 20),
            Section(
              context.l10n.socialRoundHistory,
              child: Column(
                children: [
                  for (var i = 0; i < b.rounds.length; i++)
                    ListTile(
                      leading: CircleAvatar(child: Text('${i + 1}')),
                      title: Text(
                        context.l10n.socialCardVersus(
                          b.rounds[i].wild
                              ? context.l10n.socialWildMove(
                                  handName(context, b.rounds[i].mine.index),
                                )
                              : handName(context, b.rounds[i].mine.index),
                          handName(context, b.rounds[i].opponent.index),
                        ),
                      ),
                      subtitle: Text(
                        b.rounds[i].automatic
                            ? context.l10n.socialAutomaticResult(
                                resultName(context, b.rounds[i].outcome),
                              )
                            : resultName(context, b.rounds[i].outcome),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          PlayerIdentity(vm.me, compact: true),
          if (b.finished) ...[
            const SizedBox(height: 20),
            FilledButton(
              key: const ValueKey('battle-done'),
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.done),
            ),
          ],
          const SizedBox(height: 32),
        ],
      );
      return b.finished
          ? PopScope<Object?>(
              onPopInvokedWithResult: (didPop, _) {
                if (didPop) vm.markLiveBattleResultSeen(b.id);
              },
              child: page,
            )
          : page;
    },
  );
  Widget _arena(Battle battle) {
    final latest = battle.rounds.isEmpty ? null : battle.rounds.last;
    final showing =
        latest != null &&
        (battle.finished || widget.vm.secondsUntil(revealUntil) > 0);
    final duration = Duration(
      milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 200,
    );
    return Section(
      showing
          ? context.l10n.socialRoundReveal(battle.rounds.length)
          : context.l10n.socialArena,
      icon: Icons.style_outlined,
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: duration,
            child: Row(
              key: ValueKey('arena-${battle.rounds.length}-$showing'),
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(context.l10n.socialMyMove),
                      const SizedBox(height: 8),
                      RevealCard(
                        key: const ValueKey('battle-mine-face'),
                        revealed: showing,
                        label: latest == null
                            ? context.l10n.socialWaitingMove
                            : latest.wild
                            ? context.l10n.socialWildMove(
                                handName(context, latest.mine.index),
                              )
                            : handName(context, latest.mine.index),
                        icon: latest == null
                            ? Icons.help_outline
                            : handIcon(latest.mine.index),
                        special: showing && latest.wild,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      Text(context.l10n.socialOpponentMove),
                      const SizedBox(height: 8),
                      RevealCard(
                        key: const ValueKey('battle-opponent-face'),
                        revealed: showing,
                        label: latest == null
                            ? context.l10n.socialWaitingMove
                            : handName(context, latest.opponent.index),
                        icon: latest == null
                            ? Icons.help_outline
                            : handIcon(latest.opponent.index),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            showing
                ? latest.automatic
                      ? context.l10n.socialAutomaticResult(
                          resultName(context, latest.outcome),
                        )
                      : resultName(context, latest.outcome)
                : context.l10n.socialRevealHint,
          ),
        ],
      ),
    );
  }
}

class _InviteActions extends StatelessWidget {
  const _InviteActions({required this.onRespond});
  final ValueChanged<bool>? onRespond;

  @override
  Widget build(BuildContext context) => OverflowBar(
    spacing: 8,
    overflowSpacing: 8,
    children: [
      FilledButton(
        onPressed: onRespond == null ? null : () => onRespond!(true),
        child: Text(context.l10n.socialAccept),
      ),
      OutlinedButton(
        onPressed: onRespond == null ? null : () => onRespond!(false),
        child: Text(context.l10n.socialDecline),
      ),
    ],
  );
}

class FriendsView extends StatefulWidget {
  const FriendsView({super.key, required this.vm});
  final GameViewModel vm;
  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView> {
  String? filter;
  String query = '';
  @override
  Widget build(BuildContext context) => CosmicPage(
    title: context.l10n.socialFriendCount(widget.vm.friends.length),
    vm: widget.vm,
    builder: (context) {
      final vm = widget.vm;
      final incoming = vm.incomingFriends;
      final allTags = widget.vm.friends.expand((f) => f.tags).toSet().toList()
        ..sort();
      final people = widget.vm.friends
          .where(
            (p) =>
                (filter == null || p.tags.contains(filter)) &&
                (query.isEmpty ||
                    playerName(
                      context,
                      p,
                    ).toLowerCase().contains(query.toLowerCase())),
          )
          .toList();
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (incoming.isNotEmpty) ...[
            Section(
              context.l10n.socialFriendRequests,
              icon: Icons.person_add_alt_1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final p in incoming) ...[
                    PlayerIdentity(p, compact: true),
                    _InviteActions(
                      onRespond: vm.busy
                          ? null
                          : (accept) => vm.respondFriend(p.id, accept),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          TextField(
            decoration: InputDecoration(
              labelText: context.l10n.socialSearchNickname,
              prefixIcon: const Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => query = value),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text(context.l10n.socialAll),
                selected: filter == null,
                onSelected: (_) => setState(() => filter = null),
              ),
              for (final tag in allTags)
                FilterChip(
                  label: Text('#${tagName(context, tag)}'),
                  selected: filter == tag,
                  onSelected: (value) =>
                      setState(() => filter = value ? tag : null),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(context.l10n.socialFriendCount(people.length)),
          if (people.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Text(context.l10n.socialNoMatchingFriends),
            ),
          for (final p in people)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: InkWell(
                onTap: () =>
                    openPage(context, PlayerView(vm: widget.vm, player: p)),
                borderRadius: BorderRadius.circular(28),
                child: PlayerIdentity(p, compact: true),
              ),
            ),
        ],
      );
    },
  );
}

class RankingView extends StatefulWidget {
  const RankingView({super.key, required this.vm});
  final GameViewModel vm;
  @override
  State<RankingView> createState() => _RankingViewState();
}

class _RankingViewState extends State<RankingView> {
  int tab = 0;
  @override
  Widget build(BuildContext context) {
    final metric = ['points', 'friends', 'planets'][tab];
    return CosmicPage(
      title: context.l10n.socialRanking,
      vm: widget.vm,
      builder: (context) {
        final entries = widget.vm.ranking(metric);
        final ownIndex = entries.indexWhere(
          (r) => r.player.id == widget.vm.me.id,
        );
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var i = 0; i < 3; i++)
                    ChoiceChip(
                      label: Text(
                        [
                          context.l10n.points,
                          context.l10n.friends,
                          context.l10n.planets,
                        ][i],
                      ),
                      selected: i == tab,
                      onSelected: (_) => setState(() => tab = i),
                    ),
                ],
              ),
            ),
            if (widget.vm.phase == EventPhase.ended)
              Text(context.l10n.socialRankingFinal),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (var i = 0; i < entries.length; i++)
                    Card.filled(
                      child: ListTile(
                        contentPadding: EdgeInsets.all(i < 3 ? 20 : 12),
                        leading: Text(
                          i < 3 ? ['🥇', '🥈', '🥉'][i] : '${i + 1}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        title: Row(
                          children: [
                            PlanetOrb(
                              entries[i].player.planet,
                              size: i < 3 ? 64 : 40,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                playerName(context, entries[i].player),
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${entries[i].value}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        onTap: () => openPage(
                          context,
                          PlayerView(vm: widget.vm, player: entries[i].player),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Material(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: SafeArea(
                top: false,
                child: ListTile(
                  leading: const Icon(Icons.person_pin_circle),
                  title: Text(
                    ownIndex < 0
                        ? context.l10n.socialNotRanked
                        : context.l10n.socialMyRank(ownIndex + 1),
                  ),
                  trailing: Text(
                    '${ownIndex < 0 ? 0 : entries[ownIndex].value}',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class StationBindingView extends StatefulWidget {
  const StationBindingView({super.key, required this.vm, required this.uid});
  final GameViewModel vm;
  final String uid;
  @override
  State<StationBindingView> createState() => _StationBindingViewState();
}

class _StationBindingViewState extends State<StationBindingView> {
  String? selected;
  @override
  Widget build(BuildContext context) => CosmicPage(
    title: context.l10n.socialBindStation,
    vm: widget.vm,
    builder: (context) => ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          context.l10n.socialUnknownTag,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        SelectableText(widget.uid),
        const SizedBox(height: 16),
        for (final station in widget.vm.stations)
          Card.outlined(
            child: ListTile(
              key: ValueKey('station-option-${station.id}'),
              selected: selected == station.id,
              leading: Icon(
                selected == station.id
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
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
              onTap: () => setState(() => selected = station.id),
            ),
          ),
        const SizedBox(height: 16),
        ReasonButton(
          key: const ValueKey('station-bind'),
          label: context.l10n.socialConfirmBinding,
          reason:
              widget.vm.role != AccountRole.staff ||
                  widget.vm.scannerMode != ScannerMode.staff
              ? context.l10n.socialBindingUnauthorized
              : selected == null
              ? context.l10n.socialChooseStation
              : null,
          onPressed: widget.vm.busy
              ? null
              : () async {
                  final bound = await widget.vm.bindStation(
                    widget.uid,
                    selected!,
                  );
                  if (bound && context.mounted) {
                    await messageDialog(
                      context,
                      context.l10n.socialBindingComplete,
                      context.l10n.socialBindingCompleteHint,
                    );
                    if (context.mounted) Navigator.pop(context, true);
                  }
                },
        ),
      ],
    ),
  );
}
