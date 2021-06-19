import 'package:TimeliNUS/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TodoEntity extends Equatable {
  final bool complete;
  final String id;
  final String note;
  final String task;
  final Timestamp deadline;
  final List<User> pic;
  final DocumentReference ref;

  TodoEntity(this.task, this.id, this.note, this.complete, this.deadline,
      this.pic, this.ref);

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
        (json['pic'] as List<User>),
        ref);
  }

  @override
  List<Object> get props => [task, id, note, complete, deadline, pic, ref];
}
