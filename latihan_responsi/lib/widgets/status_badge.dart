import 'package:flutter/material.dart';

// Widget Badge untuk menampilkan status karakter (Alive: hijau, Dead: merah, Unknown: abu-abu)
class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    Color dotColor;
    Color bgColor;

    final lower = status.toLowerCase();
    if (lower == 'alive') {
      dotColor = const Color(0xFF10B981); // Hijau untuk status hidup
      bgColor = const Color(0xFF10B981).withValues(alpha: 0.15);
    } else if (lower == 'dead') {
      dotColor = const Color(0xFFEF4444); // Merah untuk status mati
      bgColor = const Color(0xFFEF4444).withValues(alpha: 0.15);
    } else {
      dotColor = const Color(0xFF9CA3AF); // Abu-abu untuk status unknown
      bgColor = const Color(0xFF9CA3AF).withValues(alpha: 0.15);
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Lingkaran kecil berwarna sesuai status
          Container(
            width: compact ? 6 : 8,
            height: compact ? 6 : 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          // Teks status
          Text(
            status,
            style: TextStyle(
              color: dotColor,
              fontWeight: FontWeight.bold,
              fontSize: compact ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
