import '../../../../centralized_library.dart';

class ContentBlocksConfig {
  final String? fontFamily;
  final EdgeInsets? padding;

  const ContentBlocksConfig({
    this.fontFamily,
    this.padding,
  });

  ContentBlocksConfig copyWith({
    String? fontFamily,
    EdgeInsets? padding
  }) {
    return ContentBlocksConfig(
      fontFamily: fontFamily ?? this.fontFamily,
      padding:  padding?? this.padding,
    );
  }
}