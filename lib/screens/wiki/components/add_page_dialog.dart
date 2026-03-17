import 'package:admin/constants.dart';
import 'package:admin/models/Wiki.dart';
import 'package:admin/services/wiki_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AddPageDialog extends StatefulWidget {
  final WikiService wikiService;
  final WikiPage? pageToEdit;

  const AddPageDialog({super.key, required this.wikiService, this.pageToEdit});

  @override
  State<AddPageDialog> createState() => _AddPageDialogState();
}

class _AddPageDialogState extends State<AddPageDialog> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  String? selectedCategoryId;
  bool get isEditing => widget.pageToEdit != null;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.pageToEdit?.title ?? "");
    contentController = TextEditingController(text: widget.pageToEdit?.content ?? "");
    // TODO: Salvar o categoryId no modelo WikiPage para preencher aqui na edição.
    // selectedCategoryId = widget.pageToEdit?.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: darkBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: borderColor, width: 0.5),
      ),
      title: Row(
        children: [
          Icon(
            isEditing ? Icons.edit_note_outlined : Icons.note_add_outlined,
            color: orangeAccentColor,
          ),
          const SizedBox(width: defaultPadding),
          Text(
            isEditing ? 'Editar Página' : 'Nova Página',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6, // Responsivo
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                label: 'Título da Página',
                hint: 'Como instalar o Flutter no Windows',
                icon: Icons.title,
              ),
            ),
            const SizedBox(height: defaultPadding),
            StreamBuilder<List<WikiCategory>>(
              stream: widget.wikiService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const LinearProgressIndicator();
                return DropdownButtonFormField<String>(
                  dropdownColor: darkSecondaryColor,
                  value: selectedCategoryId,
                  items: snapshot.data!.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.title,
                          style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedCategoryId = value),
                  decoration: _inputDecoration(
                    label: 'Categoria de Destino',
                    hint: 'Selecione uma categoria',
                    icon: Icons.folder_special_outlined,
                  ),
                );
              },
            ),
            const SizedBox(height: defaultPadding),
            TextField(
              controller: contentController,
              maxLines: 12,
              style: GoogleFonts.firaCode(textStyle: const TextStyle(color: Colors.white70)),
              decoration: _inputDecoration(
                label: 'Conteúdo da Página (Markdown)',
                hint: 'Use a sintaxe Markdown para formatar o texto...',
              ).copyWith(alignLabelWithHint: true, prefixIcon: null),
            ),
          ],
        ),
      ),
      actions: [
        _DialogActionButton(
          label: "CANCELAR",
          onTap: () => Navigator.pop(context),
          isPrimary: false,
        ),
        const SizedBox(width: 8),
        _DialogActionButton(
          label: isEditing ? 'SALVAR' : 'CRIAR PÁGINA',
          onTap: () async {
            if (titleController.text.isEmpty ||
                (selectedCategoryId == null && !isEditing)) {
              // TODO: Mostrar feedback de erro para o usuário
              return;
            }

            if (isEditing) {
              // TODO: Implementar a lógica de update no WikiService
              // await widget.wikiService.updatePage(...);
            } else {
              await widget.wikiService.addPage(
                  titleController.text, contentController.text, selectedCategoryId!);
            }
            if (mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required String hint, IconData? icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon, color: Colors.white38) : null,
      labelStyle: const TextStyle(color: Colors.white54),
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: darkSecondaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: orangeAccentColor, width: 1),
      ),
    );
  }
}

class _DialogActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _DialogActionButton({
    required this.label,
    required this.onTap,
    this.isPrimary = true,
  });

  @override
  __DialogActionButtonState createState() => __DialogActionButtonState();
}

class __DialogActionButtonState extends State<_DialogActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final Color textColor = widget.isPrimary
        ? Colors.black
        : _isHovered
            ? Colors.white
            : Colors.white60;
    final Color bgColor = widget.isPrimary
        ? orangeAccentColor
        : _isHovered
            ? Colors.white.withOpacity(0.1)
            : Colors.transparent;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding, vertical: defaultPadding / 2),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: widget.isPrimary
                  ? Colors.transparent
                  : _isHovered
                      ? Colors.white70
                      : Colors.white30,
              width: 0.5,
            ),
          ),
          child: Text(
            widget.label,
            style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
