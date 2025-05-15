import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeTitle extends StatelessWidget {
  final String title;

  const HomeTitle({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: GoogleFonts.roboto(
        fontSize: 48,
        fontWeight: FontWeight.w900,
        color: theme.colorScheme.primary,
        letterSpacing: 2.0,
        decoration: TextDecoration.none,
        decorationThickness: 2,
        fontStyle: FontStyle.normal,
      ),
    );
  }
}
