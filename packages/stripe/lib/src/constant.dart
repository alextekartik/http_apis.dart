/// Euro price.
const stripeCurrencyEuro = 'eur';

/// price: recurring.interval
/// enum
/// The frequency at which a subscription is billed. One of day, week, month or year.
///
/// Possible enum values
/// - month
/// - year
/// - week
/// - day
///
/// recurring.interval_count
/// positive integer
/// The number of intervals (specified in the interval attribute) between subscription billings. For example, interval=month and interval_count=3 bills every 3 months.

const stripePriceRecurringIntervalYear = 'year';
const stripePriceRecurringIntervalMonth = 'month';
const stripePriceRecurringIntervalWeek = 'week';
const stripePriceRecurringIntervalDay = 'day';

/// Supported locale
const stripeLocaleFr = 'fr';
