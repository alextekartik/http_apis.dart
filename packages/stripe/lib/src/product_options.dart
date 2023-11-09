/// https://stripe.com/docs/api/products/create
class StripeApiProductOptions {
  final String name;
  final String? description;

  StripeApiProductOptions({required this.name, this.description});
}
