import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const privacyPolicyUrl =
    'https://ben78baker.github.io/find-catalogue-privacy-policy/';
const supportUrl =
    'https://ben78baker.github.io/find-catalogue-privacy-policy/find-catalogue-support/';

class PrivacySupportScreen extends StatelessWidget {
  const PrivacySupportScreen({super.key});

  Future<void> _openUrl(BuildContext context, String value) async {
    try {
      final opened = await launchUrl(
        Uri.parse(value),
        mode: LaunchMode.externalApplication,
      );
      if (opened || !context.mounted) return;
    } catch (_) {
      if (!context.mounted) return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not open that page.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy & support')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Text(
            'Find Catalogue keeps your catalogue in the app on your device. '
            'It has no account, advertising, analytics or developer-operated '
            'catalogue server.',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(height: 1.4),
          ),
          const SizedBox(height: 20),
          Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  key: const Key('open_privacy_policy'),
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy policy'),
                  subtitle: const Text(
                    'How local records, maps and sharing work',
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openUrl(context, privacyPolicyUrl),
                ),
                const Divider(height: 1),
                ListTile(
                  key: const Key('open_support_page'),
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Support'),
                  subtitle: const Text(
                    'Help, common checks and contact details',
                  ),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _openUrl(context, supportUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Interactive maps load OpenStreetMap tiles only when you open a '
            'map. Sharing happens only when you create an export and choose a '
            'destination.',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }
}
