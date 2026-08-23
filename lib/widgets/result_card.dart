import 'package:flutter/material.dart';
import '../models/analysis.dart';

class ResultCard extends StatelessWidget {
  final AnalysisResult result;
  final bool compact;
  final VoidCallback? onTag;

  const ResultCard({
    super.key,
    required this.result,
    this.compact = false,
    this.onTag,
  });

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: result.temperaturaColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: result.temperaturaColor.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      result.temperaturaEmoji,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      result.temperatura.toUpperCase(),
                      style: TextStyle(
                        color: result.temperaturaColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (result.tagEmocional != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: const Color(0xFF7C3AED).withOpacity(0.3)),
                  ),
                  child: Text(
                    '🏷️ ${result.tagEmocional}',
                    style: const TextStyle(
                      color: Color(0xFFA78BFA),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (onTag != null)
                IconButton(
                  icon: const Icon(Icons.label_outline,
                      size: 18, color: Color(0xFF6B5B8A)),
                  onPressed: onTag,
                  tooltip: 'Adicionar tag',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (!compact) ...[
            const Text(
              '📩 Mensagem original',
              style: TextStyle(
                color: Color(0xFF6B5B8A),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0A1A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '"${result.mensagemOriginal}"',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          _buildSection(
            '📖 Significado literal',
            result.literal,
            color: const Color(0xFF60A5FA),
          ),
          const SizedBox(height: 8),
          _buildSection(
            '🔍 Subtexto',
            result.subtexto,
            color: const Color(0xFFA78BFA),
          ),
          const SizedBox(height: 8),
          if (result.sinais.isNotEmpty) ...[
            const Text(
              '🚩 Sinais observados',
              style: TextStyle(
                color: Color(0xFFFBBF24),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...result.sinais.map((sinal) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(color: Color(0xFFFBBF24))),
                      Expanded(
                        child: Text(
                          sinal,
                          style: const TextStyle(
                              color: Color(0xFFB8A5D4), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 8),
          ],
          if (!compact) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF7F1D1D).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFF7F1D1D).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '😰 Mente Ansiosa',
                    style: TextStyle(
                      color: Color(0xFFFCA5A5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.leituraAnsiosa,
                    style:
                        const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '🧘 Mente Neutra',
                    style: TextStyle(
                      color: Color(0xFF6EE7B7),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    result.leituraNeutra,
                    style:
                        const TextStyle(color: Color(0xFF6EE7B7), fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '💬 Respostas sugeridas',
              style: TextStyle(
                color: Color(0xFF06B6D4),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            ...result.respostasSugeridas.map((resposta) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0A1A),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF06B6D4).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getTomEmoji(resposta.tom)} ${resposta.tom.toUpperCase()}',
                          style: const TextStyle(
                            color: Color(0xFF06B6D4),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          resposta.texto,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
          if (compact) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Spacer(),
                Text(
                  _formatDate(result.timestamp),
                  style: const TextStyle(
                    color: Color(0xFF6B5B8A),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content, {required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          content,
          style: const TextStyle(
            color: Color(0xFFE8E0F0),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  String _getTomEmoji(String tom) {
    switch (tom.toLowerCase()) {
      case 'curiosa':
        return '🤔';
      case 'assertiva':
        return '💪';
      case 'distanciada':
        return '🧊';
      default:
        return '💬';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return 'Hoje ${_formatTime(date)}';
    } else if (diff.inDays == 1) {
      return 'Ontem ${_formatTime(date)}';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
