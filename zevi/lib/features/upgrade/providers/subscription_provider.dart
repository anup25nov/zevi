import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/payment_service.dart';

enum SubscriptionTier { free, pro }

class SubscriptionState {
  final SubscriptionTier tier;
  final int messagesUsed;
  final int messagesLimit;
  final bool isLoading;
  final String? error;

  SubscriptionState({
    this.tier = SubscriptionTier.free,
    this.messagesUsed = 42,
    this.messagesLimit = 50,
    this.isLoading = false,
    this.error,
  });

  SubscriptionState copyWith({
    SubscriptionTier? tier,
    int? messagesUsed,
    int? messagesLimit,
    bool? isLoading,
    String? error,
  }) {
    return SubscriptionState(
      tier: tier ?? this.tier,
      messagesUsed: messagesUsed ?? this.messagesUsed,
      messagesLimit: messagesLimit ?? this.messagesLimit,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isProUser => tier == SubscriptionTier.pro;
  double get usageRatio => messagesUsed / messagesLimit;
}

class SubscriptionNotifier extends StateNotifier<SubscriptionState> {
  final PaymentService _paymentService;

  SubscriptionNotifier(this._paymentService) : super(SubscriptionState());

  Future<PaymentResult> handleUpgrade({
    required String countryCode,
    required String email,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final region = countryCode == 'IN' ? 'IN' : 'global';
      final order = await _paymentService.createOrder(region: region);

      PaymentResult result;

      if (region == 'IN') {
        result = await _paymentService.razorpayCheckout(
          subscriptionId: order['subscription_id'] ?? '',
          email: email,
          name: name,
        );
      } else {
        result = await _paymentService.stripeCheckout(
          clientSecret: order['client_secret'] ?? '',
        );
      }

      if (result.success) {
        state = state.copyWith(
          tier: SubscriptionTier.pro,
          messagesUsed: 0,
          messagesLimit: 999999,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.error,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return PaymentResult(success: false, error: e.toString());
    }
  }

  void upgradeToPro() {
    state = state.copyWith(
      tier: SubscriptionTier.pro,
      messagesUsed: 0,
      messagesLimit: 999999,
    );
  }
}

final subscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, SubscriptionState>((ref) {
  final paymentService = ref.watch(paymentServiceProvider);
  return SubscriptionNotifier(paymentService);
});
