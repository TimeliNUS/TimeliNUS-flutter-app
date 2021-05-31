import 'package:TimeliNUS/models/person.dart';
import 'package:TimeliNUS/models/todoEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

@immutable
class Todo extends Equatable {
  final bool complete;
  final String id;
  final String note;
  final String title;
  final DateTime deadline;
  final Person pic;

  const Todo(this.title,
      {this.id,
      this.complete = false,
      this.note = '',
      this.deadline,
      this.pic});

  Todo copyWith(
      {String title,
      bool complete,
      String note,
      DateTime deadline,
      Person pic}) {
    return Todo(
      title ?? this.title,
      id: id ?? this.id,
      complete: complete ?? this.complete,
      note: note ?? '',
      deadline: deadline ?? this.deadline,
      pic: pic ?? this.pic,
    );
  }

  @override
  String toString() {
    return 'Todo { complete: $complete, title: $title, note: $note, id: $id }';
  }

  TodoEntity toEntity() {
    return TodoEntity(title, id, note, complete,
        deadline != null ? Timestamp.fromDate(deadline) : null);
  }

  static Todo fromEntity(TodoEntity entity) {
    return Todo(entity.task,
        id: entity.id,
        complete: entity.complete ?? false,
        note: entity.note,
        deadline: entity.deadline != null ? entity.deadline.toDate() : null);
  }

  @override
  List<Object> get props => [complete, id, note, title];
}
