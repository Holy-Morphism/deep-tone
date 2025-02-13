import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserInput extends StatelessWidget {
  const UserInput({
    super.key,
    required this.textEditingController,
    this.isPass = false,
    required this.textInputType,
    required this.hintText,
    required this.label,
  });

  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        style: GoogleFonts.nunitoSans(),
        cursorColor: Colors.grey.shade900,
        controller: textEditingController,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.nunitoSans(
            color: Theme.of(context).colorScheme.secondary,
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(style: BorderStyle.solid),
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
        ),
        keyboardType: textInputType,
        obscureText: isPass,
      ),
    );
  }
}
