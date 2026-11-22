import 'package:flutter/material.dart';

import 'package:sitcon_backend/game/game_service.dart';

import 'l10n/localization.dart';
import 'services/preferences/app_locale_settings.dart';
import 'services/preferences/test_server_settings.dart';
import 'services/game/mock_game_service.dart';
import 'services/game/device_sessions.dart';
import 'services/game/http_game_service.dart';
import 'services/nfc/scan_route_observer.dart';
import 'viewmodels/game_view_model.dart';
import 'views/home_view.dart';
import 'widgets/cosmic_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appLocaleSettings.load();
  runApp(AppStartup(serverSettings: await TestServerSettings.load()));
}

ThemeData expressiveTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: navy, brightness: brightness);
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);
  return base.copyWith(
    scaffoldBackgroundColor: scheme.surface,
    textTheme: base.textTheme.copyWith(
      displayLarge: base.textTheme.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
      ),
      displayMedium: base.textTheme.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1.5,
      ),
      displaySmall: base.textTheme.displaySmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -1,
      ),
      headlineLarge: base.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: base.textTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      headlineSmall: base.textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      labelLarge: base.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: scheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ExpressiveShape.panel),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ExpressiveShape.control),
      ),
      contentPadding: const EdgeInsets.all(16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
    ),
    chipTheme: base.chipTheme.copyWith(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ExpressiveShape.control),
      ),
      side: BorderSide.none,
      selectedColor: scheme.secondaryContainer,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: scheme.surfaceContainer,
      indicatorColor: scheme.secondaryContainer,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => TextStyle(
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w800
              : FontWeight.w500,
        ),
      ),
    ),
  );
}

enum AppMode { demo, server }

class AppStartup extends StatefulWidget {
  const AppStartup({
    super.key,
    this.initialMode = const String.fromEnvironment('APP_MODE'),
    this.serviceFactory,
    this.serverSettings,
    this.serverUrls = const String.fromEnvironment('TEST_SERVER_URLS'),
  });
  final String initialMode;
  final Future<GameService> Function(AppMode)? serviceFactory;
  final TestServerSettings? serverSettings;
  final String serverUrls;

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  GameService? service;
  AppMode? mode;
  Object? error;
  bool connecting = false;
  static const defaultServerUrl = 'http://127.0.0.1:8787';
  static const configuredServerUrl = String.fromEnvironment('API_BASE_URL');
  late final configuredOrigin = testServerOrigin(configuredServerUrl)
      ?.toString();
  late final List<String> serverPresets = _buildServerPresets();

  List<String> _buildServerPresets() {
    final urls = {
      for (final value in widget.serverUrls.split(','))
        if (testServerOrigin(value) case final origin?) origin.toString(),
      ?configuredOrigin,
    };
    return urls.isEmpty ? [defaultServerUrl] : urls.toList();
  }

  late final serverUrl = TextEditingController(
    text:
        widget.serverSettings?.lastUrl ??
        configuredOrigin ??
        serverPresets.first,
  );
  final serverForm = GlobalKey<FormState>();
  late final deviceSessions = DeviceSessions.secure();

  bool get validServerUrl => testServerOrigin(serverUrl.text) != null;

  void chooseEnvironment() {
    final previous = service;
    setState(() {
      service = null;
      mode = null;
      error = null;
    });
    previous?.dispose();
  }

  void connect() {
    if (serverForm.currentState?.validate() == true) {
      open(AppMode.server, rememberUrl: true);
    }
  }

