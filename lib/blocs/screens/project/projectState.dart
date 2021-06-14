part of 'projectBloc.dart';

abstract class ProjectState extends Equatable {
  final List<Project> projects;
  const ProjectState(this.projects);

  @override
  List<Object> get props => [projects];
}

class ProjectInitial extends ProjectState {
  ProjectInitial() : super([]);
}

class ProjectLoading extends ProjectState {
  ProjectLoading() : super([]);
  @override
  String toString() => 'ProjectLoading';
}

class ProjectLoaded extends ProjectState {
  final List<Project> projects;

  ProjectLoaded(this.projects) : super(projects);

  @override
  String toString() => 'ProjectLoaded { projects: $projects }';

  @override
  List<Object> get props => [projects];
}

class ProjectNotLoaded extends ProjectState {
  ProjectNotLoaded() : super([]);
  @override
  String toString() => 'ProjectNotLoaded';
}
