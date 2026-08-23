import 'package:flutter/material.dart';
import '../services/huggingface_service.dart';

class ConversationScreen extends StatefulWidget {
  const ConversationScreen({super.key});

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final HuggingFaceService _hfService = HuggingFaceService();
  final _formKey = GlobalKey<FormState>();
  final _contextoController = TextEditingController();
  final List<TextEditingController> _mensagemControllers = [];
  String _tipoRelacao = 'crush';
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _errorMessage;

  final List<String> _relacoes = ['crush', 'amigo', 'familiar', 'colega'];

  @override
  void initState() {
    super.initState();
    _addMessageField();
  }

  @override
  void dispose() {
    _contextoController.dispose();
    for (var c in _mensagemControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addMessageField() {
    setState(() {
      _mensagemControllers.add(TextEditingController());
    });
  }

  void _removeMessageField(int index) {
    if (_mensagemControllers.length <= 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mínimo de 2 mensagens para análise'),
          backgroundColor: Color(0xFF7C3AED),
        ),
      );
      return;
    }
    setState(() {
      _mensagemControllers[index].dispose();
      _mensagemControllers.removeAt(index);
    });
  }

  Future<void> _analyzeConversation() async {
    if (!_formKey.currentState!.validate()) return;

    final mensagens = _mensagemControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    if (mensagens.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione pelo menos 2 mensagens para análise'),
          backgroundColor: Color(0xFF7C3AED),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _result = null;
    });

    try {
      final result = await _hfService.analyzeConversation(
        mensagens: mensagens,
        contexto: _contextoController.text.trim().isEmpty
            ? 'Conversa casual'
            : _contextoController.text.trim(),
        tipoRelacao: _tipoRelacao,
      );

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 Análise de Conversa'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF06B6D4), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📊 Mapeie a dinâmica da conversa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Cole 2-10 mensagens de um trecho para analisar poder, investimento e padrões',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '📝 Contexto geral',
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
                          'Ex: Conversa sobre um rolê que não aconteceu...',
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
                          if (value != null)
                            setState(() => _tipoRelacao = value);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '💬 Mensagens (na ordem da conversa)',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ..._mensagemControllers.asMap().entries.map((entry) {
                    final index = entry.key;
                    final controller = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2D1B4E),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Color(0xFFA78BFA),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              controller: controller,
                              maxLines: 2,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Mensagem ${index + 1}',
                                hintStyle:
                                    const TextStyle(color: Color(0xFF6B5B8A)),
                                suffixIcon: _mensagemControllers.length > 2
                                    ? IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Color(0xFF6B5B8A)),
                                        onPressed: () =>
                                            _removeMessageField(index),
                                      )
                                    : null,
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Campo obrigatório';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 8),
                  if (_mensagemControllers.length < 10)
                    TextButton.icon(
                      onPressed: _addMessageField,
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Adicionar mensagem'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF7C3AED),
                      ),
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _analyzeConversation,
                      child: const Text('📊 Analisar conversa'),
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
                          const Icon(Icons.error_outline,
                              color: Color(0xFFFCA5A5)),
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
                    _buildResultCard(),
                  ],
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF7C3AED)),
                    SizedBox(height: 16),
                    Text(
                      'Analisando a conversa...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultCard() {
    final data = _result!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1230), Color(0xFF2D1B4E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 Análise da Conversa',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('⚡ Dinâmica de poder',
              data['dinamica_poder'] ?? 'Não disponível'),
          _buildInfoRow(
              '💖 Investimento', data['investimento'] ?? 'Não disponível'),
          _buildInfoRow('🌡️ Tensão', data['tensao'] ?? 'Não disponível'),
          const SizedBox(height: 12),
          const Text(
            '🔍 Padrões observados',
            style: TextStyle(
              color: Color(0xFFA78BFA),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          ...(data['padroes'] as List? ?? []).map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(color: Color(0xFF7C3AED))),
                    Expanded(
                        child: Text(p,
                            style: const TextStyle(color: Color(0xFFB8A5D4)))),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          const Text(
            '💡 Recomendações',
            style: TextStyle(
              color: Color(0xFF06B6D4),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          ...(data['recomendacoes'] as List? ?? []).map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('→ ',
                        style: TextStyle(color: Color(0xFF06B6D4))),
                    Expanded(
                        child: Text(r,
                            style: const TextStyle(color: Color(0xFFB8A5D4)))),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFA78BFA),
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
