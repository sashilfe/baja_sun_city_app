import 'package:admin/screens/members/components/member_history.dart';
import 'package:admin/screens/members/components/member_kpi.dart';
import 'package:flutter/material.dart';
import 'package:admin/constants.dart';
import 'package:admin/models/Usuario.dart';

class MemberPerformanceTabs extends StatelessWidget {
  final Usuario user;

  const MemberPerformanceTabs({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Quantidade de abas
      child: Container(
        padding: const EdgeInsets.all(defaultPadding),
        decoration: BoxDecoration(
          color: secondaryColor,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: Column(
          children: [
            TabBar(
              indicatorColor: Colors.orangeAccent,
              labelColor: Colors.orangeAccent,
              unselectedLabelColor: Colors.white54,
              tabs: [
                Tab(text: "Desempenho Técnico"),
                Tab(text: "Histórico de OSs"),
              ],
            ),
            const SizedBox(height: defaultPadding),
            Expanded(
              child: TabBarView(
                children: [
                  MemberKPITab(user: user),
                  MemberHistoryTab(user: user),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
