import 'package:admin/controllers/Auth.dart';
import 'package:admin/screens/members/components/team_tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';

class TeamScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final usuario = authController.usuario;

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
            SizedBox(height: defaultPadding),
            TeamTables(onSelect: (usuario) {}, usuarioLogado: usuario),
          ],
        ),
      ),
    );
  }
}
