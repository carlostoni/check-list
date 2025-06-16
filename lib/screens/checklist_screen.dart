import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/categoria.dart';
import '../models/topico.dart';
import '../providers/checklist_provider.dart';
import '../widgets/topico_item.dart';

class ChecklistScreen extends StatelessWidget {
  final Categoria categoria;

  const ChecklistScreen({super.key, required this.categoria});

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ChecklistProvider>(context);

    // Encontre a versão atual da categoria do estado do provider
    final currentCategoria = provider.categorias.firstWhere(
      (cat) => cat.id == categoria.id,
      orElse: () => categoria,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Checklist - ${currentCategoria.nome}'),
        actions: [
          // Botão de Arquivar Categoria
          IconButton(
            icon: const Icon(Icons.archive),
            tooltip: 'Arquivar Categoria',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Arquivar Categoria'),
                    content: const Text('Tem certeza que deseja arquivar esta categoria? Todos os seus tópicos serão movidos para o histórico e um novo registro será criado para cada um.'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Arquivar'),
                        onPressed: () {
                          provider.archiveCategoria(currentCategoria); // Usa o novo método archiveCategoria
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).pop(); // Volta para a tela inicial após arquivar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Categoria "${currentCategoria.nome}" arquivada com sucesso!')),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
          // Botão de Resetar Categoria
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Resetar Categoria',
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Resetar Categoria'),
                    content: const Text('Tem certeza que deseja resetar todos os tópicos e subtópicos desta categoria? Todos os itens marcados serão desmarcados.'),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancelar'),
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Resetar'),
                        onPressed: () {
                          provider.resetCategoria(currentCategoria);
                          Navigator.of(dialogContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Categoria "${currentCategoria.nome}" resetada!')),
                          );
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...currentCategoria.topicos.map((topico) => TopicoItem(topico: topico, categoria: currentCategoria)).toList(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final controller = TextEditingController();
                  return AlertDialog(
                    title: const Text('Novo Tópico'),
                    content: TextField(controller: controller, decoration: const InputDecoration(hintText: 'Título do tópico')),
                    actions: [
                      TextButton(
                        onPressed: () {
                          provider.addTopico(currentCategoria, controller.text);
                          Navigator.pop(context);
                        },
                        child: const Text('Adicionar'),
                      )
                    ],
                  );
                },
              );
            },
            child: const Text('Adicionar Tópico'),
          )
        ],
      ),
    );
  }
}
