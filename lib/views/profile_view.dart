import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sitcon_backend/game/game_service.dart';

import '../l10n/localization.dart';
import '../services/nfc/ntag_reader.dart';
import '../services/nfc/scan_route_observer.dart';

import 'package:sitcon_backend/testing/test_tag_ids.dart';

import '../viewmodels/game_view_model.dart';
import '../widgets/cosmic_widgets.dart';
import 'operator_widgets.dart';

class ProfileEditor extends StatefulWidget {
  const ProfileEditor({super.key, required this.vm, this.onboarding = false});
  final GameViewModel vm;
  final bool onboarding;
  @override
  State<ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<ProfileEditor> {
  late final name = TextEditingController(text: widget.vm.me.name);
  late final contact = TextEditingController(text: widget.vm.me.contact);
  late final tags = widget.vm.me.tags.toSet();
  @override
  void dispose() {
    name.dispose();
    contact.dispose();
    super.dispose();
  }

  bool get tagsLocked => widget.vm.me.tags.isNotEmpty;

  String? get invalid {
    if (name.text.trim().isEmpty) return context.l10n.shellNameRequired;
    if (tagsLocked) return null;
    for (final entry in hashtagOptions.entries) {
      final count = entry.value.where(tags.contains).length;
      if (count < 1 || count > 3) {
        return context.l10n.shellTagRange(categoryName(context, entry.key));
      }
    }
    for (final pair in opposingTags) {
      if (pair.every(tags.contains)) {
        return context.l10n.shellTagConflict(
          pair.map((tag) => tagName(context, tag)).join(' / '),
        );
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => CosmicPage(
    title: widget.onboarding
        ? context.l10n.shellCreateCard
        : context.l10n.shellEditCard,
    vm: widget.vm,
    builder: (context) => ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AccountRoleCard(vm: widget.vm),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('profile-nickname'),
          controller: name,
          onChanged: (_) => setState(() {}),
          maxLength: 32,
          decoration: InputDecoration(
            labelText: context.l10n.shellNickname,
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('profile-contact'),
          controller: contact,
          maxLength: 200,
          minLines: 1,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: context.l10n.shellContact,
            helperText: context.l10n.shellPublicContact,
          ),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          children: [
            for (final role in widget.vm.me.roles)
              Chip(
                avatar: const Icon(Icons.verified_outlined, size: 18),
                label: Text(roleName(context, role)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (tagsLocked) ...[
          Text(context.l10n.shellTagsLocked),
          Wrap(
            spacing: 8,
            children: [
              for (final tag in widget.vm.me.tags)
                Chip(label: Text('#${tagName(context, tag)}')),
            ],
          ),
        ] else
          Text(context.l10n.shellTagsHint),
        for (final entry in tagsLocked
            ? const <MapEntry<String, List<String>>>[]
            : hashtagOptions.entries) ...[
          const SizedBox(height: 24),
          Text(
            '${categoryName(context, entry.key)}  ${entry.value.where(tags.contains).length} / 3',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final tag in entry.value)
                Builder(
                  builder: (context) {
                    final selected = tags.contains(tag);
                    final opposite = opposingTags.any(
                      (pair) =>
                          pair.contains(tag) &&
                          pair.any(
                            (other) => other != tag && tags.contains(other),
                          ),
                    );
                    final full = entry.value.where(tags.contains).length >= 3;
                    return Tooltip(
                      message: opposite
                          ? context.l10n.shellOpposingTag
                          : full && !selected
                          ? context.l10n.shellTagLimit
                          : '#${tagName(context, tag)}',
                      child: FilterChip(
                        key: ValueKey('tag-$tag'),
                        label: Text('#${tagName(context, tag)}'),
                        selected: selected,
                        onSelected: opposite || full && !selected
                            ? null
                            : (value) => setState(() {
                                value ? tags.add(tag) : tags.remove(tag);
                              }),
                      ),
                    );
                  },
                ),
            ],
          ),
        ],
        const SizedBox(height: 24),
        ReasonButton(
          key: const ValueKey('profile-save'),
          label: widget.onboarding
              ? context.l10n.shellFinishCard
              : context.l10n.save,
          icon: Icons.check_rounded,
          reason: invalid,
          onPressed: widget.vm.busy
              ? null
              : () async {
                  final saved = await widget.vm.saveProfile(
                    tagsLocked ? widget.vm.me.tags : tags.toList(),
                    contact.text.trim(),
                    name.text.trim(),
                  );
                  if (saved && context.mounted) Navigator.pop(context, true);
                },
        ),
        const SizedBox(height: 32),
      ],
    ),
  );
}

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key, required this.vm});
  final GameViewModel vm;
  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with WidgetsBindingObserver, RouteAware {
  late final _reader = createNtagReader(
    promptProvider: () => context.l10n.domainNfcPrompt,
  );
  GameViewModel get vm => widget.vm;
  ModalRoute<dynamic>? _route;
  late final _testUid = TextEditingController(
    text: vm.badgeUid ?? (vm.isOfflineDemo ? TestTagIds.selfUid : ''),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route != _route) {
      scanRouteObserver.unsubscribe(this);
      _route = route;
      scanRouteObserver.subscribe(this, route);
    }
  }

