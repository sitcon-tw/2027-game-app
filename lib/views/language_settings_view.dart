import 'package:flutter/material.dart';

import '../l10n/localization.dart';
import '../services/preferences/app_locale_settings.dart';

class LanguageSettingsView extends StatefulWidget {
  const LanguageSettingsView({super.key, this.settings});
  final AppLocaleSettings? settings;

  @override
  State<LanguageSettingsView> createState() => _LanguageSettingsViewState();
}

class _LanguageSettingsViewState extends State<LanguageSettingsView> {
  bool _saving = false;
  AppLocaleSettings get settings => widget.settings ?? appLocaleSettings;

  Future<void> _select(AppLanguage language) async {
    if (_saving) return;
    setState(() => _saving = true);
    ScaffoldMessenger.of(context).clearSnackBars();
    try {
      await settings.setLanguage(language);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(gameText(context, error))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.language)),
    body: SafeArea(
      child: ValueListenableBuilder<AppLanguage>(
        valueListenable: settings,
        builder: (context, language, _) => RadioGroup<AppLanguage>(
          groupValue: language,
          onChanged: (value) {
            if (value != null) _select(value);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              for (final option in AppLanguage.values)
                RadioListTile<AppLanguage>(
                  key: ValueKey('language-${option.name}'),
                  value: option,
                  enabled: !_saving,
                  title: Text(switch (option) {
                    AppLanguage.system => context.l10n.languageSystem,
                    AppLanguage.zhTw => context.l10n.languageTraditionalChinese,
                    AppLanguage.en => context.l10n.languageEnglish,
                  }),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
