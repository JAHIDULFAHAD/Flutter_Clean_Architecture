import 'package:dartz/dartz.dart';

import '../error/failures.dart';

class InputConverter {
  Either<Failure, int> stringToUnsignedInteger(String str) {
    try {
      final value = int.parse(str);
      if (value < 0) {
        return const Left(InvalidInputFailure());
      }
      return Right(value);
    } catch (_) {
      return const Left(InvalidInputFailure());
    }
  }
}
