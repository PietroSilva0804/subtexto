import 'package:flutter/material.dart'; // <-- ESSA LINHA FOI ADICIONADA

class AnalysisResult {
  final String literal;
  final String subtexto;
  final String temperatura;
  final List<String> sinais;
  final String leituraAnsiosa;
  final String leituraNeutra;
  final List<RespostaSugerida> respostasSugeridas;
  final String mensagemOriginal;
  final String contexto;
  final String tipoRelacao;
  final DateTime timestamp;
  String? tagEmocional;

  AnalysisResult({
    required this.literal,
    required this.subtexto,
    required this.temperatura,
    required this.sinais,
    required this.leituraAnsiosa,
    required this.leituraNeutra,
    required this.respostasSugeridas,
    required this.mensagemOriginal,
    required this.contexto,
    required this.tipoRelacao,
    DateTime? timestamp,
    this.tagEmocional,
  }) : timestamp = timestamp ?? DateTime.now();

  factory AnalysisResult.fromJson(
    Map<String, dynamic> json, {
    required String mensagemOriginal,
    required String contexto,
    required String tipoRelacao,
  }) {
    return AnalysisResult(
      literal: json['literal'] ?? '',
      subtexto: json['subtexto'] ?? '',
      temperatura: json['temperatura'] ?? 'ambígua',
      sinais: List<String>.from(json['sinais'] ?? []),
      leituraAnsiosa: json['leitura_ansiosa'] ?? '',
      leituraNeutra: json['leitura_neutra'] ?? '',
      respostasSugeridas: (json['respostas_sugeridas'] as List? ?? [])
          .map((r) => RespostaSugerida.fromJson(r))
          .toList(),
      mensagemOriginal: mensagemOriginal,
      contexto: contexto,
      tipoRelacao: tipoRelacao,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'literal': literal,
      'subtexto': subtexto,
      'temperatura': temperatura,
      'sinais': sinais,
      'leitura_ansiosa': leituraAnsiosa,
      'leitura_neutra': leituraNeutra,
      'respostas_sugeridas': respostasSugeridas.map((r) => r.toJson()).toList(),
      'mensagemOriginal': mensagemOriginal,
      'contexto': contexto,
      'tipoRelacao': tipoRelacao,
      'timestamp': timestamp.toIso8601String(),
      'tagEmocional': tagEmocional,
    };
  }

  factory AnalysisResult.fromStorage(Map<String, dynamic> json) {
    return AnalysisResult(
      literal: json['literal'] ?? '',
      subtexto: json['subtexto'] ?? '',
      temperatura: json['temperatura'] ?? 'ambígua',
      sinais: List<String>.from(json['sinais'] ?? []),
      leituraAnsiosa: json['leitura_ansiosa'] ?? '',
      leituraNeutra: json['leitura_neutra'] ?? '',
      respostasSugeridas: (json['respostas_sugeridas'] as List? ?? [])
          .map((r) => RespostaSugerida.fromJson(r))
          .toList(),
      mensagemOriginal: json['mensagemOriginal'] ?? '',
      contexto: json['contexto'] ?? '',
      tipoRelacao: json['tipoRelacao'] ?? '',
      timestamp:
          DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      tagEmocional: json['tagEmocional'],
    );
  }

  String get temperaturaEmoji {
    switch (temperatura) {
      case 'fria':
        return '❄️';
      case 'morna':
        return '🌤️';
      case 'quente':
        return '🔥';
      default:
        return '🌫️';
    }
  }

  Color get temperaturaColor {
    switch (temperatura) {
      case 'fria':
        return const Color(0xFF60A5FA);
      case 'morna':
        return const Color(0xFFFBBF24);
      case 'quente':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF9CA3AF);
    }
  }
}

class RespostaSugerida {
  final String tom;
  final String texto;

  RespostaSugerida({required this.tom, required this.texto});

  factory RespostaSugerida.fromJson(Map<String, dynamic> json) {
    return RespostaSugerida(
      tom: json['tom'] ?? '',
      texto: json['texto'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tom': tom,
      'texto': texto,
    };
  }
}
