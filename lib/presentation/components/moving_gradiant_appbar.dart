import 'package:flutter/material.dart';

class MovingGradientAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;

  MovingGradientAppBar({Key? key, required this.title}) : super(key: key);

  @override
  _MovingGradientAppBarState createState() => _MovingGradientAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MovingGradientAppBarState extends State<MovingGradientAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        duration: const Duration(seconds: 3),
        onEnd: () => setState(() {}), // Restart the animation
        builder: (context, value, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: const [Color(0xFF6213D1), Color(0xFF4601BE), Colors.deepPurpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [value, value + 0.5], // Make gradient move
              ),
            ),
          );
        },
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      foregroundColor: Colors.white,
      title: Text(widget.title),
    );
  }
}
