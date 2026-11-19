import 'package:cv/cv.dart';

import 'list_options.dart';
import 'stripe_models.dart';

/// An amount of a currency in a balance.
class StripeApiBalanceAmount extends CvModelBase {
  /// Cents.
  final amount = CvField<int>('amount');

  /// `eur`...
  final currency = CvField<String>('currency');

  @override
  CvFields get fields => [amount, currency];
}

/// The balance of the account.
/// https://docs.stripe.com/api/balance/balance_object
class StripeApiBalance extends CvModelBase {
  /// Can be paid out.
  final available = CvModelListField<StripeApiBalanceAmount>('available');

  /// Not available yet.
  final pending = CvModelListField<StripeApiBalanceAmount>('pending');

  /// Livemode.
  final livemode = CvField<bool>('livemode');

  @override
  CvFields get fields => [available, pending, livemode];
}

/// The type of a balance transaction of a payment.
const stripeBalanceTransactionTypeCharge = 'charge';

/// The type of a balance transaction of a payment (Payment Intents).
const stripeBalanceTransactionTypePayment = 'payment';

/// The type of a balance transaction of a refund.
const stripeBalanceTransactionTypeRefund = 'refund';

/// The type of a balance transaction of a payout.
const stripeBalanceTransactionTypePayout = 'payout';

/// A movement of the balance (a payment, a refund, a fee, a payout).
/// https://docs.stripe.com/api/balance_transactions/object
class StripeApiBalanceTransaction extends CvModelBase {
  /// `txn_...`.
  final id = CvField<String>('id');

  /// Gross amount, cents (negative for a refund or a payout).
  final amount = CvField<int>('amount');

  /// Stripe fees, cents.
  final fee = CvField<int>('fee');

  /// [amount] minus [fee], cents.
  final net = CvField<int>('net');

  /// `eur`...
  final currency = CvField<String>('currency');

  /// [stripeBalanceTransactionTypeCharge]...
  final type = CvField<String>('type');

  /// `charge`, `refund`, `payout`, `fee`...
  final reportingCategory = CvField<String>('reporting_category');

  /// Unix seconds.
  final created = CvField<int>('created');

  /// When it becomes available, unix seconds.
  final availableOn = CvField<int>('available_on');

  /// `available` or `pending`.
  final status = CvField<String>('status');

  /// The description.
  final description = CvField<String>('description');

  /// The id of the object behind it (`ch_...`, `re_...`, `po_...`).
  final source = CvField<String>('source');

  @override
  CvFields get fields => [
    id,
    amount,
    fee,
    net,
    currency,
    type,
    reportingCategory,
    created,
    availableOn,
    status,
    description,
    source,
  ];
}

/// A page of balance transactions.
class StripeApiBalanceTransactionList extends CvModelBase {
  /// More after.
  final hasMore = CvField<bool>('has_more');

  /// The transactions, newest first.
  final data = CvModelListField<StripeApiBalanceTransaction>('data');

  @override
  CvFields get fields => [data, hasMore];
}

/// https://docs.stripe.com/api/balance_transactions/list
class StripeApiBalanceTransactionListOptions extends CvModelBase
    with StripeApiListOptionsMixin {
  /// The transactions of a payout (`po_...`): what it paid out.
  final payout = CvField<String>('payout');

  /// The transactions of a type ([stripeBalanceTransactionTypeCharge]...).
  final type = CvField<String>('type');

  @override
  CvFields get fields => [payout, type, ...listOptionsMixinFields];

  /// The query parameters.
  Map<String, Object> toQueryParameters() => {
    ...listQueryParameters(),
    'payout': ?payout.v,
    'type': ?type.v,
  };
}

/// A payout to the bank account.
/// https://docs.stripe.com/api/payouts/object
class StripeApiPayout extends CvModelBase with StripeApiMetadataMixin {
  /// `po_...`.
  final id = CvField<String>('id');

  /// Cents.
  final amount = CvField<int>('amount');

  /// `eur`...
  final currency = CvField<String>('currency');

  /// Expected on the bank account, unix seconds.
  final arrivalDate = CvField<int>('arrival_date');

  /// Unix seconds.
  final created = CvField<int>('created');

  /// `paid`, `pending`, `in_transit`, `canceled`, `failed`.
  final status = CvField<String>('status');

  /// true for a payout of the automatic schedule, false for a manual one.
  final automatic = CvField<bool>('automatic');

  /// `standard` or `instant`.
  final method = CvField<String>('method');

  /// The description.
  final description = CvField<String>('description');

  /// What the bank statement shows.
  final statementDescriptor = CvField<String>('statement_descriptor');

  @override
  CvFields get fields => [
    id,
    amount,
    currency,
    arrivalDate,
    created,
    status,
    automatic,
    method,
    description,
    statementDescriptor,
    ...metadataMixinFields,
  ];
}

/// A page of payouts.
class StripeApiPayoutList extends CvModelBase {
  /// More after.
  final hasMore = CvField<bool>('has_more');

  /// The payouts, newest first.
  final data = CvModelListField<StripeApiPayout>('data');

  @override
  CvFields get fields => [data, hasMore];
}

/// https://docs.stripe.com/api/payouts/list
class StripeApiPayoutListOptions extends CvModelBase
    with StripeApiListOptionsMixin {
  /// `paid`, `pending`, `in_transit`, `canceled`, `failed`.
  final status = CvField<String>('status');

  @override
  CvFields get fields => [status, ...listOptionsMixinFields];

  /// The query parameters.
  Map<String, Object> toQueryParameters() => {
    ...listQueryParameters(),
    'status': ?status.v,
  };
}
