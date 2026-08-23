import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/analysis.dart';

class HuggingFaceService {
  // Default key keeps local runs simple; dart-define can override it.
  static const String _defaultApiKey =
      'AQ.Ab8RN6JaFbTTX5T90Y0oN-quwAIZGI-izkLJ3AySvJSK3Xq2fA';
  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: _defaultApiKey,
  );

  // Gemini API endpoint.
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent';

  Future<AnalysisResult> analyzeMessage({
    required String mensagem,
    required String contexto,
    required String tipoRelacao,
  }) async {
    try {
      final prompt = _buildPrompt(mensagem, contexto, tipoRelacao);

      final generatedText = await _generateText(prompt);

      final jsonStr = _extractJson(generatedText);
      if (jsonStr == null) {
        // Tenta limpar a resposta
        final cleaned = _cleanJson(generatedText);
        if (cleaned != null) {
          final jsonData = jsonDecode(cleaned);
          return AnalysisResult.fromJson(
            jsonData,
            mensagemOriginal: mensagem,
            contexto: contexto,
            tipoRelacao: tipoRelacao,
          );
        }
        throw Exception('Resposta não é JSON válido: $generatedText');
      }

      final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
      return AnalysisResult.fromJson(
        jsonData,
        mensagemOriginal: mensagem,
        contexto: contexto,
        tipoRelacao: tipoRelacao,
      );
    } catch (e) {
      print('❌ ERRO: $e');
      rethrow;
    }
  }

  Future<String> _generateText(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception(
          'Chave Gemini ausente. Execute com --dart-define=GEMINI_API_KEY=SUA_CHAVE.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ],
        'generationConfig': {
          'temperature': 0.3,
          'maxOutputTokens': 4096,
          'responseMimeType': 'application/json',
          'responseSchema': {
            'type': 'OBJECT',
            'properties': {
              'literal': {'type': 'STRING'},
              'subtexto': {'type': 'STRING'},
              'temperatura': {'type': 'STRING'},
              'sinais': {
                'type': 'ARRAY',
                'items': {'type': 'STRING'}
              },
              'leitura_ansiosa': {'type': 'STRING'},
              'leitura_neutra': {'type': 'STRING'},
              'respostas_sugeridas': {
                'type': 'ARRAY',
                'items': {
                  'type': 'OBJECT',
                  'properties': {
                    'tom': {'type': 'STRING'},
                    'texto': {'type': 'STRING'},
                  },
                  'required': ['tom', 'texto'],
                },
              },
            },
            'required': [
              'literal',
              'subtexto',
              'temperatura',
              'sinais',
              'leitura_ansiosa',
              'leitura_neutra',
              'respostas_sugeridas',
            ],
          },
        },
      }),
    );

    if (response.statusCode != 200) {
      if (response.statusCode == 400 ||
          response.statusCode == 401 ||
          response.statusCode == 403) {
        throw Exception(
            'Chave Gemini inválida ou sem acesso à API Generative Language.');
      }
      throw Exception('Erro Gemini: ${response.statusCode} - ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = data['candidates'] as List<dynamic>?;
    final firstCandidate = candidates?.isNotEmpty == true
        ? candidates!.first as Map<String, dynamic>
        : null;
    final content = firstCandidate?['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    final text = parts?.isNotEmpty == true ? parts!.first['text'] : null;
    if (text is! String || text.isEmpty) {
      throw Exception('Gemini não retornou texto para a análise.');
    }
    return text;
  }

  String _buildPrompt(String mensagem, String contexto, String tipoRelacao) {
    return '''
  Analise a mensagem e retorne somente um objeto JSON válido. Não use markdown, não escreva introdução e não repita a pergunta. Seja conciso: cada texto deve ter no máximo 2 frases, use exatamente 3 sinais e 2 respostas.

MENSAGEM: "$mensagem"
CONTEXTO: "$contexto"
RELAÇÃO: "$tipoRelacao" (crush/amigo/familiar/colega)

Retorne EXATAMENTE neste formato JSON:
{
  "literal": "o que a mensagem diz explicitamente, de forma objetiva",
  "subtexto": "o que provavelmente está implícito na mensagem, considerando o contexto e a relação",
  "temperatura": "fria/morna/quente/ambígua",
  "sinais": ["lista de 3-5 sinais observados na mensagem"],
  "leitura_ansiosa": "como uma mente ansiosa interpretaria esta mensagem",
  "leitura_neutra": "interpretação mais equilibrada e realista",
  "respostas_sugeridas": [
    {"tom": "curiosa", "texto": "resposta que demonstra interesse genuíno sem pressão"},
    {"tom": "assertiva", "texto": "resposta que estabelece limites ou comunica com clareza"}
  ]
}

Regras: seja honesto, não romantize sinais fracos, não dê falsas esperanças e diferencie fatos de suposições.
''';
  }

  String? _extractJson(String text) {
    final start = text.indexOf('{');
    if (start == -1) return null;

    var depth = 0;
    var quoted = false;
    var escaped = false;
    for (var index = start; index < text.length; index++) {
      final character = text[index];
      if (quoted) {
        if (escaped) {
          escaped = false;
        } else if (character == '\\') {
          escaped = true;
        } else if (character == '"') {
          quoted = false;
        }
        continue;
      }
      if (character == '"') {
        quoted = true;
      } else if (character == '{') {
        depth++;
      } else if (character == '}') {
        depth--;
        if (depth == 0) return text.substring(start, index + 1);
      }
    }
    return null;
  }

  String? _cleanJson(String text) {
    var cleaned = text.replaceAll(RegExp(r'```json\n?'), '');
    cleaned = cleaned.replaceAll(RegExp(r'```\n?'), '');
    cleaned = cleaned.trim();
    return _extractJson(cleaned);
  }

  // Análise de conversa completa
  Future<Map<String, dynamic>> analyzeConversation({
    required List<String> mensagens,
    required String contexto,
    required String tipoRelacao,
  }) async {
    try {
      final mensagensText = mensagens
          .asMap()
          .entries
          .map((e) => '[${e.key + 1}] ${e.value}')
          .join('\n');

      final prompt = '''
Analise o trecho de conversa abaixo e retorne APENAS JSON (sem markdown).

CONVERSAS:
$mensagensText

CONTEXTO: "$contexto"
RELAÇÃO: "$tipoRelacao" (crush/amigo/familiar/colega)

Retorne EXATAMENTE neste formato JSON:
{
  "dinamica_poder": "quem está no controle da conversa? quem investe mais?",
  "investimento": "avaliação de quem está investindo mais emocionalmente na interação",
  "padroes": ["lista de 3-4 padrões observados na comunicação"],
  "tensao": "nível de tensão percebido (baixo/médio/alto)",
  "recomendacoes": ["lista de 2-3 recomendações para a pessoa que pediu análise"]
}

Use linguagem acessível, seja direto e honesto.
''';

      final generatedText = await _generateText(prompt);

      final jsonStr = _extractJson(generatedText);
      if (jsonStr == null) {
        throw Exception('Resposta inválida: $generatedText');
      }

      return jsonDecode(jsonStr);
    } catch (e) {
      print('❌ ERRO na conversa: $e');
      rethrow;
    }
  }
}
