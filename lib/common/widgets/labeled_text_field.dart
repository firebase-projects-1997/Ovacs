import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

class LabeledTextField extends StatelessWidget {
  final String label;
  final Color? labelColor;
  final String hint;
  final TextEditingController? controller;
  final bool isPassword;
  final IconData? icon;
  final bool obscureText;
  final VoidCallback? toggleObscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final List<String>? autofillHints;
  final int maxLines;
  final bool enabled;
  final bool enableSuggestions;
  final bool autocorrect;
  final List<TextInputFormatter>? inputFormatters;

  // Add these two new optional params:
  final bool? filled;
  final Color? fillColor;

  const LabeledTextField({
    super.key,
    required this.label,
    this.labelColor,
    required this.hint,
    this.controller,
    this.isPassword = false,
    this.icon,
    this.obscureText = false,
    this.toggleObscure,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.autofillHints,
    this.maxLines = 1,
    this.enabled = true,
    this.enableSuggestions = true,
    this.autocorrect = true,
    this.inputFormatters,
    this.filled,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != '') ...[
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: labelColor),
          ),
          const SizedBox(height: 10),
        ],
        TextFormField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          autofillHints: autofillHints,
          maxLines: isPassword ? 1 : maxLines,
          enabled: enabled,
          enableSuggestions: enableSuggestions,
          autocorrect: autocorrect,
          inputFormatters: inputFormatters,
          style: Theme.of(context).textTheme.bodySmall,
          decoration: InputDecoration(
            hintText: hint,
            filled: filled,
            fillColor: fillColor,
            prefixIcon: icon != null
                ? Icon(icon, color: Theme.of(context).primaryColor)
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Iconsax.eye_slash : Iconsax.eye,
                      color: Theme.of(context).primaryColor,
                    ),
                    onPressed: toggleObscure,
                  )
                : null,
          ),
          validator:
              validator ??
              (value) {
                if (value == null || value.isEmpty) {
                  return 'this field is required.';
                }
                if (isPassword && value.length < 8) {
                  return 'password most not be less than 8 charachters.';
                }

                if (keyboardType == TextInputType.emailAddress &&
                    !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                return null;
              },
        ),
      ],
    );
  }
}
