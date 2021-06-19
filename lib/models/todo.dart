import 'package:TimeliNUS/models/person.dart';
import 'package:TimeliNUS/models/todoEntity.dart';
import 'package:TimeliNUS/models/userModel.dart';
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
  final List<User> pic;
  final DocumentReference ref;

  const Todo(this.title,
      {this.id,
      this.complete = false,
      this.note = '',
      this.deadline,
      this.pic,
      this.ref});

  Todo copyWith(
      {String title,
      String id,
      bool complete,
      String note,
      DateTime deadline,
      List<Person> pic,
      DocumentReference ref}) {
    return Todo(title ?? this.title,
        id: id ?? this.id,
        complete: complete ?? this.complete,
        note: note ?? (this.note ?? ''),
        deadline: deadline ?? this.deadline,
        pic: pic ?? this.pic,
        ref: ref ?? this.ref);
  }

  @override
  String toString() {
    return 'Todo { complete: $complete, title: $title, note: $note, id: $id, deadline: $deadline, ref: $ref}';
  }

  TodoEntity toEntity() {
    return TodoEntity(title, id, note, complete,
        deadline != null ? Timestamp.fromDate(deadline) : null, pic, ref);
  }

  static Todo fromEntity(TodoEntity entity) {
    return Todo(entity.task,
        id: entity.id,
        complete: entity.complete ?? false,
        note: entity.note,
        deadline: entity.deadline != null ? entity.deadline.toDate() : null,
        pic: entity.pic ?? [],
        ref: entity.ref);
  }

  @override
  List<Object> get props => [complete, id, note, title, pic, deadline, ref];
}
