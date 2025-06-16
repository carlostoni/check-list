// lib/widgets/topico_list.dart (If this file is still needed, otherwise delete it)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/categoria.dart';
import '../models/topico.dart';
import '../providers/checklist_provider.dart';
import 'subtopico_list.dart'; // Widget that shows subtopics
import 'topico_item.dart'; // It seems this is the intended usage, but TopicoItem already wraps ExpansionTile

// Given that ChecklistScreen already uses TopicoItem, this TopicoList widget
// might be redundant or intended for a different layout.
// If TopicoItem already handles the ExpansionTile, then this widget
// would simply list TopicoItems.

class TopicoList extends StatefulWidget {
  final Categoria categoria;

  const TopicoList({Key? key, required this.categoria}) : super(key: key);

  @override
  State<TopicoList> createState() => _TopicoListState();
}

class _TopicoListState extends State<TopicoList> {
  // Use String (ID) as key for robustness, as Topico objects might change instances
  final Map<String, bool> _expandedState = {};
  final TextEditingController _novoTopicoController = TextEditingController();

  @override
  void dispose() {
    _novoTopicoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChecklistProvider>(context);

    // Get the current list of topics from the provider's category
    // This ensures reactivity if topics are added/removed/changed
    final currentCategoria = provider.categorias.firstWhere((cat) => cat.id == widget.categoria.id, orElse: () => widget.categoria);
    final topicos = currentCategoria.topicos;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: topicos.length,
            itemBuilder: (context, index) {
              final topico = topicos[index];
              // Use the TopicoItem widget directly if it provides the full UI for a topic
              return TopicoItem(topico: topico, categoria: currentCategoria); // Pass currentCategoria
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _novoTopicoController,
                  decoration: const InputDecoration(
                    hintText: 'Adicionar novo tópico',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (text) {
                    final titulo = text.trim();
                    if (titulo.isNotEmpty) {
                      provider.addTopico(currentCategoria, titulo);
                      _novoTopicoController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  final texto = _novoTopicoController.text.trim();
                  if (texto.isNotEmpty) {
                    provider.addTopico(currentCategoria, texto);
                    _novoTopicoController.clear();
                  }
                },
                child: const Icon(Icons.add),
              ),
            ],
          ),
        ),
      ],
    );
  }
}