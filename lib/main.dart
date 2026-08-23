import 'package:flutter/material.dart';
import 'data/question_bank.dart';
import 'models/analysis.dart';
import 'services/huggingface_service.dart';
import 'services/storage_service.dart';

void main() {
  runApp(const SubtextoApp());
}

class SubtextoApp extends StatelessWidget {
  const SubtextoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Subtexto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
          brightness: Brightness.dark,
          primary: const Color(0xFF7C3AED),
          secondary: const Color(0xFFEC4899),
          tertiary: const Color(0xFF06B6D4),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F0A1A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1230),
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: const CardThemeData(
          color: Color(0xFF1A1230),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1A1230),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
          ),
          hintStyle: const TextStyle(color: Color(0xFF6B5B8A)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF7C3AED),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF100A1D), Color(0xFF25153D)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x557C3AED),
                            blurRadius: 28,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.forum_rounded,
                          color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 28),
                    const Text('Subtexto',
                        style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            height: 1)),
                    const SizedBox(height: 16),
                    const Text(
                      'Entenda o que as mensagens dizem\ne o que elas deixam nas entrelinhas.',
                      style: TextStyle(
                          color: Color(0xFFD9CBEA), fontSize: 20, height: 1.35),
                    ),
                    const SizedBox(height: 36),
                    const Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _WelcomeTag(
                            icon: Icons.visibility_outlined, text: 'Clareza'),
                        _WelcomeTag(
                            icon: Icons.psychology_outlined, text: 'Contexto'),
                        _WelcomeTag(
                            icon: Icons.favorite_border,
                            text: 'Sem suposições'),
                      ],
                    ),
                    const SizedBox(height: 44),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                                builder: (_) => const HomeScreen())),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text('Começar análise'),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                        'Uma leitura mais calma para conversas confusas.',
                        style: TextStyle(color: Color(0xFF9F8DBD))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeTag extends StatelessWidget {
  const _WelcomeTag({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0x332D1B4E),
        border: Border.all(color: const Color(0x665C4583)),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 17, color: const Color(0xFFE4D7F6)),
          const SizedBox(width: 7),
          Text(text, style: const TextStyle(color: Color(0xFFE4D7F6))),
        ]),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _messageController = TextEditingController();
  final _contextController = TextEditingController();
  final _api = HuggingFaceService();
  final _storage = StorageService();
  String _relationship = 'crush';
  String _category = 'Intenção';
  AnalysisResult? _result;
  String? _error;
  bool _loading = false;

  @override
  void dispose() {
    _messageController.dispose();
    _contextController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      setState(() => _error = 'Digite ou cole uma mensagem para analisar.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await _api.analyzeMessage(
        mensagem: message,
        contexto: _contextController.text.trim().isEmpty
            ? 'Sem contexto adicional'
            : _contextController.text.trim(),
        tipoRelacao: _relationship,
      );
      await _storage.saveAnalysis(result);
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final questions = QuestionBank.categories[_category]!;
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Subtexto'),
            Text('Leitura de mensagens',
                style: TextStyle(fontSize: 11, color: Color(0xFFB8A5D4))),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Limpar campos',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() {
              _messageController.clear();
              _contextController.clear();
              _result = null;
              _error = null;
            }),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF21163A),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF3A285B)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Subtexto',
                        style: TextStyle(
                            color: Color(0xFFEC4899),
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 8),
                    Text('Leia o que ficou nas entrelinhas',
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.1)),
                    SizedBox(height: 8),
                    Text('Contexto, tom e intenção em uma leitura mais clara.'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF171025),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF302047)),
                ),
                child: const Row(children: [
                  Icon(Icons.lock_outline, size: 18, color: Color(0xFFB8A5D4)),
                  SizedBox(width: 10),
                  Expanded(
                      child: Text(
                          'Você decide o contexto. A análise separa fatos de interpretações.',
                          style: TextStyle(color: Color(0xFFB8A5D4)))),
                ]),
              ),
              const SizedBox(height: 20),
              _Panel(
                step: '01',
                title: 'Escolha uma pergunta',
                subtitle:
                    'Comece por um atalho ou escreva seu próprio contexto.',
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(labelText: 'Categoria'),
                      items: QuestionBank.categories.keys
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) => setState(() => _category = value!),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: questions
                            .map((question) => ActionChip(
                                label: Text(question),
                                onPressed: () =>
                                    _contextController.text = question))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _Panel(
                step: '02',
                title: 'Cole a mensagem',
                subtitle: 'Quanto mais contexto, mais útil será a leitura.',
                child: TextField(
                  controller: _messageController,
                  minLines: 4,
                  maxLines: 7,
                  decoration: const InputDecoration(
                      hintText: 'Ex.: “Estou ansiosa pra te ver em breve”'),
                ),
              ),
              const SizedBox(height: 16),
              _Panel(
                step: '03',
                title: 'Dê um pouco de contexto',
                subtitle:
                    'Conte o que aconteceu antes ou o que você quer entender.',
                child: Column(
                  children: [
                    TextField(
                      controller: _contextController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                          hintText: 'Ex.: depois do nosso encontro...'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _relationship,
                      decoration:
                          const InputDecoration(labelText: 'Tipo de relação'),
                      items: const ['crush', 'amigo', 'familiar', 'colega']
                          .map((item) =>
                              DropdownMenuItem(value: item, child: Text(item)))
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _relationship = value!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                  onPressed: _loading ? null : _analyze,
                  icon: const Icon(Icons.auto_awesome),
                  label:
                      Text(_loading ? 'Analisando...' : 'Analisar mensagem')),
              if (_error != null) ...[
                const SizedBox(height: 16),
                SelectableText(_error!,
                    style: const TextStyle(color: Colors.redAccent)),
              ],
              if (_result != null) ...[
                const SizedBox(height: 24),
                _ResultView(result: _result!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({required this.result});
  final AnalysisResult result;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${result.temperaturaEmoji} ${result.temperatura}',
              style: TextStyle(
                  color: result.temperaturaColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _section('Leitura direta', result.literal),
          _section('Possível subtexto', result.subtexto),
          _section('Leitura equilibrada', result.leituraNeutra),
          if (result.sinais.isNotEmpty)
            _section('Sinais observados', result.sinais.join('\n• ')),
          if (result.respostasSugeridas.isNotEmpty)
            _section(
                'Respostas possíveis',
                result.respostasSugeridas
                    .map((item) => '${item.tom}: ${item.texto}')
                    .join('\n\n')),
        ]),
      ),
    );
  }

  Widget _section(String title, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(text)
        ]),
      );
}

class _Panel extends StatelessWidget {
  const _Panel(
      {required this.step,
      required this.title,
      required this.subtitle,
      required this.child});

  final String step;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(
                radius: 14,
                backgroundColor: const Color(0xFF7C3AED),
                child: Text(step,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.bold))),
            const SizedBox(width: 10),
            Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 6),
          Padding(
              padding: const EdgeInsets.only(left: 38),
              child: Text(subtitle,
                  style: const TextStyle(color: Color(0xFFB8A5D4)))),
          const SizedBox(height: 16),
          child,
        ]),
      ),
    );
  }
}
