import 'dart:async';
import 'dart:math';

class EarningDetail {
  final String id;
  final String projectTitle;
  final String companyName;
  final double amount;
  final String status;

  const EarningDetail({
    required this.id,
    required this.projectTitle,
    required this.companyName,
    required this.amount,
    required this.status,
  });
}

class Earning {
  final String id;
  final String title;
  final double amount;
  EarningDetail? detail;

  Earning({
    required this.id,
    required this.title,
    required this.amount,
    this.detail,
  });
}

class WalletUpdate {
  final String id;
  final String title;
  final double amount;

  const WalletUpdate({
    required this.id,
    required this.title,
    required this.amount,
  });

  Earning toEarning() {
    return Earning(
      id: id,
      title: title,
      amount: amount,
    );
  }
}

String formatCurrency(double amount) {
  return '₹${amount.toStringAsFixed(2)}';
}

// YOUR EXACT CLASS:
class EarningItemViewModel {
  final Earning raw;
  final String formattedAmount;

  EarningItemViewModel({
    required this.raw,
    required this.formattedAmount,
  });

  factory EarningItemViewModel.fromEarning(Earning earning) {
    return EarningItemViewModel(
      raw: earning,
      formattedAmount: formatCurrency(earning.amount), // Runs ONCE per item
    );
  }
}

// Dummy API to test 2,000 items + live stream updates on your phone
class EarningsApi {
  final _rng = Random();

  Future<List<Earning>> fetchEarnings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    // Generates 2,000 items to test smooth scrolling on budget phones
    return List.generate(2000, (index) {
      final num = 2000 - index;
      return Earning(
        id: 'e_$num',
        title: 'Project Reward #$num',
        amount: 100.0 + _rng.nextInt(900),
      );
    });
  }

  Stream<WalletUpdate> walletUpdates(String userId) {
    // Sends a new live earning every 10 seconds to test your stream listener
    return Stream.periodic(const Duration(seconds: 10), (count) {
      return WalletUpdate(
        id: 'live_${count + 1}',
        title: 'Live Bonus Reward #${count + 1}',
        amount: 250.0 + _rng.nextInt(500),
      );
    });
  }

  Future<EarningDetail> fetchDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return EarningDetail(
      id: id,
      projectTitle: 'Brand Campaign ($id)',
      companyName: 'Funngro Partner',
      amount: 450.0,
      status: 'Credited to Wallet',
    );
  }
}