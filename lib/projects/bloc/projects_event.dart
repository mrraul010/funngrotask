part of 'projects_bloc.dart';

@immutable
sealed class ProjectsEvent {}

class LoadFirstPage extends ProjectsEvent {}

class LoadNextPage extends ProjectsEvent {}
