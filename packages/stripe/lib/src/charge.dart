import 'package:cv/cv.dart';

import 'list_options.dart';
import 'stripe_models.dart';

/// `billing_details` of a charge.
class StripeApiBillingDetails extends CvModelBase {
  /// The email given.
  final email = CvField<String>('email');

  /// The name given.
  final name = CvField<String>('name');

  /// The phone given.
  final phone = CvField<String>('phone');

  @override
  CvFields get fields => [email, name, phone];
}

/// A charge: one payment attempt, succeeded or not.
/// https://docs.stripe.com/api/charges/object
class StripeApiCharge extends CvModelBase with StripeApiMetadataMixin {
  /// `ch_...` or `py_...`.
  final id = CvField<String>('id');

  /// Cents.
  final amount = CvField<int>('amount');

  /// Cents refunded.
  final amountRefunded = CvField<int>('amount_refunded');

  /// `eur`...
  final currency = CvField<String>('currency');

  /// `succeeded`, `pending` or `failed`.
  final status = CvField<String>('status');

  /// Succeeded.
  final paid = CvField<bool>('paid');

  /// Fully refunded.
  final refunded = CvField<bool>('refunded');

  /// Unix seconds.
  final created = CvField<int>('created');

  /// The description.
  final description = CvField<String>('description');

  /// Where the receipt went.
  final receiptEmail = CvField<String>('receipt_email');

  /// The receipt page.
  final receiptUrl = CvField<String>('receipt_url');

  /// The customer id, if any.
  final customer = CvField<String>('customer');

  /// The payment intent id.
  final paymentIntent = CvField<String>('payment_intent');

  /// The balance transaction id (fees, net).
  final balanceTransaction = CvField<String>('balance_transaction');

  /// Why it failed.
  final failureMessage = CvField<String>('failure_message');

  /// Who paid.
  final billingDetails = CvModelField<StripeApiBillingDetails>(
    'billing_details',
  );

  /// Livemode.
  final livemode = CvField<bool>('livemode');

  @override
  CvFields get fields => [
    id,
    amount,
    amountRefunded,
    currency,
    status,
    paid,
    refunded,
    created,
    description,
    receiptEmail,
    receiptUrl,
    customer,
    paymentIntent,
    balanceTransaction,
    failureMessage,
    billingDetails,
    livemode,
    ...metadataMixinFields,
  ];
}

/// A page of charges.
class StripeApiChargeList extends CvModelBase {
  /// More after.
  final hasMore = CvField<bool>('has_more');

  /// The charges, newest first.
  final data = CvModelListField<StripeApiCharge>('data');

  @override
  CvFields get fields => [data, hasMore];
}

/// https://docs.stripe.com/api/charges/list
class StripeApiChargeListOptions extends CvModelBase
    with StripeApiListOptionsMixin {
  /// The charges of a customer.
  final customer = CvField<String>('customer');

  /// The charges of a payment intent.
  final paymentIntent = CvField<String>('payment_intent');

  @override
  CvFields get fields => [customer, paymentIntent, ...listOptionsMixinFields];

  /// The query parameters.
  Map<String, Object> toQueryParameters() => {
    ...listQueryParameters(),
    'customer': ?customer.v,
    'payment_intent': ?paymentIntent.v,
  };
}

/// https://docs.stripe.com/api/refunds/create
class StripeApiRefundCreate extends CvModelBase with StripeApiMetadataMixin {
  /// The charge to refund (or [paymentIntent]).
  final charge = CvField<String>('charge');

  /// The payment intent to refund (or [charge]).
  final paymentIntent = CvField<String>('payment_intent');

  /// Cents, all that remains when null.
  final amount = CvField<int>('amount');

  /// `duplicate`, `fraudulent` or `requested_by_customer`.
  final reason = CvField<String>('reason');

  @override
  CvFields get fields => [
    charge,
    paymentIntent,
    amount,
    reason,
    ...metadataMixinFields,
  ];
}

/// A refund.
/// https://docs.stripe.com/api/refunds/object
class StripeApiRefund extends CvModelBase with StripeApiMetadataMixin {
  /// `re_...`.
  final id = CvField<String>('id');

  /// Cents.
  final amount = CvField<int>('amount');

  /// `eur`...
  final currency = CvField<String>('currency');

  /// The refunded charge.
  final charge = CvField<String>('charge');

  /// `pending`, `succeeded`, `failed`, `canceled`...
  final status = CvField<String>('status');

  /// Unix seconds.
  final created = CvField<int>('created');

  @override
  CvFields get fields => [
    id,
    amount,
    currency,
    charge,
    status,
    created,
    ...metadataMixinFields,
  ];
}
