import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_data_source_impl.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:http/http.dart' as http;

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(mockHttpClient);
  });

  const tNumber = 1;
  final tModel =
  NumberTriviaModel(number: 1, text: 'Test Text');

  group('getConcreteNumberTrivia', () {
    test('should perform a GET request with correct URL and headers', () async {
      // Arrange
      when(() => mockHttpClient.get(
        any(),
        headers: any(named: 'headers'),
      )).thenAnswer(
            (_) async => http.Response(
          fixture('trivia.json'),
          200,
        ),
      );

      // Act
      await dataSource.getConcreteNumberTrivia(tNumber);

      // Assert
      verify(() => mockHttpClient.get(
        Uri.parse('http://numbersapi.com/$tNumber?json'),
        headers: {'Content-Type': 'application/json'},
      )).called(1);
    });

    test('should return NumberTriviaModel when status code is 200', () async {
      // Arrange
      when(() => mockHttpClient.get(
        any(),
        headers: any(named: 'headers'),
      )).thenAnswer(
            (_) async => http.Response(
          fixture('trivia.json'),
          200,
        ),
      );

      // Act
      final result =
      await dataSource.getConcreteNumberTrivia(tNumber);

      // Assert
      expect(result, tModel);
    });

    test('should throw ServerException when status code is not 200', () async {
      // Arrange
      when(() => mockHttpClient.get(
        any(),
        headers: any(named: 'headers'),
      )).thenAnswer(
            (_) async => http.Response('Something went wrong', 404),
      );

      // Act
      final call = dataSource.getConcreteNumberTrivia;

      // Assert
      expect(() => call(tNumber), throwsA(isA<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    test('should return NumberTriviaModel when status code is 200', () async {
      // Arrange
      when(() => mockHttpClient.get(
        any(),
        headers: any(named: 'headers'),
      )).thenAnswer(
            (_) async => http.Response(
          fixture('trivia.json'),
          200,
        ),
      );

      // Act
      final result = await dataSource.getRandomNumberTrivia();

      // Assert
      expect(result, tModel);
    });
  });
}
