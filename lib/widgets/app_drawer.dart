import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/orders_screen.dart';
import '../screens/user_products_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.shop,
            ),
            title: const Text('Shop'),
            onTap: () => Navigator.of(context).pushReplacementNamed('/'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.payment,
            ),
            title: const Text('Orders'),
            onTap: () => Navigator.of(context)
                .pushReplacementNamed(OrdersScreen.routeName),
            //     Navigator.of(context).pushReplacement(
            //   CustomRoute(
            //     builder: (ctx) => OrdersScreen(),
            //   ),
            // ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.edit,
            ),
            title: const Text('Manage Products'),
            onTap: () {
              Navigator.of(context)
                  .pushReplacementNamed(UserProductsScreen.routeName);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(
              Icons.exit_to_app,
            ),
            title: const Text('Logout'),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => Builder(
                  builder: (innerCtx) => AlertDialog(
                    title: const Text('Are you sure?'),
                    titleTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize:
                          Theme.of(innerCtx).textTheme.titleLarge!.fontSize,
                    ),
                    content: const Text('You will logout of your account.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(innerCtx).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(innerCtx).pop();
                          Navigator.of(innerCtx).pushReplacementNamed('/');
                          Provider.of<Auth>(context, listen: false).logout();
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
