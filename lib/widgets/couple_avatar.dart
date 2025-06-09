import 'package:flutter/material.dart';

class CoupleAvatar extends StatelessWidget {
  final String name;
  final String? imageUrl;
  final double size;

  const CoupleAvatar({
    Key? key,
    required this.name,
    this.imageUrl,
    this.size = 70,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.pink[200]!,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.pink.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildPlaceholder();
                    },
                  )
                : _buildPlaceholder(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.pink[700],
            shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.white.withOpacity(0.5),
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.pink[50],
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size / 2,
            fontWeight: FontWeight.bold,
            color: Colors.pink[300],
          ),
        ),
      ),
    );
  }
}