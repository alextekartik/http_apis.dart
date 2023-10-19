bool get needJsonp => false;
Future<Object> jsonpRequest(Uri uri, {String callbackParam = 'callback'}) =>
    throw UnsupportedError('jsonpRequest on io');
