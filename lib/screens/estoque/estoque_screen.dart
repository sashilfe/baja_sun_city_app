import 'package:admin/constants.dart';
import 'package:admin/controllers/Auth.dart';
import 'package:admin/controllers/Estoque.dart';
import 'package:admin/models/ItemEstoque.dart';
import 'package:admin/screens/estoque/components/movimentacao_dialog.dart';
import 'package:admin/screens/estoque/components/movimentacoes_panel.dart';
import 'package:admin/screens/estoque/components/peca_form_dialog.dart';
import 'package:admin/services/estoque_service.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EstoqueScreen extends StatefulWidget {
  const EstoqueScreen({Key? key}) : super(key: key);

  @override
  State<EstoqueScreen> createState() => _EstoqueScreenState();
}

class _EstoqueScreenState extends State<EstoqueScreen> {
  final ValueNotifier<String?> _itemSelecionadoNotifier =
      ValueNotifier<String?>(null);

  final List<String> categorias = const [
    'Todas',
    'Mecanica',
    'Eletrica',
    'Consumiveis',
  ];

  @override
  void dispose() {
    _itemSelecionadoNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthController>().usuario;

    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Consumer<EstoqueController>(
        builder: (context, controller, _) {
          return StreamBuilder<List<ItemEstoque>>(
            stream: EstoqueService().getItensEstoque(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final itens = snapshot.data ?? const <ItemEstoque>[];
              final itensFiltrados = _filtrarItens(itens, controller);
              _sincronizarSelecao(itensFiltrados);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isDesktop = constraints.maxWidth > 1260;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(context, usuario, itens, itensFiltrados),
                      const SizedBox(height: defaultPadding),
                      _buildToolbar(context, usuario, itens),
                      const SizedBox(height: defaultPadding),
                      Expanded(
                        child: isDesktop
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: _buildInventorySection(
                                        context, itensFiltrados),
                                  ),
                                  const SizedBox(width: defaultPadding),
                                  Expanded(
                                    flex: 2,
                                    child: _buildAuditSection(itensFiltrados),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Expanded(
                                    child: _buildInventorySection(
                                        context, itensFiltrados),
                                  ),
                                  const SizedBox(height: defaultPadding),
                                  //SizedBox(
                                  //  height: 420,
                                  //  child: _buildAuditSection(itensFiltrados),
                                  //),
                                ],
                              ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHero(
    BuildContext context,
    dynamic usuario,
    List<ItemEstoque> itens,
    List<ItemEstoque> itensFiltrados,
  ) {
    final totalItens = itens.length;
    final estoqueBaixo = itens.where((item) => item.estoqueBaixo).length;
    final categoriasAtivas = itens
        .map((item) => item.categoria)
        .toSet()
        .where((e) => e.isNotEmpty)
        .length;

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF2B2B2F),
            Color(0xFF1B1B1D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: defaultPadding,
            runSpacing: defaultPadding,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 520,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: orangeAccentColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Oficina • Almoxarifado',
                        style: TextStyle(
                          color: orangeAccentColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Controle de Pecas',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Visualize saldo, identifique risco de ruptura e execute entradas e manutencao cadastral sem sair do fluxo da oficina.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            height: 1.45,
                          ),
                    ),
                    if (usuario != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Operador atual: ${usuario.nome}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _SummaryCard(
                    title: 'Itens cadastrados',
                    value: '$totalItens',
                    subtitle: '${itensFiltrados.length} visiveis agora',
                    icon: Icons.inventory_2_outlined,
                    color: orangeAccentColor,
                  ),
                  _SummaryCard(
                    title: 'Estoque baixo',
                    value: '$estoqueBaixo',
                    subtitle: estoqueBaixo == 0
                        ? 'Sem alertas criticos'
                        : 'Reposicao recomendada',
                    icon: Icons.warning_amber_rounded,
                    color: estoqueBaixo == 0
                        ? Colors.greenAccent
                        : Colors.redAccent,
                  ),
                  _SummaryCard(
                    title: 'Categorias ativas',
                    value: '$categoriasAtivas',
                    subtitle: 'Mecanica, Eletrica e consumiveis',
                    icon: Icons.category_outlined,
                    color: Colors.lightBlueAccent,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    dynamic usuario,
    List<ItemEstoque> itens,
  ) {
    final categoriaSelecionada =
        context.watch<EstoqueController>().categoriaFiltro;

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
          Wrap(
            spacing: defaultPadding,
            runSpacing: defaultPadding,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 340,
                child: TextField(
                  onChanged: context.read<EstoqueController>().setBusca,
                  decoration: InputDecoration(
                    hintText: 'Buscar item, categoria ou posicao',
                    hintStyle: const TextStyle(color: Colors.white38),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: bgColor.withValues(alpha: 0.55),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categorias
                    .map(
                      (categoria) => ChoiceChip(
                        label: Text(categoria),
                        selected: categoriaSelecionada == categoria,
                        selectedColor:
                            orangeAccentColor.withValues(alpha: 0.18),
                        backgroundColor: bgColor.withValues(alpha: 0.35),
                        side: BorderSide(
                          color: categoriaSelecionada == categoria
                              ? orangeAccentColor.withValues(alpha: 0.45)
                              : Colors.white10,
                        ),
                        labelStyle: TextStyle(
                          color: categoriaSelecionada == categoria
                              ? orangeAccentColor
                              : Colors.white70,
                          fontWeight: categoriaSelecionada == categoria
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                        onSelected: (_) => context
                            .read<EstoqueController>()
                            .setCategoriaFiltro(categoria),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: orangeAccentColor,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                onPressed: usuario == null || itens.isEmpty
                    ? null
                    : () => _abrirEntradaEstoque(context, itens, usuario.nome),
                icon: const Icon(Icons.inventory_rounded),
                label: const Text('Registrar entrada'),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                onPressed: () => _abrirCadastroPeca(context),
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('Cadastrar nova peca'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventorySection(BuildContext context, List<ItemEstoque> itens) {
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
          Row(
            children: [
              const Icon(Icons.table_chart_outlined, color: orangeAccentColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mapa de Estoque',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      itens.isEmpty
                          ? 'Nenhum item corresponde aos filtros atuais.'
                          : '${itens.length} itens prontos para consulta e operacao.',
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: defaultPadding),
          Expanded(
            child: itens.isEmpty
                ? _buildInventoryEmpty()
                : DataTable2(
                    minWidth: 980,
                    columnSpacing: defaultPadding,
                    horizontalMargin: 12,
                    headingRowHeight: 52,
                    dataRowHeight: 66,
                    showCheckboxColumn: false,
                    headingRowColor: MaterialStateProperty.all(
                        Colors.white.withValues(alpha: 0.04)),
                    columns: const [
                      DataColumn2(label: Text('Item'), size: ColumnSize.L),
                      DataColumn(label: Text('Categoria')),
                      DataColumn(label: Text('Saldo')),
                      DataColumn(label: Text('Minimo')),
                      DataColumn(label: Text('Unidade')),
                      DataColumn2(label: Text('Posicao'), size: ColumnSize.M),
                      DataColumn(label: Text('Status')),
                      DataColumn2(label: Text('Acoes'), size: ColumnSize.M),
                    ],
                    rows:
                        itens.map((item) => _buildRow(context, item)).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryEmpty() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bgColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 44, color: Colors.white30),
            SizedBox(height: 12),
            Text(
              'Nenhum item encontrado',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Ajuste os filtros ou cadastre uma nova peca para iniciar o controle do almoxarifado.',
              style: TextStyle(color: Colors.white54, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuditSection(List<ItemEstoque> itens) {
    return ValueListenableBuilder<String?>(
      valueListenable: _itemSelecionadoNotifier,
      builder: (context, itemId, _) {
        if (itemId == null || itens.isEmpty) {
          return _buildAuditEmpty();
        }

        final item = itens.firstWhere(
          (element) => element.id == itemId,
          orElse: () => itens.first,
        );

        return MovimentacoesPanel(
          item: item,
          movimentacoesStream: EstoqueService().getMovimentacoesItem(item.id!),
        );
      },
    );
  }

  Widget _buildAuditEmpty() {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: darkSecondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fact_check_outlined, size: 42, color: Colors.white30),
            SizedBox(height: 12),
            Text(
              'Auditoria de movimentacoes',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8),
            Text(
              'Selecione uma peca na tabela para acompanhar entradas, saidas e vinculos com OS.',
              style: TextStyle(color: Colors.white54, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<ItemEstoque> _filtrarItens(
    List<ItemEstoque> itens,
    EstoqueController controller,
  ) {
    final busca = controller.busca.trim().toLowerCase();
    return itens.where((item) {
      final categoriaValida = controller.categoriaFiltro == 'Todas' ||
          item.categoria.toLowerCase() ==
              controller.categoriaFiltro.toLowerCase();
      final buscaValida = busca.isEmpty ||
          item.nome.toLowerCase().contains(busca) ||
          item.categoria.toLowerCase().contains(busca) ||
          item.posicaoNoAlmoxarifado.toLowerCase().contains(busca);
      return categoriaValida && buscaValida;
    }).toList();
  }

  DataRow _buildRow(BuildContext context, ItemEstoque item) {
    final baixo = item.estoqueBaixo;
    final selecionado = _itemSelecionadoNotifier.value == item.id;

    return DataRow(
      selected: selecionado,
      color: MaterialStateProperty.resolveWith((states) {
        if (selecionado) {
          return orangeAccentColor.withValues(alpha: 0.08);
        }
        return Colors.transparent;
      }),
      onSelectChanged: (_) => _itemSelecionadoNotifier.value = item.id,
      cells: [
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.nome,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                item.id ?? '-',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
        DataCell(_pill(item.categoria, Colors.lightBlueAccent)),
        DataCell(
          Text(
            item.quantidadeAtual.toStringAsFixed(2),
            style: TextStyle(
              color: baixo ? Colors.redAccent : Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        DataCell(Text(item.quantidadeMinima.toStringAsFixed(2))),
        DataCell(Text(item.unidade)),
        DataCell(Text(item.posicaoNoAlmoxarifado)),
        DataCell(_statusPill(baixo)),
        DataCell(
          Row(
            children: [
              IconButton(
                tooltip: 'Editar peca',
                onPressed: () => _abrirCadastroPeca(context, item: item),
                icon:
                    const Icon(Icons.edit_outlined, color: Colors.orangeAccent),
              ),
              IconButton(
                tooltip: 'Ver auditoria',
                onPressed: () => _itemSelecionadoNotifier.value = item.id,
                icon: Icon(
                  Icons.history_toggle_off_rounded,
                  color:
                      selecionado ? orangeAccentColor : Colors.lightBlueAccent,
                ),
              ),
              IconButton(
                tooltip: 'Remover item',
                onPressed: () => _confirmarRemocao(context, item),
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pill(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _statusPill(bool baixo) {
    final color = baixo ? Colors.redAccent : Colors.greenAccent;
    final label = baixo ? 'Reposicao' : 'Saudavel';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  void _sincronizarSelecao(List<ItemEstoque> itensFiltrados) {
    if (itensFiltrados.isEmpty) {
      _itemSelecionadoNotifier.value = null;
      return;
    }

    final selecionadoExiste =
        itensFiltrados.any((item) => item.id == _itemSelecionadoNotifier.value);
    if (!selecionadoExiste) {
      _itemSelecionadoNotifier.value = itensFiltrados.first.id;
    }
  }

  Future<void> _abrirCadastroPeca(BuildContext context,
      {ItemEstoque? item}) async {
    final salvo = await showDialog<bool>(
      context: context,
      builder: (_) => PecaFormDialog(item: item),
    );

    if (salvo == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            item == null
                ? 'Peca cadastrada com sucesso.'
                : 'Peca atualizada com sucesso.',
          ),
        ),
      );
    }
  }

  Future<void> _abrirEntradaEstoque(
    BuildContext context,
    List<ItemEstoque> itens,
    String responsavelNome,
  ) async {
    final salvo = await showDialog<bool>(
      context: context,
      builder: (_) => MovimentacaoDialog(
        itens: itens,
        responsavelNome: responsavelNome,
      ),
    );

    if (salvo == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Entrada de estoque registrada.')),
      );
    }
  }

  Future<void> _confirmarRemocao(BuildContext context, ItemEstoque item) async {
    final remover = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: darkSecondaryColor,
        title: const Text('Remover item'),
        content: Text(
          'Deseja remover ${item.nome}? Itens com movimentacoes nao podem ser excluidos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Remover',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (remover != true) return;

    try {
      await EstoqueService().removerItem(item.id!);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item removido com sucesso.')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nao foi possivel remover o item: $e')),
      );
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 210,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
