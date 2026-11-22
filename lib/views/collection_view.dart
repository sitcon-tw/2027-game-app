import 'package:flutter/material.dart';

import 'package:sitcon_backend/game/game_service.dart';

import '../l10n/localization.dart';
import '../viewmodels/game_view_model.dart';
import '../widgets/cosmic_widgets.dart';

Future<void> purchaseEgg(
  BuildContext context,
  GameViewModel vm, {
  bool chooseSeries = false,
  int? selectedSeries,
}) async {
  int? series = selectedSeries;
  if (chooseSeries) {
    series = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l10n.collectionChooseSeries),
        children: [
          for (var s = 0; s < 6; s++)
            SimpleDialogOption(
              onPressed: vm.seriesCount(s) == 7
                  ? null
                  : () => Navigator.pop(context, s),
              child: Row(
                children: [
                  PlanetOrb(s * 7, size: 48),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      vm.seriesCount(s) == 7
                          ? context.l10n.collectionSeriesComplete(
                              seriesName(context, s),
                            )
                          : context.l10n.collectionSeriesProgress(
                              seriesName(context, s),
                              vm.seriesCount(s),
                            ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
    if (series == null || !context.mounted) return;
  }
  final price = series == null ? vm.randomEggPrice : vm.seriesEggPrice;
  final remaining = series == null
      ? 42 - vm.planets.length
      : 7 - vm.seriesCount(series);
  if (remaining == 0 ||
      vm.coins < price ||
      vm.phase != EventPhase.active ||
      !vm.checkedIn) {
    return;
  }
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(
        series == null
            ? context.l10n.collectionBuyRandomTitle
            : context.l10n.collectionBuySeriesTitle(
                seriesName(context, series),
              ),
      ),
      content: Text(
        series == null
            ? context.l10n.collectionRandomConfirmation(
                remaining,
                price,
                vm.coins - price,
              )
            : context.l10n.collectionSeriesConfirmation(
                remaining,
                price,
                vm.coins - price,
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        FilledButton(
          key: const ValueKey('egg-confirm'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.collectionConfirmPurchase),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final result = await vm.buyEgg(series: series);
  if (result != null && context.mounted) {
    // Keep the game shell, not the shop or earlier hatch results, under this result.
    await Navigator.of(context).pushAndRemoveUntil<void>(
      MaterialPageRoute(builder: (_) => HatchView(vm: vm, result: result)),
      (route) => route.isFirst,
    );
  }
}

class EggShop extends StatelessWidget {
  const EggShop({super.key, required this.vm});
  final GameViewModel vm;
  String? reason(BuildContext context, int price) => !vm.checkedIn
      ? context.l10n.collectionCheckInFirst
      : vm.phase != EventPhase.active
      ? context.l10n.collectionShopActiveOnly
      : vm.planets.length == 42
      ? context.l10n.collectionAllPlanets
      : vm.coins < price
      ? context.l10n.collectionMissingCoins(price - vm.coins)
      : null;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 16,
    children: [
      ReasonButton(
        key: const ValueKey('egg-random'),
        label: context.l10n.collectionRandomEggPrice(vm.randomEggPrice),
        icon: Icons.egg_outlined,
        reason: reason(context, vm.randomEggPrice),
        onPressed: vm.busy ? null : () => purchaseEgg(context, vm),
      ),
      ReasonButton(
        key: const ValueKey('egg-series'),
        label: context.l10n.collectionSeriesEggPrice(vm.seriesEggPrice),
        icon: Icons.auto_awesome,
        reason: reason(context, vm.seriesEggPrice),
        onPressed: vm.busy
            ? null
            : () => purchaseEgg(context, vm, chooseSeries: true),
      ),
    ],
  );
}

class CollectionView extends StatelessWidget {
  const CollectionView({super.key, required this.vm, this.appearance = false});
  final GameViewModel vm;
  final bool appearance;
  @override
  Widget build(BuildContext context) => CosmicPage(
    title: appearance
        ? context.l10n.collectionAppearance
        : context.l10n.collectionTitle,
    vm: vm,
    builder: (context) => ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          context.l10n.collectionPlanetProgress(vm.planets.length),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(context.l10n.collectionCompletedSeries(vm.completeSeries)),
        const SizedBox(height: 16),
        ListTile(
          leading: const PlanetOrb(null, size: 56),
          title: Text(context.l10n.baseCard),
          subtitle: Text(context.l10n.collectionBaseCardDescription),
          trailing: vm.me.planet == null
              ? const Icon(Icons.check_circle)
              : null,
          onTap: vm.busy ? null : () => vm.appearance(null, vm.me.style),
        ),
        for (var s = 0; s < 6; s++)
          Section(
            vm.seriesCount(s) == 7
                ? context.l10n.collectionSeriesComplete(seriesName(context, s))
                : context.l10n.collectionSeriesProgress(
                    seriesName(context, s),
                    vm.seriesCount(s),
                  ),
            child: Wrap(
              spacing: 4,
              runSpacing: 12,
              children: [
                for (var c = 0; c < 7; c++)
                  Builder(
                    builder: (context) {
                      final p = s * 7 + c;
                      final owned = vm.planets.contains(p);
                      return SizedBox(
                        width: 88,
                        child: InkWell(
                          key: ValueKey('planet-$p'),
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(planetName(context, p)),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PlanetOrb(p, size: 160, locked: !owned),
                                  Text(
                                    owned
                                        ? context.l10n.collectionAcquiredAt(
                                            stamp(context, vm.planetDates[p]),
                                          )
                                        : context.l10n.collectionPlanetLocked(
                                            seriesName(context, s),
                                          ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dialogContext),
                                  child: Text(context.l10n.close),
                                ),
                                if (owned)
                                  FilledButton(
                                    onPressed: vm.busy
                                        ? null
                                        : () async {
                                            await vm.appearance(p, vm.me.style);
                                            if (dialogContext.mounted) {
                                              Navigator.pop(dialogContext);
                                            }
                                          },
                                    child: Text(
                                      context.l10n.collectionSetRepresentative,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              PlanetOrb(p, size: 72, locked: !owned),
                              Text(
                                '${colorName(context, c)}${vm.me.planet == p
                                    ? ' ✓'
                                    : owned
                                    ? ''
                                    : ' 🔒'}',
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        const SizedBox(height: 16),
        Section(
          context.l10n.collectionCardStyles,
          icon: Icons.style_outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    key: const ValueKey('style-default'),
                    label: Text(context.l10n.collectionDefaultStyle),
                    selected: vm.me.style == -1,
                    onSelected: vm.busy
                        ? null
                        : (_) => vm.appearance(vm.me.planet, -1),
                  ),
                  for (var s = 0; s < 6; s++)
                    Tooltip(
                      message: vm.seriesCount(s) == 7
                          ? context.l10n.collectionApplyStyle(
                              seriesName(context, s),
                            )
                          : context.l10n.collectionUnlockStyle(
                              seriesName(context, s),
                            ),
                      child: ChoiceChip(
                        key: ValueKey('style-$s'),
                        label: Text(
                          '${vm.seriesCount(s) == 7 ? '' : '🔒 '}${seriesName(context, s)}',
                        ),
                        selected: vm.me.style == s,
                        onSelected: vm.seriesCount(s) == 7 && !vm.busy
                            ? (_) => vm.appearance(vm.me.planet, s)
                            : null,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Section(context.l10n.collectionShopTitle, child: EggShop(vm: vm)),
        const SizedBox(height: 32),
      ],
    ),
  );
}

class HatchView extends StatefulWidget {
  const HatchView({super.key, required this.vm, required this.result});
  final GameViewModel vm;
  final HatchResult result;
  @override
  State<HatchView> createState() => _HatchViewState();
}

class _HatchViewState extends State<HatchView> {
  bool revealed = false;
  int specialRevealed = 0;
  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final series = result.planet ~/ 7;
    final reduced = MediaQuery.disableAnimationsOf(context);
    return CosmicPage(
      title: context.l10n.collectionHatchTitle,
      vm: widget.vm,
      builder: (context) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Center(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: reduced ? 0 : 600),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: revealed
                  ? PlanetOrb(
                      result.planet,
                      key: const ValueKey('hatched'),
                      size: 220,
                    )
                  : Icon(
                      Icons.egg_outlined,
                      key: const ValueKey('egg'),
                      size: 180,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
          ),
          const SizedBox(height: 24),
          if (!revealed) ...[
            FilledButton(
              key: const ValueKey('hatch-reveal'),
              onPressed: () => setState(() => revealed = true),
              child: Text(context.l10n.collectionRevealEgg),
            ),
          ] else ...[
            Text(
              planetName(context, result.planet),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: widget.vm.busy
                  ? null
                  : () =>
                        widget.vm.appearance(result.planet, widget.vm.me.style),
              child: Text(
                widget.vm.me.planet == result.planet
                    ? context.l10n.collectionRepresentativeSelected
                    : context.l10n.collectionSetRepresentative,
              ),
            ),
            if (result.seriesCompleted) ...[
              const SizedBox(height: 24),
              Section(
                context.l10n.collectionSeriesComplete(
                  seriesName(context, series),
                ),
                icon: Icons.celebration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        for (var c = 0; c < 7; c++)
                          PlanetOrb(series * 7 + c, size: 48),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(context.l10n.collectionSeriesRewards),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (var i = 0; i < 2; i++)
                          RevealCard(
                            key: ValueKey('special-reveal-$i'),
                            special: true,
                            revealed: (specialRevealed & (1 << i)) != 0,
                            icon: i == 0
                                ? Icons.auto_awesome
                                : Icons.visibility,
                            label: i == 0
                                ? context.l10n.collectionWildReward
                                : context.l10n.collectionPeekReward,
                            onTap: () =>
                                setState(() => specialRevealed |= 1 << i),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    FilledButton.tonal(
                      onPressed: () => openPage(
                        context,
                        CollectionView(vm: widget.vm, appearance: true),
                      ),
                      child: Text(context.l10n.collectionChangeStyle),
                    ),
                    if (specialRevealed == 3)
                      FilledButton(
                        onPressed: widget.vm.packs > 0
                            ? () => openPage(context, PackView(vm: widget.vm))
                            : null,
                        child: Text(context.l10n.collectionOpenRewardPack),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            ReasonButton(
              key: const ValueKey('hatch-again'),
              label: context.l10n.collectionBuyAnotherEgg,
              icon: Icons.egg_outlined,
              reason: widget.vm.phase != EventPhase.active
                  ? context.l10n.collectionShopClosed
                  : widget.vm.planets.length == 42
                  ? context.l10n.collectionAllPlanets
                  : widget.vm.coins < widget.vm.randomEggPrice
                  ? context.l10n.collectionMissingCoins(
                      widget.vm.randomEggPrice - widget.vm.coins,
                    )
                  : null,
              onPressed: widget.vm.busy
                  ? null
                  : () => purchaseEgg(context, widget.vm),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.l10n.back),
            ),
          ],
        ],
      ),
    );
  }
}

class PackView extends StatefulWidget {
  const PackView({super.key, required this.vm});
  final GameViewModel vm;
  @override
  State<PackView> createState() => _PackViewState();
}

class _PackViewState extends State<PackView> {
  List<HandCard>? cards;
  int revealed = 0;
  int selectedPack = 0;
  bool overview = false;
  bool sliding = false;
  double tear = 0;
  List<int> before = [];
  Future<void> open({bool all = false, bool skip = false}) async {
    if (widget.vm.busy) return;
    if (cards != null) {
      setState(() {
        revealed = cards!.length;
        overview = true;
      });
      return;
    }
    before = List.of(widget.vm.hand);
    setState(() => sliding = true);
    final result = await widget.vm.openPacks(all: all);
    if (!mounted) return;
    setState(() {
      sliding = false;
      tear = 0;
      if (result != null) {
        cards = result;
        overview = all || skip;
        revealed = overview ? result.length : 0;
      }
    });
  }

  void next() {
    if (cards == null) {
      open();
      return;
    }
    setState(() {
      if (revealed < cards!.length) {
        revealed++;
      } else {
        overview = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) => CosmicPage(
    title: context.l10n.collectionPacksTitle,
    vm: widget.vm,
    builder: (context) {
      final reduced = MediaQuery.disableAnimationsOf(context);
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.collectionUnopenedPacks(widget.vm.packs),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              if (!overview)
                TextButton(
                  key: const ValueKey('pack-skip'),
                  onPressed: sliding ? null : () => open(skip: true),
                  child: Text(context.l10n.collectionSkipAnimation),
                ),
            ],
          ),
          const SizedBox(height: 24),
          if (cards == null) ...[
            Text(
              context.l10n.collectionPackContents,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            if (widget.vm.packs > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: context.l10n.collectionPreviousPack,
                    onPressed: () => setState(
                      () => selectedPack = (selectedPack - 1) % widget.vm.packs,
                    ),
                    icon: const Icon(Icons.chevron_left),
                  ),
                  Text(
                    context.l10n.collectionPackPosition(
                      selectedPack + 1,
                      widget.vm.packs,
                    ),
                  ),
                  IconButton(
                    tooltip: context.l10n.collectionNextPack,
                    onPressed: () => setState(
                      () => selectedPack = (selectedPack + 1) % widget.vm.packs,
                    ),
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
              Semantics(
                button: true,
                label: context.l10n.collectionOpenPackSemantics,
                child: GestureDetector(
                  key: const ValueKey('pack-tear'),
                  onTap: sliding ? null : () => open(),
                  onHorizontalDragUpdate: sliding
                      ? null
                      : (d) => setState(
                          () => tear = (tear + d.delta.dx).clamp(0, 240),
                        ),
                  onHorizontalDragEnd: sliding
                      ? null
                      : (_) {
                          if (tear > 120) {
                            open();
                          } else {
                            setState(() => tear = 0);
                          }
                        },
                  child: Center(
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: reduced ? 0 : 250),
                      transform: Matrix4.rotationZ(tear / 5000),
                      width: 240,
                      height: 300,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [navy, Color(0xFF34436E)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: sky, width: 2),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          LinearProgressIndicator(
                            value: tear / 240,
                            color: pink,
                            backgroundColor: Colors.white24,
                          ),
                          const Icon(Icons.auto_awesome, color: sky, size: 88),
                          Text(
                            context.l10n.collectionPackBrand,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                          if (sliding)
                            const CircularProgressIndicator(color: pink)
                          else
                            Text(
                              context.l10n.collectionTearRight,
                              style: const TextStyle(color: pink),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                key: const ValueKey('pack-open'),
                onPressed: sliding ? null : () => open(),
                child: Text(context.l10n.collectionOpenPack),
              ),
              OutlinedButton(
                key: const ValueKey('pack-open-all'),
                onPressed: sliding ? null : () => open(all: true),
                child: Text(
                  context.l10n.collectionOpenAllPacks(widget.vm.packs),
                ),
              ),
            ] else
              Center(child: Text(context.l10n.collectionNoPacks)),
          ] else ...[
            Text(
              overview
                  ? context.l10n.collectionCardsAdded
                  : revealed == 0
                  ? context.l10n.collectionRevealCards
                  : context.l10n.collectionCardsRevealed(revealed),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onVerticalDragEnd: overview
                  ? null
                  : (details) {
                      if ((details.primaryVelocity ?? 0) < 0) next();
                    },
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1, end: 0),
                duration: Duration(milliseconds: reduced ? 0 : 400),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) => Transform.translate(
                  offset: Offset(0, value * 64),
                  child: child,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < cards!.length; i++)
                      RevealCard(
                        key: ValueKey('pack-card-$i'),
                        revealed: i < revealed,
                        label: handName(context, cards![i].index),
                        icon: handIcon(cards![i].index),
                        onTap: overview ? null : next,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (!overview)
              FilledButton(
                key: const ValueKey('pack-next'),
                onPressed: next,
                child: Text(
                  revealed == cards!.length
                      ? context.l10n.collectionAddToHand
                      : revealed == cards!.length - 1
                      ? context.l10n.collectionRevealLastCard
                      : context.l10n.collectionRevealNextCard,
                ),
              )
            else ...[
              Section(
                context.l10n.collectionPacksOpened(cards!.length ~/ 3),
                child: Column(
                  children: [
                    for (var i = 0; i < 3; i++)
                      ListTile(
                        leading: Icon(handIcon(i)),
                        title: Text(handName(context, i)),
                        trailing: Text(
                          context.l10n.collectionHandChange(
                            before[i],
                            before[i] +
                                cards!.where((c) => c.index == i).length,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              FilledButton(
                key: const ValueKey('pack-done'),
                onPressed: () => Navigator.pop(context),
                child: Text(context.l10n.done),
              ),
              if (widget.vm.packs > 0)
                OutlinedButton(
                  key: const ValueKey('pack-reopen'),
                  onPressed: () => setState(() {
                    cards = null;
                    revealed = 0;
                    overview = false;
                    selectedPack = 0;
                  }),
                  child: Text(context.l10n.collectionOpenAnotherPack),
                ),
            ],
          ],
          const SizedBox(height: 24),
        ],
      );
    },
  );
}
