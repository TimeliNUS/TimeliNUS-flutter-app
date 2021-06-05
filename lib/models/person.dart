import 'package:equatable/equatable.dart';

class Person extends Equatable {
  final String name;
  final String id;
  const Person({this.id, this.name});

  @override
  List<Object> get props => [name, id];
}
