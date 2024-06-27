import 'package:findit/controller/services/services.dart';
import 'package:findit/view/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final userId = context.read<Shared>().userId ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 26,
            letterSpacing: 0,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Seller Dashboard option (for sellers only)
            if (userId.contains("SL"))
              ProfileOption(
                title: "Seller Dashboard",
                icon: Icons.storefront,
                isSellerOption: true,
                onTap: () => _navigateTo(context, SellerDashboardPage()),
              ),
            // Orders & Returns option
            ProfileOption(
              title: "Orders & Returns",
              icon: Icons.auto_awesome_mosaic_outlined,
              onTap: () => _navigateTo(context, const OrdersPage()),
            ),
            // Help & Support option
            ProfileOption(
              title: "Help & Support",
              icon: Icons.help_outline,
              onTap: () => _navigateTo(context, const HelpSupportScreen()),
            ),
            const SizedBox(height: 20),
            // Logout button
            ElevatedButton(
              onPressed: () async {
                await context.read<AuthService>().signOut(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: theme.colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Log out",
                style: TextStyle(fontSize: 17, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to navigate to a new page
  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

class ProfileOption extends StatelessWidget {
  final String title;
  final String? detail;
  final IconData icon;
  final VoidCallback onTap;
  final bool isSellerOption;

  const ProfileOption({
    Key? key,
    required this.title,
    required this.icon,
    this.detail,
    required this.onTap,
    this.isSellerOption = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 15,
            horizontal: 20,
          ),
          leading: Icon(icon),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: isSellerOption
              ? const Text(
                  'For Sellers Only',
                  style: TextStyle(color: Colors.grey),
                )
              : detail != null
                  ? Text(detail!)
                  : null,
          trailing: const Icon(Icons.arrow_forward_ios),
        ),
      ),
    );
  }
}
