import 'package:flutter/material.dart';
import 'package:bapp_mobile_ui/src/models/access.dart';

/// A simple list picker that lets the user choose a tenant.
/// This is the entry-point of the tenant-first selection flow.
class TenantPicker extends StatelessWidget {
  final List<AccessTenant> tenants;
  final void Function(AccessTenant) onPick;
  const TenantPicker({super.key, required this.tenants, required this.onPick});

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

/// A simple list picker that lets the user choose an app from a given tenant's
/// available apps.
class AppPicker extends StatelessWidget {
  final List<AccessApp> apps;
  final void Function(AccessApp) onPick;
  const AppPicker({super.key, required this.apps, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose app')),
      body: ListView.builder(
        itemCount: apps.length,
        itemBuilder: (context, i) {
          final app = apps[i];
          return ListTile(
            title: Text(app.name),
            onTap: () => onPick(app),
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
