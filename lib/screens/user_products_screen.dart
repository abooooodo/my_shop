import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';
import './edit_product_screen.dart';

class UserProductsScreen extends StatefulWidget {
  static const routeName = '/userProductScreen';

  const UserProductsScreen({super.key});

  @override
  State<UserProductsScreen> createState() => _UserProductsScreenState();
}

class _UserProductsScreenState extends State<UserProductsScreen> {
  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<Products>(ctx, listen: false)
        .fetchAndSetProducts(true)
        .timeout(const Duration(seconds: 10))
        .onError(
          (error, stackTrace) => ScaffoldMessenger.of(ctx).showSnackBar(
            const SnackBar(
              content: Text('Network error! Check your connection.'),
              duration: Duration(seconds: 2),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      title: const Text('Your Products'),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).pushNamed(EditProductScreen.routeName);
          },
          icon: const Icon(
            Icons.add,
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: RefreshIndicator(
        onRefresh: () async {
          var result = await _refreshProducts(context);
          setState(() {});
          return result;
        },
        child: FutureBuilder(
          future: Provider.of<Products>(context, listen: false)
              .fetchAndSetProducts(true),
          builder: ((ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.error != null) {
              return SingleChildScrollView(
                child: SizedBox(
                  height: (mediaQuery.size.height -
                          appBar.preferredSize.height -
                          mediaQuery.padding.top) +
                      0.001,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (snapshot.error
                          .toString()
                          .contains('TimeoutException'))
                        const Text('Network error! Check your connection.')
                      else
                        const Text('An error has occurred!'),
                    ],
                  ),
                ),
              );
            } else {
              return Consumer<Products>(
                builder: (ctx, productData, _) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: productData.items.isEmpty
                      ? const Center(
                          child: Text(
                              'You have no products yet! Press + to add one.'),
                        )
                      : ListView.builder(
                          itemCount: productData.items.length,
                          itemBuilder: (_, i) => Column(
                            children: [
                              UserProductItem(
                                id: productData.items[i].id,
                                title: productData.items[i].title,
                                imageUrl: productData.items[i].imageUrl,
                              ),
                              const Divider(),
                            ],
                          ),
                        ),
                ),
              );
            }
          }),
        ),
      ),
      drawer: const AppDrawer(),
    );
  }
}
