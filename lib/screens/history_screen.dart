import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/analysis.dart';
import '../widgets/result_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final StorageService _storageService = StorageService();
  List<AnalysisResult> _history = [];
  bool _isLoading = true;
  String _filterTag = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final history = await _storageService.getHistory();
      setState(() {
        _history = history.reversed.toList();
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearHistory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1230),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Limpar Histórico',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Tem certeza que deseja apagar todo o histórico?',
          style: TextStyle(color: Color(0xFFB8A5D4)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('Apagar tudo'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _storageService.deleteHistory();
      _loadHistory();
    }
  }

  List<AnalysisResult> get _filteredHistory {
    if (_filterTag.isEmpty) return _history;
    return _history.where((item) => item.tagEmocional == _filterTag).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📚 Histórico'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _history.isEmpty ? null : _clearHistory,
            tooltip: 'Limpar histórico',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7C3AED)))
          : _history.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: FutureBuilder<List<String>>(
                        future: _storageService.getAvailableTags(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const SizedBox.shrink();
                          final tags = snapshot.data!;
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                ActionChip(
                                  label: const Text('Todos'),
                                  onPressed: () =>
                                      setState(() => _filterTag = ''),
                                  backgroundColor: _filterTag.isEmpty
                                      ? const Color(0xFF7C3AED)
                                      : const Color(0xFF2D1B4E),
                                  labelStyle: TextStyle(
                                    color: _filterTag.isEmpty
                                        ? Colors.white
                                        : const Color(0xFFB8A5D4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ...tags.map((tag) {
                                  final isSelected = _filterTag == tag;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ActionChip(
                                      label: Text(tag),
                                      onPressed: () => setState(() {
                                        _filterTag = isSelected ? '' : tag;
                                      }),
                                      backgroundColor: isSelected
                                          ? const Color(0xFF7C3AED)
                                          : const Color(0xFF2D1B4E),
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFFB8A5D4),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _filteredHistory.isEmpty
                          ? Center(
                              child: Text(
                                _filterTag.isEmpty
                                    ? 'Nenhum item no histórico'
                                    : 'Nenhum item com a tag "$_filterTag"',
                                style:
                                    const TextStyle(color: Color(0xFF6B5B8A)),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _filteredHistory.length,
                              itemBuilder: (context, index) {
                                final item = _filteredHistory[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ResultCard(
                                    result: item,
                                    compact: true,
                                    onTag: () async {
                                      final tags = await _storageService
                                          .getAvailableTags();
                                      final tagController =
                                          TextEditingController(
                                        text: item.tagEmocional ?? '',
                                      );
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          backgroundColor:
                                              const Color(0xFF1A1230),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          title: const Text(
                                            'Editar Tag',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Wrap(
                                                spacing: 8,
                                                children: tags.map((tag) {
                                                  return ActionChip(
                                                    label: Text(tag),
                                                    onPressed: () {
                                                      tagController.text = tag;
                                                    },
                                                    backgroundColor:
                                                        const Color(0xFF2D1B4E),
                                                    labelStyle: const TextStyle(
                                                      color: Color(0xFFB8A5D4),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                              const SizedBox(height: 12),
                                              TextField(
                                                controller: tagController,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                decoration:
                                                    const InputDecoration(
                                                  hintText: 'Digite uma tag',
                                                  hintStyle: TextStyle(
                                                      color: Color(0xFF6B5B8A)),
                                                ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancelar'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (tagController
                                                    .text.isNotEmpty) {
                                                  await _storageService
                                                      .updateTag(
                                                    item.timestamp
                                                        .toIso8601String(),
                                                    tagController.text,
                                                  );
                                                  await _storageService.addTag(
                                                      tagController.text);
                                                  _loadHistory();
                                                }
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Salvar'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: const Color(0xFF6B5B8A),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhuma análise salva',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Faça sua primeira análise na tela principal',
            style: TextStyle(
              color: Color(0xFF6B5B8A),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('🔍 Analisar mensagem'),
          ),
        ],
      ),
    );
  }
}
