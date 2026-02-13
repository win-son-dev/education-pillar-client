import '../../centralized_library.dart';

class LanguageModel extends Equatable {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final bool isRTL;
  final bool isEnabled;
  final String? fontFamily;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    this.flag = '',
    this.isRTL = false,
    this.isEnabled = true,
    this.fontFamily,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] as String,
      name: json['name'] as String,
      nativeName: json['nativeName'] as String,
      flag: json['flag'] as String? ?? '',
      isRTL: json['isRTL'] as bool? ?? false,
      isEnabled: json['isEnabled'] as bool? ?? true,
      fontFamily: json['fontFamily'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'flag': flag,
      'isRTL': isRTL,
      'isEnabled': isEnabled,
      if (fontFamily != null) 'fontFamily': fontFamily,
    };
  }

  @override
  List<Object?> get props => [code, name, nativeName, flag, isRTL, isEnabled, fontFamily];
}