import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextFormField extends StatelessWidget {
  const AppTextFormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    super.key,
    this.fieldKey,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.suffixIcon,
    this.autofillHints,
    this.enabled = true,
    this.inputFormatters,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData prefixIcon;
  final Key? fieldKey;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final bool obscureText;
  final Widget? suffixIcon;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      key: fieldKey,
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      obscureText: obscureText,
      autofillHints: autofillHints,
      enabled: enabled,
      inputFormatters: inputFormatters,
      autocorrect: !obscureText,
      enableSuggestions: !obscureText,
      cursorColor: colorScheme.primary,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
        suffixIcon: suffixIcon,
        errorMaxLines: 2,
      ),
    );
  }
}
