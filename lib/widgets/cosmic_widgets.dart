import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import 'package:sitcon_backend/game/game_service.dart';

import '../l10n/localization.dart';
import '../viewmodels/game_view_model.dart';

const navy = Color(0xFF142559);
const sky = Color(0xFF68BCDF);
const pink = Color(0xFFF2D8E6);
const planetColors = [
  Color(0xFF75CBA2),
  Color(0xFFF1AACA),
  Color(0xFFFFAE74),
  Color(0xFFF6D875),
  Color(0xFF68BCDF),
  Color(0xFF547ACC),
  Color(0xFFB79BE7),
];

abstract final class ExpressiveShape {
  static const control = 20.0;
  static const panel = 28.0;
  static const feature = 32.0;
  static const hero = 48.0;
}

/// Spec-inspired press/selection motion, not an official Flutter M3E component.
class ExpressiveButton extends StatefulWidget {
  const ExpressiveButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.tonal = false,
    this.selected = false,
    this.groupEdge,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool tonal, selected;
  final bool? groupEdge;
  @override
  State<ExpressiveButton> createState() => _ExpressiveButtonState();
}

class _ExpressiveButtonState extends State<ExpressiveButton>
    with SingleTickerProviderStateMixin {
  late final motion = AnimationController.unbounded(vsync: this);
  bool get reduced => MediaQuery.disableAnimationsOf(context);
  void move(bool pressed) {
    final target = pressed ? 1.0 : 0.0;
    if (reduced) {
      motion.stop();
      motion.value = target;
    } else {
      motion.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 1, stiffness: 420, damping: 28),
          motion.value,
          target,
          motion.velocity,
        ),
      );
    }
  }

  @override
  void dispose() {
    motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null;
    final fill = !enabled
        ? colors.surfaceContainerHighest
        : widget.tonal
        ? colors.secondaryContainer
        : colors.primary;
    final foreground = !enabled
        ? colors.onSurfaceVariant
        : widget.tonal
        ? colors.onSecondaryContainer
        : colors.onPrimary;
    return AnimatedBuilder(
      animation: motion,
      builder: (context, _) {
        final amount = reduced ? 0.0 : motion.value.clamp(0.0, 1.2);
        final radius = widget.selected
            ? ExpressiveShape.hero
            : ExpressiveShape.panel;
        final outer = Radius.circular(
          radius + (ExpressiveShape.control - radius) * amount,
        );
        final inner = Radius.circular(8 + 12 * amount);
        final shape = widget.groupEdge == null
            ? BorderRadius.all(outer)
            : BorderRadius.horizontal(
                left: widget.groupEdge! ? outer : inner,
                right: widget.groupEdge! ? inner : outer,
              );
        return Transform.scale(
          scale: 1 - .035 * amount,
          child: Material(
            color: fill,
            borderRadius: shape,
            child: InkWell(
              borderRadius: shape,
              onTap: widget.onPressed,
              onHighlightChanged: move,
              child: AnimatedContainer(
                duration: reduced
                    ? Duration.zero
                    : const Duration(milliseconds: 200),
                constraints: const BoxConstraints(minHeight: 56, minWidth: 48),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, color: foreground),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(color: foreground),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

String planetName(BuildContext context, int? p) => p == null
    ? context.l10n.baseCard
    : '${seriesName(context, p ~/ 7)} · ${colorName(context, p % 7)}';
String stamp(BuildContext context, DateTime? time) {
  if (time == null) return context.l10n.notAcquired;
  final localizations = MaterialLocalizations.of(context);
  return '${localizations.formatShortDate(time)} ${localizations.formatTimeOfDay(TimeOfDay.fromDateTime(time), alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context))}';
}

String resultName(BuildContext context, int value) => value > 0
    ? context.l10n.win
    : value < 0
    ? context.l10n.loss
    : context.l10n.draw;
IconData handIcon(int i) => [
  Icons.content_cut_rounded,
  Icons.landscape_rounded,
  Icons.pan_tool_rounded,
  Icons.auto_awesome_rounded,
][i];

class CosmicPage extends StatelessWidget {
  const CosmicPage({
    super.key,
    required this.title,
    required this.vm,
    required this.builder,
    this.actions,
    this.bottom,
  });
  final String title;
  final GameViewModel vm;
  final Widget Function(BuildContext) builder;
  final List<Widget>? actions;
  final Widget? bottom;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: vm,
    builder: (context, _) => Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: SafeArea(
        child: Column(
          children: [
            GameEnvironmentBanner(offline: vm.isOfflineDemo),
            if (vm.busy) const LinearProgressIndicator(),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 840),
                  child: builder(context),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: bottom,
    ),
  );
}

class GameEnvironmentBanner extends StatelessWidget {
  const GameEnvironmentBanner({super.key, required this.offline});
  final bool offline;
  String label(BuildContext context) =>
      offline ? context.l10n.shellOffline : context.l10n.shellConnected;
  @override
  Widget build(BuildContext context) => Semantics(
    label: label(context),
    child: Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        label(context),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onTertiaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class Section extends StatelessWidget {
  const Section(
    this.title, {
    super.key,
    required this.child,
    this.action,
    this.icon,
  });
  final String title;
  final Widget child;
  final Widget? action;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => Card.filled(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ExpressiveShape.panel),
    ),
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ),
  );
}

class ReasonButton extends StatelessWidget {
  const ReasonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.reason,
    this.icon = Icons.arrow_forward_rounded,
  });
  final String label;
  final VoidCallback? onPressed;
  final String? reason;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      ExpressiveButton(
        onPressed: reason == null ? onPressed : null,
        icon: icon,
        label: label,
      ),
      if (reason != null)
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(reason!, style: Theme.of(context).textTheme.bodySmall),
        ),
    ],
  );
}

