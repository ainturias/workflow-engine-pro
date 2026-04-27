import 'package:flutter/material.dart';

/// Widget que genera campos de formulario dinámicamente
/// basado en el esquema JSON definido en el Workflow Designer.
class DynamicForm extends StatefulWidget {
  final List<dynamic> fields; // Lista de campos definidos en el nodo
  final Function(Map<String, dynamic>) onSubmit;
  final String submitLabel;

  const DynamicForm({
    super.key,
    required this.fields,
    required this.onSubmit,
    this.submitLabel = 'Completar Tarea',
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Inicializar controladores y mapa de datos
    for (var field in widget.fields) {
      String name = field['name'] ?? '';
      String type = field['type'] ?? 'TEXT';
      
      if (type == 'CHECKBOX') {
        _formData[name] = false;
      } else if (type == 'SELECT' || type == 'RADIO') {
        _formData[name] = (field['options'] != null && field['options'].isNotEmpty) 
            ? field['options'][0] 
            : null;
      } else {
        _controllers[name] = TextEditingController();
        _formData[name] = '';
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.fields.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text(
            "Esta tarea no requiere completar ningún formulario.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...widget.fields.map((field) => _buildField(field)),
          const SizedBox(height: 24),
          // Botón de Envío
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667eea),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              child: Text(
                widget.submitLabel,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(Map<String, dynamic> field) {
    String type = field['type'] ?? 'TEXT';
    String label = field['label'] ?? 'Campo';
    String name = field['name'] ?? '';
    bool required = field['required'] ?? false;
    String placeholder = field['placeholder'] ?? '';

    // Manejo de tipos no editables (TITLE, LABEL, DIVIDER)
    if (type == 'TITLE') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
      );
    }
    if (type == 'LABEL') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14)),
      );
    }
    if (type == 'DIVIDER') {
      return Divider(color: Colors.white.withOpacity(0.1), height: 32);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              if (required) const Text(' *', style: TextStyle(color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 8),
          _getFieldWidget(field, type, name, placeholder, required),
        ],
      ),
    );
  }

  Widget _getFieldWidget(Map<String, dynamic> field, String type, String name, String placeholder, bool required) {
    final decoration = _inputDecoration(placeholder);

    switch (type) {
      case 'TEXTAREA':
        return TextFormField(
          controller: _controllers[name],
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: decoration,
          validator: required ? (v) => v!.isEmpty ? 'Requerido' : null : null,
        );

      case 'NUMBER':
        return TextFormField(
          controller: _controllers[name],
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: decoration,
          validator: required ? (v) => v!.isEmpty ? 'Requerido' : null : null,
        );

      case 'DATE':
        return TextFormField(
          controller: _controllers[name],
          readOnly: true,
          style: const TextStyle(color: Colors.white),
          decoration: decoration.copyWith(suffixIcon: const Icon(Icons.calendar_today, color: Colors.white38)),
          onTap: () => _selectDate(name),
          validator: required ? (v) => v!.isEmpty ? 'Requerido' : null : null,
        );

      case 'SELECT':
        List<dynamic> options = field['options'] ?? [];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _formData[name],
              dropdownColor: const Color(0xFF1a1a2e),
              style: const TextStyle(color: Colors.white),
              items: options.map((opt) => DropdownMenuItem<String>(
                value: opt.toString(),
                child: Text(opt.toString()),
              )).toList(),
              onChanged: (val) => setState(() => _formData[name] = val),
            ),
          ),
        );

      case 'CHECKBOX':
        return SwitchListTile(
          title: Text(placeholder.isNotEmpty ? placeholder : 'Activar', style: const TextStyle(color: Colors.white54, fontSize: 13)),
          value: _formData[name] ?? false,
          activeColor: const Color(0xFF667eea),
          contentPadding: EdgeInsets.zero,
          onChanged: (val) => setState(() => _formData[name] = val),
        );

      case 'RADIO':
        List<dynamic> options = field['options'] ?? [];
        return Column(
          children: options.map((opt) => RadioListTile<String>(
            title: Text(opt.toString(), style: const TextStyle(color: Colors.white70, fontSize: 14)),
            value: opt.toString(),
            groupValue: _formData[name],
            activeColor: const Color(0xFF667eea),
            contentPadding: EdgeInsets.zero,
            onChanged: (val) => setState(() => _formData[name] = val),
          )).toList(),
        );

      case 'FILE':
      case 'IMAGE':
      case 'SIGNATURE':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1), style: BorderStyle.solid),
          ),
          child: Column(
            children: [
              Icon(type == 'SIGNATURE' ? Icons.edit_note : Icons.cloud_upload_outlined, color: Colors.white38),
              const SizedBox(height: 8),
              Text(type == 'SIGNATURE' ? 'Toca para firmar' : 'Subir archivo', style: const TextStyle(color: Colors.white38, fontSize: 12)),
            ],
          ),
        );

      default: // TEXT, EMAIL, etc
        return TextFormField(
          controller: _controllers[name],
          keyboardType: type == 'EMAIL' ? TextInputType.emailAddress : TextInputType.text,
          style: const TextStyle(color: Colors.white),
          decoration: decoration,
          validator: required ? (v) => v!.isEmpty ? 'Requerido' : null : null,
        );
    }
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.white.withOpacity(0.05))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF667eea))),
    );
  }

  Future<void> _selectDate(String name) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF667eea), onPrimary: Colors.white, surface: Color(0xFF1a1a2e), onSurface: Colors.white),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _controllers[name]?.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // Sincronizar controladores de texto con el mapa de datos
      _controllers.forEach((key, controller) {
        _formData[key] = controller.text;
      });
      widget.onSubmit(_formData);
    }
  }
}
