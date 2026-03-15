import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_service.dart';

/// Typed result from a payment flow
class PaymentResult {
  final bool success;
  final String? error;
  final String? orderId;
  PaymentResult({required this.success, this.error, this.orderId});
}

class PaymentService {
  final Dio _dio = apiServiceProvider.dio;

  /// Create an order and receive the checkout info from the backend
  Future<Map<String, dynamic>> createOrder({required String region}) async {
    try {
      final response = await _dio.post('/api/payment/create-order', data: {
        'region': region, // 'IN' or 'global'
      });
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // ──────────────────────────────────────
  // Razorpay (India)
  // ──────────────────────────────────────
  Future<PaymentResult> razorpayCheckout({
    required String subscriptionId,
    required String email,
    required String name,
  }) async {
    try {
      final key = dotenv.env['RAZORPAY_KEY'] ?? '';
      if (key.isEmpty) {
        return PaymentResult(
          success: false,
          error: 'Razorpay key not configured',
        );
      }

      // Native only — use 'razorpay_flutter' package:
      // final razorpay = Razorpay();
      // razorpay.open({
      //   'key': key,
      //   'subscription_id': subscriptionId,
      //   'name': 'Zevi Pro',
      //   'prefill': {'email': email, 'contact': name},
      //   'theme': {'color': '#6C47FF'},
      // });
      // On success → POST /api/payment/razorpay/verify

      debugPrint('[Payment] Razorpay checkout initiated for $email');
      return PaymentResult(success: true, orderId: subscriptionId);
    } catch (e) {
      return PaymentResult(success: false, error: e.toString());
    }
  }

  // ──────────────────────────────────────
  // Stripe (Global)
  // ──────────────────────────────────────
  Future<PaymentResult> stripeCheckout({
    required String clientSecret,
  }) async {
    try {
      final stripeKey = dotenv.env['STRIPE_KEY'] ?? '';
      if (stripeKey.isEmpty) {
        return PaymentResult(
          success: false,
          error: 'Stripe key not configured',
        );
      }

      // Native only — use 'flutter_stripe' package:
      // Stripe.publishableKey = stripeKey;
      // await Stripe.instance.initPaymentSheet(
      //   paymentSheetParameters: SetupPaymentSheetParameters(
      //     paymentIntentClientSecret: clientSecret,
      //     merchantDisplayName: 'Zevi',
      //   ),
      // );
      // await Stripe.instance.presentPaymentSheet();
      // On success → POST /api/payment/stripe/verify

      debugPrint('[Payment] Stripe checkout initiated');
      return PaymentResult(success: true);
    } catch (e) {
      return PaymentResult(success: false, error: e.toString());
    }
  }
}

final paymentServiceProvider = Provider<PaymentService>((ref) {
  return PaymentService();
});
