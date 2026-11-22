import 'package:flutter/material.dart';

import 'package:sitcon_backend/game/game_service.dart';

import '../l10n/localization.dart';
import '../viewmodels/game_view_model.dart';
import '../widgets/cosmic_widgets.dart';
import 'social_view.dart';

class TasksView extends StatefulWidget {
  const TasksView({super.key, required this.vm, this.initialTab = 0});
  final GameViewModel vm;
  final int initialTab;
  @override
  State<TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<TasksView> {
  late int tab = widget.initialTab;
  @override
  void didUpdateWidget(TasksView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
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
                  key: ValueKey(
                    ['tasks-hashtag', 'tasks-checkpoint', 'tasks-booth'][i],
                  ),
                  label: Text(
                    [
                      context.l10n.taskHashtags,
                      context.l10n.checkpoints,
                      context.l10n.taskBooths,
                    ][i],
                  ),
                  selected: tab == i,
                  onSelected: (_) => setState(() => tab = i),
                ),
            ],
          ),
        ),
        Expanded(
          child: tab == 0
              ? _hashtags(context, vm)
              : tab == 1
              ? _checkpoints(context, vm)
              : _booths(context, vm),
        ),
      ],
    );
  }

  Widget _hashtags(BuildContext context, GameViewModel vm) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
    children: [
      Text(
        context.l10n.taskMissionSummary(
          vm.completedMissions,
          vm.ledger
              .where((e) => e.reason == 'mission.complete')
              .fold<int>(0, (sum, e) => sum + e.coins),
        ),
      ),
      Text(context.l10n.taskMissionRules(vm.parameters['missionCoins']!)),
      const SizedBox(height: 16),
      for (final category in hashtagOptions.keys)
        Section(
          categoryName(context, category),
          child: Column(
            children: [
              for (final m in vm.missions.where((m) => m.category == category))
                Card.outlined(
                  child: ExpansionTile(
                    key: ValueKey('mission-${m.tag}'),
                    leading: Icon(
                      m.completedAt != null ? Icons.check_circle : Icons.tag,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text('#${tagName(context, m.tag)}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.taskMissionProgress(
                            m.own
                                ? context.l10n.taskOwnTag
                                : context.l10n.taskNewTag,
                            m.progress,
                            m.completedAt == null
                                ? context.l10n.taskInProgress
                                : context.l10n.taskCompleted,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: m.progress / 3),
                      ],
                    ),
                    children: [
                      if (m.friends.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(context.l10n.taskNoMatchingFriends),
                        ),
                      for (final id in m.friends)
                        Builder(
                          builder: (context) {
                            final matches = vm.friends.where((p) => p.id == id);
                            final person = matches.isEmpty
                                ? null
                                : matches.first;
                            return ListTile(
                              leading: person == null
                                  ? const Icon(Icons.person_outline)
                                  : PlanetOrb(person.planet, size: 40),
                              title: Text(
                                person == null
                                    ? id
                                    : playerName(context, person),
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: person == null
                                  ? null
                                  : () => openPage(
                                      context,
                                      PlayerView(vm: vm, player: person),
                                    ),
                            );
                          },
                        ),
                      if (m.completedAt != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            context.l10n.taskCompletedAt(
                              stamp(context, m.completedAt),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
    ],
  );
  Widget _checkpoints(BuildContext context, GameViewModel vm) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
    children: [
      Text(context.l10n.taskCheckpointProgress(vm.collected)),
      const SizedBox(height: 16),
      Section(
        vm.collected >= 7
            ? context.l10n.taskPostcardUnlocked
            : context.l10n.taskPostcard,
        icon: Icons.mail_outline,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: (vm.collected / 7).clamp(0, 1)),
            const SizedBox(height: 8),
            if (vm.collected < 7)
              Text(context.l10n.taskPostcardRemaining(7 - vm.collected)),
            if (vm.collected >= 7)
              TextButton(
                key: const ValueKey('postcard-open'),
                onPressed: () => openPage(context, PostcardView(vm: vm)),
                child: Text(context.l10n.taskOpenPostcard),
              ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      ReasonButton(
        key: const ValueKey('hint-redeem'),
        label: context.l10n.taskRedeemHint(vm.hintCredits),
        icon: Icons.lightbulb_outline,
        reason: vm.hintCredits == 0
            ? context.l10n.taskNextHint(
                vm.parameters['hintThreshold']! - vm.hintRemainder,
              )
            : vm.collected == 42
            ? context.l10n.taskAllCheckpointsFound
            : vm.phase != EventPhase.active
            ? context.l10n.taskHintsActiveOnly
            : null,
        onPressed: vm.busy
            ? null
            : () async {
                final hint = await vm.hint();
                if (hint != null && context.mounted) {
                  await messageDialog(
                    context,
                    context.l10n.taskHint,
                    gameText(context, hint),
                  );
                }
              },
      ),
      const SizedBox(height: 20),
      _checkpointGrid(
        context,
        vm,
        vm.checkpoints.where((c) => c.area != '限定款').toList(),
      ),
      const SizedBox(height: 24),
      Text(
        context.l10n.taskLimitedCheckpoints,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      const SizedBox(height: 8),
      _checkpointGrid(
        context,
        vm,
        vm.checkpoints.where((c) => c.area == '限定款').toList(),
      ),
    ],
  );
  Widget _checkpointGrid(
    BuildContext context,
    GameViewModel vm,
    List<Checkpoint> points,
  ) => LayoutBuilder(
    builder: (context, constraints) {
      final width = ((constraints.maxWidth - 24) / 4).clamp(64.0, 130.0);
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final point in points)
            SizedBox(
              width: width,
              child: Card.outlined(
                child: InkWell(
                  key: ValueKey('checkpoint-${point.number}'),
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _checkpointDetail(context, point),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          point.collectedAt == null
                              ? Icons.location_searching
                              : Icons.location_on,
                          color: Theme.of(context).colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(context.l10n.taskCheckpointNumber(point.number)),
                        Text(
                          point.collectedAt == null
                              ? context.l10n.taskNotFound
                              : context.l10n.taskCollected,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );
  void _checkpointDetail(BuildContext context, Checkpoint point) =>
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.taskCheckpointTitle(point.number)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  point.collectedAt == null
                      ? context.l10n.notAcquired
                      : context.l10n.taskCollected,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point.collectedAt != null || point.hint != null
                            ? areaName(context, point.area)
                            : context.l10n.taskAreaHidden,
                      ),
                    ),
                  ],
                ),
                if (point.collectedAt != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.taskCollectedAt(
                      stamp(context, point.collectedAt),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Text(
                  point.hint == null
                      ? context.l10n.taskHintNotRedeemed
                      : gameText(context, point.hint),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.close),
            ),
          ],
        ),
      );
  Widget _booths(BuildContext context, GameViewModel vm) => ListView(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
    children: [
      Text(context.l10n.taskBoothRules),
      const SizedBox(height: 16),
      for (final b in vm.booths)
        Card.filled(
          child: ListTile(
            isThreeLine: true,
            leading: const Icon(Icons.storefront_outlined),
            title: Text(boothName(context, b)),
            subtitle: Text(
              context.l10n.taskBoothStatus(
                b.visited
                    ? context.l10n.taskVisited
                    : context.l10n.taskNotVisited,
                b.completed
                    ? context.l10n.taskCompleted
                    : context.l10n.taskInProgress,
                b.url,
              ),
            ),
            trailing: const Icon(Icons.open_in_new),
            onTap: () => openBooth(context, vm, b),
          ),
        ),
    ],
  );
}

class PostcardView extends StatelessWidget {
  const PostcardView({super.key, required this.vm});
  final GameViewModel vm;
  @override
  Widget build(BuildContext context) => CosmicPage(
    title: context.l10n.taskPostcard,
    vm: vm,
    builder: (context) => ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: sky),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.taskPostcardHeading,
                style: const TextStyle(color: sky, letterSpacing: 2),
              ),
              const SizedBox(height: 32),
              PlanetOrb(vm.me.planet, size: 160),
              const SizedBox(height: 24),
              Text(
                context.l10n.taskPostcardGreeting(vm.me.name),
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: pink),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.taskPostcardBody(vm.collected),
                style: const TextStyle(color: Colors.white, height: 1.8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(context.l10n.taskPhysicalPostcardNotice),
      ],
    ),
  );
}
