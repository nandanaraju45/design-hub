import 'package:flutter/material.dart';

class FormTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType textInputType;
  final TextCapitalization textCapitalization;
  final String? Function(String?) validator;
  final bool isPassword; // <-- NEW

  const FormTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.textInputType,
    required this.textCapitalization,
    required this.validator,
    this.isPassword = false, // <-- NEW default
  });

  @override
  State<FormTextField> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<FormTextField> {
  bool _obscureText = true; // <-- For password toggle

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false, // Only obscure if isPassword
      decoration: InputDecoration(
        labelStyle: TextStyle(fontSize: 14, color: Colors.grey[600]),
        floatingLabelStyle: const TextStyle(color: Colors.blue),
        labelText: widget.label,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
      ),
      keyboardType: widget.textInputType,
      textCapitalization: widget.textCapitalization,
      validator: (value) => widget.validator(value),
    );
  }
}
