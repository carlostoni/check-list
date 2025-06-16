// lib/widgets/topico_simple_item.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/categoria.dart';
import '../models/topico.dart';
import '../providers/checklist_provider.dart';

class TopicoSimpleItem extends StatefulWidget {
  final Topico topico;
  final Categoria categoriaPai; // Needed to remove the topic from its parent category

  const TopicoSimpleItem({
    super.key,
    required this.topico,
    required this.categoriaPai,
  });

  @override
  State<TopicoSimpleItem> createState() => _TopicoSimpleItemState();
}

class _TopicoSimpleItemState extends State<TopicoSimpleItem> {
  late TextEditingController _observacaoController;
  late FocusNode _observacaoFocusNode;

  @override
  void initState() {
    super.initState();
    _observacaoController = TextEditingController(text: widget.topico.observacao);
    _observacaoFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _observacaoController.dispose();
    _observacaoFocusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant TopicoSimpleItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.topico.observacao != oldWidget.topico.observacao) {
      if (_observacaoController.text != widget.topico.observacao && !_observacaoFocusNode.hasFocus) {
        _observacaoController.text = widget.topico.observacao;
        _observacaoController.selection = TextSelection.fromPosition(
          TextPosition(offset: _observacaoController.text.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChecklistProvider>(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        title: Text(widget.topico.titulo),
        leading: Checkbox(
          value: widget.topico.checked,
          onChanged: (val) {
            provider.toggleTopico(widget.topico, val);
            // After toggling, ensure the observation text field reflects the latest data
            // This is safe because toggling a checkbox doesn't involve direct text input.
            if (_observacaoController.text != widget.topico.observacao && !_observacaoFocusNode.hasFocus) {
                 _observacaoController.text = widget.topico.observacao;
                 _observacaoController.selection = TextSelection.fromPosition(TextPosition(offset: _observacaoController.text.length));
            }
          },
        ),
        subtitle: TextField(
          controller: _observacaoController,
          focusNode: _observacaoFocusNode,
          onChanged: (value) {
            provider.updateTopicoObservation(widget.topico, value); // Corrected method name
          },
          onSubmitted: (value) {
            FocusScope.of(context).unfocus();
          },
          decoration: const InputDecoration(
            labelText: 'Observação',
            border: OutlineInputBorder(),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Excluir Tópico'),
                    content: Text('Tem certeza que deseja excluir o tópico "${widget.topico.titulo}"?'),
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
                          provider.removeTopico(widget.categoriaPai, widget.topico);
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ],
                  );
                },
              );
          },
        ),
      ),
    );
  }
}