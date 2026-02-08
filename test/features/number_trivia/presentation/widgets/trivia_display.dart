import 'package:flutter/material.dart';
import '../../../../../lib/features/number_trivia/domain/entities/number_trivia.dart';


class TriviaDisplay extends StatelessWidget {
  final NumberTrivia trivia;
  const TriviaDisplay({super.key, required this.trivia});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          trivia.number.toString(),
          style: const TextStyle(fontSize: 44, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          trivia.text,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
