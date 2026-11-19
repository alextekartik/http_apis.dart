## 1.7.0

- Payment Links read their expanded line items (`lineItemList`, with
  `expand: ['data.line_items']`: the price date is the only date of a link)
  and the paid count of a link paid once
  (`restrictions.completedSessions.count`).

## 1.6.0

- Dashboard and back office calls: `getBalance`, `getAccount` (payout
  schedule), `listBalanceTransactions` (those of a payout), `listPayouts`,
  `listCharges`, `getCharge`, `createRefund`, `listSubscriptions`.
- Checkout Sessions: `listCheckoutSessions` (by Payment Link, status,
  creation range, `expand`), `listCheckoutSessionLineItems`; the session
  model reads its amounts, customer details, payment link and line items.
- Payment Links: `listPaymentLinks`, `listPaymentLinkLineItems`,
  `restrictions` (`completed_sessions.limit`: a link paid once).
- Products: `active` (archive), `defaultPrice`, `created`, metadata,
  `defaultPriceData` on creation, `deleteProduct`, list by `active`; prices
  read `type` and `created`, list pages (`startingAfter`).
- `StripeApiListOptionsMixin` (limit, page, created range, expand),
  `stripeApiDateTime` / `stripeApiSeconds`.
- `stripeApiErrorMessage`: the status and Stripe message of a failed call.

## 1.5.0

- Webhook event constants: `stripeEventCheckoutSessionExpired`,
  `stripeEventCheckoutSessionAsyncPaymentFailed`,
  `stripeEventCheckoutSessionAsyncPaymentSucceeded`.

## 1.4.0

- Invoices: `listInvoices` (`StripeApiInvoiceListOptions`: customer,
  subscription, status, page), `getInvoice`, `StripeApiInvoice` (its
  subscription, metadata and tax read before and after the API version
  2025-03-31).

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
