part of 'earnings_bloc_bloc.dart';

enum EarningsStatus { loading, loaded, error }

class EarningsBlocState {
  final EarningsStatus status;
  final List<EarningItemViewModel> items;
  final String? errorMessage;
  final String? loadingDetailId;
  final EarningDetail? selectedDetailToNavigate;
  final String? snackbarError;

  const EarningsBlocState({
    this.status = EarningsStatus.loading,
    this.items = const [],
    this.errorMessage,
    this.loadingDetailId,
    this.selectedDetailToNavigate,
    this.snackbarError,
  });

  EarningsBlocState copyWith({
    EarningsStatus? status,
    List<EarningItemViewModel>? items,
    String? errorMessage,
    String? loadingDetailId,
    bool clearLoadingDetailId = false,
    EarningDetail? selectedDetailToNavigate,
    String? snackbarError,
  }) {
    return EarningsBlocState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage,
      loadingDetailId: clearLoadingDetailId
          ? null
          : (loadingDetailId ?? this.loadingDetailId),
      selectedDetailToNavigate: selectedDetailToNavigate,
      snackbarError: snackbarError,
    );
  }
}
