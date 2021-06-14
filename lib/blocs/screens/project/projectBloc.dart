import 'dart:async';

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
    }
  }

  Stream<ProjectState> _mapLoadProjectsToState(LoadProjects event) async* {
    print("yes");
    try {
      yield ProjectLoading();
      final projectEntities = await projectRepository.loadProjects(event.id);
      final List<Project> projects = projectEntities
          .map((project) => Project.fromEntity(project))
          .toList();
      yield ProjectLoaded(projects);
    } catch (err) {
      yield ProjectNotLoaded();
    }
  }

  Stream<ProjectState> _mapAddProjectToState(AddProject event) async* {
    List<Project> currentProjects = state.projects;
    yield ProjectLoading();
    DocumentReference newTodoRef = await projectRepository.addNewProject(
        event.project.toEntity(), event.id);
    final updatedProjects = currentProjects
      ..add(event.project.copyWith(ref: newTodoRef));
    yield ProjectLoaded(updatedProjects);
  }
}