  Future<void> enterTransfer(BuildContext context) async {
    if (connecting || serverForm.currentState?.validate() != true) return;
    String code = '';
    final submitted = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        scrollable: true,
        title: Text(dialogContext.l10n.deviceTransferIn),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(dialogContext.l10n.deviceTransferWarning),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('startup-transfer-code'),
              autocorrect: false,
              enableSuggestions: false,
              enableIMEPersonalizedLearning: false,
              decoration: InputDecoration(
                labelText: dialogContext.l10n.deviceTransferCode,
                helperText: dialogContext.l10n.deviceTransferResume,
                helperMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => code = value.trim(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(dialogContext.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, code),
            child: Text(dialogContext.l10n.deviceTransferIn),
          ),
        ],
      ),
    );
    if (!mounted || submitted == null) return;
    await open(AppMode.server, rememberUrl: true, transferCode: submitted);
  }

  @override
  void initState() {
    super.initState();
    switch (widget.initialMode) {
      case 'demo':
        open(AppMode.demo);
      case 'server':
        open(AppMode.server);
      case '':
        break;
      default:
        error = widget.initialMode;
    }
  }

  Future<void> open(
    AppMode selected, {
    bool rememberUrl = false,
    String? transferCode,
  }) async {
    if (connecting) return;
    final origin = selected == AppMode.server
        ? testServerOrigin(serverUrl.text)
        : null;
    if (selected == AppMode.server && origin == null) return;
    setState(() {
      mode = selected;
      connecting = true;
      error = null;
    });
    GameService? next;
    try {
      if (rememberUrl && origin != null) {
        await widget.serverSettings?.remember(origin);
      }
      next = widget.serviceFactory != null
          ? await widget.serviceFactory!(selected)
          : selected == AppMode.demo
          ? await MockGameService.open()
          : await deviceSessions.open(origin!.toString(), transferCode: transferCode);
      await next.initialize();
      if (!mounted) {
        next.dispose();
        return;
      }
      if (next case final HttpGameService connected) {
        connected.onSessionRevoked = (failure) {
          Future<void>(() {
            if (!mounted || !identical(service, connected)) return;
            setState(() {
              service = null;
              mode = AppMode.server;
              error = failure;
            });
            connected.dispose();
          });
        };
      }
      setState(() {
        service = next;
        connecting = false;
      });
    } catch (e) {
      next?.dispose();
      if (!mounted) return;
      setState(() {
        connecting = false;
        error = e;
      });
    }
  }

  @override
  void dispose() {
    serverUrl.dispose();
    service?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (service != null) {
      return SitconApp(
        service: service!,
        onChooseEnvironment: chooseEnvironment,
      );
    }
    final offline = mode == AppMode.demo;
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: appLocaleSettings,
      builder: (context, _, child) => MaterialApp(
        onGenerateTitle: (context) => context.l10n.appTitle,
        locale: appLocaleSettings.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: expressiveTheme(Brightness.light),
        darkTheme: expressiveTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        home: Builder(
          builder: (context) => Scaffold(
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.l10n.appTitle,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 24),
                        if (mode != null)
                          GameEnvironmentBanner(offline: offline),
                        if (connecting) ...[
                          const SizedBox(height: 16),
                          const LinearProgressIndicator(),
                          Text(context.l10n.loading),
                        ] else ...[
                          if (error != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              mode == null
                                  ? context.l10n.shellUnsupportedMode(
                                      widget.initialMode,
                                    )
                                  : gameText(context, error),
                              key: const ValueKey('startup-error'),
                            ),
                          ],
                          if (mode != AppMode.demo) ...[
                            const SizedBox(height: 16),
                            Form(
                              key: serverForm,
                              child: TextFormField(
                                key: const ValueKey('test-server-url'),
                                controller: serverUrl,
                                keyboardType: TextInputType.url,
                                autocorrect: false,
                                enableSuggestions: false,
                                decoration: InputDecoration(
                                  labelText: context.l10n.shellServerUrl,
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (_) => validServerUrl
                                    ? null
                                    : context.l10n.shellInvalidServerUrl,
                                onFieldSubmitted: (_) => connect(),
                              ),
                            ),
                            if (serverPresets.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                children: [
                                  for (final url in serverPresets)
                                    ActionChip(
                                      label: Text(url),
                                      onPressed: () => serverUrl.text = url,
                                    ),
                                ],
                              ),
                            if (widget.serviceFactory == null)
                              TextButton.icon(
                                key: const ValueKey('startup-transfer'),
                                onPressed: () => enterTransfer(context),
                                icon: const Icon(Icons.swap_horiz),
                                label: Text(context.l10n.deviceTransferIn),
                              ),
                          ],
                          if (mode != null) ...[
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              key: const ValueKey('startup-retry'),
                              onPressed: offline
                                  ? () => open(AppMode.demo)
                                  : connect,
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(context.l10n.retry),
                            ),
                            TextButton(
                              key: const ValueKey('startup-choose-mode'),
                              onPressed: chooseEnvironment,
                              child: Text(context.l10n.shellChooseMode),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              key: const ValueKey('mode-demo'),
                              onPressed: () => open(AppMode.demo),
                              icon: const Icon(Icons.offline_bolt_rounded),
                              label: Text(context.l10n.shellOffline),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              key: const ValueKey('mode-server'),
                              onPressed: connect,
                              icon: const Icon(Icons.cloud_outlined),
                              label: Text(context.l10n.shellConnected),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SitconApp extends StatefulWidget {
  const SitconApp({super.key, required this.service, this.onChooseEnvironment});
  final GameService service;
  final VoidCallback? onChooseEnvironment;
  @override
  State<SitconApp> createState() => _SitconAppState();
}

class _SitconAppState extends State<SitconApp> {
  late GameViewModel vm;
  @override
  void initState() {
    super.initState();
    vm = GameViewModel(widget.service);
  }

  @override
  void didUpdateWidget(SitconApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.service != widget.service) {
      vm.dispose();
      vm = GameViewModel(widget.service);
    }
  }

  @override
  void dispose() {
    vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<AppLanguage>(
    valueListenable: appLocaleSettings,
    builder: (context, _, child) => MaterialApp(
      onGenerateTitle: (context) => context.l10n.appTitle,
      locale: appLocaleSettings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      theme: expressiveTheme(Brightness.light),
      darkTheme: expressiveTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      navigatorObservers: [scanRouteObserver],
      home: HomeView(
        key: ObjectKey(vm),
        vm: vm,
        onChooseEnvironment: widget.onChooseEnvironment,
        issueTransferCode: switch (widget.service) {
          final HttpGameService service when service.supportsDeviceTransfer =>
            service.issueTransferCode,
          _ => null,
        },
      ),
    ),
  );
}
