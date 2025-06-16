// lib/widgets/categoria_drawer.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/categoria.dart';
import '../providers/checklist_provider.dart';
import '../screens/checklist_screen.dart';
import '../screens/historico_screen.dart';
// If you have a screen for archived categories:
// import '../screens/historico_categorias_screen.dart';

class CategoriaDrawer extends StatelessWidget {
  final Function(Categoria)? onCategorySelected;
  final String? selectedCategoryId; // To highlight the selected category

  const CategoriaDrawer({
    super.key,
    this.onCategorySelected,
    this.selectedCategoryId,
  });

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ChecklistProvider>(context);
    // Filter out archived categories for the main drawer
    final activeCategories = provider.categorias.where((cat) => !cat.isArchived).toList();
    final archivedCategories = provider.categorias.where((cat) => cat.isArchived).toList();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Text('Categorias', style: TextStyle(color: Colors.white, fontSize: 24)),
          ),
          ...activeCategories.map((cat) => ListTile(
                title: Text(cat.nome),
                selected: selectedCategoryId == cat.id, // Highlight selected
                trailing: IconButton(
                  icon: const Icon(Icons.delete_forever, color: Colors.red), // More explicit delete icon
                  onPressed: () {
                    // Show confirmation dialog before deleting
                    showDialog(
                      context: context,
                      builder: (BuildContext dialogContext) {
                        return AlertDialog(
                          title: const Text('Excluir Categoria'),
                          content: Text('Tem certeza que deseja excluir a categoria "${cat.nome}"? Esta ação não pode ser desfeita e removerá todos os tópicos e subtópicos associados.'),
                          actions: <Widget>[
                            TextButton(
                              child: const Text('Cancelar'),
                              onPressed: () {
                                Navigator.of(dialogContext).pop();
                              },
                            ),
                            TextButton(
                              child: const Text('Excluir'),
                              onPressed: () {
                                provider.removeCategoria(cat);
                                Navigator.of(dialogContext).pop(); // Close dialog
                                // If the deleted category was selected, deselect it in HomeScreen
                                if (selectedCategoryId == cat.id) {
                                  // Pass null to deselect. Adjust HomeScreen's _onCategorySelected if needed.
                                  onCategorySelected?.call(Categoria(nome: '', id: '')); // Use a dummy category for deselection
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Categoria "${cat.nome}" excluída.')),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                onTap: () {
                  // Notify parent widget of category selection
                  onCategorySelected?.call(cat);
                  // Navigator.pop(context); // This is handled by HomeScreen now
                },
              )),
          const Divider(), // Separator
          // Add Category option
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Adicionar Categoria'),
            onTap: () {
              // Close the drawer before showing the dialog
              Navigator.pop(context);
              _showAddCategoriaDialog(context, provider);
            },
          ),
          // Archived Categories Section (optional, if you want to display them here)
          if (archivedCategories.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text('Categorias Arquivadas', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...archivedCategories.map((cat) => ListTile(
                  title: Text(cat.nome, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
                  trailing: IconButton(
                    icon: const Icon(Icons.unarchive, color: Colors.blue),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Desarquivar Categoria'),
                            content: Text('Tem certeza que deseja desarquivar a categoria "${cat.nome}"? Todos os tópicos serão resetados.'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancelar'),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Desarquivar'),
                                onPressed: () {
                                  provider.unarchiveCategoria(cat);
                                  Navigator.of(dialogContext).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Categoria "${cat.nome}" desarquivada e resetada.')),
                                  );
                                  // Optionally, select the unarchived category in HomeScreen
                                  onCategorySelected?.call(cat);
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  onTap: () {
                    // Maybe navigate to a read-only view or allow unarchiving from here
                    // For now, let's just close the drawer and do nothing or unarchive
                     showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Ação para Categoria Arquivada'),
                            content: Text('Você selecionou a categoria arquivada "${cat.nome}". Deseja desarquivá-la para usá-la novamente?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Cancelar'),
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Desarquivar'),
                                onPressed: () {
                                  provider.unarchiveCategoria(cat);
                                  Navigator.of(dialogContext).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Categoria "${cat.nome}" desarquivada e resetada.')),
                                  );
                                  // Optionally, select the unarchived category in HomeScreen
                                  onCategorySelected?.call(cat);
                                },
                              ),
                            ],
                          );
                        },
                      );
                  },
                )),
            const Divider(),
          ],
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Histórico de Tópicos Arquivados'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoricoScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddCategoriaDialog(BuildContext context, ChecklistProvider provider) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Categoria'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nome da categoria'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final nome = controller.text.trim();
              if (nome.isNotEmpty) {
                provider.addCategoria(nome);
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('Adicionar'),
          )
        ],
      ),
    );
  }
}
