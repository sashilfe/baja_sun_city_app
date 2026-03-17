import 'package:admin/constants.dart';
import 'package:admin/models/Wiki.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class PageView extends StatelessWidget {
  final WikiPage? page;
  final VoidCallback? onEdit;
  const PageView({Key? key, this.page, this.onEdit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (page == null) return _buildEmptyState();

    return Expanded(
      child: Container(
        color: darkBgColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding * 3, vertical: defaultPadding * 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header da Página
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("DOCUMENTAÇÃO TÉCNICA",
                          style: TextStyle(
                              color: orangeAccentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1)),
                      const SizedBox(height: 8),
                      Text(page!.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ],
                  ),
                  _EditButton(onEdit: onEdit), // Botão de edição refatorado
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: defaultPadding),
                child: Divider(color: borderColor),
              ),
              // Markdown Estilizado
              MarkdownBody(
                data: page!.content,
                selectable: true,
                styleSheet: _getMarkdownStyleSheet(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MarkdownStyleSheet _getMarkdownStyleSheet(BuildContext context) {
    return MarkdownStyleSheet(
      h1: const TextStyle(
          color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
      h2: const TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700),
      h3: const TextStyle(
          color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      p: const TextStyle(
          color: Colors.white70, height: 1.6, fontSize: 16),
      code: GoogleFonts.firaCode(
        textStyle: const TextStyle(
          backgroundColor: darkCodeBgColor,
          color: Colors.cyanAccent,
        ),
      ),
      codeblockDecoration: BoxDecoration(
        color: darkCodeBgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      blockquote: const TextStyle(
          color: Colors.white60, fontStyle: FontStyle.italic),
      blockquoteDecoration: const BoxDecoration(
        border: Border(left: BorderSide(color: orangeAccentColor, width: 4)),
        color: darkSecondaryColor,
      ),
      listBullet:
          const TextStyle(color: Colors.white70, height: 1.6, fontSize: 16),
    );
  }

  Widget _buildEmptyState() {
    return const Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_stories_outlined, size: 80, color: darkSecondaryColor),
            SizedBox(height: 16),
            Text(
              "Selecione um tópico na barra lateral\npara visualizar o guia técnico.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditButton extends StatefulWidget {
  final VoidCallback? onEdit;
  const _EditButton({this.onEdit});

  @override
  __EditButtonState createState() => __EditButtonState();
}

class __EditButtonState extends State<_EditButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isEnabled = widget.onEdit != null;
    final Color color = isEnabled
        ? (_isHovered ? Colors.white : Colors.white54)
        : Colors.white12;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Tooltip(
        message: "Editar Página",
        child: IconButton(
          icon: Icon(Icons.edit_outlined, size: 20, color: color),
          onPressed: widget.onEdit,
          style: IconButton.styleFrom(
            backgroundColor: _isHovered && isEnabled
                ? Colors.white.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
