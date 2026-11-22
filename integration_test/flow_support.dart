import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder keyed(String key) => find.byKey(ValueKey<String>(key));

Future<void> waitFor(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 80; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  expect(finder, findsWidgets, reason: 'Required flow control did not appear');
}

Future<Finder> findControl(WidgetTester tester, String key) async {
  final matches = keyed(key);
  for (var attempt = 0; attempt < 10 && matches.evaluate().isEmpty; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  if (matches.evaluate().isEmpty) {
    final vertical = find.byElementPredicate((element) {
      final widget = element.widget;
      if (widget is! Scrollable ||
          (widget.axisDirection != AxisDirection.down &&
              widget.axisDirection != AxisDirection.up)) {
        return false;
      }
      final state = (element as StatefulElement).state as ScrollableState;
      return state.position.hasContentDimensions &&
          state.position.maxScrollExtent > 0;
    }).hitTestable();
    expect(
      vertical,
      findsWidgets,
      reason: 'Scrollable containing $key must exist',
    );
    final scroller = vertical.first;
    tester.state<ScrollableState>(scroller).position.jumpTo(0);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.scrollUntilVisible(
      matches,
      300,
      scrollable: scroller,
      maxScrolls: 30,
    );
  }
  await waitFor(tester, matches);
  return matches.first;
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final finder = await findControl(tester, key);
  final buttons = find.descendant(
    of: finder,
    matching: find.byWidgetPredicate((widget) => widget is ButtonStyleButton),
  );
  final ink = find.descendant(of: finder, matching: find.byType(InkWell));
  final target = buttons.evaluate().isNotEmpty
      ? buttons.first
      : ink.evaluate().isNotEmpty
      ? ink.first
      : finder;
  final widget = tester.widget(target);
  if (widget is ButtonStyleButton) {
    expect(widget.onPressed, isNotNull, reason: '$key must be enabled');
  }
  if (widget is InkWell) {
    expect(widget.onTap, isNotNull, reason: '$key must be enabled');
  }
  await Scrollable.ensureVisible(tester.element(target), alignment: 0.5);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.tap(target);
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 10),
  );
  expect(
    tester.takeException(),
    isNull,
    reason: 'No rendering or application errors after $key',
  );
}

Future<void> dismissRewards(WidgetTester tester) async {
  for (var count = 0; count < 30; count++) {
    await tester.pump(const Duration(milliseconds: 300));
    String? dismissKey;
    for (final candidate in [
      'reward-dismiss',
      'scan-result-dismiss',
      'message-dismiss',
    ]) {
      if (keyed(candidate).hitTestable().evaluate().isNotEmpty) {
        dismissKey = candidate;
        break;
      }
    }
    if (dismissKey == null) return;
    await tapKey(tester, dismissKey);
  }
  fail('Reward queue did not drain');
}

Future<void> back(WidgetTester tester) async {
  final navigator = tester.state<NavigatorState>(find.byType(Navigator).first);
  expect(navigator.canPop(), isTrue);
  navigator.pop();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle(
    const Duration(milliseconds: 100),
    EnginePhase.sendSemanticsUpdate,
    const Duration(seconds: 10),
  );
}
