// lib/widgets/topico_item.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/topico.dart';
import '../models/subtopico.dart';
import '../models/categoria.dart';
import '../providers/checklist_provider.dart';
import '../widgets/subtopico_list.dart';

class TopicoItem extends StatefulWidget {
  final Topico topico;
  final Categoria categoria; // Needed for removing the topic in provider

  const TopicoItem({
    Key? key,
    required this.topico,
    required this.categoria,
  }) : super(key: key);

  @override
  State<TopicoItem> createState() => _TopicoItemState();
}

class _TopicoItemState extends State<TopicoItem> {
  bool _expanded = false;
  bool _addingSubtopico = false;
  final TextEditingController _subtopicoController = TextEditingController();
  late TextEditingController _topicoObservacaoController;
  late FocusNode _topicoObservacaoFocusNode;


  @override
  void initState() {
    super.initState();
    _topicoObservacaoController = TextEditingController(text: widget.topico.observacao);
    _topicoObservacaoFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _subtopicoController.dispose();
    _topicoObservacaoController.dispose();
    _topicoObservacaoFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TopicoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.topico.observacao != oldWidget.topico.observacao) {
      if (_topicoObservacaoController.text != widget.topico.observacao && !_topicoObservacaoFocusNode.hasFocus) {
        _topicoObservacaoController.text = widget.topico.observacao;
        _topicoObservacaoController.selection = TextSelection.fromPosition(
          TextPosition(offset: _topicoObservacaoController.text.length),
        );
      }
    }
    if (widget.topico.isFullyChecked != oldWidget.topico.isFullyChecked) {
      if (widget.topico.isFullyChecked) {
        // Optionally collapse if fully checked, or keep expanded
        // _expanded = false;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChecklistProvider>(context);

    // Get the most current version of the topic from the provider to ensure reactivity
    final currentTopico = widget.categoria.topicos.firstWhere(
      (t) => t.id == widget.topico.id,
      orElse: () => widget.topico,
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        key: ValueKey(currentTopico.id),
        initiallyExpanded: _expanded,
        onExpansionChanged: (expanded) {
          setState(() {
            _expanded = expanded;
          });
        },
        leading: Checkbox(
          value: currentTopico.checked,
          onChanged: (val) {
            provider.toggleTopico(currentTopico, val);
          },
        ),
        title: Text(currentTopico.titulo),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _topicoObservacaoController,
              focusNode: _topicoObservacaoFocusNode,
              decoration: const InputDecoration(
                hintText: 'Observação do Tópico',
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                provider.updateTopicoObservation(currentTopico, value);
              },
              onSubmitted: (value) {
                FocusScope.of(context).unfocus();
              },
            ),
            if (currentTopico.completionDate != null && currentTopico.checked)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Concluído em: ${currentTopico.completionDate!.day}/${currentTopico.completionDate!.month}/${currentTopico.completionDate!.year}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.archive),
              tooltip: 'Arquivar Tópico',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('Arquivar Tópico'),
                      content: const Text('Tem certeza que deseja arquivar este tópico? Ele será movido para o histórico de tópicos e um novo registro será criado.'),
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
                            // Chama o novo método archiveTopico que remove da categoria e adiciona ao histórico
                            provider.archiveTopico(widget.categoria, currentTopico);
                            Navigator.of(dialogContext).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Tópico "${currentTopico.titulo}" arquivado.')),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              tooltip: 'Excluir Tópico',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext dialogContext) {
                    return AlertDialog(
                      title: const Text('Excluir Tópico'),
                      content: Text('Tem certeza que deseja excluir o tópico "${currentTopico.titulo}"?'),
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
                            provider.removeTopico(widget.categoria, currentTopico);
                            Navigator.of(dialogContext).pop();
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
        children: [
          SubtopicoList(topico: currentTopico),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: _addingSubtopico
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _subtopicoController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: 'Novo subtópico',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (text) => _addSubtopico(provider),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () => _addSubtopico(provider),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _addingSubtopico = false;
                            _subtopicoController.clear();
                          });
                        },
                      )
                    ],
                  )
                : Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _addingSubtopico = true;
                        });
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar Subtópico'),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _addSubtopico(ChecklistProvider provider) {
    final texto = _subtopicoController.text.trim();
    if (texto.isNotEmpty) {
      provider.addSubtopico(widget.topico, texto);
      _subtopicoController.clear();
      setState(() {
        _addingSubtopico = false;
      });
    }
  }
}
