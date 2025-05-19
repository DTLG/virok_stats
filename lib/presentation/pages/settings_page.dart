import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isTestDatabase = false;
  final _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await _prefs;
    setState(() {
      _isTestDatabase = prefs.getBool('isTestDatabase') ?? false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await _prefs;
    await prefs.setBool('isTestDatabase', _isTestDatabase);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Налаштування'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),
          _buildSection(
            title: 'База даних',
            child: Column(
              children: [
                _buildDatabaseOption(
                  title: 'Жива база',
                  subtitle: 'Використовувати основну базу даних',
                  isSelected: !_isTestDatabase,
                  onTap: () {
                    setState(() {
                      _isTestDatabase = false;
                    });
                    _saveSettings();
                  },
                ),
                const Divider(),
                _buildDatabaseOption(
                  title: 'Тестова база',
                  subtitle: 'Використовувати тестову базу даних',
                  isSelected: _isTestDatabase,
                  onTap: () {
                    setState(() {
                      _isTestDatabase = true;
                    });
                    _saveSettings();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Про додаток',
            child: const Column(
              children: [
                ListTile(
                  title: const Text('Версія'),
                  subtitle: const Text('1.0.0'),
                ),
                // const Divider(),
                // ListTile(
                //   title: const Text('Розробник'),
                //   subtitle: const Text('Virok'),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: child,
        ),
      ],
    );
  }

  Widget _buildDatabaseOption({
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
            )
          : const Icon(
              Icons.circle_outlined,
              color: Colors.grey,
            ),
      onTap: onTap,
    );
  }
}
