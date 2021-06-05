import 'package:cloud_firestore/cloud_firestore.dart';

class TodoEntity {
  final bool complete;
  final String id;
  final String note;
  final String task;
  final Timestamp deadline;
  final DocumentReference ref;

  TodoEntity(
      this.task, this.id, this.note, this.complete, this.deadline, this.ref);

  @override
  int get hashCode =>
      complete.hashCode ^
      task.hashCode ^
      note.hashCode ^
      id.hashCode ^
      deadline.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TodoEntity &&
          runtimeType == other.runtimeType &&
          complete == other.complete &&
          task == other.task &&
          note == other.note &&
          deadline == other.deadline &&
          id == other.id;

  Map<String, Object> toJson() {
    return {
      'complete': complete,
      'task': task,
      'note': note,
      'id': id,
      'deadline': deadline
    };
  }

  @override
  String toString() {
    return 'TodoEntity{complete: $complete, task: $task, note: $note, id: $id, deadline: $deadline, ref: $ref}';
  }

  static TodoEntity fromJson(Map<String, Object> json,
      [String id, DocumentReference ref]) {
    return TodoEntity(
        json['task'] as String,
        id != null ? id : json['id'] as String,
        json['note'] as String,
        json['complete'] as bool,
        json['deadline'] as Timestamp,
        ref);
  }
}
