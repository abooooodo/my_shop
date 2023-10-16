import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  const UserProductItem({
    super.key,
    required this.title,
    required this.imageUrl,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    final scaffold = ScaffoldMessenger.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundColor: Colors.grey,
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: SizedBox(
        width: 100,
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  EditProductScreen.routeName,
                  arguments: id,
                );
              },
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (ctx) => Builder(
                  builder: (innerContext) => AlertDialog(
                    title: const Text('Confirm Deletion'),
                    titleTextStyle: TextStyle(
                      color: Colors.black,
                      fontSize:
                          Theme.of(innerContext).textTheme.titleLarge!.fontSize,
                    ),
                    content: const Text(
                        'Are you sure you want to delete this product?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(innerContext).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          try {
                            await Provider.of<Products>(context, listen: false)
                                .deleteProduct(id);
                            Navigator.of(innerContext).pop();
                          } catch (err) {
                            scaffold.showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Deleting failed!',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            );
                          }
                        },
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ),
              ),
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