class PlanetOrb extends StatelessWidget {
  const PlanetOrb(
    this.planet, {
    super.key,
    this.size = 100,
    this.locked = false,
  });
  final int? planet;
  final double size;
  final bool locked;
  @override
  Widget build(BuildContext context) {
    final color = planet == null
        ? const Color(0xFF8B8C96)
        : planetColors[planet! % 7];
    return Semantics(
      label:
          '${planetName(context, planet)}${locked ? ' · ${context.l10n.locked}' : ''}',
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: _PlanetPainter(
            color,
            planet == null ? -1 : planet! ~/ 7,
            locked,
          ),
        ),
      ),
    );
  }
}

class _PlanetPainter extends CustomPainter {
  _PlanetPainter(this.color, this.series, this.locked);
  final Color color;
  final int series;
  final bool locked;
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final radius = size.width * .34;
    final rect = Rect.fromCircle(center: c, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-.5, -.6),
        colors: [
          Color.lerp(color, Colors.white, .45)!,
          color,
          Color.lerp(color, navy, .55)!,
        ],
      ).createShader(rect);
    if (locked) paint.color = color.withValues(alpha: .18);
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = Colors.white.withValues(alpha: locked ? .22 : 1),
    );
    canvas.drawCircle(c, radius, paint);
    final spots = Paint()..color = navy.withValues(alpha: .16);
    for (var i = 0; i < 4; i++) {
      final angle = i * 1.8 + series;
      canvas.drawCircle(
        c + Offset(math.cos(angle), math.sin(angle)) * radius * .5,
        radius * (.12 + i * .025),
        spots,
      );
    }
    if (series == 4) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(-.35);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 3.1,
          height: radius * .75,
        ),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = size.width * .07,
      );
      canvas.restore();
    }
    if (series == 0) {
      for (var i = 0; i < 12; i++) {
        final a = i * math.pi / 6;
        canvas.drawLine(
          c + Offset(math.cos(a), math.sin(a)) * radius * 1.12,
          c + Offset(math.cos(a), math.sin(a)) * radius * 1.3,
          Paint()
            ..color = color
            ..strokeWidth = size.width * .035
            ..strokeCap = StrokeCap.round,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PlanetPainter old) =>
      color != old.color || series != old.series || locked != old.locked;
}

class PlayerIdentity extends StatelessWidget {
  const PlayerIdentity(
    this.player, {
    super.key,
    this.compact = false,
    this.action,
  });
  final PlayerCard player;
  final bool compact;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(ExpressiveShape.feature),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.primaryContainer,
          Theme.of(context).colorScheme.secondaryContainer,
        ],
      ),
      border: Border.all(
        color: player.style < 0
            ? sky.withValues(alpha: .5)
            : planetColors[player.style % 7],
        width: 2,
      ),
    ),
    padding: EdgeInsets.all(compact ? 16 : 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.shellIdentity,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  letterSpacing: compact ? 1 : 2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ?action,
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            PlanetOrb(player.planet, size: compact ? 64 : 100),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    playerName(context, player),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    planetName(context, player.planet),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final role in player.roles)
              _IdentityTag(roleName(context, role), role: true),
            for (final tag in player.tags)
              _IdentityTag('#${tagName(context, tag)}'),
          ],
        ),
        if (playerContact(player) case final contact when contact.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: SelectableText(
              contact,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
      ],
    ),
  );
}

