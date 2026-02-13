import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/language_model.dart';
import '../../models/translation_model.dart';
import '../../repositories/language_repository.dart';

class LanguageState extends Equatable {
  final LanguageModel? currentLanguage;
  final List<LanguageModel> supportedLanguages;
  final TranslationModel? currentTranslations;
  final bool isLoading;

  const LanguageState({
    this.currentLanguage,
    this.supportedLanguages = const [],
    this.currentTranslations,
    this.isLoading = false,
  });

  LanguageState copyWith({
    LanguageModel? currentLanguage,
    List<LanguageModel>? supportedLanguages,
    TranslationModel? currentTranslations,
    bool? isLoading,
  }) {
    return LanguageState(
      currentLanguage: currentLanguage ?? this.currentLanguage,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      currentTranslations: currentTranslations ?? this.currentTranslations,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [currentLanguage, supportedLanguages, currentTranslations, isLoading];
}

class LanguageCubit extends Cubit<LanguageState> {
  final LanguageRepository _repository;

  LanguageCubit(this._repository) : super(const LanguageState()) {
    initializeAsync();
  }

  Future<void> initializeAsync() async {
    emit(state.copyWith(isLoading: true));

    final supportedLanguages = await _repository.getSupportedLanguagesAsync();
    final userPreference = await _repository.getUserLanguagePreferenceAsync();
    final selectedLanguage = userPreference ?? supportedLanguages.first;
    final translations = await _repository.getTranslationsAsync(selectedLanguage.code);

    emit(state.copyWith(
      supportedLanguages: supportedLanguages,
      currentLanguage: selectedLanguage,
      currentTranslations: translations,
      isLoading: false,
    ));
  }

  Future<void> changeLanguageAsync(LanguageModel language) async {
    await _repository.saveUserLanguagePreferenceAsync(language);
    emit(state.copyWith(currentLanguage: language));

    final translations = await _repository.getTranslationsAsync(language.code);
    emit(state.copyWith(currentTranslations: translations));
  }

  Future<void> forceRefreshAsync() async {
    emit(state.copyWith(isLoading: true));

    await _repository.forceRefreshAsync();
    await initializeAsync();
  }

  String translate(String path, {Map<String, dynamic>? params, String? fallback}) {
    return state.currentTranslations?.translate(
      path,
      params: params,
      fallback: fallback,
    ) ?? fallback ?? path;
  }

  Locale get currentLocale {
    final code = state.currentLanguage?.code ?? 'en';
    return Locale(code);
  }

  TextDirection get textDirection {
    return state.currentLanguage?.isRTL ?? false
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}

// ==================== Translation Extension ====================
extension TranslationExtension on BuildContext {
  String tr(String path, {Map<String, dynamic>? params, String? fallback}) {
    return read<LanguageCubit>().translate(
      path,
      params: params,
      fallback: fallback,
    );
  }

  LanguageCubit get language => read<LanguageCubit>();

  String? get currentFontFamily =>
      read<LanguageCubit>().state.currentLanguage?.fontFamily;

  String get currentLanguageCode =>
      read<LanguageCubit>().state.currentLanguage?.code ?? 'en';
}

// ==================== Language Cubit Extensions ====================
extension LanguageCubitExtension on LanguageCubit {
  List<LanguageModel> get supportedLanguages => state.supportedLanguages;

  LanguageModel? get currentLanguage => state.currentLanguage;

  bool get isLoading => state.isLoading;

  LanguageModel? findLanguageByCode(String code) {
    return state.supportedLanguages.where((lang) => lang.code == code).firstOrNull;
  }
}

// ==================== BuildContext Language Extensions ====================
extension LanguageContextExtension on BuildContext {
  List<LanguageModel> get supportedLanguages =>
      read<LanguageCubit>().supportedLanguages;

  LanguageModel? get currentLanguage =>
      read<LanguageCubit>().currentLanguage;
}