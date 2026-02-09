import 'package:flutter/material.dart';

class CommentaryWidget extends StatelessWidget {
  final List<String> commentary;

  const CommentaryWidget({super.key, required this.commentary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            commentary
                .map(
                  (c) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      c,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }
}
