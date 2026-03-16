import 'package:flutter/material.dart';
import '../../../constants.dart';

class OSDialogForm extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: secondaryColor,
      title: Text("Registrar Nova Atividade"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: "Título da Tarefa"),
                validator: (value) =>
                    value!.isEmpty ? "Campo obrigatório" : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "Subsistema"),
                items: [
                  "Suspensão",
                  "Powertrain",
                  "Chassi",
                  "Eletrônica",
                  "Cálculo"
                ]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {},
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Responsável"),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "Horas Estimadas"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context), child: Text("Cancelar")),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Lógica para salvar no Firebase virá aqui
              Navigator.pop(context);
            }
          },
          child: Text("Salvar OS"),
        ),
      ],
    );
  }
}
