// lib/widgets/subtopico_item_field.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subtopico.dart';
import '../models/topico.dart';
import '../providers/checklist_provider.dart';

class SubtopicoItemField extends StatefulWidget {
  final Subtopico subtopico;
  final Topico topicoPai; // We need the parent topic for provider methods

  const SubtopicoItemField({
    super.key,
    required this.subtopico,
    required this.topicoPai,
  });

  @override
  State<SubtopicoItemField> createState() => _SubtopicoItemFieldState();
}

class _SubtopicoItemFieldState extends State<SubtopicoItemField> {
  late TextEditingController _observacaoController;

  @override
  void initState() {
    super.initState();
    _observacaoController = TextEditingController(text: widget.subtopico.observacao);
  }

  @override
  void dispose() {
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant SubtopicoItemField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update controller text if the actual observation data has changed
    // and the user is not currently typing in this field.
    if (widget.subtopico.observacao != oldWidget.subtopico.observacao) {
      if (_observacaoController.text != widget.subtopico.observacao) {
        _observacaoController.text = widget.subtopico.observacao;
        // Optionally set cursor to end if text changed programmatically
        _observacaoController.selection = TextSelection.fromPosition(
          TextPosition(offset: _observacaoController.text.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChecklistProvider>(context);

    return ListTile(
      title: Text(widget.subtopico.titulo),
      leading: Checkbox(
        value: widget.subtopico.checked,
        onChanged: (val) {
          provider.toggleSubtopico(widget.topicoPai, widget.subtopico, val);
        },
      ),
      subtitle: TextField(
        controller: _observacaoController,
        onChanged: (value) {
          // No need to call unfocus here, it handles itself
          provider.updateSubtopicoObservation(widget.subtopico, value); // Corrected method name
        },
        onSubmitted: (value) {
          // If you want to save only on submit, uncomment the line below
          // provider.updateSubtopicoObservation(widget.subtopico, value);
          FocusScope.of(context).unfocus(); // Dismiss keyboard on submit
        },
        decoration: const InputDecoration(
          hintText: 'Observação',
          border: OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext dialogContext) {
              return AlertDialog(
                title: const Text('Excluir Subtópico'),
                content: Text('Tem certeza que deseja excluir o subtópico "${widget.subtopico.titulo}"?'),
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
                      provider.removeSubtopico(widget.topicoPai, widget.subtopico);
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}