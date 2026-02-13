import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/language_model.dart';
import '../models/translation_model.dart';

abstract class LanguageRepository {
  Future<List<LanguageModel>> getSupportedLanguagesAsync();
  Future<LanguageModel?> getUserLanguagePreferenceAsync();
  Future<void> saveUserLanguagePreferenceAsync(LanguageModel language);
  Future<TranslationModel> getTranslationsAsync(String languageCode);
  Future<void> forceRefreshAsync();
}

class LanguageRepositoryImpl implements LanguageRepository {
  final FirebaseRemoteConfig _remoteConfig;
  final SharedPreferences _prefs;

  static const String _languagePrefKey = 'selected_language';
  static const String _cachedTranslationsPrefix = 'cached_translations_';
  static const String _cachedLanguagesKey = 'cached_languages';

  LanguageRepositoryImpl({
    required FirebaseRemoteConfig remoteConfig,
    required SharedPreferences prefs,
  })  : _remoteConfig = remoteConfig,
        _prefs = prefs;

  @override
  Future<List<LanguageModel>> getSupportedLanguagesAsync() async {
    final languagesJson = _remoteConfig.getString('supported_languages');

    if (languagesJson.isNotEmpty) {
      final List<dynamic> languagesList = jsonDecode(languagesJson);
      final languages = languagesList
          .map((json) => LanguageModel.fromJson(json as Map<String, dynamic>))
          .where((lang) => lang.isEnabled)
          .toList();

      await _cacheLanguagesList(languages);
      return languages;
    }

    // Fallback to SharedPreferences cache
    final cached = _getCachedLanguagesList();
    if (cached != null) return cached;

    // Last resort: default languages
    return _getDefaultLanguages();
  }

  @override
  Future<LanguageModel?> getUserLanguagePreferenceAsync() async {
    final languageJson = _prefs.getString(_languagePrefKey);

    if (languageJson == null) return null;

    return LanguageModel.fromJson(
      jsonDecode(languageJson) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> saveUserLanguagePreferenceAsync(LanguageModel language) async {
    await _prefs.setString(
      _languagePrefKey,
      jsonEncode(language.toJson()),
    );
  }

  @override
  Future<TranslationModel> getTranslationsAsync(String languageCode) async {
    // Get from Remote Config (already cached, respects minimumFetchInterval)
    final translationsJson = _remoteConfig.getString('translations_$languageCode');
    final remoteVersion = _remoteConfig.getInt('translations_${languageCode}_version');

    if (translationsJson.isNotEmpty) {
      final translations = Map<String, dynamic>.from(
        jsonDecode(translationsJson) as Map,
      );

      final translationModel = TranslationModel(
        languageCode: languageCode,
        translations: translations,
        version: remoteVersion,
      );

      // Cache for offline use
      await _cacheTranslations(translationModel);
      return translationModel;
    }

    // Fallback to SharedPreferences cache
    final cached = await _getCachedTranslations(languageCode);
    if (cached != null) return cached;

    // No translations found
    return TranslationModel(
      languageCode: languageCode,
      translations: {},
      version: 1,
    );
  }

  @override
  Future<void> forceRefreshAsync() async {
    // Force fetch from Firebase (ignores minimumFetchInterval)
    await _remoteConfig.fetchAndActivate();
  }

  Future<void> _cacheTranslations(TranslationModel translation) async {
    await _prefs.setString(
      '$_cachedTranslationsPrefix${translation.languageCode}',
      jsonEncode(translation.toJson()),
    );
  }

  Future<TranslationModel?> _getCachedTranslations(String languageCode) async {
    final cachedJson = _prefs.getString('$_cachedTranslationsPrefix$languageCode');

    if (cachedJson == null) return null;

    return TranslationModel.fromJson(
      jsonDecode(cachedJson) as Map<String, dynamic>,
    );
  }

  Future<void> _cacheLanguagesList(List<LanguageModel> languages) async {
    await _prefs.setString(
      _cachedLanguagesKey,
      jsonEncode(languages.map((l) => l.toJson()).toList()),
    );
  }

  List<LanguageModel>? _getCachedLanguagesList() {
    final cachedJson = _prefs.getString(_cachedLanguagesKey);
    if (cachedJson == null) return null;

    final List<dynamic> languagesList = jsonDecode(cachedJson);
    return languagesList
        .map((json) => LanguageModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  List<LanguageModel> _getDefaultLanguages() {
    return const [
      LanguageModel(
        code: 'en',
        name: 'English',
        nativeName: 'English',
        flag: '🇺🇸',
      ),
    ];
  }
}
