import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_style.dart';
import '../widgets/animated_card.dart';
import '../widgets/animated_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  String? _selectedCurrency = 'EUR';
  String? _selectedLanguage = 'fr';
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _displayNameController.text = authProvider.user?.displayName ?? '';
    _isDarkMode = context.read<ThemeProvider>().isDarkMode;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil & Paramètres'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Section Profil
              AnimatedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Profil',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _displayNameController,
                      decoration: AppStyle.inputDecoration(
                        context,
                        'Nom d\'affichage',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer un nom d\'affichage';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section Paramètres
              AnimatedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paramètres',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Devise
                    DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: AppStyle.inputDecoration(
                        context,
                        'Devise',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'EUR',
                          child: Row(
                            children: [
                              Text('€', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Text('Euro'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'USD',
                          child: Row(
                            children: [
                              Text(r'$', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Text('Dollar'),
                            ],
                          ),
                        ),
                        const DropdownMenuItem(
                          value: 'TND',
                          child: Row(
                            children: [
                              Text('DT', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Text('Dinar Tunisien'),
                            ],
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.currency_exchange),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Langue
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: AppStyle.inputDecoration(
                        context,
                        'Langue',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: 'fr',
                          child: Row(
                            children: [
                              Text('🇫🇷', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 8),
                              Text('Français'),
                            ],
                          ),
                        ),
                        const DropdownMenuItem(
                          value: 'en',
                          child: Row(
                            children: [
                              Text('🇬🇧', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 8),
                              Text('English'),
                            ],
                          ),
                        ),
                        const DropdownMenuItem(
                          value: 'ar',
                          child: Row(
                            children: [
                              Text('🇹🇳', style: TextStyle(fontSize: 18)),
                              SizedBox(width: 8),
                              Text('العربية'),
                            ],
                          ),
                        ),
                      ],
                      icon: const Icon(Icons.language),
                      isExpanded: true,
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Thème
                    Container(
                      decoration: AppStyle.cardDecoration(context),
                      child: SwitchListTile(
                        title: const Text('Mode sombre'),
                        value: _isDarkMode,
                        onChanged: (bool value) {
                          setState(() {
                            _isDarkMode = value;
                          });
                          context.read<ThemeProvider>().toggleTheme();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: AnimatedButton(
                      onPressed: _saveProfile,
                      icon: Icons.save,
                      child: const Text('Enregistrer les modifications'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AnimatedButton(
                      onPressed: () {
                        context.read<AuthProvider>().signOut();
                      },
                      outlined: true,
                      icon: Icons.logout,
                      color: Colors.red,
                      child: const Text('Se déconnecter'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = context.read<AuthProvider>();
        await authProvider.updateProfile(
          displayName: _displayNameController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil mis à jour avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur lors de la mise à jour : $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
