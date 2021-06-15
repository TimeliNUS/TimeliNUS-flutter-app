part of 'projectBloc.dart';

abstract class ProjectEvent extends Equatable {
  const ProjectEvent();

  @override
  List<Object> get props => [];
}

class LoadProjects extends ProjectEvent {
  final String id;
  LoadProjects(this.id) : super();

  @override
  String toString() => 'LoadProjects';

  @override
  List<Object> get props => [id];
}

class AddProject extends ProjectEvent {
  final Project project;
  final String id;
  AddProject(this.project, this.id) : super();

  @override
  String toString() => 'AddProject { project: $project, id: $id }';

  @override
  List<Object> get props => [project, id];
}

class UpdateProject extends ProjectEvent {
  final Project updatedProject;
  final String id;

  UpdateProject(this.updatedProject, this.id) : super();

  @override
  String toString() => 'UpdateProject { updatedProject: $updatedProject }';

  @override
  List<Object> get props => [updatedProject];
}
