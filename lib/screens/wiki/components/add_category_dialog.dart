import 'package:admin/constants.dart';
import 'package:admin/services/wiki_service.dart';
import 'package:flutter/material.dart';

class AddCategoryDialog extends StatelessWidget {
  final WikiService wikiService;
  final TextEditingController controller = TextEditingController();

  AddCategoryDialog({super.key, required this.wikiService});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: darkBgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: borderColor, width: 0.5),
      ),
      child: Container(
        padding: const EdgeInsets.all(defaultPadding * 1.5),
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.create_new_folder_outlined,
                    color: orangeAccentColor),
                const SizedBox(width: defaultPadding),
                Text(
                  "Nova Categoria",
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding * 1.5),
            TextField(
              controller: controller,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration(
                label: "Título da Categoria",
                hint: "Ex: Suspensão, Eletrônica...",
                icon: Icons.folder_open,
              ),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _DialogActionButton(
                  label: "CANCELAR",
                  onTap: () => Navigator.pop(context),
                  isPrimary: false,
                ),
                const SizedBox(width: 8),
                _DialogActionButton(
                  label: "CRIAR",
                  onTap: () {
                    if (controller.text.isNotEmpty) {
                      wikiService.addCategory(controller.text);
                      Navigator.pop(context);
                    }
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
      {required String label, required String hint, required IconData icon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.white38),
      labelStyle: const TextStyle(color: Colors.white54),
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: darkSecondaryColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
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
            style:
                TextStyle(color: textColor, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
