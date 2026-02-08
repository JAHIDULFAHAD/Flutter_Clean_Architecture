import 'dart:convert';

import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_data_source_impl.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements http.Client {}

void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(Uri.parse('http://example.com'));
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(mockHttpClient);
  });

  const tNumber = 1;
  const tModel = NumberTriviaModel(number: 1, text: 'Test Text');

  group('getConcreteNumberTrivia', () {
    test(
        'should perform a GET request with correct URL and headers',
            () async {
          // arrange
          when(
                () => mockHttpClient.get(
              any<Uri>(),
              headers: any(named: 'headers'),
            ),
          ).thenAnswer(
                (_) async => http.Response(fixture('trivia.json'), 200),
          );

          // act
          await dataSource.getConcreteNumberTrivia(tNumber);

          // assert
          verify(
                () => mockHttpClient.get(
              Uri.parse('http://numbersapi.com/$tNumber?json'),
              headers: {'Content-Type': 'application/json'},
            ),
          ).called(1);
        });

    test('should return NumberTriviaModel when status code is 200',
            () async {
          when(
                () => mockHttpClient.get(
              any<Uri>(),
              headers: any(named: 'headers'),
            ),
          ).thenAnswer(
                (_) async => http.Response(fixture('trivia.json'), 200),
          );

          final result =
          await dataSource.getConcreteNumberTrivia(tNumber);

          expect(result, tModel);
        });

    test('should throw ServerException when status code is not 200',
            () async {
          when(
                () => mockHttpClient.get(
              any<Uri>(),
              headers: any(named: 'headers'),
            ),
          ).thenAnswer(
                (_) async => http.Response('Error', 404),
          );

          final call = dataSource.getConcreteNumberTrivia;

          expect(() => call(tNumber),
              throwsA(isA<ServerException>()));
        });
  });

  group('getRandomNumberTrivia', () {
    test('should return NumberTriviaModel when status code is 200',
            () async {
          when(
                () => mockHttpClient.get(
              any<Uri>(),
              headers: any(named: 'headers'),
            ),
          ).thenAnswer(
                (_) async => http.Response(fixture('trivia.json'), 200),
          );

          final result = await dataSource.getRandomNumberTrivia();

          expect(result, tModel);
        });
  });
}
