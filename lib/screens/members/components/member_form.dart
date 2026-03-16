import 'package:admin/constants.dart';
import 'package:admin/models/Usuario.dart';
import 'package:admin/services/firestore_service.dart';
import 'package:flutter/material.dart';

class MemberForm extends StatefulWidget {
  final Usuario? membro;
  final VoidCallback onSave;

  const MemberForm({Key? key, this.membro, required this.onSave})
      : super(key: key);

  @override
  _MemberFormState createState() => _MemberFormState();
}

class _MemberFormState extends State<MemberForm> {
  final _formKey = GlobalKey<FormState>();
  late String _nome, _email, _role;
  late List<String> _subsistema;
  bool _ativo = true;

  @override
  void initState() {
    super.initState();
    // Inicializa com os dados do membro ou valores padrão
    _nome = widget.membro?.nome ?? "";
    _email = widget.membro?.email ?? "";
    _subsistema = List<String>.from(widget.membro?.subsistema ?? []);
    _role = widget.membro?.role.toString().split('.').last ?? "membro";
    _ativo = widget.membro?.ativo ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField("Nome Completo", _nome, (val) => _nome = val),
            _buildTextField("E-mail Acadêmico", _email, (val) => _email = val,
                enabled: widget.membro == null),
            _buildMultiSelectSubsistemas(),
            _buildDropdown(
                "Cargo / Permissão",
                _role,
                [
                  'capitao',
                  'diretor',
                  'lider',
                  'membro',
                  'treinee',
                  'orientador'
                ],
                (val) => setState(() => _role = val!)),
            SwitchListTile(
              title: Text("Membro Ativo", style: TextStyle(fontSize: 14)),
              value: _ativo,
              activeColor: Colors.orangeAccent,
              onChanged: (val) => setState(() => _ativo = val),
            ),
            SizedBox(height: defaultPadding),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    if (_subsistema.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Selecione ao menos um subsistema")));
                      return;
                    }
                    await FirestoreService().salvarMembro(
                      uid: widget.membro?.uid,
                      nome: _nome,
                      email: _email,
                      subsistema: _subsistema,
                      role: _role,
                      ativo: _ativo,
                    );
                    widget.onSave();
                  }
                },
                child: Text(
                    widget.membro == null
                        ? "ADICIONAR MEMBRO"
                        : "SALVAR ALTERAÇÕES",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiSelectSubsistemas() {
    List<String> todosSubsistemas = [
      'FASD',
      'CE',
      'EAD',
      'PEE',
      'Marketing',
      'Financeiro',
      'Patrocínio'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Subsistemas (Selecione um ou mais)",
            style: TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          children: todosSubsistemas.map((sub) {
            bool isSelected = _subsistema.contains(sub);
            return FilterChip(
              label: Text(sub,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white,
                    fontSize: 12,
                  )),
              selected: isSelected,
              selectedColor: Colors.orangeAccent,
              checkmarkColor: Colors.black,
              backgroundColor: secondaryColor,
              shape: StadiumBorder(
                  side: BorderSide(
                      color:
                          isSelected ? Colors.orangeAccent : Colors.white24)),
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _subsistema.add(sub);
                  } else {
                    _subsistema.remove(sub);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: defaultPadding),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    String initialValue,
    Function(String) onSave, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: TextFormField(
        initialValue: initialValue,
        enabled: enabled,
        maxLines: maxLines,
        style: TextStyle(color: enabled ? Colors.white : Colors.white38),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          // Estilo quando o campo está desabilitado (ex: e-mail de membro existente)
          disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white10),
            borderRadius: BorderRadius.circular(10),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orangeAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor:
              enabled ? Colors.transparent : Colors.white.withOpacity(0.02),
        ),
        onSaved: (val) => onSave(val ?? ""),
        validator: (val) =>
            val == null || val.isEmpty ? "Campo obrigatório" : null,
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged, {
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: DropdownButtonFormField<String>(
        value: items.contains(value)
            ? value
            : null, // Evita erro se o valor não estiver na lista
        onChanged: enabled ? onChanged : null, // Desabilita se necessário
        style: const TextStyle(color: Colors.white, fontSize: 14),
        dropdownColor: Colors.grey[800],
        icon: const Icon(Icons.arrow_drop_down, color: Colors.orangeAccent),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor:
              enabled ? Colors.transparent : Colors.white.withOpacity(0.02),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.orangeAccent),
            borderRadius: BorderRadius.circular(10),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white10),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        validator: (val) => val == null ? "Seleção obrigatória" : null,
      ),
    );
  }
}
