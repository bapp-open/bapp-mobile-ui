import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/src/models/access.dart';

/// A simple list picker that lets the user choose an app.
class AppPicker extends StatelessWidget {
  final List<({AccessApp app, List<AccessTenant> tenants})> apps;
  final void Function(AccessApp) onPick;
  const AppPicker({super.key, required this.apps, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose app')),
      body: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (context, i) {
          final entry = apps[i];
          return ListTile(
            title: Text(entry.app.name),
            subtitle: Text(
              entry.tenants.length == 1
                  ? '1 tenant'
                  : '${entry.tenants.length} tenants',
            ),
            onTap: () => onPick(entry.app),
          );
        },
      ),
    );
  }
}

/// A simple list picker that lets the user choose a tenant for a given app.
class TenantPicker extends StatelessWidget {
  final AccessApp app;
  final List<AccessTenant> tenants;
  final void Function(AccessTenant) onPick;
  const TenantPicker(
      {super.key,
      required this.app,
      required this.tenants,
      required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose tenant')),
      body: ListView.builder(
        itemCount: tenants.length,
        itemBuilder: (context, i) {
          final tenant = tenants[i];
          return ListTile(
            title: Text(tenant.name),
            onTap: () => onPick(tenant),
          );
        },
      ),
    );
  }
}

/// Shown when the access matrix has no apps for this user.
class NoAccessView extends StatelessWidget {
  const NoAccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('No mobile apps available for your account'),
      ),
    );
  }
}
