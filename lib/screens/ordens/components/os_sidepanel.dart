import 'package:admin/models/Usuario.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../controllers/Auth.dart';
import '../../../models/OrdemServico.dart';
import '../../../services/firestore_service.dart';

class OSFormSidePanel extends StatefulWidget {
  @override
  _OSFormSidePanelState createState() => _OSFormSidePanelState();
}

class _OSFormSidePanelState extends State<OSFormSidePanel> {
  final _formKey = GlobalKey<FormState>();

  String? _subsistema;
  List<String> _responsavel = [];
  String? _prioridade;
  List<OSDependencia> _dependencias = [];
  String? _osDependenteId;
  String _tipoDependencia = "FS";
  String _codigoSequencial = '';

  String _titulo = '';
  String _descricao = '';
  int _horas = 1;

  @override
  Widget build(BuildContext context) {
    final userLogado = context.watch<AuthController>().usuario;
    if (userLogado == null) {
      print("Usuário não logado. Não é possível abrir o formulário.");
      return const Center(child: CircularProgressIndicator());
    }

    if (_subsistema == null) {
      List<String> permitidos = _getListaSubsistemasPermitidos(userLogado);
      if (permitidos.isNotEmpty) {
        print("Subsistema inicial definido como: ${permitidos.first}");
        _subsistema = permitidos.first;
      }
    }

    return Container(
      color: Colors.black87,
      padding: EdgeInsets.all(defaultPadding),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text("Nova Ordem de Serviço",
                style: Theme.of(context).textTheme.titleLarge),
            const Divider(color: Colors.white10),
            Expanded(
              child: ListView(
                children: [
                  _buildField("Título da OS", (val) => _titulo = val),
                  _buildSubsistemaDropdown(userLogado),
                  const SizedBox(height: defaultPadding / 2),
                  _buildPrioridadeDropdown(),
                  const SizedBox(height: defaultPadding / 2),
                  _buildMultiResponsavelSelect(userLogado),
                  const SizedBox(height: defaultPadding / 2),
                  _buildDependenciaDropdown(),
                  SizedBox(height: defaultPadding / 2),
                  _buildTipoDependenciaDropdown(),
                  const SizedBox(height: defaultPadding / 2),
                  _buildField("Horas Estimadas (H/H)",
                      (val) => _horas = int.tryParse(val) ?? 1,
                      isNumber: true),
                  _buildField("Descrição Técnica", (val) => _descricao = val,
                      maxLines: 4),
                ],
              ),
            ),
            _buildSubmitButton(userLogado.nome),
          ],
        ),
      ),
    );
  }

  List<String> _getListaSubsistemasPermitidos(Usuario user) {
    const todosSubsistemas = [
      'FASD',
      'CE',
      'EAD',
      'PEE',
      'Marketing',
      'Financeiro',
      'Patrocínio'
    ];

    if (user.role == UserRole.capitao || user.role == UserRole.admin) {
      return todosSubsistemas;
    } else if (user.role == UserRole.diretor || user.role == UserRole.lider) {
      return user.subsistema;
    }

    return []; // Membros comuns (se houver lógica para eles)
  }

  Widget _buildTipoDependenciaDropdown() {
    return Theme(
      // Remove o roxo padrão do Material 3 para este widget
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          brightness: Brightness.dark,
          primary: Colors.orangeAccent,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: _tipoDependencia,
        items: const [
          DropdownMenuItem(
            value: "FS",
            child: Text("Finalizar → Iniciar"),
          ),
          DropdownMenuItem(
            value: "SS",
            child: Text("Iniciar → Iniciar"),
          ),
        ],
        onChanged: (val) {
          setState(() {
            _tipoDependencia = val!;
          });
        },
        decoration: const InputDecoration(
          labelText: "Tipo de dependência",
        ),
        dropdownColor: Colors.grey[800],
      ),
    );
  }

  Widget _buildDependenciaDropdown() {
    return StreamBuilder<List<OrdemServico>>(
      stream: FirestoreService().getTodasOS(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        List<OrdemServico> lista = snapshot.data!;

        return Theme(
          // Remove o roxo padrão do Material 3 para este widget
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.orangeAccent,
              brightness: Brightness.dark,
              primary: Colors.orangeAccent,
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: _osDependenteId,
            hint: const Text("Selecionar OS dependente"),
            items: lista.map((os) {
              return DropdownMenuItem(
                value: os.id,
                child: Text(
                  "${os.codigoSequencial} - ${os.titulo}",
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
            onChanged: (val) {
              setState(() {
                _osDependenteId = val;
                _codigoSequencial =
                    lista.firstWhere((os) => os.id == val).codigoSequencial ??
                        '';
              });
            },
            decoration: const InputDecoration(
              labelText: "Depende de",
            ),
            dropdownColor:
                Colors.grey[800], // Cinza escuro consistente com o template
          ),
        );
      },
    );
  }

  Widget _buildSubsistemaDropdown(Usuario user) {
    List<String> opcoesPermitidas = _getListaSubsistemasPermitidos(user);
    return Theme(
      // Remove o roxo padrão do Material 3 para este widget
      data: Theme.of(context).copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          brightness: Brightness.dark,
          primary: Colors.orangeAccent,
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue:
            _subsistema, // Alterado para 'value' para melhor controle de estado
        items: opcoesPermitidas
            .map((s) => DropdownMenuItem(
                  value: s,
                  child: Text(s, style: const TextStyle(color: Colors.white)),
                ))
            .toList(),
        onChanged: (val) {
          setState(() {
            _subsistema = val!;
            _responsavel = [];
          });
        },
        decoration: InputDecoration(
          labelText: "Subsistema: " + _subsistema.toString(),
          labelStyle: const TextStyle(color: Colors.white54),
          // Cor da borda inferior ao clicar (foco)
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.orangeAccent),
          ),
          helperText: opcoesPermitidas.length == 1
              ? "Fixo para seu nível de acesso"
              : null,
        ),
        dropdownColor:
            Colors.grey[800], // Cinza escuro consistente com o template
        validator: (val) => val == null ? "Selecione um subsistema" : null,
        iconEnabledColor: Colors.orangeAccent, // Seta laranja
        focusColor: Colors.transparent, // Remove o fundo roxo ao selecionar
      ),
    );
  }

  Widget _buildMultiResponsavelSelect(Usuario user) {
    return StreamBuilder<List<Usuario>>(
      stream: FirestoreService().getUsuariosPorSubsistema(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator(color: Colors.orangeAccent);
        }
        if (snapshot.hasError) return const Text("Erro ao carregar membros");

        List<Usuario> membros = snapshot.data ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.group_outlined,
                    color: Colors.orangeAccent, size: 20),
                SizedBox(width: 8),
                Text("Responsáveis", style: TextStyle(color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 12),
            membros.isEmpty
                ? Text("Nenhum membro em $_subsistema",
                    style: const TextStyle(color: Colors.white24, fontSize: 13))
                : Wrap(
                    spacing: 8.0, // Espaço horizontal entre os nomes
                    runSpacing: 4.0, // Espaço vertical se quebrar a linha
                    children: membros.map((m) {
                      // Verificamos se o nome do membro já está na nossa lista de selecionados
                      final isSelected = _responsavel.contains(m.nome);

                      return FilterChip(
                        label: Text(m.nome),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white70,
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        selected: isSelected,
                        selectedColor: Colors.orangeAccent,
                        backgroundColor: Colors.grey[800],
                        checkmarkColor: Colors.black,
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _responsavel.add(m.nome);
                            } else {
                              _responsavel.remove(m.nome);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
          ],
        );
      },
    );
  }

  Widget _buildPrioridadeDropdown() {
    return Theme(
      data: Theme.of(context).copyWith(
        // Isso remove o realce roxo quando o menu abre
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orangeAccent,
          brightness: Brightness.dark,
          primary: Colors.orangeAccent, // Substitui o roxo globalmente aqui
        ),
      ),
      child: DropdownButtonFormField<String>(
        initialValue:
            _prioridade, // Use value em vez de initialValue para refletir mudanças
        items: ['Urgente', 'Alta', 'Media', 'Baixa']
            .map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p, style: const TextStyle(color: Colors.white)),
                ))
            .toList(),
        onChanged: (val) => setState(() => _prioridade = val!),
        // Ajuste da decoração para evitar bordas roxas
        decoration: InputDecoration(
          labelText: "Prioridade",
          labelStyle: const TextStyle(color: Colors.white54),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.orangeAccent),
          ),
        ),
        dropdownColor:
            Colors.grey[800], // Usando a cor do template (cinza escuro)
        validator: (val) => val == null ? "Selecione uma prioridade" : null,
        iconEnabledColor: Colors.orangeAccent, // Seta do dropdown laranja
        // Remova o focusColor ou defina como transparente
        focusColor: Colors.transparent,
      ),
    );
  }

  Widget _buildSubmitButton(String criadoPor) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            _formKey.currentState!.save();

            if (_osDependenteId != null) {
              print(
                  "Criando dependência: OS nova depende de $_osDependenteId com tipo $_tipoDependencia");
              _dependencias = [
                OSDependencia(
                  osId: _osDependenteId!,
                  tipo: _tipoDependencia,
                  codigoSequencial: _codigoSequencial,
                )
              ];
            }
            OrdemServico nova = OrdemServico(
              titulo: _titulo,
              descricao: _descricao,
              subsistema: _subsistema,
              responsavel: _responsavel,
              prioridade: _prioridade,
              horasEstimadas: _horas,
              status: "Pendente",
              dependentes: _dependencias,
            );

            await FirestoreService().abrirNovaOS(nova, criadoPor);
            Navigator.pop(context);
          }
        },
        child: const Text("CRIAR OS",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Widget de campo genérico para economizar código
  Widget _buildField(String label, Function(String) onSave,
      {bool isNumber = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: defaultPadding),
      child: Theme(
        // Aplicamos o tema local para garantir que o cursor e a borda
        // de foco usem o laranja da equipe
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.orangeAccent,
            brightness: Brightness.dark,
            primary: Colors.orangeAccent,
          ),
        ),
        child: TextFormField(
          maxLines: maxLines,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white54),
            // Borda padrão (quando não está selecionado)
            border: const OutlineInputBorder(),
            // Borda quando o aluno clica para digitar (Remove o Roxo)
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.orangeAccent, width: 2),
            ),
            // Cor da label quando focada
            floatingLabelStyle: const TextStyle(color: Colors.orangeAccent),
          ),
          onSaved: (val) => onSave(val ?? ""),
          validator: (val) => val!.isEmpty ? "Campo Obrigatório" : null,
          cursorColor: Colors.orangeAccent, // Cursor laranja
        ),
      ),
    );
  }
}
