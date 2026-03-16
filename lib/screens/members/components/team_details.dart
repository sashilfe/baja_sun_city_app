import 'package:admin/controllers/Auth.dart';
import 'package:admin/controllers/OS.dart';
import 'package:admin/models/Usuario.dart';
import 'package:admin/screens/members/components/member_identify.dart';
import 'package:admin/screens/members/components/member_tabs.dart';
import 'package:admin/screens/ordens/components/os_info_card.dart';
import 'package:admin/screens/ordens/components/os_tabs_view.dart';
import 'package:admin/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/models/OrdemServico.dart';
import 'package:provider/provider.dart';

class TeamDetailsScreen extends StatelessWidget {
  final Usuario membro; // Agora passamos o objeto Usuario que queremos analisar

  const TeamDetailsScreen({Key? key, required this.membro}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text("Perfil do Membro: ${membro.nome}"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 900) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ESQUERDA: Dados do Usuário (Identidade e Cargo)
                    Expanded(flex: 2, child: MemberIdentityCard(user: membro)),
                    SizedBox(width: defaultPadding),
                    // DIREITA: Abas de Desempenho, Histórico e Habilidades
                    Expanded(
                        flex: 3, child: MemberPerformanceTabs(user: membro)),
                  ],
                );
              } else {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      MemberIdentityCard(user: membro),
                      SizedBox(height: defaultPadding),
                      SizedBox(
                          height: 600,
                          child: MemberPerformanceTabs(user: membro)),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
