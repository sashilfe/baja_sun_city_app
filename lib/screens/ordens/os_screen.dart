import 'package:admin/controllers/Auth.dart';
import 'package:admin/screens/ordens/components/os_sidepanel.dart';
import 'package:admin/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import 'components/os_table.dart';
import '../../responsive.dart';

class OrdensServicoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final usuario = authController.usuario;

    final firestoreService = FirestoreService();
    if (usuario == null) {
      return Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      );
    }
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (usuario == null) Center(child: CircularProgressIndicator()),
                if (usuario.podeCriarOS ?? true)
                  ElevatedButton.icon(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: defaultPadding * 1.5,
                        vertical: defaultPadding /
                            (Responsive.isMobile(context) ? 2 : 1),
                      ),
                      backgroundColor: Colors.orangeAccent,
                    ),
                    onPressed: () {
                      _abrirFormularioModal(context);
                    },
                    icon: Icon(Icons.add, color: Colors.black),
                    label:
                        Text("NOVA OS", style: TextStyle(color: Colors.black)),
                  ),
              ],
            ),
            SizedBox(height: defaultPadding),
            OSTableFull(
                osStream: firestoreService
                    .getDashboardOS(usuario!)), // A tabela com todos os dados
          ],
        ),
      ),
    );
  }
}

void _abrirFormularioModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: OSFormSidePanel(),
          ),
        ),
      );
    },
  );
}
