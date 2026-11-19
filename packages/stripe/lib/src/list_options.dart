import 'package:cv/cv.dart';

/// The options every Stripe list endpoint takes: a page ([limit],
/// [startingAfter]), a creation range ([createdGte], [createdLt], unix
/// seconds) and the fields to expand ([expand], `data.line_items`...).
///
/// The class adding it returns [listQueryParameters] (plus its own filters)
/// from its `toQueryParameters`.
mixin StripeApiListOptionsMixin on CvModelBase {
  /// 1 to 100, 10 by default.
  final limit = CvField<int>('limit');

  /// The page after this object id (the last id of the previous page).
  final startingAfter = CvField<String>('starting_after');

  /// Created at or after (unix time in seconds).
  final createdGte = CvField<int>('created_gte');

  /// Created before (unix time in seconds).
  final createdLt = CvField<int>('created_lt');

  /// The fields to expand (`data.line_items`), `expand[]` repeated.
  final expand = CvListField<String>('expand');

  /// The fields of the mixin.
  List<CvField<Object?>> get listOptionsMixinFields => [
    limit,
    startingAfter,
    createdGte,
    createdLt,
    expand,
  ];

  /// The query parameters of the mixin fields.
  Map<String, Object> listQueryParameters() => {
    if (limit.v case var limit?) 'limit': '$limit',
    'starting_after': ?startingAfter.v,
    if (createdGte.v case var value?) 'created[gte]': '$value',
    if (createdLt.v case var value?) 'created[lt]': '$value',
    if (expand.v case var expand? when expand.isNotEmpty) 'expand[]': expand,
  };
}

/// The answer of a delete (`{id, deleted: true}`).
class StripeApiDeleted extends CvModelBase {
  /// The id of the deleted object.
  final id = CvField<String>('id');

  /// true once deleted.
  final deleted = CvField<bool>('deleted');

  @override
  CvFields get fields => [id, deleted];
}

/// A Stripe date (unix seconds) as a [DateTime], null when null.
DateTime? stripeApiDateTime(int? seconds) => seconds == null
    ? null
    : DateTime.fromMillisecondsSinceEpoch(seconds * 1000, isUtc: true);

/// A [DateTime] as a Stripe date (unix seconds).
int stripeApiSeconds(DateTime dateTime) =>
    dateTime.millisecondsSinceEpoch ~/ 1000;