  void _readerError(Object error, StackTrace stack) {
    if (mounted) {
      vm.reportError(error);
    } else {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stack),
      );
    }
  }

  @override
  void didPushNext() => unawaited(_reader.cancel().catchError(_readerError));

  @override
  void didPop() => unawaited(_reader.cancel().catchError(_readerError));

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      unawaited(_reader.cancel().catchError(_readerError));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scanRouteObserver.unsubscribe(this);
    unawaited(_reader.dispose().catchError(_readerError));
    _testUid.dispose();
    super.dispose();
  }

  Future<void> _bind(BuildContext context, String uid) async {
    await vm.bind(uid);
    if (vm.error == null && context.mounted) {
      await openPage(context, ProfileEditor(vm: vm, onboarding: true));
    }
  }

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      Text(
        context.l10n.shellCheckIn,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 16),
      Section(
        context.l10n.shellBindBadge,
        icon: Icons.contactless_rounded,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.shellBadgeHint),
            const SizedBox(height: 16),
            ReasonButton(
              key: const ValueKey('checkin-native'),
              label: context.l10n.shellScanBadge,
              icon: Icons.nfc,
              reason: vm.phase == EventPhase.before
                  ? context.l10n.shellCheckInNotOpen
                  : null,
              onPressed: vm.busy
                  ? null
                  : () async {
                      try {
                        final uid = await _reader.readUid();
                        if (uid != null && context.mounted) {
                          await _bind(context, uid);
                        }
                      } catch (e) {
                        if (mounted) vm.reportError(e);
                      }
                    },
            ),
            const SizedBox(height: 8),
            if (vm.testToolsEnabled) ...[
              TextField(
                key: const ValueKey('checkin-test-uid'),
                controller: _testUid,
                enabled: !vm.busy,
                autocorrect: false,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(labelText: context.l10n.socialUid),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const ValueKey('checkin-mock-bind'),
                onPressed: vm.phase == EventPhase.before || vm.busy
                    ? null
                    : () => _bind(context, _testUid.text.trim()),
                icon: const Icon(Icons.science_outlined),
                label: Text(context.l10n.shellTestCheckIn),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),
      EarlyBirdCard(vm: vm),
      const SizedBox(height: 32),
    ],
  );
}

class EarlyBirdCard extends StatelessWidget {
  const EarlyBirdCard({super.key, required this.vm});
  final GameViewModel vm;
  @override
  Widget build(BuildContext context) => Section(
    context.l10n.shellEarlyBird,
    icon: Icons.auto_awesome_outlined,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.shellEarlyHint),
        const SizedBox(height: 16),
        ReasonButton(
          key: const ValueKey('early-claim'),
          label: vm.earlyClaimed
              ? context.l10n.shellEarlyClaimed
              : context.l10n.shellEarlyClaim,
          icon: vm.earlyClaimed ? Icons.check_circle_outline : Icons.qr_code,
          reason: vm.earlyClaimed
              ? (vm.checkedIn && vm.phase != EventPhase.before
                    ? context.l10n.shellEarlyUnlocked
                    : context.l10n.shellEarlyLocked)
              : vm.phase != EventPhase.before
              ? context.l10n.shellEarlyClosed
              : null,
          onPressed: vm.busy ? null : vm.claimEarly,
        ),
      ],
    ),
  );
}

class TutorialView extends StatefulWidget {
  const TutorialView({super.key, required this.vm});
  final GameViewModel vm;
  @override
  State<TutorialView> createState() => _TutorialViewState();
}

class _TutorialViewState extends State<TutorialView> {
  int step = 0;
  List<(IconData, String, String)> get pages => [
    (
      Icons.contactless_rounded,
      context.l10n.scan,
      context.l10n.shellTutorialScan,
    ),
    (
      Icons.egg_outlined,
      context.l10n.planets,
      context.l10n.shellTutorialEggs(
        widget.vm.randomEggPrice,
        widget.vm.seriesEggPrice,
      ),
    ),
    (
      Icons.explore_outlined,
      context.l10n.tasks,
      context.l10n.shellTutorialTasks(widget.vm.parameters['missionCoins']!),
    ),
  ];
  Future<void> finish() async {
    await widget.vm.finishTutorial();
    if (mounted && widget.vm.tutorialSeen) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => CosmicPage(
    title: context.l10n.shellTutorialStep(step + 1),
    vm: widget.vm,
    builder: (context) => ListView(
      padding: const EdgeInsets.all(32),
      children: [
        const SizedBox(height: 48),
        Icon(
          pages[step].$1,
          size: 100,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 32),
        Text(pages[step].$2, style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Text(pages[step].$3, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 40),
        FilledButton(
          key: const ValueKey('tutorial-next'),
          onPressed: widget.vm.busy
              ? null
              : () {
                  if (step == 2) {
                    finish();
                  } else {
                    setState(() => step++);
                  }
                },
          child: Text(
            step == 2 ? context.l10n.shellStart : context.l10n.shellNext,
          ),
        ),
        TextButton(
          key: const ValueKey('tutorial-skip'),
          onPressed: widget.vm.busy ? null : finish,
          child: Text(context.l10n.shellSkipTutorial),
        ),
      ],
    ),
  );
}
