import 'package:flutter/material.dart';
import '../services/huggingface_service.dart';
import '../services/storage_service.dart';
import '../models/analysis.dart';
import '../widgets/result_card.dart';
import '../widgets/loading_overlay.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final HuggingFaceService _hfService = HuggingFaceService();
  final StorageService _storageService = StorageService();
  final _formKey = GlobalKey<FormState>();

  final _mensagemController = TextEditingController();
  final _contextoController = TextEditingController();
  String _tipoRelacao = 'crush';

  bool _isLoading = false;
  AnalysisResult? _result;
  String? _errorMessage;

  final List<String> _relacoes = ['crush', 'amigo', 'familiar', 'colega'];

  @override
  void dispose() {
    _mensagemController.dispose();
    _contextoController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await _hfService.analyzeMessage(
        mensagem: _mensagemController.text.trim(),
        contexto: _contextoController.text.trim().isEmpty
            ? 'Sem contexto adicional'
            : _contextoController.text.trim(),
        tipoRelacao: _tipoRelacao,
      );

      await _storageService.saveAnalysis(result);

      setState(() {
        _result = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro ao analisar: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _showTagDialog(AnalysisResult result) {
    final tagController = TextEditingController();
    final tags = [
      'confuso',
      'aliviado',
      'preocupado',
      'feliz',
      'ansioso',
      'neutro'
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1230),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Adicionar Tag',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Como você se sente sobre esta análise?',
              style: TextStyle(color: Color(0xFFB8A5D4)),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: tags.map((tag) {
                return ActionChip(
                  label: Text(tag),
                  onPressed: () {
                    tagController.text = tag;
                  },
                  backgroundColor: const Color(0xFF2D1B4E),
                  labelStyle: const TextStyle(color: Color(0xFFB8A5D4)),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tagController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Ou digite sua própria tag',
                hintStyle: TextStyle(color: Color(0xFF6B5B8A)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (tagController.text.isNotEmpty) {
                setState(() {
                  result.tagEmocional = tagController.text;
                });
                await _storageService.updateTag(
                  result.timestamp.toIso8601String(),
                  tagController.text,
                );
                await _storageService.addTag(tagController.text);
              }
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _navigateToHistory() {
    Navigator.pushNamed(context, '/history');
  }

  void _navigateToConversation() {
    Navigator.pushNamed(context, '/conversation');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subtexto'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _navigateToHistory,
            tooltip: 'Histórico',
          ),
          IconButton(
            icon: const Icon(Icons.group_work),
            onPressed: _navigateToConversation,
            tooltip: 'Análise de Conversa',
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🧠 Decodificador de Mensagens',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Cole uma mensagem e entenda o que está por trás das palavras',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📩 Mensagem recebida',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _mensagemController,
                      maxLines: 3,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Cole a mensagem aqui...',
                        hintStyle: TextStyle(color: Color(0xFF6B5B8A)),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Digite ou cole uma mensagem';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '📝 Contexto',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _contextoController,
                      maxLines: 2,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText:
                            'Ex: Estamos conversando sobre o fim de semana...',
                        hintStyle: TextStyle(color: Color(0xFF6B5B8A)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '👥 Tipo de relação',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1230),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _tipoRelacao,
                          dropdownColor: const Color(0xFF1A1230),
                          style: const TextStyle(color: Colors.white),
                          items: _relacoes.map((relacao) {
                            final icon = {
                                  'crush': '💕',
                                  'amigo': '🤝',
                                  'familiar': '👨‍👩‍👦',
                                  'colega': '👔',
                                }[relacao] ??
                                '';
                            return DropdownMenuItem(
                              value: relacao,
                              child: Text('$icon $relacao'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _tipoRelacao = value;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _analyze,
                            child: const Text('🔍 Analisar'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7F1D1D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Color(0xFFFCA5A5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Color(0xFFFCA5A5)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_result != null) ...[
                const SizedBox(height: 24),
                ResultCard(
                  result: _result!,
                  onTag: () => _showTagDialog(_result!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
