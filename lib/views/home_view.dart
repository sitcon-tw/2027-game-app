import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sitcon_backend/game/game_service.dart';

import '../l10n/localization.dart';
import 'language_settings_view.dart';
import '../viewmodels/game_view_model.dart';
import '../widgets/cosmic_widgets.dart';
import 'collection_view.dart';
import 'demo_controls_view.dart';
import 'profile_view.dart';
import 'social_view.dart';
import 'tasks_view.dart';
import 'utility_views.dart';
import 'operator_widgets.dart';

String? _inventoryNotice(BuildContext context, LedgerEntry entry) {
  if (entry.reason != 'admin.inventory' && entry.reason != 'mock.remote') {
    return null;
  }
  final l = context.l10n;
  final isPackDelivery = entry.reason == 'mock.remote';
  final delta = entry.args[isPackDelivery ? 'amount' : 'delta'] as int?;
  final reason = entry.args['reason'] as String?;
  final key = isPackDelivery ? 'packs' : entry.args['resource'] as String?;
  if (delta == null || reason == null || key == null) return entry.detail;
  final planet = key.startsWith('planet:') ? int.tryParse(key.substring(7)) : null;
  final name = switch (key) {
    'coins' => l.coins,
    'points' => l.points,
    'packs' => l.packs,
    'peekCards' => l.shellInventoryPeekCards,
    'hintCredits' => l.shellInventoryHints,
    'scissors' => handName(context, HandCard.scissors.index),
    'rock' => handName(context, HandCard.rock.index),
    'paper' => handName(context, HandCard.paper.index),
    'wild' => handName(context, HandCard.wild.index),
    _ => planet != null && planet >= 0 && planet < 42
        ? planetName(context, planet)
        : key,
  };
  return '$name ${delta > 0 ? '+' : '−'}${delta.abs()}\n\n$reason';
}

