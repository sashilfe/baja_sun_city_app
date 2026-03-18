import 'package:admin/constants.dart';
import 'package:admin/models/ItemEstoque.dart';
import 'package:admin/services/estoque_service.dart';
import 'package:flutter/material.dart';

class MovimentacaoDialog extends StatefulWidget {
  final List<ItemEstoque> itens;
  final String responsavelNome;
  final String? itemIdInicial;

  const MovimentacaoDialog({
    Key? key,
    required this.itens,
    required this.responsavelNome,
    this.itemIdInicial,
  }) : super(key: key);

  @override
  State<MovimentacaoDialog> createState() => _MovimentacaoDialogState();
}

class _MovimentacaoDialogState extends State<MovimentacaoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  String? _itemId;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _itemId = widget.itemIdInicial ??
        (widget.itens.isNotEmpty ? widget.itens.first.id : null);
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: darkSecondaryColor,
      title: const Text('Entrada de Estoque'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _itemId,
                dropdownColor: darkSecondaryColor,
                decoration: _decoration('Item'),
                items: widget.itens
                    .map((item) => DropdownMenuItem<String>(
                          value: item.id,
                          child: Text(item.nome),
                        ))
                    .toList(),
                validator: (value) =>
                    value == null ? 'Selecione um item' : null,
                onChanged:
                    _salvando ? null : (value) => setState(() => _itemId = value),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _quantidadeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  final quantidade =
                      double.tryParse((value ?? '').replaceAll(',', '.'));
                  if (quantidade == null || quantidade <= 0) {
                    return 'Informe uma quantidade valida';
                  }
                  return null;
                },
                decoration: _decoration('Quantidade de entrada'),
              ),
            ],
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
          onPressed: _salvando ? null : _registrarEntrada,
          child: Text(_salvando ? 'Lancando...' : 'Registrar'),
        ),
      ],
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

  Future<void> _registrarEntrada() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);
    try {
      await EstoqueService().registrarEntrada(
        itemId: _itemId!,
        quantidade:
            double.parse(_quantidadeController.text.trim().replaceAll(',', '.')),
        responsavelNome: widget.responsavelNome,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _salvando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Falha ao registrar entrada: $e')),
      );
    }
  }
}
