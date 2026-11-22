import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sitcon_backend/game/game_service.dart';
import 'package:sitcon_app/l10n/localization.dart';
import 'package:sitcon_app/services/game/demo_controls.dart';
import 'package:sitcon_app/services/game/multiplayer.dart';
import 'package:sitcon_app/services/nfc/automatic_scan_controller.dart';
import 'package:sitcon_backend/game/game_engine.dart';
import 'package:sitcon_backend/game/game_wire.dart';
import 'package:sitcon_app/services/nfc/ntag_reader.dart';
import 'package:sitcon_app/services/nfc/scan_route_observer.dart';
import 'package:sitcon_app/views/home_view.dart';
import 'package:sitcon_app/views/social_view.dart';
import 'package:sitcon_app/views/operator_widgets.dart';
import 'package:sitcon_app/viewmodels/game_view_model.dart';
import 'package:sitcon_app/widgets/cosmic_widgets.dart';

import '../integration_test/flow_support.dart' as flow;

class _Read {
  _Read(this.onReady);
  final VoidCallback? onReady;
  final result = Completer<String?>();
  bool active = true;
}

/// Cancel intentionally does not settle discovery: native channels can deliver
/// callbacks after cancellation, including after a newer session has started.
class _Reader implements NtagReader {
  final reads = <_Read>[];
  int cancellations = 0;
  bool disposed = false;
  Completer<void>? cancelGate;

  @override
  Future<String?> readUid({VoidCallback? onReady}) {
    final read = _Read(onReady);
    reads.add(read);
    onReady?.call();
    return read.result.future;
  }

  void deliver(int index, String? value) {
    reads[index].active = false;
    reads[index].result.complete(value);
  }

  void fail(int index, Object error) {
    reads[index].active = false;
    reads[index].result.completeError(error);
  }

  @override
  Future<void> cancel() async {
    cancellations++;
    for (final read in reads) {
      read.active = false;
    }
    await cancelGate?.future;
  }

  @override
  Future<void> dispose() async {
    disposed = true;
    await cancel();
    for (final read in reads) {
      if (!read.result.isCompleted) read.result.complete(null);
    }
  }
}

class _Storage implements GameStorage {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String value) async {
    this.value = value;
  }
}

class _Game extends GameEngine {
  _Game({super.clock}) : super(storage: _Storage());
  Completer<void>? scanGate;
  int scanCalls = 0;
  ScanResult? remoteResult;
  final modes = <ScannerMode>[];

  @override
  Future<ScanResult> scan(
    String uid,
    String key, {
    ScannerMode mode = ScannerMode.user,
  }) async {
    modes.add(mode);
    scanCalls++;
    await scanGate?.future;
    if (remoteResult case final result?) return result;
    return super.scan(uid, key, mode: mode);
  }
}

class _RemoteStationGame extends _Game implements RemoteStationFixtures {
  @override
  Map<String, String>? stationFixtureUids;

  void publishStationFixtures(Map<String, String>? uids) {
    stationFixtureUids = uids;
    notifyListeners();
  }
}

class _LiveGame extends _Game implements Multiplayer {
  _LiveGame() : super(clock: () => DateTime.utc(2026, 3, 28));

  static const peer = PlayerCard(
    id: 'p-remote',
    name: 'Remote attendee',
    tags: ['AI'],
  );

  @override
  MultiplayerState? multiplayer;
  @override
  Battle? battle;
  @override
  List<BattleRecord> history = [];
  (String, bool)? friendResponse;
  (String, bool)? battleResponse;
  (String, int)? readyResponse;

  void publish({
    List<PlayerCard> incoming = const [],
    List<String> outgoing = const [],
    List<String> scanned = const [],
    Battle? battle,
    bool incomingBattle = true,
    bool played = false,
    bool waitingReady = false,
    bool ready = false,
  }) {
    this.battle = battle;
    if (battle != null &&
        battle.finished &&
        !history.any((r) => r.battle.id == battle.id)) {
      history = [BattleRecord(battle, now, 3, 5, null), ...history];
    }
    multiplayer = MultiplayerState.fromJson({
      'incomingFriends': [for (final player in incoming) playerToWire(player)],
      'outgoingFriends': outgoing,
      'scanned': scanned,
      'battle': battle != null && !battle.finished
          ? {'id': battle.id, 'incoming': incomingBattle, 'played': played,
             'waitingReady': waitingReady, 'ready': ready}
          : null,
    });
    notifyListeners();
  }

