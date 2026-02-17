import 'package:centralized_library/centralized_library.dart';

class Certification extends Equatable {
  final String certificationId;
  final String name;
  final String issuingOrganization;
  final DateTime? dateObtained;
  final bool isVerified;
  final String? documentUrl;

  const Certification({
    required this.certificationId,
    required this.name,
    required this.issuingOrganization,
    this.dateObtained,
    this.isVerified = false,
    this.documentUrl,
  });

  @override
  List<Object?> get props => [
    certificationId,
    name,
    issuingOrganization,
    dateObtained,
    isVerified,
    documentUrl,
  ];

  Certification copyWith({
    String? name,
    String? issuingOrganization,
    DateTime? dateObtained,
    bool? isVerified,
    String? documentUrl,
  }) {
    return Certification(
      certificationId: certificationId,
      name: name ?? this.name,
      issuingOrganization: issuingOrganization ?? this.issuingOrganization,
      dateObtained: dateObtained ?? this.dateObtained,
      isVerified: isVerified ?? this.isVerified,
      documentUrl: documentUrl ?? this.documentUrl,
    );
  }
}
