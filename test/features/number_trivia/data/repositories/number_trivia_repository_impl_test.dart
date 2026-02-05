import 'package:clean_architecture_tdd_course/core/error/exceptions.dart';
import 'package:clean_architecture_tdd_course/core/error/failures.dart';
import 'package:clean_architecture_tdd_course/core/network/network_info.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockLocalDataSource extends Mock implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late NumberTriviaRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;
  late MockNetworkInfo mockNetwork;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    mockNetwork = MockNetworkInfo();
    repository = NumberTriviaRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
      networkInfo: mockNetwork,
    );
  });

  const tNumber = 1;
  const tModel = NumberTriviaModel(number: 1, text: 'test');

  group('getConcreteNumberTrivia', () {
    test('should check if the device is online', () async {
      when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      when(
        () => mockRemote.getConcreteNumberTrivia(any()),
      ).thenAnswer((_) async => tModel);
      when(() => mockLocal.cacheNumberTrivia(any())).thenAnswer((_) async {});

      await repository.getConcreteNumberTrivia(tNumber);

      verify(() => mockNetwork.isConnected).called(1);
    });

    group('device is online', () {
      setUp(() {
        when(() => mockNetwork.isConnected).thenAnswer((_) async => true);
      });

      test('should return remote data when call is successful', () async {
        when(
          () => mockRemote.getConcreteNumberTrivia(tNumber),
        ).thenAnswer((_) async => tModel);
        when(
          () => mockLocal.cacheNumberTrivia(tModel),
        ).thenAnswer((_) async {});

        final result = await repository.getConcreteNumberTrivia(tNumber);

        verify(() => mockRemote.getConcreteNumberTrivia(tNumber)).called(1);
        verify(() => mockLocal.cacheNumberTrivia(tModel)).called(1);
        expect(result, const Right(tModel));
      });

      test(
        'should return ServerFailure when remote throws ServerException',
        () async {
          when(
            () => mockRemote.getConcreteNumberTrivia(tNumber),
          ).thenThrow(ServerException());

          final result = await repository.getConcreteNumberTrivia(tNumber);

          verify(() => mockRemote.getConcreteNumberTrivia(tNumber)).called(1);
          verifyNever(() => mockLocal.cacheNumberTrivia(any()));
          expect(result, const Left(ServerFailure()));
        },
      );
    });

    group('device is offline', () {
      setUp(() {
        when(() => mockNetwork.isConnected).thenAnswer((_) async => false);
      });

      test('should return last cached data when present', () async {
        when(
          () => mockLocal.getLastNumberTrivia(),
        ).thenAnswer((_) async => tModel);

        final result = await repository.getConcreteNumberTrivia(tNumber);

        verify(() => mockLocal.getLastNumberTrivia()).called(1);
        verifyNever(() => mockRemote.getConcreteNumberTrivia(any()));
        expect(result, const Right(tModel));
      });

      test('should return CacheFailure when no cached data', () async {
        when(() => mockLocal.getLastNumberTrivia()).thenThrow(CacheException());

        final result = await repository.getConcreteNumberTrivia(tNumber);

        verify(() => mockLocal.getLastNumberTrivia()).called(1);
        expect(result, const Left(CacheFailure()));
      });
    });
  });
}
