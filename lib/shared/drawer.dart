import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../injection_container.dart';

class AiDrawer extends StatelessWidget {
  const AiDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Add a ListView to the drawer. This ensures the user can scroll
      // through the options in the drawer if there isn't enough vertical
      // space to fit everything.
      child: ListView(
        // Important: Remove any padding from the ListView.
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.black12),
            child: Text('Deep Voice'),
          ),

          ListTile(
            title: Row(
              children: [
                Icon(Icons.exit_to_app),
                SizedBox(width: 5),
                const Text('Sign out'),
              ],
            ),
            onTap: () {
              locator<SupabaseClient>().auth.signOut();

              //context.go('/authentication');
            },
          ),
        ],
      ),
    );
  }
}
