import 'package:clean_architecture_tdd_course/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_tdd_course/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

//fake repository
class MockNumberTriviaRepository extends Mock
    implements NumberTriviaRepository {}

void main() {
  late GetConcreteNumberTrivia usecase;
  late MockNumberTriviaRepository mockRepository;

  setUp(() {
    mockRepository = MockNumberTriviaRepository();
    usecase = GetConcreteNumberTrivia(mockRepository);
  });

  const tNumber = 1;
  const tNumberTrivia = NumberTrivia(number: 1, text: 'test');

  test('should get trivia for the number from the repository', () async {
    // Arrange
    when(() => mockRepository.getConcreteNumberTrivia(any()))
        .thenAnswer((_) async => const Right(tNumberTrivia));

    // Act
    final result = await usecase(tNumber);

    // Assert
    expect(result, const Right(tNumberTrivia));
    verify(() => mockRepository.getConcreteNumberTrivia(tNumber)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
