## 1.3.0

- Checkout Session: `automaticTax` (Stripe Tax), `billingAddressCollection`,
  `customerUpdate`, `taxIdCollection`.
- Products: `taxCode`, `updateProduct` (`StripeApiProductUpdate`).

## 1.2.0

- `StripeApiCredentials.toMapEnc` / `fromMapEnc`: the credentials as an
  obfuscated map (the publishable key slightly obfuscated in clear, the
  whole aes encrypted, the password next to it); `toJsonEnc` writes it as a
  json to keep in a git ignored file and paste in a `fromMapEnc` call;
  `toMap` / `fromMap`.

## 1.1.0

- Subscriptions: prices by lookup key, Checkout Sessions, the customer
  portal (sessions, configurations), subscriptions (get, update, cancel),
  webhook endpoints, webhook events and `StripeWebhookSignature` (from
  calendelio).

## 1.0.0

- Initial version.
