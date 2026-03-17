import 'package:admin/constants.dart';
import 'package:admin/models/Wiki.dart';
import 'package:flutter/material.dart';

class CategoryList extends StatelessWidget {
  final List<WikiCategory> categories;
  final Function(WikiPage) onPageSelected;
  final VoidCallback onAddCategory;
  final VoidCallback onAddPage;
  final String? selectedPageId;

  const CategoryList({
    Key? key,
    required this.categories,
    required this.onPageSelected,
    required this.onAddCategory,
    required this.onAddPage,
    this.selectedPageId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(
        color: darkDrawerColor,
        border: Border(right: BorderSide(color: borderColor, width: 0.5)),
      ),
      child: Column(
        children: [
          _buildSearchField(),
          _buildActionButtons(),
          const Divider(height: 1, color: borderColor),
          Expanded(
            child: ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Theme(
                  data: Theme.of(context)
                      .copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    leading: const Icon(Icons.folder_open,
                        size: 20, color: orangeAccentColor),
                    title: Text(
                      category.title.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.white70),
                    ),
                    children: category.pages
                        .map((page) => _buildPageTile(page))
                        .toList(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageTile(WikiPage page) {
    bool isSelected = page.id == selectedPageId;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPageSelected(page),
        hoverColor: orangeAccentColor.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? orangeAccentColor.withOpacity(0.1) : null,
            border: isSelected
                ? const Border(
                    left: BorderSide(color: orangeAccentColor, width: 3))
                : null,
          ),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 48, right: 16, top: 12, bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    page.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.arrow_forward_ios,
                      size: 14, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: TextField(
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          // Filtragem futura
        },
        decoration: const InputDecoration(
          hintText: "Pesquisar manuais...",
          hintStyle: TextStyle(color: Colors.white38),
          fillColor: darkSecondaryColor,
          filled: true,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          prefixIcon: Icon(Icons.search, color: Colors.white54, size: 20),
          contentPadding: EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: defaultPadding)
          .copyWith(bottom: defaultPadding),
      child: Row(
        children: [
          Expanded(
            child: _WikiActionButton(
              label: "Categoria",
              icon: Icons.create_new_folder_outlined,
              onTap: onAddCategory,
              color: Colors.blueAccent,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _WikiActionButton(
              label: "Página",
              icon: Icons.note_add_outlined,
              onTap: onAddPage,
              color: orangeAccentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _WikiActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _WikiActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  __WikiActionButtonState createState() => __WikiActionButtonState();
}

class __WikiActionButtonState extends State<_WikiActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(10),
        hoverColor: widget.color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: widget.color.withOpacity(_isHovered ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: widget.color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(widget.icon, color: widget.color, size: 20),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.color,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
