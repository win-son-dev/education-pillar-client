import 'package:centralized_library/centralized_library.dart';

abstract class TutorDiscoveryEvent extends Equatable {
  const TutorDiscoveryEvent();
  @override
  List<Object?> get props => [];
}

class LoadTutors extends TutorDiscoveryEvent {}

class FilterTutors extends TutorDiscoveryEvent {
  final String? query;
  final String? specialization;
  final double? maxPrice;

  const FilterTutors({this.query, this.specialization, this.maxPrice});

  @override
  List<Object?> get props => [query, specialization, maxPrice];
}
