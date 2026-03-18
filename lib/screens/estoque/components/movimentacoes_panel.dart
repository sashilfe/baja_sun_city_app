import 'package:admin/constants.dart';
import 'package:admin/models/ItemEstoque.dart';
import 'package:admin/utils/formatters.dart';
import 'package:flutter/material.dart';

class MovimentacoesPanel extends StatelessWidget {
  final ItemEstoque item;
  final Stream<List<MovimentacaoEstoque>> movimentacoesStream;

  const MovimentacoesPanel({
    Key? key,
    required this.item,
    required this.movimentacoesStream,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: darkSecondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const SizedBox(height: defaultPadding),
          _buildHighlightStrip(),
          const SizedBox(height: defaultPadding),
          Expanded(
            child: StreamBuilder<List<MovimentacaoEstoque>>(
              stream: movimentacoesStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final movimentacoes =
                    snapshot.data ?? const <MovimentacaoEstoque>[];
                if (movimentacoes.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.separated(
                  itemCount: movimentacoes.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: defaultPadding / 2),
                  itemBuilder: (context, index) {
                    final mov = movimentacoes[index];
                    final isEntrada = mov.tipo.toLowerCase() == 'entrada';
                    final destaque =
                        isEntrada ? Colors.greenAccent : orangeAccentColor;

                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: bgColor.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: destaque.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              isEntrada
                                  ? Icons.south_west_rounded
                                  : Icons.north_east_rounded,
                              color: destaque,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        mov.tipo,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    _tag(
                                      '${mov.quantidade.toStringAsFixed(2)} ${mov.unidade ?? item.unidade}',
                                      destaque,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _buildSubtitle(mov),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    height: 1.35,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _smallInfo(
                                      Icons.schedule_rounded,
                                      formatDateTime(mov.data),
                                    ),
                                    if (mov.osId != null && mov.osId!.isNotEmpty)
                                      _smallInfo(
                                        Icons.assignment_outlined,
                                        'OS ${mov.osId}',
                                      ),
                                    if (mov.custoEstimado != null)
                                      _smallInfo(
                                        Icons.attach_money_rounded,
                                        'R\$ ${mov.custoEstimado!.toStringAsFixed(2)}',
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: orangeAccentColor.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.fact_check_outlined,
            color: orangeAccentColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Auditoria de Movimentacoes',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                item.nome,
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${item.categoria} • ${item.posicaoNoAlmoxarifado}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightStrip() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _HighlightCard(
          label: 'Saldo atual',
          value: '${item.quantidadeAtual.toStringAsFixed(2)} ${item.unidade}',
          color: orangeAccentColor,
        ),
        _HighlightCard(
          label: 'Limite minimo',
          value: '${item.quantidadeMinima.toStringAsFixed(2)} ${item.unidade}',
          color: item.estoqueBaixo ? Colors.redAccent : Colors.greenAccent,
        ),
        _HighlightCard(
          label: 'Status',
          value: item.estoqueBaixo ? 'Reposicao necessaria' : 'Nivel saudavel',
          color: item.estoqueBaixo ? Colors.redAccent : Colors.lightBlueAccent,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 320),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_toggle_off_rounded,
                size: 42, color: Colors.white30),
            SizedBox(height: 12),
            Text(
              'Sem movimentacoes registradas',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Este item ainda nao possui entradas ou saidas auditadas no almoxarifado.',
              style: TextStyle(color: Colors.white54, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle(MovimentacaoEstoque mov) {
    final buffer = <String>[
      'Responsavel: ${mov.responsavelNome.isEmpty ? 'Nao informado' : mov.responsavelNome}',
    ];
    if (mov.itemNome != null && mov.itemNome!.isNotEmpty) {
      buffer.add('Item: ${mov.itemNome}');
    }
    return buffer.join(' • ');
  }

  Widget _tag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _smallInfo(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white54),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HighlightCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
