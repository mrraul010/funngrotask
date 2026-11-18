part of 'earnings_bloc_bloc.dart';

abstract class EarningsBlocEvent {}

class LoadEarnings extends EarningsBlocEvent {
  final String userId;
  LoadEarnings(this.userId);
}

class _WalletUpdateReceived extends EarningsBlocEvent {
  final WalletUpdate update;
  _WalletUpdateReceived(this.update);
}

class SelectEarning extends EarningsBlocEvent {
  final EarningItemViewModel item;
  SelectEarning(this.item);
}
