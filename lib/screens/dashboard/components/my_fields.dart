import 'package:admin/models/MyFiles.dart';
import 'package:admin/models/OSSummary.dart';
import 'package:admin/responsive.dart';
import 'package:admin/services/firestore_service.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import 'file_info_card.dart';

class MyFiles extends StatelessWidget {
  const MyFiles({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "KPIs",
              style: Theme.of(context).textTheme.titleMedium,
            )
          ],
        ),
        SizedBox(height: defaultPadding),
        Responsive(
          mobile: FileInfoCardGridView(
            crossAxisCount: _size.width < 650 ? 2 : 4,
            childAspectRatio: _size.width < 650 && _size.width > 350 ? 1.3 : 1,
          ),
          tablet: FileInfoCardGridView(),
          desktop: FileInfoCardGridView(
            childAspectRatio: _size.width < 1400 ? 1.1 : 1.4,
          ),
        ),
      ],
    );
  }
}

class FileInfoCardGridView extends StatelessWidget {
  const FileInfoCardGridView({
    Key? key,
    this.crossAxisCount = 4,
    this.childAspectRatio = 1,
  }) : super(key: key);

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();
    return StreamBuilder<OSSummary>(
      stream:
          firestoreService.getOSSummaryStream(), // O Stream que criamos antes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final summary = snapshot.data ?? OSSummary();

        // Mapeamos os dados do Firebase para o formato dos Cards
        List<OSStatusInfo> osCards = [
          OSStatusInfo(
            title: "Pendentes",
            totalOS: summary.pendentes,
            svgSrc: "assets/icons/Documents.svg",
            color: primaryColor,
            percentage: summary.total > 0
                ? (summary.pendentes / summary.total) * 100
                : 0,
          ),
          OSStatusInfo(
            title: "Em Execução",
            totalOS: summary.abertas,
            svgSrc: "assets/icons/google_drive.svg",
            color: const Color(0xFFFFA113), // Laranja Baja
            percentage:
                summary.total > 0 ? (summary.abertas / summary.total) * 100 : 0,
          ),
          OSStatusInfo(
            title: "Concluídas",
            totalOS: summary.fechadas,
            svgSrc: "assets/icons/one_drive.svg",
            color: const Color(0xFF00B127), // Verde sucesso
            percentage: summary.total > 0
                ? (summary.fechadas / summary.total) * 100
                : 0,
          ),
        ];

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: osCards.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: defaultPadding,
            mainAxisSpacing: defaultPadding,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) => FileInfoCard(
            title: osCards[index].title,
            svgSrc: osCards[index].svgSrc,
            amount: osCards[index].totalOS.toString(),
            percentage: osCards[index].percentage.toInt(),
            color: osCards[index].color,
          ),
        );
      },
    );
  }
}

class OSStatusInfo {
  final String title, svgSrc;
  final int totalOS;
  final Color color;
  final double percentage;

  OSStatusInfo({
    required this.title,
    required this.svgSrc,
    required this.totalOS,
    required this.color,
    required this.percentage,
  });
}
