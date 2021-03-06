import 'package:TimeliNUS/models/models.dart';
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
  final Project project;
  final List<User> pic;
  final bool includeTime;
  final DocumentReference ref;

  const Todo(this.title,
      {this.id,
      this.complete = false,
      this.note = '',
      this.deadline,
      this.project,
      this.pic,
      this.ref,
      this.includeTime});

  Todo copyWith(
      {String title,
      String id,
      bool complete,
      String note,
      DateTime deadline,
      Project project,
      List<User> pic,
      bool includeTime,
      DocumentReference ref}) {
    return Todo(title ?? this.title,
        id: id ?? this.id,
        complete: complete ?? this.complete,
        note: note ?? (this.note ?? ''),
        deadline: deadline ?? this.deadline,
        project: project ?? this.project,
        pic: pic ?? this.pic,
        includeTime: includeTime ?? this.includeTime,
        ref: ref ?? this.ref);
  }

  @override
  String toString() {
    return 'Todo { complete: $complete, title: $title, note: $note, deadline: $deadline, ref: $ref, pic: $pic}';
  }

  TodoEntity toEntity() {
    return TodoEntity(title, id, note, complete, deadline != null ? Timestamp.fromDate(deadline) : null, project, pic,
        includeTime, ref);
  }

  static Todo fromEntity(TodoEntity entity) {
    return Todo(entity.task,
        id: entity.id,
        complete: entity.complete ?? false,
        note: entity.note,
        deadline: entity.deadline != null ? entity.deadline.toDate() : null,
        project: entity.project,
        pic: entity.pic ?? [],
        includeTime: entity.includeTime ?? false,
        ref: entity.ref);
  }

  @override
  List<Object> get props => [complete, id, note, title, pic, ref, includeTime];
}
