import 'package:flutter/material.dart';

import './lang/translations.i69n.dart';
import './lang/translations_he.i69n.dart';

const _supportedLocales = ['en', 'he'];

class ExampleLocalizations {
  final Translations translations;

  const ExampleLocalizations(this.translations);

  static final _translations = <String, Translations Function()>{
    'en': () => Translations(),
    'he': () => const Translations_he(),
  };

  static const LocalizationsDelegate<ExampleLocalizations> delegate =
      _ExampleLocalizationsDelegate();

  static final List<Locale> supportedLocales =
      _supportedLocales.map((x) => Locale(x)).toList();

  static Future<ExampleLocalizations> load(Locale locale) =>
      Future.value(ExampleLocalizations(_translations[locale.languageCode]()));

  static Translations of(BuildContext context) =>
      Localizations.of<ExampleLocalizations>(context, ExampleLocalizations)
          .translations;
}

class _ExampleLocalizationsDelegate
    extends LocalizationsDelegate<ExampleLocalizations> {
  const _ExampleLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      _supportedLocales.contains(locale.languageCode);

  @override
  Future<ExampleLocalizations> load(Locale locale) =>
      ExampleLocalizations.load(locale);

  @override
  bool shouldReload(LocalizationsDelegate<ExampleLocalizations> old) => false;
}
