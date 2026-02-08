import 'package:clean_architecture_tdd_course/core/usecases/usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_concrete_number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';
import 'number_trivia_event.dart';
import 'number_trivia_state.dart';


const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc({
    required this.getConcreteNumberTrivia,
    required this.getRandomNumberTrivia,
    required this.inputConverter,
  }) : super(const Empty()) {
    on<GetTriviaForConcreteNumber>(_onConcrete);
    on<GetTriviaForRandomNumber>(_onRandom);
  }

  Future<void> _onConcrete(
      GetTriviaForConcreteNumber event,
      Emitter<NumberTriviaState> emit,
      ) async {
    final inputEither =
    inputConverter.stringToUnsignedInteger(event.numberString);

    await inputEither.fold(
          (failure) async {
        emit(const Error(message: INVALID_INPUT_FAILURE_MESSAGE));
      },
          (number) async {
        emit(const Loading());
        final result = await getConcreteNumberTrivia(Params(number: number));
        emit(_eitherToState(result as Either<Failure, NumberTrivia>));
      },
    );
  }

  Future<void> _onRandom(
      GetTriviaForRandomNumber event,
      Emitter<NumberTriviaState> emit,
      ) async {
    emit(const Loading());
    final result = await getRandomNumberTrivia(const NoParams());
    emit(_eitherToState(result as Either<Failure, NumberTrivia>));
  }

  NumberTriviaState _eitherToState(Either<Failure, NumberTrivia> either) {
    return either.fold(
          (failure) => Error(message: _mapFailureToMessage(failure)),
          (trivia) => Loaded(trivia: trivia),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure.runtimeType) {
      ServerFailure => SERVER_FAILURE_MESSAGE,
      CacheFailure => CACHE_FAILURE_MESSAGE,
      InvalidInputFailure => INVALID_INPUT_FAILURE_MESSAGE,
      _ => 'Unexpected Error',
    };
  }
}
