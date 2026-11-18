import 'package:bloc/bloc.dart';
import 'package:funngroapp/projects/model/project_model.dart';
import 'package:meta/meta.dart';

part 'projects_event.dart';
part 'projects_state.dart';

class ProjectsBloc extends Bloc<ProjectsEvent, ProjectsState> {
  final ProjectsApi api;

  ProjectsBloc({required this.api}) : super(const ProjectsState()) {
    on<LoadFirstPage>(_onLoadFirstPage);
    on<LoadNextPage>(_onLoadNextPage);
  }

  Future<void> _onLoadFirstPage(
    LoadFirstPage event,
    Emitter<ProjectsState> emit,
  ) async {
    emit(
      const ProjectsState(
        isFirstLoading: true,
        currentPage: 0,
        projects: [],
        hasReachedEnd: false,
      ),
    );

    try {
      final firstPageItems = await api.fetchProjects(0);
      emit(
        state.copyWith(
          projects: firstPageItems,
          currentPage: 0,
          isFirstLoading: false,
          hasReachedEnd: firstPageItems.isEmpty,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isFirstLoading: false,
          firstLoadError: 'Failed to load initial projects. Please try again.',
        ),
      );
    }
  }

  Future<void> _onLoadNextPage(
    LoadNextPage event,
    Emitter<ProjectsState> emit,
  ) async {
    if (state.isFirstLoading || state.isLoadingMore || state.hasReachedEnd) {
      return;
    }

    final nextPage = state.currentPage + 1;

    emit(state.copyWith(isLoadingMore: true, pageLoadError: null));

    try {
      final newItems = await api.fetchProjects(nextPage);
      if (newItems.isEmpty) {
        emit(state.copyWith(isLoadingMore: false, hasReachedEnd: true));
      } else {
        emit(
          state.copyWith(
            projects: [...state.projects, ...newItems],
            currentPage: nextPage,
            isLoadingMore: false,
          ),
        );
      }
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          pageLoadError: 'Could not load page ${nextPage + 1}. Tap retry.',
        ),
      );
    }
  }
}
