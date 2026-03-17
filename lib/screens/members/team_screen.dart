import 'package:admin/controllers/Auth.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/members/components/team_tables.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';

class TeamScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Responsive(
        mobile: TeamScreenMobile(),
        tablet: TeamScreenDesktop(),
        desktop: TeamScreenDesktop(),
      ),
    );
  }
}

class TeamScreenDesktop extends StatelessWidget {
  const TeamScreenDesktop({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final usuario = authController.usuario;

    if (usuario == null) {
      return Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          SizedBox(height: defaultPadding),
          TeamTables(onSelect: (usuario) {}, usuarioLogado: usuario),
        ],
      ),
    );
  }
}

class TeamScreenMobile extends StatelessWidget {
  const TeamScreenMobile({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final usuario = authController.usuario;

    if (usuario == null) {
      return Center(
        child: CircularProgressIndicator(color: Colors.orangeAccent),
      );
    }
    return SingleChildScrollView(
      padding: EdgeInsets.all(defaultPadding),
      child: Column(
        children: [
          SizedBox(height: defaultPadding),
          TeamTables(onSelect: (usuario) {}, usuarioLogado: usuario),
        ],
      ),
    );
  }
}
