import 'dart:async';

import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/models/project.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

part 'projectEvent.dart';
part 'projectState.dart';

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository projectRepository;
  ProjectBloc({
    @required this.projectRepository,
  })  : assert(projectRepository != null),
        super(ProjectInitial());

  @override
  Stream<ProjectState> mapEventToState(
    ProjectEvent event,
  ) async* {
    if (event is LoadProjects) {
      yield* _mapLoadProjectsToState(event);
    } else if (event is AddProject) {
      yield* _mapAddProjectToState(event);
    } else if (event is UpdateProject) {
      yield* _mapUpdateProjectToState(event);
    } else if (event is DeleteProject) {
      yield* _mapDeleteProjectToState(event);
    }
  }

  Stream<ProjectState> _mapLoadProjectsToState(LoadProjects event) async* {
    try {
      yield ProjectLoading();
      List<Future> futures = [];
      List<ProjectEntity> projectEntities;
      List<ProjectEntity> invitationEntities;
      futures.add(projectRepository.loadProjects(event.id).then((x) => projectEntities = x));
      futures.add(projectRepository.loadProjectInvitations(event.id).then((x) => invitationEntities = x));
      await Future.wait(futures);
      final List<Project> projects = projectEntities.map((project) => Project.fromEntity(project)).toList();
      final List<Project> invitations = invitationEntities.map((project) => Project.fromEntity(project)).toList();
      yield ProjectLoaded(projects, invitations);
    } catch (err) {
      print(err);
      yield ProjectNotLoaded();
    }
  }

  Stream<ProjectState> _mapAddProjectToState(AddProject event) async* {
    List<Project> currentProjects = state.projects;
    yield ProjectLoading();
    DocumentReference newTodoRef = await projectRepository.addNewProject(event.project.toEntity(), event.id);
    final updatedProjects = currentProjects..add(event.project.copyWith(ref: newTodoRef, id: newTodoRef.id));
    yield ProjectLoaded(updatedProjects, state.invitations);
  }

  Stream<ProjectState> _mapUpdateProjectToState(UpdateProject event) async* {
    yield ProjectLoading();
    final updatedProjects = state.projects.map((project) {
      return project.id == event.updatedProject.id ? event.updatedProject : project;
    }).toList();
    yield ProjectLoaded(updatedProjects, state.invitations);
    await projectRepository.updateProject(event.updatedProject.toEntity());
  }

  Stream<ProjectState> _mapDeleteProjectToState(DeleteProject event) async* {
    // if (state is TodoLoaded) {
    yield ProjectLoading();
    final updatedProjects = state.projects.where((project) => project.id != event.project.id).toList();
    yield ProjectLoaded(updatedProjects, state.invitations);
    // }
    await projectRepository.deleteTodo(event.project, event.userId);
  }
}
