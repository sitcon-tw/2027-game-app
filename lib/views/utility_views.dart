import 'package:flutter/material.dart';

import 'package:sitcon_backend/game/game_service.dart';

import '../l10n/localization.dart';
import '../services/sharing/recap_share_service.dart';
import '../viewmodels/game_view_model.dart';
import '../widgets/cosmic_widgets.dart';
import 'social_view.dart';

class LedgerView extends StatelessWidget {
  const LedgerView({super.key, required this.vm, this.battles = false});
  final GameViewModel vm;
  final bool battles;
  @override
  Widget build(BuildContext context) => CosmicPage(
    title: battles
        ? context.l10n.utilityBattleHistory
        : context.l10n.utilityLedger,
    vm: vm,
    builder: (context) => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (battles && vm.history.isEmpty || !battles && vm.ledger.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Text(context.l10n.noRecords),
          ),
        if (battles)
          for (final record in vm.history)
            Card.outlined(
              child: ExpansionTile(
                leading: PlanetOrb(record.battle.opponent.planet, size: 48),
                title: Text(
                  '${resultName(context, record.battle.result)} · ${playerName(context, record.battle.opponent)}',
                ),
                subtitle: Text(
                  '${stamp(context, record.at)}\n${context.l10n.socialBattleRewardSummary(record.points, record.coins)}',
                ),
                children: [
                  for (var i = 0; i < record.battle.rounds.length; i++)
                    ListTile(
                      title: Text(
                        context.l10n.utilityRoundResult(
                          i + 1,
                          resultName(context, record.battle.rounds[i].outcome),
                        ),
                      ),
                      subtitle: Text(
                        [
                          context.l10n.socialCardVersus(
                            record.battle.rounds[i].wild
                                ? context.l10n.socialWildMove(
                                    handName(
                                      context,
                                      record.battle.rounds[i].mine.index,
                                    ),
                                  )
                                : handName(
                                    context,
                                    record.battle.rounds[i].mine.index,
                                  ),
                            handName(
                              context,
                              record.battle.rounds[i].opponent.index,
                            ),
                          ),
                          if (record.battle.rounds[i].automatic)
                            context.l10n.utilityAutomaticPlay,
                        ].join(' · '),
                      ),
                    ),
                  ListTile(
                    title: Text(
                      record.reward == null
                          ? context.l10n.socialNoCardDraw
                          : context.l10n.socialCardDraw(
                              handName(context, record.reward!.index),
                            ),
                    ),
                  ),
                ],
              ),
            )
        else ...[
          Section(
            context.l10n.utilityCoinBalance(vm.coins),
            icon: Icons.monetization_on_outlined,
            child: Text(context.l10n.utilityPointsSeparate),
          ),
          for (final entry in vm.ledger)
            Card.outlined(
              child: ListTile(
                leading: Icon(
                  entry.coins > 0
                      ? Icons.add_circle_outline
                      : entry.coins < 0
                      ? Icons.remove_circle_outline
                      : Icons.receipt_long_outlined,
                ),
                title: Text(gameText(context, entry.message)),
                subtitle: Text(stamp(context, entry.at)),
                trailing: entry.coins == 0
                    ? null
                    : Text('${entry.coins > 0 ? '+' : ''}${entry.coins}'),
              ),
            ),
        ],
      ],
    ),
  );
}

class RecapView extends StatefulWidget {
  const RecapView({super.key, required this.vm});
  final GameViewModel vm;
  @override
  State<RecapView> createState() => _RecapViewState();
}

class _RecapViewState extends State<RecapView> {
  final storyKey = GlobalKey();
  bool sharing = false;
  @override
  Widget build(BuildContext context) => CosmicPage(
    title: context.l10n.utilityRecapTitle,
    vm: widget.vm,
    builder: (context) {
      final vm = widget.vm;
      final moves = List<int>.filled(3, 0);
      for (final record in vm.history) {
        for (final round in record.battle.rounds) {
          if (round.mine.index < 3) moves[round.mine.index]++;
        }
      }
      final max = moves.reduce((a, b) => a > b ? a : b);
      final favorite = max == 0
          ? context.l10n.utilityNoMoves
          : [
              for (var i = 0; i < 3; i++)
                if (moves[i] == max) handName(context, i),
            ].join(' / ');
      final winRate = vm.history.isEmpty
          ? '0%'
          : '${(vm.wins / vm.history.length * 100).round()}%';
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: RepaintBoundary(
                key: storyKey,
                child: AspectRatio(
                  key: const ValueKey('recap-story'),
                  aspectRatio: 9 / 16,
                  // Keep preview typography identical to the exported story.
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 420,
                      height: 420 * 16 / 9,
                      child: MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(textScaler: TextScaler.noScaling),
                        child: LayoutBuilder(
                          builder: (context, constraints) => Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  navy,
                                  Color(0xFF34436E),
                                  Color(0xFF17234B),
                                ],
                              ),
                            ),
                            padding: EdgeInsets.all(constraints.maxWidth * .07),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.utilityStoryTitle,
                                  style: const TextStyle(
                                    color: sky,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Center(
                                    child: PlanetOrb(
                                      vm.me.planet,
                                      size: constraints.maxWidth * .52,
                                    ),
                                  ),
                                ),
                                Text(
                                  vm.me.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: constraints.maxWidth * .075,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Expanded(
                                  flex: 4,
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _storyRow(
                                        context.l10n.utilityBattles,
                                        context.l10n.utilityBattleCount(
                                          vm.history.length,
                                        ),
                                        context.l10n.utilityWinRate,
                                        winRate,
                                      ),
                                      _storyRow(
                                        context.l10n.planets,
                                        '${vm.planets.length} / 42',
                                        context.l10n.utilityCompleteSeries,
                                        '${vm.completeSeries} / 6',
                                      ),
                                      _storyRow(
                                        context.l10n.checkpoints,
                                        '${vm.collected} / 42',
                                        context.l10n.friends,
                                        context.l10n.utilityPeopleCount(
                                          vm.friends.length,
                                        ),
                                      ),
                                      _storyRow(
                                        context.l10n.utilityHashtagMissions,
                                        '${vm.completedMissions} / 6',
                                        context.l10n.utilityFavoriteMove,
                                        favorite,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  vm.isOfflineDemo
                                      ? context.l10n.utilityOfflineRecord
                                      : context.l10n.utilityTestRecord,
                                  style: const TextStyle(
                                    color: sky,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          ReasonButton(
            key: const ValueKey('recap-share'),
            label: sharing
                ? context.l10n.utilityGeneratingImage
                : context.l10n.utilityShareStory,
            icon: Icons.ios_share,
            reason: vm.phase != EventPhase.ended
                ? context.l10n.utilityRecapAfterEvent
                : null,
            onPressed: sharing
                ? null
                : () async {
                    setState(() => sharing = true);
                    try {
                      await RecapShareService.share(
                        storyKey,
                        title: context.l10n.utilityRecapTitle,
                      );
                    } catch (e) {
                      vm.reportError(e);
                    } finally {
                      if (mounted) setState(() => sharing = false);
                    }
                  },
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => openPage(context, FriendsView(vm: vm)),
            child: Text(context.l10n.friends),
          ),
          const SizedBox(height: 32),
        ],
      );
    },
  );
  Widget _storyRow(
    String label1,
    String value1,
    String label2,
    String value2,
  ) => Row(
    children: [
      Expanded(child: _storyStat(label1, value1)),
      const SizedBox(width: 8),
      Expanded(child: _storyStat(label2, value2)),
    ],
  );
  Widget _storyStat(String label, String value) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: sky, fontSize: 11)),
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}
