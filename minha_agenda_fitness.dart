import 'package:flutter/material.dart';

void main() {
  runApp(const MinhaAgendaApp());
}

class MinhaAgendaApp extends StatelessWidget {
  const MinhaAgendaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Minha Agenda Fitness',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF101510),
      ),
      home: const PaginaInicial(),
    );
  }
}

class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  DateTime mesAtual = DateTime.now();
  DateTime diaSelecionado = DateTime.now();

  // 1 = Treinou | 2 = Faltou
  final Map<String, int> historico = {};

  // Consumo de água separado por data.
  final Map<String, List<int>> aguaPorDia = {};

  int metaAgua = 2000;

  String chaveData(DateTime data) {
    return '${data.year}-'
        '${data.month.toString().padLeft(2, '0')}-'
        '${data.day.toString().padLeft(2, '0')}';
  }

  String get chaveSelecionada => chaveData(diaSelecionado);

  List<int> get consumosDoDia =>
      aguaPorDia[chaveSelecionada] ?? [];

  int get aguaConsumida =>
      consumosDoDia.fold(0, (total, ml) => total + ml);

  int get totalTreinos =>
      historico.values.where((status) => status == 1).length;

  int get totalFaltas =>
      historico.values.where((status) => status == 2).length;

  int get diasNoMes =>
      DateTime(mesAtual.year, mesAtual.month + 1, 0).day;

  int get primeiroDiaSemana =>
      DateTime(mesAtual.year, mesAtual.month, 1).weekday;

  final List<String> meses = const [
    'Janeiro', 'Fevereiro', 'Março', 'Abril',
    'Maio', 'Junho', 'Julho', 'Agosto',
    'Setembro', 'Outubro', 'Novembro', 'Dezembro'
  ];

  void mudarMes(int quantidade) {
    setState(() {
      mesAtual = DateTime(
        mesAtual.year,
        mesAtual.month + quantidade,
        1,
      );
    });
  }

  void selecionarDia(int dia) {
    setState(() {
      diaSelecionado = DateTime(
        mesAtual.year,
        mesAtual.month,
        dia,
      );
    });
  }

  void registrarStatus(int status) {
    setState(() {
      historico[chaveSelecionada] = status;
    });
  }

  void adicionarAgua(int ml) {
    setState(() {
      aguaPorDia.putIfAbsent(chaveSelecionada, () => []);
      aguaPorDia[chaveSelecionada]!.add(ml);
    });
  }

  void desfazerAgua() {
    if (consumosDoDia.isEmpty) return;

    setState(() {
      consumosDoDia.removeLast();
      if (consumosDoDia.isEmpty) {
        aguaPorDia.remove(chaveSelecionada);
      }
    });
  }

  void limparAgua() {
    setState(() {
      aguaPorDia.remove(chaveSelecionada);
    });
  }

  Future<void> editarMetaAgua() async {
    final controller = TextEditingController(
      text: metaAgua.toString(),
    );

    final valor = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meta diária de água'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Meta em ml',
            hintText: 'Ex.: 2000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final numero = int.tryParse(controller.text);
              if (numero != null && numero > 0) {
                Navigator.pop(context, numero);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (valor != null) {
      setState(() {
        metaAgua = valor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final progresso =
        (aguaConsumida / metaAgua).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Minha Agenda Fitness',
          style: TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        // LayoutBuilder mede a largura disponível e adapta o conteúdo.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final largura = constraints.maxWidth;
            final margemHorizontal = largura < 360
                ? 10.0
                : largura < 600
                    ? 16.0
                    : 24.0;
            final larguraMaxima = largura >= 1000 ? 900.0 : largura;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: larguraMaxima),
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: margemHorizontal,
                    vertical: 16,
                  ),
                  children: [
            const Text(
              'Olá! Vamos cuidar da sua rotina?',
              style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // RESUMO
            Row(
              children: [
                Expanded(
                  child: resumoCard(
                    'Treinos',
                    '$totalTreinos',
                    Icons.fitness_center,
                    Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: resumoCard(
                    'Faltas',
                    '$totalFaltas',
                    Icons.event_busy,
                    Colors.redAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // CALENDÁRIO
            Card(
              color: const Color(0xFF1C241D),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    const Text(
                      'Calendário da academia',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => mudarMes(-1),
                          icon: const Icon(Icons.chevron_left),
                        ),
                        Text(
                          '${meses[mesAtual.month - 1]} ${mesAtual.year}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => mudarMes(1),
                          icon: const Icon(Icons.chevron_right),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: const [
                        'Seg', 'Ter', 'Qua', 'Qui',
                        'Sex', 'Sáb', 'Dom'
                      ].map((dia) {
                        return Expanded(
                          child: Center(
                            child: Text(
                              dia,
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 8),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: diasNoMes + primeiroDiaSemana - 1,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 3,
                        childAspectRatio: 0.95,
                      ),
                      itemBuilder: (context, index) {
                        if (index < primeiroDiaSemana - 1) {
                          return const SizedBox.shrink();
                        }

                        final dia = index - primeiroDiaSemana + 2;
                        final data = DateTime(
                          mesAtual.year,
                          mesAtual.month,
                          dia,
                        );
                        final chave = chaveData(data);
                        final status = historico[chave];
                        final selecionado =
                            chave == chaveData(diaSelecionado);

                        Color cor = Colors.transparent;

                        if (status == 1) {
                          cor = Colors.green.shade700;
                        } else if (status == 2) {
                          cor = Colors.red.shade700;
                        }

                        if (selecionado && status == null) {
                          cor = Colors.blueGrey;
                        }

                        return GestureDetector(
                          onTap: () => selecionarDia(dia),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cor,
                              borderRadius: BorderRadius.circular(10),
                              border: selecionado
                                  ? Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    )
                                  : Border.all(
                                      color: Colors.white10,
                                    ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$dia',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Data selecionada: '
                      '${diaSelecionado.day.toString().padLeft(2, '0')}/'
                      '${diaSelecionado.month.toString().padLeft(2, '0')}/'
                      '${diaSelecionado.year}',
                    ),

                    const SizedBox(height: 12),

                    if (historico[chaveSelecionada] == 1)
                      const Text(
                        'Você treinou neste dia!',
                        style: TextStyle(color: Colors.greenAccent),
                      )
                    else if (historico[chaveSelecionada] == 2)
                      const Text(
                        'Falta registrada neste dia.',
                        style: TextStyle(color: Colors.redAccent),
                      )
                    else
                      const Text('Nenhum registro neste dia.'),

                    const SizedBox(height: 12),

                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () => registrarStatus(1),
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Treinei'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => registrarStatus(2),
                          icon: const Icon(Icons.close),
                          label: const Text('Faltei'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              historico.remove(chaveSelecionada);
                            });
                          },
                          child: const Text('Limpar'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    const Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 14,
                      children: [
                        Legenda(cor: Colors.green, texto: 'Treinou'),
                        Legenda(cor: Colors.red, texto: 'Faltou'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // CONTROLE DE ÁGUA
            Card(
              color: const Color(0xFF1C241D),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.water_drop,
                          color: Colors.lightBlueAccent,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Controle de água',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: editarMetaAgua,
                          icon: const Icon(Icons.settings),
                          tooltip: 'Editar meta',
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '$aguaConsumida ml de $metaAgua ml',
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 12,
                        color: Colors.lightBlueAccent,
                        backgroundColor: Colors.blueGrey.shade800,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      aguaConsumida >= metaAgua
                          ? 'Parabéns! Meta de água atingida!'
                          : 'Faltam ${metaAgua - aguaConsumida} ml para sua meta.',
                    ),

                    const SizedBox(height: 18),

                    const Text('Adicionar água consumida:'),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        botaoAgua(150),
                        botaoAgua(250),
                        botaoAgua(300),
                        botaoAgua(500),
                      ],
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: consumosDoDia.isEmpty
                                ? null
                                : desfazerAgua,
                            icon: const Icon(Icons.undo),
                            label: const Text('Desfazer'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextButton(
                            onPressed: consumosDoDia.isEmpty
                                ? null
                                : limparAgua,
                            child: const Text('Zerar o dia'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Center(
              child: Text(
                'Pequenos hábitos, grandes resultados!',
                style: TextStyle(
                  color: Colors.white60,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget resumoCard(
    String titulo,
    String valor,
    IconData icone,
    Color cor,
  ) {
    return Card(
      color: const Color(0xFF1C241D),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icone, color: cor, size: 30),
            const SizedBox(height: 8),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(titulo),
          ],
        ),
      ),
    );
  }

  Widget botaoAgua(int ml) {
    return OutlinedButton(
      onPressed: () => adicionarAgua(ml),
      child: Text('+$ml ml'),
    );
  }
}

class Legenda extends StatelessWidget {
  final Color cor;
  final String texto;

  const Legenda({
    super.key,
    required this.cor,
    required this.texto,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: cor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(texto),
      ],
    );
  }
}
