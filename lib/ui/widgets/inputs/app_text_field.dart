import 'package:flutter/material.dart';

class AppTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isPassword;
  final bool readOnly;

  const AppTextField({
    required this.labelText,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.readOnly = false,
  });

  @override
  _AppTextFieldState createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.labelText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 5), 
        
            // Input Field
            TextFormField(
              controller: widget.controller,
              keyboardType: widget.keyboardType,
              obscureText: widget.isPassword ? _obscureText : false,
              decoration: InputDecoration(
                hintText: widget.labelText,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ),
                suffixIcon: widget.isPassword
                    ? IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                          color: Colors.purple[700],
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      )
                    : null, 
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "${widget.labelText} is required";
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