  @override
  Future<void> requestFriend(String id) async {
    publish(outgoing: [id], scanned: [id]);
  }

  @override
  Future<void> respondFriend(String id, bool accept) async {
    friendResponse = (id, accept);
    publish(battle: battle);
  }

  @override
  Future<void> inviteBattle(String id) async {
    publish(
      outgoing: [id],
      scanned: [id],
      incomingBattle: false,
      battle: Battle(
        id: 'live-outgoing',
        opponent: peer,
        deadline: now.add(const Duration(seconds: 30)),
      ),
    );
  }

  @override
  Future<void> respondBattle(String id, bool accept) async {
    battleResponse = (id, accept);
    publish(
      waitingReady: accept,
      battle: accept
          ? Battle(
              id: id,
              opponent: peer,
              deadline: now.add(const Duration(seconds: 10)),
              accepted: true,
            )
          : history.firstOrNull?.battle,
    );
  }

  @override
  Future<void> readyBattle(String id, int round) async {
    readyResponse = (id, round);
    publish(battle: battle, waitingReady: true, ready: true);
  }

  @override
  Future<void> playCard(HandCard card, {HandCard? asCard}) async {
    publish(battle: battle, played: true);
  }
}

// Capability injection only: scan results still use the real game engine.
class _FixtureVm extends GameViewModel {
  _FixtureVm(super.service);
  @override
  bool get testToolsEnabled => true;
  @override
  bool get isOfflineDemo => stationFixtureUids == null;
}

class _DisposalScope extends StatefulWidget {
  const _DisposalScope({required this.onDispose, required this.child});
  final VoidCallback onDispose;
  final Widget child;
  @override
  State<_DisposalScope> createState() => _DisposalScopeState();
}

class _DisposalScopeState extends State<_DisposalScope> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

Future<(_Game, GameViewModel, GlobalKey<NavigatorState>)> _launch(
  WidgetTester tester,
  _Reader reader, {
  bool fixtures = false,
  AccountRole role = AccountRole.user,
  bool checkedIn = true,
  String badgeUid = GameEngine.selfUid,
  _Game? service,
  bool startInScanner = true,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(430, 1000);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  final game = service ?? _Game();
  await game.initialize();
  await game.setMockPhase(EventPhase.active);
  if (checkedIn) {
    await game.bindBadge(badgeUid);
    await game.saveProfile(['AI', 'Vim派', '夜貓族'], '');
    await game.finishTutorial();
  }
  await game.configureRole(
    role,
    boothId: role == AccountRole.booth ? game.booths.first.id : null,
  );
  final vm = fixtures ? _FixtureVm(game) : GameViewModel(game);
  final navigator = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    _DisposalScope(
      onDispose: vm.dispose,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorKey: navigator,
        navigatorObservers: [scanRouteObserver],
        home: startInScanner
            ? const Scaffold(body: Text('Launcher'))
            : HomeView(vm: vm),
      ),
    ),
  );
  if (startInScanner) {
    unawaited(
      navigator.currentState!.push<void>(
        MaterialPageRoute(
          builder: (_) => ScanView(vm: vm, reader: reader),
        ),
      ),
    );
  }
  await tester.pumpAndSettle();
  addTearDown(() async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    game.dispose();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });
  return (game, vm, navigator);
}

Future<AutomaticScanController> _controller(
  WidgetTester tester,
  _Reader reader,
  Future<void> Function(String) onUid,
) async {
  final controller = AutomaticScanController(reader: reader, onUid: onUid);
  await tester.pumpWidget(
    _DisposalScope(
      onDispose: controller.dispose,
      child: const SizedBox.shrink(),
    ),
  );
  controller.setResumed(true);
  controller.setRouteVisible(true);
  return controller;
}

