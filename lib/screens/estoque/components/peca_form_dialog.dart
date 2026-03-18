import 'package:admin/constants.dart';
import 'package:admin/models/ItemEstoque.dart';
import 'package:admin/services/estoque_service.dart';
import 'package:flutter/material.dart';

class PecaFormDialog extends StatefulWidget {
  final ItemEstoque? item;

  const PecaFormDialog({Key? key, this.item}) : super(key: key);

  @override
  State<PecaFormDialog> createState() => _PecaFormDialogState();
}

class _PecaFormDialogState extends State<PecaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _quantidadeAtualController;
  late final TextEditingController _quantidadeMinimaController;
  late final TextEditingController _unidadeController;
  late final TextEditingController _posicaoController;
  late final TextEditingController _precoController;
  late String _categoria;
  bool _salvando = false;

  static const _categorias = ['Mecanica', 'Eletrica', 'Consumiveis'];

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nomeController = TextEditingController(text: item?.nome ?? '');
    _quantidadeAtualController = TextEditingController(
      text: item == null ? '' : item.quantidadeAtual.toString(),
    );
    _quantidadeMinimaController = TextEditingController(
      text: item == null ? '' : item.quantidadeMinima.toString(),
    );
    _unidadeController = TextEditingController(text: item?.unidade ?? 'un');
    _posicaoController =
        TextEditingController(text: item?.posicaoNoAlmoxarifado ?? '');
    _precoController = TextEditingController(
      text: item?.precoUnitario == null ? '' : item!.precoUnitario.toString(),
    );
    _categoria = item?.categoria ?? _categorias.first;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeAtualController.dispose();
    _quantidadeMinimaController.dispose();
    _unidadeController.dispose();
    _posicaoController.dispose();
    _precoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: darkSecondaryColor,
      title: Text(widget.item == null ? 'Nova Peca' : 'Editar Peca'),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_nomeController, 'Nome da peca'),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _categoria,
                  dropdownColor: darkSecondaryColor,
                  decoration: _decoration('Categoria'),
                  items: _categorias
                      .map((categoria) => DropdownMenuItem<String>(
                            value: categoria,
                            child: Text(categoria),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _categoria = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        _quantidadeAtualController,
                        'Quantidade atual',
                        isNumber: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        _quantidadeMinimaController,
                        'Quantidade minima',
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(_unidadeController, 'Unidade'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTextField(
                        _precoController,
                        'Preco unitario',
                        isNumber: true,
                        required: false,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildTextField(_posicaoController, 'Posicao no almoxarifado'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _salvando ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: orangeAccentColor,
            foregroundColor: Colors.black,
          ),
          onPressed: _salvando ? null : _salvar,
          child: Text(_salvando ? 'Salvando...' : 'Salvar'),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      validator: (value) {
        final texto = value?.trim() ?? '';
        if (required && texto.isEmpty) {
          return 'Campo obrigatorio';
        }
        if (isNumber && texto.isNotEmpty && _parseDouble(texto) == null) {
          return 'Valor invalido';
        }
        return null;
      },
      decoration: _decoration(label),
    );
  }

  InputDecoration _decoration(String label) {
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

  double? _parseDouble(String value) {
    return double.tryParse(value.replaceAll(',', '.'));
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      final item = ItemEstoque(
        id: widget.item?.id,
        nome: _nomeController.text.trim(),
        categoria: _categoria,
        quantidadeAtual: _parseDouble(_quantidadeAtualController.text.trim()) ?? 0,
        quantidadeMinima:
            _parseDouble(_quantidadeMinimaController.text.trim()) ?? 0,
        unidade: _unidadeController.text.trim(),
        posicaoNoAlmoxarifado: _posicaoController.text.trim(),
        precoUnitario: _precoController.text.trim().isEmpty
            ? null
            : _parseDouble(_precoController.text.trim()),
      );

      await EstoqueService().salvarItem(item);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao salvar peca: $e')),
      );
    }
  }
}
