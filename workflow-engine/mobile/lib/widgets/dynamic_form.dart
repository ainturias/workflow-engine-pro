import 'package:flutter/material.dart';

/// Widget que genera campos de formulario dinámicamente
/// basado en los datos del workflow.
class DynamicForm extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final Function(Map<String, dynamic>) onSubmit;
  final String submitLabel;

  const DynamicForm({
    super.key,
    this.initialData = const {},
    required this.onSubmit,
    this.submitLabel = 'Enviar',
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _formData = {};
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final entry in widget.initialData.entries) {
      _controllers[entry.key] = TextEditingController(text: entry.value?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.initialData.isNotEmpty) ...[
            ...widget.initialData.entries.map((entry) => _buildField(entry.key, entry.value)),
            const SizedBox(height: 16),
          ],
          // Comment field (always present)
          _buildStyledField(
            label: 'Comentario / Observación',
            child: TextFormField(
              controller: _commentController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDecoration('Escribe un comentario...'),
            ),
          ),
          const SizedBox(height: 24),
          // Submit
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check_circle_outline, size: 20),
              label: Text(widget.submitLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43e97b),
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String key, dynamic value) {
    return _buildStyledField(
      label: _formatLabel(key),
      child: TextFormField(
        controller: _controllers[key],
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: _inputDecoration('Ingrese $key'),
        keyboardType: value is num ? TextInputType.number : TextInputType.text,
      ),
    );
  }

  Widget _buildStyledField({required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.25)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF667eea)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  String _formatLabel(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(0)}')
        .replaceAll('_', ' ')
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '')
        .join(' ');
  }

  void _submit() {
    // Collect form data
    for (final entry in _controllers.entries) {
      _formData[entry.key] = entry.value.text;
    }
    widget.onSubmit({
      'formData': _formData,
      'comment': _commentController.text,
    });
  }
}
