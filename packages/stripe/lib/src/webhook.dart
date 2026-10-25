import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:cv/cv.dart';

import 'stripe_models.dart';

/// Checkout completed.
const stripeEventCheckoutSessionCompleted = 'checkout.session.completed';

/// A subscription made.
const stripeEventCustomerSubscriptionCreated = 'customer.subscription.created';

/// A subscription changed (renewed, cancelled at period end, past due...).
const stripeEventCustomerSubscriptionUpdated = 'customer.subscription.updated';

/// A subscription ended.
const stripeEventCustomerSubscriptionDeleted = 'customer.subscription.deleted';

/// An invoice paid (a renewal).
const stripeEventInvoicePaid = 'invoice.paid';

/// An invoice payment failed.
const stripeEventInvoicePaymentFailed = 'invoice.payment_failed';

/// https://docs.stripe.com/api/webhook_endpoints/create
class StripeApiWebhookEndpointCreate extends CvModelBase
    with StripeApiMetadataMixin {
  /// The url Stripe posts the events to.
  final url = CvField<String>('url');

  /// The event types (`checkout.session.completed`...).
  final enabledEvents = CvListField<String>('enabled_events');

  /// A description.
  final description = CvField<String>('description');

  /// The API version of the events, the account's when null.
  final apiVersion = CvField<String>('api_version');

  @override
  CvFields get fields => [
    url,
    enabledEvents,
    description,
    apiVersion,
    ...metadataMixinFields,
  ];
}

/// A webhook endpoint; its [secret] only in the answer of its creation.
class StripeApiWebhookEndpoint extends CvModelBase with StripeApiMetadataMixin {
  /// `we_...`.
  final id = CvField<String>('id');

  /// See [StripeApiWebhookEndpointCreate.url].
  final url = CvField<String>('url');

  /// The signing secret (`whsec_...`), at creation only.
  final secret = CvField<String>('secret');

  /// `enabled`, `disabled`.
  final status = CvField<String>('status');

  /// See [StripeApiWebhookEndpointCreate.enabledEvents].
  final enabledEvents = CvListField<String>('enabled_events');

  /// Livemode.
  final livemode = CvField<bool>('livemode');

  @override
  CvFields get fields => [
    id,
    url,
    secret,
    status,
    enabledEvents,
    livemode,
    ...metadataMixinFields,
  ];
}

/// A list of webhook endpoints.
class StripeApiWebhookEndpointList extends CvModelBase {
  /// More after.
  final hasMore = CvField<bool>('has_more');

  /// The endpoints.
  final data = CvModelListField<StripeApiWebhookEndpoint>('data');

  @override
  CvFields get fields => [data, hasMore];
}

/// An event posted to a webhook endpoint.
class StripeApiEvent extends CvModelBase {
  /// `evt_...`.
  final id = CvField<String>('id');

  /// `checkout.session.completed`...
  final type = CvField<String>('type');

  /// Unix seconds.
  final created = CvField<int>('created');

  /// Livemode.
  final livemode = CvField<bool>('livemode');

  /// `object`: the checkout session, the subscription, the invoice...
  final data = CvField<Model>('data');

  /// The object of the event, as Stripe sends it.
  Map<String, Object?> get object {
    var object = data.v?['object'];
    return object is Map ? object.cast<String, Object?>() : const {};
  }

  @override
  CvFields get fields => [id, type, created, livemode, data];
}

/// Stripe webhook signature check (`Stripe-Signature` header).
///
/// The header is `t=<unix seconds>,v1=<hex hmac>[,v1=...][,v0=...]`; the
/// signed payload is `<t>.<raw body>` and the signature an HMAC SHA256 with
/// the endpoint signing secret (`whsec_...`).
class StripeWebhookSignature {
  /// Timestamp, unix seconds.
  final int timestamp;

  /// The `v1` signatures (hex).
  final List<String> signatures;

  /// A parsed header.
  const StripeWebhookSignature({
    required this.timestamp,
    required this.signatures,
  });

  /// Parse a header, null when malformed.
  static StripeWebhookSignature? parse(String? header) {
    if (header == null) {
      return null;
    }
    int? timestamp;
    var signatures = <String>[];
    for (var part in header.split(',')) {
      var index = part.indexOf('=');
      if (index <= 0) {
        continue;
      }
      var key = part.substring(0, index).trim();
      var value = part.substring(index + 1).trim();
      if (key == 't') {
        timestamp = int.tryParse(value);
      } else if (key == 'v1') {
        signatures.add(value.toLowerCase());
      }
    }
    if (timestamp == null || signatures.isEmpty) {
      return null;
    }
    return StripeWebhookSignature(timestamp: timestamp, signatures: signatures);
  }

  /// The expected `v1` signature of [payload] at [timestamp] with [secret].
  static String sign({
    required String payload,
    required int timestamp,
    required String secret,
  }) {
    var hmac = Hmac(sha256, utf8.encode(secret));
    return hmac.convert(utf8.encode('$timestamp.$payload')).toString();
  }

  /// A header as Stripe would send it (tests).
  static String header({
    required String payload,
    required int timestamp,
    required String secret,
  }) =>
      't=$timestamp,v1=${sign(payload: payload, timestamp: timestamp, secret: secret)}';

  /// Constant time comparison.
  static bool _secureEquals(String a, String b) {
    if (a.length != b.length) {
      return false;
    }
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// True when [header] signs [payload] with [secret] and its timestamp is
  /// within [tolerance] of [now] (replay protection).
  static bool verify({
    required String payload,
    required String? header,
    required String secret,
    DateTime? now,
    Duration tolerance = const Duration(minutes: 5),
  }) {
    var parsed = parse(header);
    if (parsed == null) {
      return false;
    }
    var nowSeconds =
        (now ?? DateTime.now().toUtc()).millisecondsSinceEpoch ~/ 1000;
    if ((nowSeconds - parsed.timestamp).abs() > tolerance.inSeconds) {
      return false;
    }
    var expected = sign(
      payload: payload,
      timestamp: parsed.timestamp,
      secret: secret,
    );
    for (var signature in parsed.signatures) {
      if (_secureEquals(signature, expected)) {
        return true;
      }
    }
    return false;
  }
}
