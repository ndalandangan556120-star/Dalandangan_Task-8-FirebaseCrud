import 'dart:io';

import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'crud_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService auth = AuthService();
  final CrudService crud = CrudService();
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  bool loading = false;
  File? selectedImageFile;
  String? selectedImageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  final pickedImage = await crud.pickImageForAddItem();
                  if (pickedImage != null) {
                    setState(() {
                      selectedImageFile = pickedImage.file;
                      selectedImageUrl = pickedImage.url;
                    });
                  }
                },
                child: CircleAvatar(
                  radius: 52,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage: selectedImageFile != null
                      ? FileImage(selectedImageFile!)
                      : null,
                  child: selectedImageFile == null
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 36,
                          color: Colors.teal,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () async {
                  final pickedImage = await crud.pickImageForAddItem();
                  if (pickedImage != null) {
                    setState(() {
                      selectedImageFile = pickedImage.file;
                      selectedImageUrl = pickedImage.url;
                    });
                  }
                },
                icon: const Icon(Icons.photo_library),
                label: Text(
                  selectedImageFile == null
                      ? "Add profile photo"
                      : "Change photo",
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Register"),
                onPressed: () async {
                  if (emailCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
                    return;
                  }
                  setState(() => loading = true);

                  final user = await auth.registerWithEmail(
                    emailCtrl.text,
                    passwordCtrl.text,
                    photoUrl: selectedImageUrl,
                  );

                  if (!context.mounted) return;
                  setState(() => loading = false);

                  if (user != null) {
                    // Send verification email
                    if (!user.emailVerified) {
                      await user.sendEmailVerification();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Verification email sent. Please check your inbox.",
                          ),
                        ),
                      );
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Registration failed")),
                    );
                  }
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                child: const Text("Already have an account? Login"),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
