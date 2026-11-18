import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:funngroapp/detailsscreen.dart';
import 'package:funngroapp/earnings/bloc/earnings_bloc_bloc.dart';
import 'package:funngroapp/earnings/model/earnings_viewmodel.dart';
import 'package:funngroapp/widgets/earning_tile.dart';

class EarningsScreen extends StatelessWidget {
  final String userId;
  final EarningsApi api;

  const EarningsScreen({super.key, required this.userId, required this.api});

  @override
  Widget build(BuildContext context) {
    // BlocProvider.create runs ONCE when EarningsScreen mounts
    return BlocProvider(
      create: (_) => EarningsBlocBloc(api: api)..add(LoadEarnings(userId)),
      child: Scaffold(
        appBar: AppBar(title: const Text('My Earnings')),
        body: BlocConsumer<EarningsBlocBloc, EarningsBlocState>(
          listener: (context, state) {
            if (state.selectedDetailToNavigate != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      DetailScreen(detail: state.selectedDetailToNavigate!),
                ),
              );
            }
            if (state.snackbarError != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.snackbarError!)));
            }
          },
          builder: (context, state) {
            if (state.status == EarningsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status == EarningsStatus.error) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.errorMessage ?? 'Something went wrong'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => context.read<EarningsBlocBloc>().add(
                        LoadEarnings(userId),
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.items.isEmpty) {
              return const Center(
                child: Text(
                  'No earnings yet. Complete a project to get started!',
                ),
              );
            }

            return ListView.builder(
              itemCount: state.items.length,
              itemExtent: 64.0, // Tells Flutter exact row height -> skips Layout calculation!
              addRepaintBoundaries: true, // Isolates GPU painting per tile
              itemBuilder: (context, index) {
                final item = state.items[index];
                return EarningTile(
                  key: ValueKey(
                    item.raw.id,
                  ), // Helps Flutter reuse elements efficiently
                  earning: item.raw,
                  subtitle: item.formattedAmount,
                  onTap: () =>
                      context.read<EarningsBlocBloc>().add(SelectEarning(item)),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
