import 'package:app/widget/bottomNavbar.dart';
import 'package:flutter/material.dart';

class vote_screen extends StatelessWidget {
  const vote_screen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      bottomNavigationBar: BottomNavBar(currentIndex: 1),
    );
  }
}