class _IdentityTag extends StatelessWidget {
  const _IdentityTag(this.text, {this.role = false});
  final String text;
  final bool role;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    decoration: BoxDecoration(
      color: role
          ? Theme.of(context).colorScheme.tertiaryContainer
          : Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(ExpressiveShape.control),
    ),
    child: Text(
      role ? '✓ $text' : text,
      style: TextStyle(
        color: role
            ? Theme.of(context).colorScheme.onTertiaryContainer
            : Theme.of(context).colorScheme.onSurface,
        fontSize: 12,
      ),
    ),
  );
}

class Countdown extends StatelessWidget {
  const Countdown({
    super.key,
    required this.seconds,
    required this.total,
    required this.label,
  });
  final int seconds, total;
  final String label;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: seconds <= 3,
    label: context.l10n.shellCountdown(label, seconds),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label · ${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: total <= 0 ? 0 : (seconds / total).clamp(0, 1),
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
        ),
      ],
    ),
  );
}

class StatTile extends StatelessWidget {
  const StatTile(this.label, this.value, this.icon, {super.key, this.onTap});
  final String label, value;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Card.filled(
    color: Theme.of(context).colorScheme.surfaceContainerHigh,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(ExpressiveShape.control),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(ExpressiveShape.control),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.displaySmall),
            Text(label),
            if (onTap != null)
              const Align(
                alignment: Alignment.centerRight,
                child: Icon(Icons.arrow_forward_rounded, size: 16),
              ),
          ],
        ),
      ),
    ),
  );
}

Future<T?> openPage<T>(BuildContext context, Widget page) =>
    Navigator.of(context).push<T>(MaterialPageRoute(builder: (_) => page));
Future<void> messageDialog(
  BuildContext context,
  String title,
  String message,
) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text(title),
    content: SingleChildScrollView(child: Text(message)),
    actions: [
      TextButton(
        key: const ValueKey('message-dismiss'),
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.close),
      ),
    ],
  ),
);

class RevealCard extends StatelessWidget {
  const RevealCard({
    super.key,
    required this.revealed,
    required this.label,
    required this.icon,
    this.onTap,
    this.special = false,
  });
  final bool revealed, special;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: onTap != null,
      label: revealed
          ? label
          : special
          ? context.l10n.shellRevealSpecial
          : context.l10n.shellRevealCard,
      child: ExcludeSemantics(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: revealed ? 1 : 0),
            duration: Duration(
              milliseconds: MediaQuery.disableAnimationsOf(context) ? 0 : 450,
            ),
            curve: Curves.easeInOutCubic,
            builder: (context, value, _) {
              final front = value >= .5;
              final angle = (value < .5 ? value : 1 - value) * math.pi;
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, .001)
                  ..rotateY(angle),
                child: Container(
                  width: 104,
                  constraints: BoxConstraints(
                    minHeight:
                        148 +
                        (MediaQuery.textScalerOf(context).scale(14) - 14).clamp(
                              0,
                              100,
                            ) *
                            4,
                  ),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: front
                        ? special
                              ? scheme.tertiaryContainer
                              : scheme.primaryContainer
                        : navy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: special ? pink : sky,
                      width: special ? 3 : 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        front ? icon : Icons.auto_awesome,
                        size: 40,
                        color: front
                            ? special
                                  ? scheme.onTertiaryContainer
                                  : scheme.onPrimaryContainer
                            : pink,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        front ? label : 'SITCON',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: front
                              ? special
                                    ? scheme.onTertiaryContainer
                                    : scheme.onPrimaryContainer
                              : Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
