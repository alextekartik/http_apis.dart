import 'package:cv/cv.dart';

import 'stripe_models.dart';

/// Invoice statuses: being prepared.
const stripeInvoiceStatusDraft = 'draft';

/// See [stripeInvoiceStatusDraft]: finalized, waiting for its payment.
const stripeInvoiceStatusOpen = 'open';

/// See [stripeInvoiceStatusDraft].
const stripeInvoiceStatusPaid = 'paid';

/// See [stripeInvoiceStatusDraft]: given up (the retries failed).
const stripeInvoiceStatusUncollectible = 'uncollectible';

/// See [stripeInvoiceStatusDraft]: cancelled.
const stripeInvoiceStatusVoid = 'void';

/// The invoice statuses.
const stripeInvoiceStatuses = [
  stripeInvoiceStatusDraft,
  stripeInvoiceStatusOpen,
  stripeInvoiceStatusPaid,
  stripeInvoiceStatusUncollectible,
  stripeInvoiceStatusVoid,
];

/// An invoice.
///
/// Its subscription and the subscription metadata are under `parent` since
/// the API version 2025-03-31 and at the top before; its tax is
/// `total_taxes` since then and `tax` before: [subscriptionId],
/// [subscriptionMetadata] and [taxAmount] read either.
class StripeApiInvoice extends CvModelBase with StripeApiMetadataMixin {
  /// `in_...`.
  final id = CvField<String>('id');

  /// The number shown on the invoice, null for a draft.
  final number = CvField<String>('number');

  /// See [stripeInvoiceStatusDraft].
  final status = CvField<String>('status');

  /// `eur`, `usd`...
  final currency = CvField<String>('currency');

  /// Created (unix seconds).
  final created = CvField<int>('created');

  /// The total, tax included (cents).
  final total = CvField<int>('total');

  /// The total before discounts and tax, tax included when the prices are
  /// (cents).
  final subtotal = CvField<int>('subtotal');

  /// What is due (cents).
  final amountDue = CvField<int>('amount_due');

  /// What was paid (cents).
  final amountPaid = CvField<int>('amount_paid');

  /// What is left to pay (cents).
  final amountRemaining = CvField<int>('amount_remaining');

  /// The tax before the API version 2025-03-31 (cents).
  final tax = CvField<int>('tax');

  /// The taxes since the API version 2025-03-31 (`amount`...).
  final totalTaxes = CvField<List<Object?>>('total_taxes');

  /// The customer id.
  final customer = CvField<String>('customer');

  /// The customer email.
  final customerEmail = CvField<String>('customer_email');

  /// The customer name.
  final customerName = CvField<String>('customer_name');

  /// The page of the invoice, to see and pay it.
  final hostedInvoiceUrl = CvField<String>('hosted_invoice_url');

  /// The PDF of the invoice.
  final invoicePdf = CvField<String>('invoice_pdf');

  /// Why it was made: `subscription_create`, `subscription_cycle`...
  final billingReason = CvField<String>('billing_reason');

  /// The period it bills (unix seconds).
  final periodStart = CvField<int>('period_start');

  /// See [periodStart].
  final periodEnd = CvField<int>('period_end');

  /// Livemode.
  final livemode = CvField<bool>('livemode');

  /// The subscription id before the API version 2025-03-31.
  final subscription = CvField<String>('subscription');

  /// The subscription metadata before the API version 2025-03-31
  /// (`metadata`).
  final subscriptionDetails = CvField<Model>('subscription_details');

  /// What it bills since the API version 2025-03-31
  /// (`subscription_details`: `subscription`, `metadata`).
  final parent = CvField<Model>('parent');

  /// When it changed status (`paid_at`, `voided_at`... unix seconds).
  final statusTransitions = CvField<Model>('status_transitions');

  Map<String, Object?>? get _parentSubscriptionDetails {
    var details = parent.v?['subscription_details'];
    return details is Map ? details.cast<String, Object?>() : null;
  }

  /// The subscription it bills.
  String? get subscriptionId =>
      _parentSubscriptionDetails?['subscription'] as String? ?? subscription.v;

  /// The metadata of the subscription it bills (when it was made).
  Map<String, Object?>? get subscriptionMetadata {
    var metadata =
        _parentSubscriptionDetails?['metadata'] ??
        subscriptionDetails.v?['metadata'];
    return metadata is Map ? metadata.cast<String, Object?>() : null;
  }

  /// The tax (cents), null when unknown.
  int? get taxAmount {
    var taxes = totalTaxes.v;
    if (taxes != null && taxes.isNotEmpty) {
      var sum = 0;
      for (var tax in taxes) {
        if (tax is Map && tax['amount'] is num) {
          sum += (tax['amount'] as num).toInt();
        }
      }
      return sum;
    }
    return tax.v;
  }

  /// When it was paid (unix seconds).
  int? get paidAtSeconds => (statusTransitions.v?['paid_at'] as num?)?.toInt();

  /// When it was voided (unix seconds).
  int? get voidedAtSeconds =>
      (statusTransitions.v?['voided_at'] as num?)?.toInt();

  @override
  CvFields get fields => [
    id,
    number,
    status,
    currency,
    created,
    total,
    subtotal,
    amountDue,
    amountPaid,
    amountRemaining,
    tax,
    totalTaxes,
    customer,
    customerEmail,
    customerName,
    hostedInvoiceUrl,
    invoicePdf,
    billingReason,
    periodStart,
    periodEnd,
    livemode,
    subscription,
    subscriptionDetails,
    parent,
    statusTransitions,
    ...metadataMixinFields,
  ];
}

/// A page of invoices, newest first.
class StripeApiInvoiceList extends CvModelBase {
  /// More after the last one.
  final hasMore = CvField<bool>('has_more');

  /// The invoices.
  final data = CvModelListField<StripeApiInvoice>('data');

  @override
  CvFields get fields => [data, hasMore];
}

/// https://docs.stripe.com/api/invoices/list
class StripeApiInvoiceListOptions extends CvModelBase {
  /// The invoices of a customer.
  final customer = CvField<String>('customer');

  /// The invoices of a subscription.
  final subscription = CvField<String>('subscription');

  /// The invoices of a status ([stripeInvoiceStatusDraft]...), all when
  /// null.
  final status = CvField<String>('status');

  /// 1 to 100, 10 by default.
  final limit = CvField<int>('limit');

  /// The page after this invoice id.
  final startingAfter = CvField<String>('starting_after');

  @override
  CvFields get fields => [customer, subscription, status, limit, startingAfter];

  /// The query parameters.
  Map<String, String> toQueryParameters() => {
    'customer': ?customer.v,
    'subscription': ?subscription.v,
    'status': ?status.v,
    if (limit.v case var limit?) 'limit': '$limit',
    'starting_after': ?startingAfter.v,
  };
}
