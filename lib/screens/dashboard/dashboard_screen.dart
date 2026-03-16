import 'package:admin/controllers/Auth.dart';
import 'package:admin/models/Usuario.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/components/kpi_section.dart';
import 'package:admin/screens/dashboard/components/my_fields.dart';
import 'package:admin/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants.dart';

import 'components/recent_orders.dart';
import 'components/storage_details.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final usuario = authController.usuario;

    final firestoreService = FirestoreService();
    return SafeArea(
      child: SingleChildScrollView(
        primary: false,
        padding: EdgeInsets.only(left: defaultPadding, right: defaultPadding),
        child: Column(
          children: [
            SizedBox(height: defaultPadding),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      if (usuario?.podeCriarOS ?? true) OSKpiSection(),
                      SizedBox(height: defaultPadding),
                      if (usuario != null)
                        RecentOrders(
                          osStream:
                              firestoreService.getDashboardRecentOS(usuario),
                        ),
                      if (Responsive.isMobile(context))
                        SizedBox(height: defaultPadding),
                    ],
                  ),
                ),
                if (!Responsive.isMobile(context))
                  SizedBox(width: defaultPadding),
                // On Mobile means if the screen is less than 850 we dont want to show it
                if (!Responsive.isMobile(context))
                  Expanded(
                    flex: 2,
                    child: StarageDetails(),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
