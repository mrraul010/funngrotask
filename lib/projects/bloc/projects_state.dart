part of 'projects_bloc.dart';

class ProjectsState {
  final List<Project> projects;
  final int currentPage;
  final bool isFirstLoading;
  final bool isLoadingMore;
  final bool hasReachedEnd;
  final String? firstLoadError;
  final String? pageLoadError;

  const ProjectsState({
    this.projects = const [],
    this.currentPage = 0,
    this.isFirstLoading = true,
    this.isLoadingMore = false,
    this.hasReachedEnd = false,
    this.firstLoadError,
    this.pageLoadError,
  });

  ProjectsState copyWith({
    List<Project>? projects,
    int? currentPage,
    bool? isFirstLoading,
    bool? isLoadingMore,
    bool? hasReachedEnd,
    String? firstLoadError,
    String? pageLoadError,
  }) {
    return ProjectsState(
      projects: projects ?? this.projects,
      currentPage: currentPage ?? this.currentPage,
      isFirstLoading: isFirstLoading ?? this.isFirstLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
      firstLoadError: firstLoadError,
      pageLoadError: pageLoadError,
    );
  }
}
