import 'package:clean_architecture_tdd_course/core/network/network_info.dart';
import 'package:clean_architecture_tdd_course/core/network/network_info_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mocktail/mocktail.dart';

class MockInternetConnectionChecker extends Mock
    implements InternetConnectionChecker {}

void main() {
  late NetworkInfo networkInfo;
  late MockInternetConnectionChecker mockChecker;

  setUp(() {
    mockChecker = MockInternetConnectionChecker();
    networkInfo = NetworkInfoImpl(mockChecker);
  });

  test('should forward the call to InternetConnectionChecker.hasConnection', () {
    final tFuture = Future.value(true);

    // Arrange
    when(() => mockChecker.hasConnection).thenAnswer((_) => tFuture);

    // Act
    final result = networkInfo.isConnected;

    // Assert
    verify(() => mockChecker.hasConnection).called(1);
    expect(result, tFuture);
  });
}
