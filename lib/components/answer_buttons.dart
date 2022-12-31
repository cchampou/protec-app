import 'package:flutter/material.dart';

class AnswerButtons extends StatelessWidget {
  const AnswerButtons(
      {super.key,
      required this.setAvailability,
      required this.cancel,
      required this.canCancel});

  final bool canCancel;
  final void Function(BuildContext, bool) setAvailability;
  final void Function() cancel;

  @override
  build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    setAvailability(context, true);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.green),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: const Text('Disponible'),
                )),
            Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton(
                  onPressed: () {
                    setAvailability(context, false);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.red),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  child: const Text('Non disponible'),
                )),
          ],
        ),
        if (canCancel)
          TextButton(
            onPressed: cancel,
            child: const Text('Annuler', style: TextStyle(fontSize: 20)),
          ),
      ],
    );
  }
}
