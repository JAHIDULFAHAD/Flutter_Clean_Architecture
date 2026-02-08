import 'package:flutter/material.dart';

class TriviaControls extends StatefulWidget {
  final void Function(String value) onConcrete;
  final VoidCallback onRandom;

  const TriviaControls({
    super.key,
    required this.onConcrete,
    required this.onRandom,
  });

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _submit() {
    widget.onConcrete(controller.text);
    controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Input a number',
          ),
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _submit,
                child: const Text('Search'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.onRandom,
                child: const Text('Get random trivia'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
