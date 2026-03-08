import 'package:cine_stream/core/constants/hive_table_constant.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HiveTableConstant', () {
    test('dbName should be "cinestream_db"', () {
      expect(HiveTableConstant.dbName, 'cinestream_db');
    });

    test('authTypeId should be 0', () {
      expect(HiveTableConstant.authTypeId, 0);
    });

    test('authTableName should be "auth_table"', () {
      expect(HiveTableConstant.authTableName, 'auth_table');
    });
  });
}
