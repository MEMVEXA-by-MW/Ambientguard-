import 'finding.dart';

class RoomScan {
  const RoomScan({
    required this.id,
    required this.label,
    required this.createdAt,
    required this.findings,
    this.noticeUrl,
  });

  final String id;
  final String label;
  final DateTime createdAt;
  final List<Finding> findings;
  final String? noticeUrl;

  RiskLevel get overallRisk {
    if (findings.any((item) => item.risk == RiskLevel.high)) return RiskLevel.high;
    if (findings.any((item) => item.risk == RiskLevel.medium)) return RiskLevel.medium;
    return RiskLevel.low;
  }

  int get score {
    // No findings means "inconclusive", not "safe".
    if (findings.isEmpty) return 50;
    final penalties = findings.map((finding) => switch (finding.risk) {
          RiskLevel.low => 6,
          RiskLevel.medium => 18,
          RiskLevel.high => 32,
        });
    return (100 - penalties.fold<int>(0, (a, b) => a + b)).clamp(0, 100);
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'label': label,
        'createdAt': createdAt.toIso8601String(),
        'findings': findings.map((item) => item.toJson()).toList(),
        'noticeUrl': noticeUrl,
      };

  factory RoomScan.fromJson(Map<String, dynamic> json) => RoomScan(
        id: json['id'] as String,
        label: json['label'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        findings: (json['findings'] as List<dynamic>)
            .map((item) => Finding.fromJson(item as Map<String, dynamic>))
            .toList(),
        noticeUrl: json['noticeUrl'] as String?,
      );
}
