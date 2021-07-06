part of 'projectBloc.dart';

abstract class ProjectState extends Equatable {
  final List<Project> projects;
  final List<Project> invitations;
  const ProjectState(this.projects, this.invitations);

  @override
  List<Object> get props => [projects, invitations];
}

class ProjectInitial extends ProjectState {
  ProjectInitial() : super([], []);
}

class ProjectLoading extends ProjectState {
  ProjectLoading() : super([], []);
  @override
  String toString() => 'ProjectLoading';
}

class ProjectLoaded extends ProjectState {
  final List<Project> projects;
  final List<Project> invitations;

  ProjectLoaded(this.projects, this.invitations) : super(projects, invitations);

  @override
  String toString() => 'ProjectLoaded { projects: $projects }';

  @override
  List<Object> get props => [projects, invitations];
}

class ProjectNotLoaded extends ProjectState {
  ProjectNotLoaded() : super([], []);
  @override
  String toString() => 'ProjectNotLoaded';
}
