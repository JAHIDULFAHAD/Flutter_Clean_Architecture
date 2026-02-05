import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../../lib/features/number_trivia/data/datasources/number_trivia_local_data_source_impl.dart';

class MockSharedPreferences extends Mock
    implements SharedPreferences {}

void main() {
  late NumberTriviaLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    dataSource = NumberTriviaLocalDataSourceImpl(mockSharedPreferences);
  });

  const tModel =
  NumberTriviaModel(number: 1, text: 'Test Text');

  group('getLastNumberTrivia', () {
    test('should return NumberTriviaModel when cached data is present', () async {
      // Arrange
      when(() => mockSharedPreferences.getString(any()))
          .thenReturn(json.encode(tModel.toJson()));

      // Act
      final result = await dataSource.getLastNumberTrivia();

      // Assert
      verify(() => mockSharedPreferences.getString(CACHED_NUMBER_TRIVIA))
          .called(1);
      expect(result, tModel);
    });

    test('should throw CacheException when there is no cached data', () async {
      // Arrange
      when(() => mockSharedPreferences.getString(any()))
          .thenReturn(null);

      // Act
      final call = dataSource.getLastNumberTrivia;

      // Assert
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });

  group('cacheNumberTrivia', () {
    test('should cache the data in SharedPreferences', () async {
      // Arrange
      when(() => mockSharedPreferences.setString(
        any(),
        any(),
      )).thenAnswer((_) async => true);

      // Act
      await dataSource.cacheNumberTrivia(tModel);

      // Assert
      verify(() => mockSharedPreferences.setString(
        CACHED_NUMBER_TRIVIA,
        json.encode(tModel.toJson()),
      )).called(1);
    });
  });
}
