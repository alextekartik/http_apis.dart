import 'package:tekartik_deezer_api/deezer_api.dart';
import 'package:tekartik_deezer_api/src/deezer_json.dart';
import 'package:test/test.dart';

void main() {
  initDeezerCvBuilders();
  test('deezerCheckJsonResult', () {
    expect(deezerCheckJsonResult({'id': 27}), {'id': 27});
    expect(deezerCheckJsonResult([1]), [1]);
    try {
      deezerCheckJsonResult({
        'error': {'type': 'DataException', 'message': 'no data', 'code': 800},
      });
      fail('should fail');
    } on DeezerApiException catch (e) {
      expect(e.errorInfo!.type.v, 'DataException');
      expect(e.errorInfo!.code.v, 800);
      expect(e.toString(), 'DataException: no data');
    }
  });
}
