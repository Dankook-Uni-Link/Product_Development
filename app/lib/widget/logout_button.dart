import 'package:app/services/auth_service.dart';
import 'package:flutter/material.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await AuthService().logout();
        Navigator.pushReplacementNamed(context, '/login');
      },
    );
  }
}
