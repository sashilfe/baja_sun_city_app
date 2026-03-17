import 'package:admin/constants.dart';
import 'package:admin/models/Wiki.dart';
import 'package:admin/screens/wiki/components/add_category_dialog.dart';
import 'package:admin/screens/wiki/components/add_page_dialog.dart';
import 'package:admin/screens/wiki/components/category_list.dart';
import 'package:admin/screens/wiki/components/page_view.dart';
import 'package:admin/services/wiki_service.dart';
import 'package:flutter/material.dart' hide PageView;

class WikiScreen extends StatefulWidget {
  @override
  _WikiScreenState createState() => _WikiScreenState();
}

class _WikiScreenState extends State<WikiScreen> {
  final WikiService _wikiService = WikiService();
  WikiPage? _selectedPage;

  @override
  void initState() {
    super.initState();
    _selectedPage = null;
  }

  void _editarPagina(WikiPage page) {
    showDialog(
      context: context,
      builder: (context) => AddPageDialog(
        wikiService: _wikiService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBgColor, // Aplicando a nova cor de fundo
      body: Row(
        children: [
          StreamBuilder<List<WikiCategory>>(
            stream: _wikiService.getCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return const Center(
                    child: Text("Erro ao carregar as categorias."));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return CategoryList(
                  categories: [],
                  selectedPageId: _selectedPage?.id,
                  onPageSelected: (page) {},
                  onAddCategory: _addCategory,
                  onAddPage: _addPage,
                );
              }
              final categories = snapshot.data!;
              return CategoryList(
                categories: categories,
                selectedPageId: _selectedPage?.id,
                onPageSelected: (page) {
                  setState(() {
                    _selectedPage = page;
                  });
                },
                onAddCategory: _addCategory,
                onAddPage: _addPage,
              );
            },
          ),
          PageView(
            page: _selectedPage,
            onEdit: _selectedPage != null
                ? () => _editarPagina(_selectedPage!)
                : null,
          ),
        ],
      ),
    );
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (context) => AddCategoryDialog(wikiService: _wikiService),
    );
  }

  void _addPage() {
    showDialog(
      context: context,
      builder: (context) => AddPageDialog(wikiService: _wikiService),
    );
  }
}
