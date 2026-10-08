import 'package:voltigex/features/dashboard/domain/entities/home_profile_entity.dart';
import 'package:voltigex/features/dashboard/domain/entities/transaction_entity.dart';

sealed class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  HomeLoaded({
    required this.profile,
    required this.transactions,
    required this.balanceLoading,
    required this.currencySymbol,
    this.balance,
    this.warningMessage,
  });

  final HomeProfileEntity profile;
  final List<TransactionEntity> transactions;
  final double? balance;
  final bool balanceLoading;
  final String currencySymbol;
  final String? warningMessage;

  HomeLoaded copyWith({
    HomeProfileEntity? profile,
    List<TransactionEntity>? transactions,
    double? balance,
    bool? balanceLoading,
    String? currencySymbol,
    String? warningMessage,
    bool clearWarning = false,
    bool clearBalance = false,
  }) {
    return HomeLoaded(
      profile: profile ?? this.profile,
      transactions: transactions ?? this.transactions,
      balance: clearBalance ? null : (balance ?? this.balance),
      balanceLoading: balanceLoading ?? this.balanceLoading,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      warningMessage: clearWarning ? null : (warningMessage ?? this.warningMessage),
    );
  }
}

class HomeError extends HomeState {
  HomeError(this.message);

  final String message;
}
