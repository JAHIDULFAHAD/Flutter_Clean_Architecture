import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/number_trivia.dart';
import '../repositories/number_trivia_repository.dart';

class GetConcreteNumberTrivia {
  final NumberTriviaRepository repository;

  const GetConcreteNumberTrivia(this.repository);

  Future<Either<Failure, NumberTrivia>> call(int number) async {
    return repository.getConcreteNumberTrivia(number);
  }
}
