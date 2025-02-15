import 'package:flutter/material.dart';

class ResponseLoading extends StatelessWidget {
  const ResponseLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade400,
                  Colors.grey.shade200,
                ],
                stops: const [0.1, 0.5, 0.9],
                begin: const Alignment(-1.0, -0.3),
                end: const Alignment(1.0, 0.3),
                tileMode: TileMode.clamp,
              ).createShader(bounds);
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  Colors.grey.shade200,
                  Colors.grey.shade400,
                  Colors.grey.shade200,
                ],
                stops: const [0.1, 0.5, 0.9],
                begin: const Alignment(-1.0, -0.3),
                end: const Alignment(1.0, 0.3),
                tileMode: TileMode.clamp,
              ).createShader(bounds);
            },
            child: const Text(
              'Processing response...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
