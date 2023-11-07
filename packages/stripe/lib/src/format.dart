/// An amount has to be an integer (cents) in a string.
String formatAmount(num amount) {
  return (amount * 100).round().toString();
}
