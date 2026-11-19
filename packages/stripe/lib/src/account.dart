import 'package:cv/cv.dart';

/// The payout schedule of an account.
class StripeApiPayoutSchedule extends CvModelBase {
  /// `manual`, `daily`, `weekly` or `monthly`.
  final interval = CvField<String>('interval');

  /// Days a payment waits before it can be paid out.
  final delayDays = CvField<int>('delay_days');

  /// Day of the week (`monday`...) of a `weekly` schedule.
  final weeklyAnchor = CvField<String>('weekly_anchor');

  /// Day of the month (1 to 31) of a `monthly` schedule.
  final monthlyAnchor = CvField<int>('monthly_anchor');

  @override
  CvFields get fields => [interval, delayDays, weeklyAnchor, monthlyAnchor];
}

/// `settings.payouts` of an account.
class StripeApiAccountPayoutSettings extends CvModelBase {
  /// The schedule.
  final schedule = CvModelField<StripeApiPayoutSchedule>('schedule');

  /// What the bank statement shows.
  final statementDescriptor = CvField<String>('statement_descriptor');

  @override
  CvFields get fields => [schedule, statementDescriptor];
}

/// `settings.dashboard` of an account.
class StripeApiAccountDashboardSettings extends CvModelBase {
  /// The name shown in the dashboard.
  final displayName = CvField<String>('display_name');

  @override
  CvFields get fields => [displayName];
}

/// `settings` of an account (the parts read here).
class StripeApiAccountSettings extends CvModelBase {
  /// The payouts.
  final payouts = CvModelField<StripeApiAccountPayoutSettings>('payouts');

  /// The dashboard.
  final dashboard = CvModelField<StripeApiAccountDashboardSettings>(
    'dashboard',
  );

  @override
  CvFields get fields => [payouts, dashboard];
}

/// `business_profile` of an account.
class StripeApiAccountBusinessProfile extends CvModelBase {
  /// The public name.
  final name = CvField<String>('name');

  /// The web site.
  final url = CvField<String>('url');

  /// The support email.
  final supportEmail = CvField<String>('support_email');

  @override
  CvFields get fields => [name, url, supportEmail];
}

/// The account of the key (`GET /v1/account`, a restricted key may not read
/// it).
/// https://docs.stripe.com/api/accounts/object
class StripeApiAccount extends CvModelBase {
  /// `acct_...`.
  final id = CvField<String>('id');

  /// The email of the account.
  final email = CvField<String>('email');

  /// `FR`...
  final country = CvField<String>('country');

  /// `eur`...
  final defaultCurrency = CvField<String>('default_currency');

  /// Can take payments.
  final chargesEnabled = CvField<bool>('charges_enabled');

  /// Can be paid out.
  final payoutsEnabled = CvField<bool>('payouts_enabled');

  /// The business profile.
  final businessProfile = CvModelField<StripeApiAccountBusinessProfile>(
    'business_profile',
  );

  /// The settings.
  final settings = CvModelField<StripeApiAccountSettings>('settings');

  @override
  CvFields get fields => [
    id,
    email,
    country,
    defaultCurrency,
    chargesEnabled,
    payoutsEnabled,
    businessProfile,
    settings,
  ];
}
