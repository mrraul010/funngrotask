import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funngroapp/projects/bloc/projects_bloc.dart';
import 'package:funngroapp/projects/model/project_model.dart';

class ProjectsScreen extends StatelessWidget {
  final ProjectsApi api;

  const ProjectsScreen({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProjectsBloc(api: api)..add(LoadFirstPage()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Available Projects')),
        body: BlocBuilder<ProjectsBloc, ProjectsState>(
          builder: (context, state) {
            if (state.isFirstLoading) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Loading projects...',
                      style: TextStyle(
                        backgroundColor: Color.fromARGB(255, 34, 0, 255),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state.firstLoadError != null && state.projects.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 12),
                      Text(state.firstLoadError!, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () =>
                            context.read<ProjectsBloc>().add(LoadFirstPage()),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry First Load'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<ProjectsBloc>();
                bloc.add(LoadFirstPage());

                await bloc.stream.firstWhere((s) => !s.isFirstLoading);
              },
              child: NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  final nearBottom =
                      scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent - 200;

                  if (nearBottom &&
                      !state.isLoadingMore &&
                      !state.hasReachedEnd &&
                      state.pageLoadError == null) {
                    context.read<ProjectsBloc>().add(LoadNextPage());
                  }
                  return false;
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),

                  itemCount: state.projects.length + 1,
                  itemBuilder: (context, index) {
                    if (index < state.projects.length) {
                      final project = state.projects[index];
                      return _ProjectTile(project: project);
                    }

                    return _PaginationFooter(state: state);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final Project project;

  const _ProjectTile({required this.project});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(project.id),
      title: Text(
        project.title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(project.company),
      trailing: Text(
        '₹${project.payout}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.green,
          fontSize: 15,
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final ProjectsState state;

  const _PaginationFooter({required this.state});

  @override
  Widget build(BuildContext context) {
    // STATE A: Page-load state
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
        ),
      );
    }

    // STATE B: Inline Page-error state (keeps existing items & offers Retry)
    if (state.pageLoadError != null) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                state.pageLoadError!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => context.read<ProjectsBloc>().add(LoadNextPage()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // STATE C: End-of-list state (after page 7)
    if (state.hasReachedEnd) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            '🎉 You have reached the end of all projects (160 items)',
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return const SizedBox(height: 24);
  }
}
