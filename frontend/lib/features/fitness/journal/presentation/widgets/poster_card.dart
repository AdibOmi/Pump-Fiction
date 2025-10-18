import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.imagePath,
    required this.title,
    this.weight,
  });
  final String imagePath;
  final String title;
  final double? weight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          _buildImage(),
          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black54, Colors.transparent],
              ),
            ),
          ),
          // Title + weight
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (weight != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${weight!.toStringAsFixed(weight! % 1 == 0 ? 0 : 1)} kg',
                    style: GoogleFonts.caveat(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    final isHttp = imagePath.startsWith('http');
    if (isHttp) {
      return Image.network(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.black12,
          child: const Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.white70,
          ),
        ),
      );
    } else {
      return Image.file(
        File(imagePath),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.black12,
          child: const Icon(
            Icons.broken_image,
            size: 48,
            color: Colors.white70,
          ),
        ),
      );
    }
  }
}
