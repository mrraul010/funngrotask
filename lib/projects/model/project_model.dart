import 'dart:math';

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => 'ApiException: $message';
}

class Project {
  final String id;
  final String title;
  final String company;
  final int payout;

  const Project({
    required this.id,
    required this.title,
    required this.company,
    required this.payout,
  });
}

class ProjectsApi {
  final _rng = Random();

  Future<List<Project>> fetchProjects(int page) async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (_rng.nextInt(5) == 0) throw const ApiException('server error');
    if (page > 7) return [];
    return List.generate(
      20,
      (i) => Project(
        id: 'p${page * 20 + i}',
        title: 'Project ${page * 20 + i}',
        company: 'Company ${_rng.nextInt(50)}',
        payout: 200 + _rng.nextInt(1800),
      ),
    );
  }
}
