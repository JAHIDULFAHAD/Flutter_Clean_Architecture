import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../lib/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import '../../../../../lib/features/number_trivia/presentation/bloc/number_trivia_event.dart';
import '../../../../../lib/features/number_trivia/presentation/bloc/number_trivia_state.dart';
import '../widgets/loading_widget.dart';
import '../widgets/message_display.dart';
import '../widgets/trivia_controls.dart';
import '../widgets/trivia_display.dart';



class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Trivia')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                  builder: (context, state) {
                    return switch (state) {
                      Empty() => const MessageDisplay(
                        message: 'Start searching!',
                      ),
                      Loading() => const LoadingWidget(),
                      Loaded() => TriviaDisplay(trivia: state.trivia),
                      Error() => MessageDisplay(message: state.message),
                      _ => const SizedBox.shrink(),
                    };
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            TriviaControls(
              onConcrete: (value) => context
                  .read<NumberTriviaBloc>()
                  .add(GetTriviaForConcreteNumber(value)),
              onRandom: () => context
                  .read<NumberTriviaBloc>()
                  .add(const GetTriviaForRandomNumber()),
            ),
          ],
        ),
      ),
    );
  }
}
