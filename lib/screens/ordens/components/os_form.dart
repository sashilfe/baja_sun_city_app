import 'package:flutter/material.dart';
import '../../../constants.dart';

class OrdemServicoForm extends StatefulWidget {
  @override
  _OrdemServicoFormState createState() => _OrdemServicoFormState();
}

class _OrdemServicoFormState extends State<OrdemServicoForm> {
  final _formKey = GlobalKey<FormState>();

  String? tarefa, subsistema, responsavel;
  int? horasEstimadas;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Nova Ordem de Serviço",
                style: Theme.of(context).textTheme.titleMedium),
            SizedBox(height: defaultPadding),
            TextFormField(
              decoration: InputDecoration(labelText: "Nome da Tarefa"),
              onSaved: (val) => tarefa = val,
            ),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: "Subsistema"),
                    items: ["Suspensão", "Powertrain", "Chassi", "Eletrônica"]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => subsistema = val),
                  ),
                ),
                SizedBox(width: defaultPadding),
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: "Horas Estimadas"),
                    keyboardType: TextInputType.number,
                    onSaved: (val) => horasEstimadas = int.tryParse(val ?? "0"),
                  ),
                ),
              ],
            ),
            SizedBox(height: defaultPadding),
            ElevatedButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    horizontal: defaultPadding * 1.5, vertical: defaultPadding),
                backgroundColor: Colors.orangeAccent,
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  // Aqui você chamará o seu Controller para salvar no Firebase
                }
              },
              icon: Icon(Icons.add, color: Colors.black),
              label: Text("ABRIR ORDEM", style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