class HomeView extends StatefulWidget {
  const HomeView({
    super.key,
    required this.vm,
    this.onChooseEnvironment,
    this.issueTransferCode,
  });
  final GameViewModel vm;
  final VoidCallback? onChooseEnvironment;
  final Future<String> Function()? issueTransferCode;
  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  final pages = PageController(initialPage: 1);
  int selected = 1;
  int taskTab = 0;
  bool showingReward = false;
  bool tutorialShowing = false;
  bool scheduled = false;
  Object? lastError;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.vm.addListener(_scheduleEvents);
    _scheduleEvents();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.vm.removeListener(_scheduleEvents);
    pages.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) widget.vm.resume();
  }

  void _scheduleEvents() {
    if (scheduled || !mounted) return;
    scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduled = false;
      if (mounted) _events();
    });
  }

  Future<void> _events() async {
    final vm = widget.vm;
    if (vm.error != null && vm.error != lastError) {
      lastError = vm.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(gameText(context, vm.error)),
          duration: const Duration(seconds: 7),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: context.l10n.close,
            onPressed: () {
              vm.clearError();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    } else if (vm.error == null) {
      lastError = null;
    }
    if (showingReward ||
        vm.busy ||
        vm.battle != null && vm.battle!.accepted && !vm.battle!.finished) {
      return;
    }
    const notifyReasons = {
      'checkin',
      'early.unlock',
      'mission.complete',
      'mock.agenda',
      'mock.remote',
      'admin.inventory',
      'mock.photo',
      'hint.earn',
    };
    while (vm.rewards.isNotEmpty) {
      final entry = vm.rewards.removeAt(0);
      if (!notifyReasons.contains(entry.reason)) continue;
      showingReward = true;
      final mission = entry.reason == 'mission.complete';
      final inventory = entry.reason == 'admin.inventory';
      final delta = entry.args['delta'] as int?;
      final removed = delta != null && delta < 0;
      if (mission) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(gameText(context, entry.message)),
            action: SnackBarAction(
              label: context.l10n.shellViewTasks,
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                go(2, tasks: 0);
              },
            ),
          ),
        );
      }
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          icon: Icon(
            mission
                ? Icons.task_alt
                : removed
                ? Icons.remove_circle_outline
                : Icons.auto_awesome,
            color: Theme.of(dialogContext).colorScheme.primary,
          ),
          title: Text(
            mission
                ? context.l10n.shellMissionComplete
                : entry.reason == 'hint.earn'
                ? context.l10n.shellHintEarned
                : entry.reason == 'checkin'
                ? context.l10n.shellCheckedIn
                : inventory
                ? (delta == null
                      ? context.l10n.shellInventoryUpdated
                      : removed
                      ? context.l10n.shellInventoryRemoved
                      : context.l10n.shellInventoryAdded)
                : context.l10n.shellReward,
          ),
          content: SingleChildScrollView(
            child: Text(
              entry.reason == 'checkin'
                  ? context.l10n.shellCheckInReward
                  : _inventoryNotice(context, entry) ??
                        gameText(context, entry.message),
            ),
          ),
          actions: [
            if (mission)
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  go(2, tasks: 0);
                },
                child: Text(context.l10n.shellViewTasks),
              ),
            FilledButton(
              key: const ValueKey('reward-dismiss'),
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n.done),
            ),
          ],
        ),
      );
      showingReward = false;
      if (!mounted) return;
    }
    if (vm.checkedIn &&
        !vm.tutorialSeen &&
        !tutorialShowing &&
        ModalRoute.of(context)?.isCurrent == true) {
      tutorialShowing = true;
      await openPage(context, TutorialView(vm: vm));
      tutorialShowing = false;
    }
  }

  void go(int index, {int? tasks}) {
    if (tasks != null) setState(() => taskTab = tasks);
    if (pages.hasClients) {
      pages.animateToPage(
        index,
        duration: Duration(
          milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 300,
        ),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> showTransferCode(Future<String> Function() issue) async {
    final requested = issue();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => FutureBuilder<String>(
        future: requested,
        builder: (context, snapshot) => AlertDialog(
          title: Text(context.l10n.deviceTransferCode),
          content: snapshot.hasError
              ? Text(gameText(context, snapshot.error))
              : snapshot.hasData
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.deviceTransferShare),
                    const SizedBox(height: 16),
                    SelectableText(snapshot.requireData),
                  ],
                )
              : const LinearProgressIndicator(),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(context.l10n.cancel),
            ),
            if (snapshot.data case final code?)
              FilledButton(
                key: const ValueKey('copy-transfer-code'),
                onPressed: () async {
                  try {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (!context.mounted || !mounted) return;
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text(this.context.l10n.deviceTransferCopied)),
                    );
                  } on PlatformException {
                    if (!context.mounted || !mounted) return;
                    ScaffoldMessenger.of(this.context).showSnackBar(
                      SnackBar(content: Text(this.context.l10n.deviceTransferCopyFailed)),
                    );
                  }
                },
                child: Text(context.l10n.deviceTransferCopy),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> moreActions() async {
    final page = await showModalBottomSheet<Widget>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 640),
      builder: (sheetContext) => FractionallySizedBox(
        heightFactor: .85,
        child: AnimatedBuilder(
          animation: widget.vm,
          builder: (context, _) {
            final vm = widget.vm;
            Widget entry(
              String id,
              IconData icon,
              String title,
              Widget Function() destination,
            ) => ListTile(
              key: ValueKey(id),
              leading: Icon(icon),
              title: Text(title),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(sheetContext, destination()),
            );
            return SafeArea(
              top: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Text(
                      context.l10n.shellMore,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      key: const ValueKey('more-actions'),
                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                      children: [
                        entry(
                          'more-language',
                          Icons.language,
                          context.l10n.language,
                          () => const LanguageSettingsView(),
                        ),
                        if (widget.onChooseEnvironment case final choose?)
                          ListTile(
                            key: const ValueKey('more-environment'),
                            leading: const Icon(Icons.swap_horiz),
                            title: Text(context.l10n.shellChooseMode),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              choose();
                            },
                          ),
                        if (widget.issueTransferCode case final issue?)
                          ListTile(
                            key: const ValueKey('more-transfer-code'),
                            leading: const Icon(Icons.phonelink_setup),
                            title: Text(context.l10n.deviceTransferOut),
                            onTap: () {
                              Navigator.pop(sheetContext);
                              showTransferCode(issue);
                            },
                          ),
                        if (vm.isOfflineDemo) ...[
                          entry(
                            'more-demo-tools',
                            Icons.science_outlined,
                            context.l10n.shellCheats,
                            () => DemoControlsView(vm: vm),
                          ),
                          const Divider(),
                        ],
                        if (vm.checkedIn) ...[
                          entry(
                            'more-packs',
                            Icons.inventory_2_outlined,
                            context.l10n.shellOpenPacks,
                            () => PackView(vm: vm),
                          ),
                          entry(
                            'more-shop',
                            Icons.shopping_bag_outlined,
                            context.l10n.shellEggs,
                            () => CosmicPage(
                              title: context.l10n.shellShop,
                              vm: vm,
                              builder: (_) => ListView(
                                padding: const EdgeInsets.all(24),
                                children: [EggShop(vm: vm)],
                              ),
                            ),
                          ),
                          entry(
                            'more-collection',
                            Icons.public_outlined,
                            context.l10n.shellCollection,
                            () => CollectionView(vm: vm),
                          ),
                          entry(
                            'more-friends',
                            Icons.people_outline,
                            context.l10n.shellFriends,
                            () => FriendsView(vm: vm),
                          ),
                          entry(
                            'more-rankings',
                            Icons.leaderboard_outlined,
                            context.l10n.shellRankings,
                            () => RankingView(vm: vm),
                          ),
                          const Divider(),
                          entry(
                            'more-profile',
                            Icons.edit_outlined,
                            context.l10n.shellEditCard,
                            () => ProfileEditor(vm: vm),
                          ),
                          entry(
                            'more-appearance',
                            Icons.palette_outlined,
                            context.l10n.shellAppearance,
                            () => CollectionView(vm: vm, appearance: true),
                          ),
                          entry(
                            'more-ledger',
                            Icons.receipt_long_outlined,
                            context.l10n.shellLedger,
                            () => LedgerView(vm: vm),
                          ),
                          entry(
                            'more-history',
                            Icons.history,
                            context.l10n.shellBattleHistory,
                            () => LedgerView(vm: vm, battles: true),
                          ),
                          entry(
                            'recap-open',
                            Icons.auto_graph_rounded,
                            context.l10n.shellRecap,
                            () => RecapView(vm: vm),
                          ),
                          const Divider(),
                        ],
                        entry(
                          'early-open',
                          Icons.auto_awesome_outlined,
                          context.l10n.shellEarlyBird,
                          () => CosmicPage(
                            title: context.l10n.shellEarlyBird,
                            vm: vm,
                            builder: (_) => ListView(
                              padding: const EdgeInsets.all(24),
                              children: [EarlyBirdCard(vm: vm)],
                            ),
                          ),
                        ),
                        entry(
                          'tutorial-open',
                          Icons.help_outline,
                          context.l10n.shellTutorial,
                          () => TutorialView(vm: vm),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
    if (mounted && page != null) await openPage(context, page);
  }

  void navigate(int index) {
    if (index < 3) {
      go(index);
    } else if (index == 3) {
      openPage(context, ScanView(vm: widget.vm));
    } else {
      moreActions();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.vm,
    builder: (context, _) {
      final vm = widget.vm;
      final currentBattle = vm.battle;
      final battle = currentBattle?.finished == false
          ? currentBattle
          : vm.unreadLiveBattleResult;
      final liveBattle = vm.liveBattle;
      return Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.appTitle),
              Text(
                vm.phase == EventPhase.before
                    ? context.l10n.shellPhaseBefore
                    : vm.phase == EventPhase.ended
                    ? context.l10n.shellPhaseEnded
                    : context.l10n.shellPhaseActive,
                style: Theme.of(context).textTheme.labelMedium,
              ),
              Text(
                accountRoleName(context, vm.role),
                key: const ValueKey('home-account-role'),
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              GameEnvironmentBanner(offline: vm.isOfflineDemo),
              if (vm.busy) const LinearProgressIndicator(),
              if (vm.incomingFriends.isNotEmpty)
                Material(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: ListTile(
                    key: const ValueKey('friend-requests-open'),
                    leading: const Icon(Icons.person_add_alt_1),
                    title: Text(context.l10n.socialFriendRequests),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => openPage(context, FriendsView(vm: vm)),
                  ),
                ),
              if (battle != null)
                Material(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: ListTile(
                    key: const ValueKey('battle-resume'),
                    leading: const Icon(Icons.bolt),
                    title: Text(
                      battle.finished
                          ? context.l10n.socialBattleResult
                          : liveBattle?.waitingReady == true
                          ? (liveBattle!.ready ? context.l10n.socialWaitingForReady : context.l10n.socialReady)
                          : battle.accepted
                          ? (liveBattle?.played == true
                                ? context.l10n.socialWaitingOpponentCard
                                : context.l10n.shellBattleRound(
                                    battle.rounds.length + 1,
                                  ))
                          : liveBattle == null
                          ? context.l10n.shellWaitingOpponent
                          : liveBattle.incoming
                          ? context.l10n.socialInviteReceived
                          : context.l10n.socialWaitingBattleAcceptance,
                    ),
                    subtitle: Text(
                      battle.finished
                          ? '${resultName(context, battle.result)} · '
                              '${playerName(context, battle.opponent)}'
                          : liveBattle?.waitingReady == true
                          ? playerName(context, battle.opponent)
                          : context.l10n.shellBattleRemaining(
                              vm.secondsUntil(battle.deadline),
                            ),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => openPage(
                      context,
                      BattleView(vm: vm, battleId: battle.id),
                    ),
                  ),
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 960),
                    child: !vm.checkedIn
                        ? WelcomeView(vm: vm)
                        : PageView(
                            controller: pages,
                            onPageChanged: (value) =>
                                setState(() => selected = value),
                            children: [
                              game(context, vm),
                              myCard(context, vm),
                              TasksView(vm: vm, initialTab: taskTab),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: NavigationBar(
          key: const ValueKey('player-navigation'),
          selectedIndex: selected,
          onDestinationSelected: navigate,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              key: const ValueKey('tab-game'),
              enabled: vm.checkedIn,
              icon: const Icon(Icons.sports_esports_outlined),
              selectedIcon: const Icon(Icons.sports_esports),
              label: context.l10n.games,
            ),
            NavigationDestination(
              key: ValueKey('tab-mycard'),
              icon: Icon(Icons.badge_outlined),
              selectedIcon: Icon(Icons.badge),
              label: context.l10n.shellMyCard,
            ),
            NavigationDestination(
              key: const ValueKey('tab-tasks'),
              enabled: vm.checkedIn,
              icon: const Icon(Icons.explore_outlined),
              selectedIcon: const Icon(Icons.explore),
              label: context.l10n.tasks,
            ),
            NavigationDestination(
              key: const ValueKey('scan-open'),
              enabled: vm.canOpenScanner && !vm.busy,
              icon: const Icon(Icons.contactless_outlined),
              selectedIcon: const Icon(Icons.contactless),
              label: context.l10n.scan,
              tooltip: vm.canOpenScanner
                  ? context.l10n.shellScanHint
                  : context.l10n.shellCheckInFirst,
            ),
            NavigationDestination(
              key: ValueKey('tab-more'),
              icon: Icon(Icons.more_horiz),
              label: context.l10n.more,
            ),
          ],
        ),
      );
    },
  );
  Widget status(GameViewModel vm) => Wrap(
    spacing: 12,
    runSpacing: 8,
    children: [
      Chip(
        avatar: const Icon(Icons.monetization_on_outlined, size: 18),
        label: Text(context.l10n.shellCoins(vm.coins)),
      ),
      Chip(
        avatar: const Icon(Icons.style_outlined, size: 18),
        label: Text(context.l10n.shellCards(vm.handTotal)),
      ),
      ActionChip(
        avatar: const Icon(Icons.inventory_2_outlined, size: 18),
        label: Text(context.l10n.shellPacks(vm.packs)),
        onPressed: () => openPage(context, PackView(vm: vm)),
      ),
    ],
  );

  Widget game(BuildContext context, GameViewModel vm) {
    final draws = vm.history.where((r) => r.battle.result == 0).length;
    final ranking = vm.ranking('points');
    final rank = ranking.indexWhere((r) => r.player.id == vm.me.id) + 1;
    final blocked = vm.phase != EventPhase.active
        ? context.l10n.shellBattleClosed
        : vm.battle != null && !vm.battle!.finished
        ? context.l10n.shellBattleOngoing
        : vm.cooldown > 0
        ? context.l10n.shellCooldownRemaining(vm.cooldown)
        : vm.handTotal < 3
        ? context.l10n.shellNotEnoughCards
        : null;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        status(vm),
        const SizedBox(height: 24),
        Section(
          context.l10n.shellBattle,
          icon: Icons.bolt_outlined,
          action: IconButton(
            key: const ValueKey('rankings-open'),
            tooltip: context.l10n.shellRankings,
            onPressed: () => openPage(context, RankingView(vm: vm)),
            icon: const Icon(Icons.leaderboard_outlined),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.shellBattleStats(
                  vm.history.length,
                  vm.wins,
                  draws,
                  vm.history.length - vm.wins - draws,
                ),
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.shellPointsRank(
                  vm.points,
                  rank == 0 ? '—' : '#$rank',
                ),
              ),
              const SizedBox(height: 16),
              Text(blocked ?? context.l10n.shellBattleReady),
              if (vm.cooldown > 0) ...[
                const SizedBox(height: 12),
                Countdown(
                  seconds: vm.cooldown,
                  total: vm.parameters['battleCooldownSeconds']!,
                  label: context.l10n.shellCooldown,
                ),
              ],
              const SizedBox(height: 12),
              TextButton.icon(
                key: const ValueKey('history-open'),
                onPressed: () =>
                    openPage(context, LedgerView(vm: vm, battles: true)),
                icon: const Icon(Icons.history),
                label: Text(context.l10n.shellBattleHistory),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Section(
          context.l10n.shellCollection,
          icon: Icons.public_outlined,
          action: IconButton(
            key: const ValueKey('appearance-open'),
            tooltip: context.l10n.shellAppearance,
            onPressed: () =>
                openPage(context, CollectionView(vm: vm, appearance: true)),
            icon: const Icon(Icons.palette_outlined),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PlanetOrb(vm.me.planet, size: 96),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          planetName(context, vm.me.planet),
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          context.l10n.shellCollectionProgress(
                            vm.planets.length,
                            vm.completeSeries,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              EggShop(vm: vm),
              const SizedBox(height: 20),
              for (var s = 0; s < 6; s++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(seriesName(context, s))),
                          Text(
                            '${vm.seriesCount(s)} / 7 ${vm.seriesCount(s) == 7 ? '✓' : ''}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: vm.seriesCount(s) / 7,
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ),
              TextButton.icon(
                key: const ValueKey('collection-open'),
                onPressed: () => openPage(context, CollectionView(vm: vm)),
                icon: const Icon(Icons.grid_view_rounded),
                label: Text(context.l10n.shellCollection),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        EarlyBirdCard(vm: vm),
      ],
    );
  }

  Widget myCard(BuildContext context, GameViewModel vm) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
    children: [
      status(vm),
      const SizedBox(height: 16),
      if (vm.phase == EventPhase.ended) ...[
        Section(
          context.l10n.shellRecap,
          icon: Icons.auto_graph,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.shellEndedHint),
              const SizedBox(height: 12),
              FilledButton(
                key: const ValueKey('recap-open-card'),
                onPressed: () => openPage(context, RecapView(vm: vm)),
                child: Text(context.l10n.shellRecap),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
      PlayerIdentity(
        vm.me,
        action: IconButton(
          key: const ValueKey('profile-edit'),
          tooltip: context.l10n.shellEditCard,
          onPressed: () => openPage(context, ProfileEditor(vm: vm)),
          icon: const Icon(Icons.edit_outlined),
        ),
      ),
      const SizedBox(height: 16),
      TextButton.icon(
        key: const ValueKey('mycard-appearance'),
        onPressed: () =>
            openPage(context, CollectionView(vm: vm, appearance: true)),
        icon: const Icon(Icons.palette_outlined),
        label: Text(context.l10n.shellAppearance),
      ),
      Section(
        context.l10n.shellHand,
        icon: Icons.style_outlined,
        action: IconButton(
          key: const ValueKey('ledger-open'),
          tooltip: context.l10n.shellLedger,
          onPressed: () => openPage(context, LedgerView(vm: vm)),
          icon: const Icon(Icons.receipt_long_outlined),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = 0; i < 4; i++)
                  Chip(
                    avatar: Icon(handIcon(i), size: 18),
                    label: Text('${handName(context, i)} ${vm.hand[i]}'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(context.l10n.shellPeekCards(vm.peekCards)),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              context.l10n.shellPacks(vm.packs),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const ValueKey('packs-open'),
              onPressed: vm.packs > 0
                  ? () => openPage(context, PackView(vm: vm))
                  : null,
              icon: const Icon(Icons.inventory_2_outlined),
              label: Text(context.l10n.shellOpenPacks),
            ),
            if (vm.packs == 0) Text(context.l10n.shellNoPacks),
          ],
        ),
      ),
      const SizedBox(height: 16),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth > 600 ? 3 : 2;
          final width = (constraints.maxWidth - (columns - 1) * 8) / columns;
          return Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SizedBox(
                width: width,
                child: StatTile(
                  context.l10n.coins,
                  '${vm.coins}',
                  Icons.monetization_on_outlined,
                  onTap: () => openPage(context, LedgerView(vm: vm)),
                ),
              ),
              SizedBox(
                width: width,
                child: StatTile(
                  context.l10n.friends,
                  '${vm.friends.length}',
                  Icons.people_outline,
                  key: const ValueKey('friends-open'),
                  onTap: () => openPage(context, FriendsView(vm: vm)),
                ),
              ),
              SizedBox(
                width: width,
                child: StatTile(
                  context.l10n.points,
                  '${vm.points}',
                  Icons.emoji_events_outlined,
                  key: const ValueKey('mycard-rankings'),
                  onTap: () => openPage(context, RankingView(vm: vm)),
                ),
              ),
              SizedBox(
                width: width,
                child: StatTile(
                  context.l10n.planets,
                  '${vm.planets.length}/42',
                  Icons.public_outlined,
                  onTap: () => openPage(context, CollectionView(vm: vm)),
                ),
              ),
              SizedBox(
                width: width,
                child: StatTile(
                  context.l10n.checkpoints,
                  '${vm.collected}/42',
                  Icons.location_on_outlined,
                  key: const ValueKey('mycard-checkpoints'),
                  onTap: () => go(2, tasks: 1),
                ),
              ),
              SizedBox(
                width: width,
                child: StatTile(
                  context.l10n.tasks,
                  '${vm.completedMissions}/6',
                  Icons.task_alt,
                  key: const ValueKey('mycard-missions'),
                  onTap: () => go(2, tasks: 0),
                ),
              ),
            ],
          );
        },
      ),
      if (vm.cooldown > 0) ...[
        const SizedBox(height: 20),
        Section(
          context.l10n.shellCooldown,
          child: Countdown(
            seconds: vm.cooldown,
            total: 60,
            label: context.l10n.shellCooldown,
          ),
        ),
      ],
    ],
  );
}
