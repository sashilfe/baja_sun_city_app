import 'package:admin/constants.dart';
import 'package:admin/controllers/Auth.dart';
import 'package:admin/controllers/OS.dart';
import 'package:admin/models/ItemEstoque.dart';
import 'package:admin/services/estoque_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MaterialPicker extends StatefulWidget {
  final String osId;

  const MaterialPicker({Key? key, required this.osId}) : super(key: key);

  @override
  State<MaterialPicker> createState() => _MaterialPickerState();
}

class _MaterialPickerState extends State<MaterialPicker> {
  final TextEditingController _quantidadeController = TextEditingController();
  String? _itemSelecionadoId;
  bool _salvando = false;

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<AuthController>().usuario;

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Baixa de Material',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Vincule o consumo de pecas e insumos diretamente a esta OS.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: defaultPadding),
          StreamBuilder<List<ItemEstoque>>(
            stream: EstoqueService().getItensEstoque(),
            builder: (context, snapshot) {
              final itens = snapshot.data ?? const <ItemEstoque>[];
              final selecionadoExiste =
                  itens.any((item) => item.id == _itemSelecionadoId);
              if (!selecionadoExiste && _itemSelecionadoId != null) {
                _itemSelecionadoId = null;
              }

              return Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: _itemSelecionadoId,
                    dropdownColor: darkSecondaryColor,
                    decoration: _inputDecoration('Item do estoque'),
                    items: itens
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item.id,
                            child: Text(
                              '${item.nome} (${item.quantidadeAtual.toStringAsFixed(2)} ${item.unidade})',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: _salvando
                        ? null
                        : (value) => setState(() => _itemSelecionadoId = value),
                  ),
                  const SizedBox(height: defaultPadding),
                  TextField(
                    controller: _quantidadeController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDecoration('Quantidade utilizada'),
                  ),
                  const SizedBox(height: defaultPadding),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orangeAccentColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _salvando || usuario == null
                          ? null
                          : () => _vincularMaterial(usuario.nome),
                      icon: _salvando
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.build_circle_outlined),
                      label: Text(_salvando
                          ? 'Registrando consumo...'
                          : 'Registrar consumo'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: bgColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _vincularMaterial(String responsavelNome) async {
    final quantidade = double.tryParse(_quantidadeController.text.replaceAll(',', '.'));
    if (_itemSelecionadoId == null || quantidade == null || quantidade <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um item e informe uma quantidade valida.'),
        ),
      );
      return;
    }

    setState(() => _salvando = true);
    try {
      await context
          .read<OScontroller>()
          .vincularMaterialAOS(widget.osId, _itemSelecionadoId!, quantidade,
              responsavelNome: responsavelNome);

      if (!mounted) return;
      _quantidadeController.clear();
      setState(() {
        _salvando = false;
        _itemSelecionadoId = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Material vinculado a OS com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao registrar material: $e')),
      );
    }
  }
}
