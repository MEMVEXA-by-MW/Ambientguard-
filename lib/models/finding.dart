enum FindingType { camera, microphone, speaker, display, networkDevice, notice, unknown }

enum RiskLevel { low, medium, high }

class Finding {
  const Finding({
    required this.id,
    required this.name,
    required this.type,
    required this.risk,
    required this.confidence,
    required this.reason,
    required this.source,
  });

  final String id;
  final String name;
  final FindingType type;
  final RiskLevel risk;
  final double confidence;
  final String reason;
  final String source;

  Map<String, Object> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'risk': risk.name,
        'confidence': confidence,
        'reason': reason,
        'source': source,
      };

  factory Finding.fromJson(Map<String, dynamic> json) => Finding(
        id: json['id'] as String,
        name: json['name'] as String,
        type: FindingType.values.byName(json['type'] as String),
        risk: RiskLevel.values.byName(json['risk'] as String),
        confidence: (json['confidence'] as num).toDouble(),
        reason: json['reason'] as String,
        source: json['source'] as String,
      );
}

