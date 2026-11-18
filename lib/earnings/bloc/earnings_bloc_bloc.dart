import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:funngroapp/earnings/model/earnings_viewmodel.dart';
import 'package:meta/meta.dart';

part 'earnings_bloc_event.dart';
part 'earnings_bloc_state.dart';

class EarningsBlocBloc extends Bloc<EarningsBlocEvent, EarningsBlocState> {
  final EarningsApi api;
  StreamSubscription<WalletUpdate>? _walletSub;

  EarningsBlocBloc({required this.api}) : super(const EarningsBlocState()) {
    on<LoadEarnings>(_onLoadEarnings);
    on<_WalletUpdateReceived>(_onWalletUpdateReceived);
    on<SelectEarning>(_onSelectEarning);
  }

  Future<void> _onLoadEarnings(
    LoadEarnings event,
    Emitter<EarningsBlocState> emit,
  ) async {
    emit(state.copyWith(status: EarningsStatus.loading));

    // Start listening once when loading begins
    _walletSub ??= api
        .walletUpdates(event.userId)
        .listen(
          (update) => add(_WalletUpdateReceived(update)),
          onError: (_) {},
        );

    try {
      final data = await api.fetchEarnings(event.userId);
      final formatted = data.map(EarningItemViewModel.fromEarning).toList();
      emit(state.copyWith(status: EarningsStatus.loaded, items: formatted));
    } catch (_) {
      emit(
        state.copyWith(
          status: EarningsStatus.error,
          errorMessage: 'Could not load earnings. Please try again.',
        ),
      );
    }
  }

  void _onWalletUpdateReceived(
    _WalletUpdateReceived event,
    Emitter<EarningsBlocState> emit,
  ) {
    final newItem = EarningItemViewModel.fromEarning(event.update.toEarning());
    final updatedList = List<EarningItemViewModel>.from(state.items);

    final existingIndex = updatedList.indexWhere(
      (i) => i.raw.id == newItem.raw.id,
    );
    if (existingIndex != -1) {
      updatedList[existingIndex] = newItem;
    } else {
      updatedList.insert(0, newItem);
    }

    emit(state.copyWith(items: updatedList));
  }

  Future<void> _onSelectEarning(
    SelectEarning event,
    Emitter<EarningsBlocState> emit,
  ) async {
    if (state.loadingDetailId != null) return; // Tap lock

    emit(state.copyWith(loadingDetailId: event.item.raw.id));

    try {
      final detail =
          event.item.raw.detail ?? await api.fetchDetail(event.item.raw.id);
      event.item.raw.detail = detail;

      emit(
        state.copyWith(
          clearLoadingDetailId: true,
          selectedDetailToNavigate: detail,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          clearLoadingDetailId: true,
          snackbarError: 'Failed to load earning details.',
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _walletSub?.cancel(); // Automatically cancels when BlocProvider disposes
    return super.close();
  }
}
