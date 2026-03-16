import 'package:admin/models/Usuario.dart';
import 'package:admin/screens/members/components/team_details.dart';
import 'package:admin/services/firestore_service.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import '../../../constants.dart';

class TeamTables extends StatelessWidget {
  final Function(Usuario) onSelect;
  final Usuario usuarioLogado;

  const TeamTables(
      {Key? key, required this.onSelect, required this.usuarioLogado})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Usuario>>(
      stream: FirestoreService().getUsuariosPorSubsistema(usuarioLogado),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          print("Nenhum membro encontrado no Firestore. " +
              snapshot.data.toString());
          return const Center(child: Text("Nenhum membro cadastrado."));
        }

        List<Usuario> membros = snapshot.data!;
        return SizedBox(
          height: 500,
          child: DataTable2(
            columnSpacing: defaultPadding,
            minWidth: 600,
            showCheckboxColumn: false,
            columns: const [
              DataColumn2(label: Text("Membro"), size: ColumnSize.L),
              DataColumn(label: Text("Subsistema")),
              DataColumn(label: Text("Cargo")),
              DataColumn(label: Text("Status")),
            ],
            rows: List.generate(
              membros.length,
              (index) => _buildDataRow(membros[index], context),
            ),
          ),
        );
      },
    );
  }

  DataRow _buildDataRow(Usuario membro, BuildContext context) {
    return DataRow(
      onSelectChanged: (selected) {
        if (selected != null && selected) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamDetailsScreen(membro: membro),
            ),
          );
        }
      },
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundImage: membro.fotoUrl != null
                    ? NetworkImage(membro.fotoUrl!)
                    : null,
                child: membro.fotoUrl == null
                    ? const Icon(Icons.person, size: 20)
                    : null,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(membro.nome,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(membro.email,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.white54)),
                  ],
                ),
              ),
            ],
          ),
        ),

        DataCell(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Wrap(
              spacing: 4, // Espaço horizontal entre as tags
              runSpacing: 4, // Espaço vertical se houver quebra de linha
              children: membro.subsistema.isNotEmpty
                  ? membro.subsistema
                      .map((sub) => _buildSubsistemaTag(sub))
                      .toList()
                  : [
                      const Text("Sem Subsistema",
                          style: TextStyle(fontSize: 11, color: Colors.white24))
                    ],
            ),
          ),
        ),
        // Coluna Cargo (Badge Colorida)
        DataCell(_buildRoleBadge(membro.role)),
        DataCell(
          Icon(
            Icons.circle,
            size: 12,
            color: membro.ativo ? Colors.green : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSubsistemaTag(String nome) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        nome,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.orangeAccent, // Mantendo a identidade visual do Baja
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color color;
    switch (role) {
      case UserRole.admin:
        color = Colors.redAccent;
        break;
      case UserRole.capitao:
        color = Colors.orangeAccent;
        break;
      case UserRole.diretor:
        color = Colors.purpleAccent;
        break;
      case UserRole.lider:
        color = Colors.blueAccent;
        break;
      case UserRole.orientador:
        color = Colors.greenAccent;
        break;
      default:
        color = Colors.white24;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        role.toString().split('.').last.toUpperCase(),
        style:
            TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
