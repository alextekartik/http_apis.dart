/// price: recurring.usage_type
/// enum
/// Configures how the quantity per period should be determined.
/// Can be either metered or licensed. licensed automatically bills the quantity
/// set when adding it to a subscription. metered aggregates the total usage
/// based on usage records. Defaults to licensed.
///
/// Possible enum values
/// metered
/// licensed
const stripeRecurringUsageTypeLicensed = 'licensed';
const stripeRecurringUsageTypeMetered = 'metered';

/// price: type
/// string
/// One of one_time or recurring depending on whether the price is for a
/// one-time purchase or a recurring (subscription) purchase.
const stripePriceTypeOneTime = 'one_time';
const stripePriceTypeRecurring = 'recurring';
