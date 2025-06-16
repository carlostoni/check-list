// lib/widgets/subtopico_list.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/topico.dart';
import '../models/subtopico.dart';
import '../providers/checklist_provider.dart';

class SubtopicoList extends StatefulWidget {
  final Topico topico;

  const SubtopicoList({Key? key, required this.topico}) : super(key: key);

  @override
  State<SubtopicoList> createState() => _SubtopicoListState();
}

class _SubtopicoListState extends State<SubtopicoList> {
  // Use a Map to hold controllers and focus nodes, keyed by subtopic ID
  // This map will be populated dynamically as subtopics are rendered.
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void dispose() {
    // Dispose all controllers and focus nodes when the widget is disposed
    _controllers.forEach((key, controller) => controller.dispose());
    _focusNodes.forEach((key, focusNode) => focusNode.dispose());
    _controllers.clear();
    _focusNodes.clear();
    super.dispose();
  }

  // Helper method to get or create a TextEditingController for a subtopic
  TextEditingController _getController(Subtopico subtopic) {
    if (!_controllers.containsKey(subtopic.id)) {
      _controllers[subtopic.id] = TextEditingController(text: subtopic.observacao);
    } else if (_controllers[subtopic.id]?.text != subtopic.observacao) {
      // Update text if it's different and the field is not focused
      // This prevents interrupting user input while typing
      if (!(_focusNodes[subtopic.id]?.hasFocus ?? false)) {
        _controllers[subtopic.id]!.text = subtopic.observacao;
        _controllers[subtopic.id]!.selection = TextSelection.fromPosition(
          TextPosition(offset: _controllers[subtopic.id]!.text.length),
        );
      }
    }
    return _controllers[subtopic.id]!;
  }

  // Helper method to get or create a FocusNode for a subtopic
  FocusNode _getFocusNode(Subtopico subtopic) {
    if (!_focusNodes.containsKey(subtopic.id)) {
      _focusNodes[subtopic.id] = FocusNode();
    }
    return _focusNodes[subtopic.id]!;
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ChecklistProvider>(context);

    // Get the most current version of the topic from the provider to ensure reactivity.
    // This is crucial because the 'topico' passed to the constructor might be an old instance
    // if the provider's list has been updated (e.g., subtopics were removed from the parent).
    final currentTopic = provider.categorias
        .expand((cat) => cat.topicos)
        .firstWhere((t) => t.id == widget.topico.id, orElse: () => widget.topico);

    // If for some reason currentTopic is null or its subtopics list is empty/null,
    // return an empty widget to prevent errors.
    if (currentTopic.subtopicos.isEmpty) {
      // Before returning, clean up any controllers/focus nodes for removed subtopics
      _controllers.keys.where((id) => !currentTopic.subtopicos.any((s) => s.id == id)).toList().forEach((id) {
        _controllers.remove(id)?.dispose();
        _focusNodes.remove(id)?.dispose();
      });
      return const SizedBox.shrink();
    }

    // Clean up controllers/focus nodes for subtopics that no longer exist in the currentTopic
    final currentSubtopicIds = currentTopic.subtopicos.map((s) => s.id).toSet();
    _controllers.keys.where((id) => !currentSubtopicIds.contains(id)).toList().forEach((id) {
      _controllers.remove(id)?.dispose();
      _focusNodes.remove(id)?.dispose();
    });

    return Column(
      children: currentTopic.subtopicos.map((sub) {
        final controller = _getController(sub);
        final focusNode = _getFocusNode(sub);

        return ListTile(
          key: ValueKey(sub.id), // Unique key for ListTile
          leading: Checkbox(
            value: sub.checked,
            onChanged: (val) {
              provider.toggleSubtopico(currentTopic, sub, val);
              // After toggling, ensure the observation text field reflects the latest data
              // This is safe because toggling a checkbox doesn't involve direct text input.
              if (controller.text != sub.observacao && !focusNode.hasFocus) {
                 controller.text = sub.observacao;
                 controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
              }
            },
          ),
          title: Text(sub.titulo),
          subtitle: TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: const InputDecoration(
              hintText: 'Observação',
            ),
            onChanged: (text) {
              provider.updateSubtopicoObservation(sub, text);
            },
            onSubmitted: (text) {
              FocusScope.of(context).unfocus();
            },
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: const Text('Excluir Subtópico'),
                    content: Text('Tem certeza que deseja excluir o subtópico "${sub.titulo}"?'),
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
                          provider.removeSubtopico(currentTopic, sub);
                          Navigator.of(dialogContext).pop(); // Close dialog
                          // Dispose controller and focus node after removal
                          _controllers.remove(sub.id)?.dispose();
                          _focusNodes.remove(sub.id)?.dispose();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          ),
        );
      }).toList(),
    );
  }
}