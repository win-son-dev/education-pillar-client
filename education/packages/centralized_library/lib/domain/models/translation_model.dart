import 'package:equatable/equatable.dart';

class TranslationModel extends Equatable {
  final String languageCode;
  final Map<String, dynamic> translations;
  final int version;

  const TranslationModel({
    required this.languageCode,
    required this.translations,
    required this.version,
  });

  String translate(String path, {Map<String, dynamic>? params, String? fallback}) {
    final keys = path.split('.');
    dynamic value = translations;

    for (final key in keys) {
      if (value is Map<String, dynamic> && value.containsKey(key)) {
        value = value[key];
      } else {
        return fallback ?? path;
      }
    }

    if (value is! String) return fallback ?? path;

    if (params != null) {
      String result = value;
      params.forEach((key, val) {
        result = result.replaceAll('{{$key}}', val.toString());
      });
      return result;
    }

    return value;
  }

  factory TranslationModel.fromJson(Map<String, dynamic> json) {
    return TranslationModel(
      languageCode: json['languageCode'] as String,
      translations: json['translations'] as Map<String, dynamic>,
      version: json['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'translations': translations,
      'version': version,
    };
  }

  @override
  List<Object?> get props => [languageCode, translations, version];
}