void main() {
  testWidgets('fixture cancellation cannot submit after the page is covered', (
    tester,
  ) async {
    final reader = _Reader();
    final handled = <String>[];
    final controller = await _controller(
      tester,
      reader,
      (uid) async => handled.add(uid),
    );
    final gate = reader.cancelGate = Completer<void>();
    final fixture = controller.submitFixture('fixture');
    controller.setRouteVisible(false);
    gate.complete();
    await fixture;
    expect(handled, isEmpty);
    controller.setRouteVisible(true);
    await tester.pump();
    expect(reader.reads, hasLength(2));
  });

  testWidgets('automatically arms and serializes handling until it finishes', (
    tester,
  ) async {
    final reader = _Reader();
    final handled = <String>[];
    final result = Completer<void>();
    final controller = await _controller(tester, reader, (uid) async {
      handled.add(uid);
      await result.future;
    });
    expect(reader.reads, hasLength(1));
    expect(controller.status, AutomaticScanStatus.waiting);
    reader.deliver(0, GameEngine.checkpointUid(1));
    await tester.pump();
    expect(controller.status, AutomaticScanStatus.processing);
    await controller.submitFixture(GameEngine.checkpointUid(2));
    await tester.pump(const Duration(seconds: 2));
    expect(reader.reads, hasLength(1));
    expect(handled, hasLength(1));
    result.complete();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(reader.reads, hasLength(2));
  });

  testWidgets('cancellation barrier prevents start/cancel overlap on resume', (
    tester,
  ) async {
    final reader = _Reader();
    final handled = <String>[];
    final controller = await _controller(
      tester,
      reader,
      (uid) async => handled.add(uid),
    );
    final gate = reader.cancelGate = Completer<void>();
    controller.setResumed(false);
    controller.setResumed(true);
    await tester.pump();
    expect(reader.reads, hasLength(1));
    reader.reads[0].onReady?.call();
    reader.deliver(0, GameEngine.checkpointUid(1));
    await tester.pump();
    expect(handled, isEmpty);
    gate.complete();
    await tester.pump();
    expect(reader.reads, hasLength(2));
    expect(controller.status, AutomaticScanStatus.waiting);
    reader.deliver(1, GameEngine.checkpointUid(2));
    await tester.pump();
    expect(handled, [GameEngine.checkpointUid(2)]);
  });

  testWidgets(
    'held UID is suppressed until a different tag, not just a delay',
    (tester) async {
      final reader = _Reader();
      final handled = <String>[];
      await _controller(tester, reader, (uid) async => handled.add(uid));
      final a = GameEngine.checkpointUid(1);
      final b = GameEngine.checkpointUid(2);
      for (var index = 0; index < 3; index++) {
        reader.deliver(index, a);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
      }
      expect(handled, [a]);
      reader.deliver(3, b);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      reader.deliver(4, a);
      await tester.pump();
      expect(handled, [a, b, a]);
    },
  );

  testWidgets('iOS cancellation does not reopen without explicit retry', (
    tester,
  ) async {
    final reader = _Reader();
    final controller = await _controller(tester, reader, (_) async {});
    reader.deliver(0, null);
    await tester.pump();
    expect(controller.status, AutomaticScanStatus.cancelled);
    controller.setRouteVisible(false);
    controller.setResumed(false);
    controller.setRouteVisible(true);
    controller.setResumed(true);
    await tester.pump(const Duration(seconds: 31));
    expect(reader.reads, hasLength(1));
    controller.retry();
    expect(reader.reads, hasLength(2));
    expect(controller.status, AutomaticScanStatus.waiting);
  });

  testWidgets('fixtures remain usable after hardware failure and serialize', (
    tester,
  ) async {
    final reader = _Reader();
    final handled = <String>[];
    final gate = Completer<void>();
    final controller = await _controller(tester, reader, (uid) async {
      handled.add(uid);
      await gate.future;
    });
    reader.fail(0, StateError('NFC disabled'));
    await tester.pump();
    expect(controller.status, AutomaticScanStatus.error);
    final fixture = controller.submitFixture('fixture');
    await controller.submitFixture('second');
    expect(handled, ['fixture']);
    gate.complete();
    await fixture;
    expect(controller.status, AutomaticScanStatus.error);
    controller.retry();
    expect(reader.reads, hasLength(2));
  });

  testWidgets('dispose invalidates pending discovery and readiness callbacks', (
    tester,
  ) async {
    final reader = _Reader();
    final handled = <String>[];
    final controller = await _controller(
      tester,
      reader,
      (uid) async => handled.add(uid),
    );
    final gate = reader.cancelGate = Completer<void>();
    controller.dispose();
    reader.reads[0].onReady?.call();
    reader.deliver(0, GameEngine.checkpointUid(1));
    gate.complete();
    await tester.pump();
    expect(reader.disposed, isTrue);
    expect(handled, isEmpty);
    expect(reader.reads, hasLength(1));
  });

  testWidgets(
    'real scanner route pauses for dialogs, results, pages and back',
    (tester) async {
      final reader = _Reader();
      final (game, _, navigator) = await _launch(tester, reader);
      expect(reader.reads, hasLength(1));
      expect(find.byKey(const ValueKey('scan-state-waiting')), findsOneWidget);
      expect(find.byKey(const ValueKey('scan-native')), findsNothing);

      unawaited(
        showDialog<void>(
          context: tester.element(find.byType(ScanView)),
          builder: (context) => AlertDialog(
            title: const Text('Overlay'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close overlay'),
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(reader.cancellations, 1);
      reader.deliver(0, GameEngine.checkpointUid(1));
      await tester.pump();
      expect(game.scanCalls, 0);
      await tester.tap(find.text('Close overlay'));
      await tester.pumpAndSettle();
      expect(reader.reads, hasLength(2));

      reader.deliver(1, GameEngine.checkpointUid(1));
      await tester.pumpAndSettle();
      expect(game.scanCalls, 1);
      expect(find.byKey(const ValueKey('scan-result-dismiss')), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(reader.reads, hasLength(2));
      await tester.tap(find.byKey(const ValueKey('scan-result-dismiss')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      expect(reader.reads, hasLength(3));
      reader.deliver(2, GameEngine.checkpointUid(1));
      await tester.pump();
      expect(find.byKey(const ValueKey('scan-result-dismiss')), findsNothing);
      expect(game.scanCalls, 1);
      await tester.pump(const Duration(milliseconds: 400));

      unawaited(
        navigator.currentState!.push<void>(
          MaterialPageRoute(
            builder: (_) => const Scaffold(body: Text('Covered page')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final previousReads = reader.reads.length;
      reader.deliver(previousReads - 1, GameEngine.checkpointUid(2));
      await tester.pump();
      expect(game.scanCalls, 1);
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      expect(reader.reads, hasLength(previousReads + 1));
      navigator.currentState!.pop();
      await tester.pumpAndSettle();
      expect(reader.disposed, isTrue);
      expect(find.text('Launcher'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(reader.reads, hasLength(previousReads + 1));
    },
  );

  testWidgets('an in-flight result never opens over a covering route', (
    tester,
  ) async {
    final reader = _Reader();
    final (game, _, navigator) = await _launch(tester, reader);
    game.scanGate = Completer<void>();
    reader.deliver(0, GameEngine.checkpointUid(1));
    await tester.pump();
    expect(game.scanCalls, 1);
    unawaited(
      navigator.currentState!.push<void>(
        MaterialPageRoute(
          builder: (_) => const Scaffold(body: Text('Covered page')),
        ),
      ),
    );
    await tester.pump();
    game.scanGate!.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('scan-result-dismiss')), findsNothing);
    expect(reader.reads, hasLength(1));
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    expect(reader.reads, hasLength(2));
    expect(find.byKey(const ValueKey('scan-result-dismiss')), findsNothing);
  });

  testWidgets('background stops hardware and suppresses in-flight result UI', (
    tester,
  ) async {
    final reader = _Reader();
    final (game, _, _) = await _launch(tester, reader);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(reader.cancellations, 1);
    reader.deliver(0, GameEngine.checkpointUid(1));
    await tester.pump();
    expect(game.scanCalls, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(reader.reads, hasLength(2));

    game.scanGate = Completer<void>();
    reader.deliver(1, GameEngine.checkpointUid(2));
    await tester.pump();
    expect(game.scanCalls, 1);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    game.scanGate!.complete();
    await tester.pump();
    expect(find.byKey(const ValueKey('scan-result-dismiss')), findsNothing);
    expect(reader.reads, hasLength(2));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(reader.reads, hasLength(3));
  });

  testWidgets(
    'simulated own badge submits the bound UID, not the fixture UID',
    (tester) async {
      const actualUid = '04A20000000001';
      final (game, _, _) = await _launch(
        tester,
        _Reader(),
        fixtures: true,
        badgeUid: actualUid,
      );
      final input = tester
          .widget<TextField>(find.byKey(const ValueKey('scan-uid')))
          .controller!;
      await flow.tapKey(tester, 'scan-fixture-self');
      expect(input.text, actualUid);
      expect(game.scanCalls, 1);
      expect(game.ledger.any((entry) => entry.reason == 'scan.self'), isTrue);
    },
  );

  testWidgets('server enables the open scanner list without a client flag', (
    tester,
  ) async {
    final game = _RemoteStationGame();
    await game.initialize();
    for (final id in ['station-remote', 'station-unbound']) {
      await game.configureStation(
        Station(id: id, name: id, packs: 2, remaining: 5),
      );
    }
    await game.configureRole(AccountRole.staff);
    await game.bindStation('04A70000000042', 'station-remote');
    await _launch(tester, _Reader(), service: game);
    final input = find.byKey(const ValueKey('scan-uid'));
    expect(input, findsNothing);
    game.publishStationFixtures(const {'station-remote': '04A70000000042'});
    await tester.pumpAndSettle();
    expect(input, findsOneWidget);
    game.publishStationFixtures(null);
    await tester.pumpAndSettle();
    expect(input, findsNothing);
    game.publishStationFixtures(const {'station-remote': '04A70000000042'});
    await tester.pumpAndSettle();
    final unbound = find.byKey(
      const ValueKey('scan-fixture-station-station-unbound'),
    );
    expect(tester.widget<ListTile>(unbound).onTap, isNull);
    final before = game.packs;
    await flow.tapKey(tester, 'scan-fixture-station-station-remote');
    expect(game.packs, before + 2);
  });

  testWidgets('a remote attendee scan opens a read-only card', (tester) async {
    final reader = _Reader();
    final (game, _, _) = await _launch(tester, reader);
    const uid = '04A20000000002';
    game.remoteResult = const ScanResult(
      'attendee',
      GameMessage('scan.player'),
      uid: uid,
      player: PlayerCard(id: 'p-remote', name: 'Remote attendee', tags: ['AI']),
    );
    reader.deliver(0, uid);
    await tester.pumpAndSettle();
    expect(find.text('Remote attendee'), findsWidgets);
    expect(find.byKey(const ValueKey('player-friend')), findsNothing);
  });

  testWidgets('a capable attendee scan offers real friend and battle actions', (
    tester,
  ) async {
    final reader = _Reader();
    final game = _LiveGame()..publish(scanned: [_LiveGame.peer.id]);
    await _launch(tester, reader, service: game, fixtures: true);
    const uid = '04A20000000002';
    game.remoteResult = const ScanResult(
      'attendee',
      GameMessage('scan.player'),
      uid: uid,
      player: _LiveGame.peer,
    );
    reader.deliver(0, uid);
    await tester.pumpAndSettle();

    Finder button(String key) => find.descendant(
      of: find.byKey(ValueKey(key)),
      matching: find.byType(ExpressiveButton),
    );
    await flow.findControl(tester, 'player-battle');
    expect(
      tester.widget<ExpressiveButton>(button('player-battle')).onPressed,
      isNotNull,
    );
    await flow.tapKey(tester, 'player-friend');
    await tester.pumpAndSettle();
    expect(find.text('Waiting for them to accept'), findsOneWidget);
    expect(
      tester.widget<ExpressiveButton>(button('player-friend')).onPressed,
      isNull,
    );
    expect(find.byKey(const ValueKey('player-reciprocal')), findsNothing);
    await flow.tapKey(tester, 'player-battle');
    await tester.pumpAndSettle();
    expect(find.byType(BattleView), findsOneWidget);
    expect(find.textContaining('Waiting for opponent to accept'), findsOneWidget);
    expect(find.byKey(const ValueKey('battle-reciprocal')), findsNothing);
  });

  testWidgets('home inboxes respond, lock battle moves, and show results', (
    tester,
  ) async {
    final game = _LiveGame();
    const id = 'live-invite';
    Battle invite() => Battle(
      id: id,
      opponent: _LiveGame.peer,
      deadline: game.now.add(const Duration(seconds: 30)),
    );
    final (_, _, nav) = await _launch(
      tester,
      _Reader(),
      service: game,
      startInScanner: false,
      fixtures: true,
    );
    game.publish(incoming: [_LiveGame.peer], battle: invite());
    await tester.pumpAndSettle();
    await flow.tapKey(tester, 'friend-requests-open');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Accept'));
    await tester.pumpAndSettle();
    expect(game.friendResponse, (_LiveGame.peer.id, true));
    nav.currentState!.pop();
    await tester.pumpAndSettle();

    expect(find.text('Battle invitation'), findsOneWidget);
    await flow.tapKey(tester, 'battle-resume');
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('battle-reciprocal')), findsNothing);
    await tester.tap(find.widgetWithText(FilledButton, 'Accept'));
    await tester.pumpAndSettle();
    expect(game.battleResponse, (id, true));
    expect(find.byKey(const ValueKey('battle-submit')), findsNothing);
    await flow.tapKey(tester, 'battle-ready');
    expect(game.readyResponse, (id, 0));
    expect(find.text('Waiting for opponent to be ready'), findsOneWidget);
    expect(find.byKey(const ValueKey('battle-submit')), findsNothing);
    game.publish(battle: game.battle, ready: true);
    await tester.pumpAndSettle();
    await flow.tapKey(tester, 'battle-card-0');
    await flow.tapKey(tester, 'battle-submit');
    await tester.pumpAndSettle();
    expect(find.textContaining("Waiting for opponent's card"), findsOneWidget);
    final scissors = find.byKey(const ValueKey('battle-card-0'));
    expect(tester.widget<ChoiceChip>(scissors).onSelected, isNull);
    final submit = find.byKey(const ValueKey('battle-submit'));
    expect(tester.widget<FilledButton>(submit).onPressed, isNull);

    nav.currentState!.pop();
    await tester.pumpAndSettle();
    final result = Battle(
      id: id,
      opponent: _LiveGame.peer,
      deadline: game.now,
      accepted: true,
      finished: true,
      rounds: const [
        RoundResult(HandCard.scissors, HandCard.paper, 1),
        RoundResult(HandCard.scissors, HandCard.paper, 1),
      ],
    );
    game.publish(battle: result);
    await tester.pumpAndSettle();
    expect(find.text('Battle result'), findsOneWidget);
    await flow.tapKey(tester, 'battle-resume');
    await tester.pumpAndSettle();
    expect(find.text('2 : 0'), findsOneWidget);
    nav.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('battle-resume')), findsNothing);

    game.publish(
      battle: Battle(
        id: 'live-second-invite',
        opponent: _LiveGame.peer,
        deadline: game.now.add(const Duration(seconds: 30)),
      ),
    );
    await tester.pumpAndSettle();
    await flow.tapKey(tester, 'battle-resume');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Decline'));
    await tester.pumpAndSettle();
    expect(game.battleResponse, ('live-second-invite', false));
    expect(find.text('Invitation cancelled'), findsOneWidget);
    expect(find.text('2 : 0'), findsNothing);
  });

  testWidgets('hardware errors are visible and offline fixture result works', (
    tester,
  ) async {
    final reader = _Reader();
    final (game, _, _) = await _launch(tester, reader, fixtures: true);
    reader.fail(0, StateError('sensitive native diagnostic'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('scan-state-error')), findsOneWidget);
    expect(find.byKey(const ValueKey('scan-error')), findsOneWidget);
    expect(find.textContaining('sensitive native diagnostic'), findsNothing);
    expect(find.byKey(const ValueKey('scan-native-retry')), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('scan-uid')),
      GameEngine.checkpointUid(1),
    );
    await flow.tapKey(tester, 'scan-submit');
    await tester.pumpAndSettle();
    expect(game.scanCalls, 1);
    expect(find.byKey(const ValueKey('scan-result-dismiss')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('scan-result-dismiss')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('scan-native-retry')),
      -300,
      scrollable: find
          .descendant(
            of: find.byType(ScanView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await Scrollable.ensureVisible(
      tester.element(find.byKey(const ValueKey('scan-native-retry'))),
      alignment: .5,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('scan-native-retry')));
    await tester.pump();
    expect(reader.reads, hasLength(2));
    expect(find.byKey(const ValueKey('scan-state-waiting')), findsOneWidget);
  });

  testWidgets('users cannot select operator modes or bind station tags', (
    tester,
  ) async {
    final reader = _Reader();
    final (game, vm, _) = await _launch(tester, reader);
    expect(vm.scannerMode, ScannerMode.user);
    expect(vm.scannerModes, [ScannerMode.user]);
    expect(vm.setScannerMode(ScannerMode.staff), isFalse);
    expect(vm.setScannerMode(ScannerMode.booth), isFalse);
    expect(find.byKey(const ValueKey('operator-scanner-modes')), findsNothing);
    expect(
      await vm.bindStation(GameEngine.unknownUid, game.stations.first.id),
      isFalse,
    );
    reader.deliver(0, GameEngine.unknownUid);
    await tester.pumpAndSettle();
    expect(find.byType(StationBindingView), findsNothing);
    expect(game.modes, [ScannerMode.user]);
  });

  testWidgets(
    'staff scan without onboarding shows read-only identity and stations',
    (tester) async {
      final reader = _Reader();
      final (game, vm, _) = await _launch(
        tester,
        reader,
        role: AccountRole.staff,
        checkedIn: false,
      );
      final resources = (vm.coins, vm.packs, vm.collected);
      expect(vm.scannerMode, ScannerMode.staff);
      expect(vm.scannerModes, [ScannerMode.user, ScannerMode.staff]);
      expect(vm.setScannerMode(ScannerMode.booth), isFalse);
      expect(reader.reads, hasLength(1));
      reader.deliver(0, game.demoPlayers.first.id);
      await tester.pumpAndSettle();
      expect(find.byType(OperatorResultView), findsOneWidget);
      expect(find.byKey(const ValueKey('operator-recipient')), findsOneWidget);
      expect(find.byType(PlayerView), findsNothing);
      expect(find.byKey(const ValueKey('player-friend')), findsNothing);
      expect(find.byKey(const ValueKey('player-battle')), findsNothing);
      expect(vm.hasScanned(game.demoPlayers.first.id), isFalse);
      await tester.tap(find.byKey(const ValueKey('operator-result-dismiss')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      reader.deliver(1, GameEngine.stationUid(1));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('operator-station-info')),
        findsOneWidget,
      );
      expect((vm.coins, vm.packs, vm.collected), resources);
      expect(game.modes, [ScannerMode.staff, ScannerMode.staff]);
    },
  );

  testWidgets(
    'staff unknown tags route to existing station binding; revocation disables it',
    (tester) async {
      final reader = _Reader();
      final (game, vm, _) = await _launch(
        tester,
        reader,
        role: AccountRole.staff,
        checkedIn: false,
      );
      reader.deliver(0, GameEngine.unknownUid);
      await tester.pumpAndSettle();
      expect(find.byType(StationBindingView), findsOneWidget);
      await game.configureRole(AccountRole.user);
      await tester.pump();
      expect(
        await vm.bindStation(GameEngine.unknownUid, game.stations.first.id),
        isFalse,
      );
      expect(game.scanCalls, 1);
      expect(vm.canScan, isFalse);
    },
  );

  testWidgets('a newly bound physical tag can be scanned again as staff', (
    tester,
  ) async {
    final reader = _Reader();
    final (game, _, _) = await _launch(
      tester,
      reader,
      role: AccountRole.staff,
      checkedIn: false,
    );
    final station = game.stations.first;
    reader.deliver(0, GameEngine.unknownUid);
    await tester.pumpAndSettle();
    await flow.tapKey(tester, 'station-option-${station.id}');
    await flow.tapKey(tester, 'station-bind');
    await tester.pumpAndSettle();
    await flow.tapKey(tester, 'message-dismiss');
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 400));
    reader.deliver(reader.reads.length - 1, GameEngine.unknownUid);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('operator-station-info')), findsOneWidget);
  });

  testWidgets(
    'mode changes invalidate native callbacks and user mode requires onboarding',
    (tester) async {
      final reader = _Reader();
      final (game, vm, _) = await _launch(
        tester,
        reader,
        role: AccountRole.staff,
        checkedIn: false,
      );
      await tester.tap(find.byKey(const ValueKey('scan-mode-user')));
      await tester.pumpAndSettle();
      expect(vm.scannerMode, ScannerMode.user);
      expect(vm.canScan, isFalse);
      expect(reader.cancellations, 1);
      reader.deliver(0, GameEngine.unknownUid);
      await tester.pump();
      expect(game.scanCalls, 0);
      expect(await vm.scan(GameEngine.unknownUid), isNull);
      await tester.tap(find.byKey(const ValueKey('scan-mode-staff')));
      await tester.pumpAndSettle();
      expect(reader.reads, hasLength(2));
      reader.deliver(1, GameEngine.unknownUid);
      await tester.pumpAndSettle();
      expect(find.byType(StationBindingView), findsOneWidget);
      expect(game.modes, [ScannerMode.staff]);
    },
  );

  testWidgets(
    'booth receipts show recipient, assignment and repeat without social actions',
    (tester) async {
      final reader = _Reader();
      final (game, vm, _) = await _launch(
        tester,
        reader,
        role: AccountRole.booth,
        checkedIn: false,
      );
      final ownProgress = (
        vm.coins,
        vm.packs,
        vm.hintCredits,
        vm.hintRemainder,
        vm.booths.where((booth) => booth.completed).length,
      );
      expect(vm.scannerMode, ScannerMode.booth);
      expect(vm.scannerModes, [ScannerMode.user, ScannerMode.booth]);
      expect(vm.setScannerMode(ScannerMode.staff), isFalse);
      reader.deliver(0, game.demoPlayers.first.id);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('operator-receipt-booth')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('operator-receipt-completed')),
        findsOneWidget,
      );
      expect(find.byType(PlayerView), findsNothing);
      expect(find.byKey(const ValueKey('player-friend')), findsNothing);
      expect(find.byKey(const ValueKey('player-battle')), findsNothing);
      await tester.tap(find.byKey(const ValueKey('operator-result-dismiss')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      // A different badge releases physical-tag deduplication before a repeat.
      reader.deliver(1, game.demoPlayers[1].id);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('operator-result-dismiss')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 400));
      reader.deliver(2, game.demoPlayers.first.id);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('operator-receipt-repeated')),
        findsOneWidget,
      );
      expect((
        vm.coins,
        vm.packs,
        vm.hintCredits,
        vm.hintRemainder,
        vm.booths.where((booth) => booth.completed).length,
      ), ownProgress);
      expect(game.modes, everyElement(ScannerMode.booth));
    },
  );

  testWidgets(
    'revocation suppresses an in-flight operator result and resets default mode',
    (tester) async {
      final reader = _Reader();
      final (game, vm, _) = await _launch(
        tester,
        reader,
        role: AccountRole.staff,
      );
      game.scanGate = Completer<void>();
      reader.deliver(0, game.demoPlayers.first.id);
      await tester.pump();
      expect(vm.busy, isTrue);
      expect(vm.setScannerMode(ScannerMode.user), isFalse);
      await game.configureRole(AccountRole.user);
      game.scanGate!.complete();
      await tester.pumpAndSettle();
      expect(vm.scannerMode, ScannerMode.user);
      expect(find.byType(OperatorResultView), findsNothing);
      expect(find.byType(PlayerView), findsNothing);
      expect(find.byType(StationBindingView), findsNothing);
      expect(vm.hasScanned(game.demoPlayers.first.id), isFalse);
    },
  );

  testWidgets(
    'changing booth assignment invalidates an already displayed receipt',
    (tester) async {
      final reader = _Reader();
      final (game, vm, _) = await _launch(
        tester,
        reader,
        role: AccountRole.booth,
        checkedIn: false,
      );
      reader.deliver(0, game.demoPlayers.first.id);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('operator-result')), findsOneWidget);
      await game.configureRole(AccountRole.booth, boothId: game.booths[1].id);
      await tester.pumpAndSettle();
      expect(vm.boothId, game.booths[1].id);
      expect(
        find.byKey(const ValueKey('operator-result-revoked')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('operator-recipient')), findsNothing);
      expect(
        find.byKey(const ValueKey('operator-receipt-booth')),
        findsNothing,
      );
      expect(reader.reads, hasLength(1));
    },
  );

  testWidgets(
    'context changes invalidate a fixture waiting on native cancellation',
    (tester) async {
      final reader = _Reader();
      final handled = <String>[];
      final controller = await _controller(
        tester,
        reader,
        (uid) async => handled.add(uid),
      );
      final gate = reader.cancelGate = Completer<void>();
      final fixture = controller.submitFixture('old-mode');
      controller.resetContext();
      gate.complete();
      await fixture;
      await tester.pump();
      expect(handled, isEmpty);
      expect(reader.reads, hasLength(2));
    },
  );

  testWidgets('staff choosing user mode does not bind unknown tags', (
    tester,
  ) async {
    final reader = _Reader();
    final (game, vm, _) = await _launch(
      tester,
      reader,
      role: AccountRole.staff,
    );
    await tester.tap(find.byKey(const ValueKey('scan-mode-user')));
    await tester.pumpAndSettle();
    expect(vm.scannerMode, ScannerMode.user);
    reader.deliver(1, GameEngine.unknownUid);
    await tester.pumpAndSettle();
    expect(find.byType(StationBindingView), findsNothing);
    expect(find.byType(OperatorResultView), findsNothing);
    expect(game.modes, [ScannerMode.user]);
  });

  testWidgets(
    'mode context reset allows the same physical badge in the new mode',
    (tester) async {
      final reader = _Reader();
      final handled = <String>[];
      final controller = await _controller(
        tester,
        reader,
        (uid) async => handled.add(uid),
      );
      final uid = GameEngine.playerUid(1);
      reader.deliver(0, uid);
      await tester.pump();
      controller.resetContext();
      await tester.pump();
      reader.deliver(1, uid);
      await tester.pump();
      expect(handled, [uid, uid]);
    },
  );
}
