
import 'package:clean_architecture_tdd_course/core/error/failures.dart';
import 'package:clean_architecture_tdd_course/core/util/input_converter.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/presentation/bloc/number_trivia_event.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/presentation/bloc/number_trivia_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';


class MockGetConcreteNumberTrivia extends Mock implements GetConcreteNumberTrivia {}
class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}
class MockInputConverter extends Mock implements InputConverter {}

void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockConcrete;
  late MockGetRandomNumberTrivia mockRandom;
  late MockInputConverter mockInput;

  setUp(() {
    mockConcrete = MockGetConcreteNumberTrivia();
    mockRandom = MockGetRandomNumberTrivia();
    mockInput = MockInputConverter();
    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockConcrete,
      getRandomNumberTrivia: mockRandom,
      inputConverter: mockInput,
    );
  });

  const tTrivia = NumberTrivia(number: 1, text: 'test');

  test('initial state should be Empty', () {
    expect(bloc.state, const Empty());
  });

  blocTest<NumberTriviaBloc, NumberTriviaState>(
    'should emit [Error] when input is invalid',
    build: () {
      when(() => mockInput.stringToUnsignedInteger(any()))
          .thenReturn(const Left(InvalidInputFailure()));
      return bloc;
    },
    act: (bloc) => bloc.add(const GetTriviaForConcreteNumber('abc')),
    expect: () => [
      const Error(message: INVALID_INPUT_FAILURE_MESSAGE),
    ],
    verify: (_) {
      verify(() => mockInput.stringToUnsignedInteger('abc')).called(1);
      verifyNoMoreInteractions(mockConcrete);
    },
  );

  blocTest<NumberTriviaBloc, NumberTriviaState>(
    'should emit [Loading, Loaded] when concrete trivia is returned',
    build: () {
      when(() => mockInput.stringToUnsignedInteger(any()))
          .thenReturn(const Right(1));
      when(() => mockConcrete(any()))
          .thenAnswer((_) async => const Right(tTrivia));
      return bloc;
    },
    act: (bloc) => bloc.add(const GetTriviaForConcreteNumber('1')),
    expect: () => [
      const Loading(),
      const Loaded(trivia: tTrivia),
    ],
  );

  blocTest<NumberTriviaBloc, NumberTriviaState>(
    'should emit [Loading, Error] when concrete usecase returns ServerFailure',
    build: () {
      when(() => mockInput.stringToUnsignedInteger(any()))
          .thenReturn(const Right(1));
      when(() => mockConcrete(any()))
          .thenAnswer((_) async => const Left(ServerFailure()));
      return bloc;
    },
    act: (bloc) => bloc.add(const GetTriviaForConcreteNumber('1')),
    expect: () => [
      const Loading(),
      const Error(message: SERVER_FAILURE_MESSAGE),
    ],
  );

  blocTest<NumberTriviaBloc, NumberTriviaState>(
    'should emit [Loading, Loaded] when random trivia is returned',
    build: () {
      when(() => mockRandom(any()))
          .thenAnswer((_) async => const Right(tTrivia));
      return bloc;
    },
    act: (bloc) => bloc.add(const GetTriviaForRandomNumber()),
    expect: () => [
      const Loading(),
      const Loaded(trivia: tTrivia),
    ],
  );
}
