import 'package:cv/cv.dart';

import 'price_model.dart';

/// A line item of a Checkout Session or a Payment Link (read).
/// https://docs.stripe.com/api/checkout/sessions/line_items
class StripeApiLineItem extends CvModelBase {
  /// `li_...`.
  final id = CvField<String>('id');

  /// The product name, usually.
  final description = CvField<String>('description');

  /// The quantity.
  final quantity = CvField<int>('quantity');

  /// Cents, after discounts and taxes.
  final amountTotal = CvField<int>('amount_total');

  /// Cents, before discounts and taxes.
  final amountSubtotal = CvField<int>('amount_subtotal');

  /// `eur`...
  final currency = CvField<String>('currency');

  /// The price (its `product` id).
  final price = CvModelField<StripeApiPrice>('price');

  @override
  CvFields get fields => [
    id,
    description,
    quantity,
    amountTotal,
    amountSubtotal,
    currency,
    price,
  ];
}

/// A page of line items.
class StripeApiLineItemList extends CvModelBase {
  /// More after.
  final hasMore = CvField<bool>('has_more');

  /// The line items.
  final data = CvModelListField<StripeApiLineItem>('data');

  @override
  CvFields get fields => [data, hasMore];
}
