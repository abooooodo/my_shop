import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../widgets/products_grid.dart';
import '../widgets/badge.dart' as badge;
import '../widgets/app_drawer.dart';
import '../providers/cart.dart';
import '../providers/products.dart';
import 'cart_screen.dart';

enum FilterOptions {
  favorites,
  all,
}

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({super.key});

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult>? subscription;

  // var _isInit = true;
  // var _isLoading = false;

  // @override
  // void didChangeDependencies() {
  //   if (_isInit) {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     Provider.of<Products>(context).fetchAndSetProducts().then((_) {
  //       setState(() {
  //         _isLoading = false;
  //       });
  //     });
  //   }
  //   _isInit = false;
  //   super.didChangeDependencies();
  // }

  @override
  initState() {
    super.initState();

    subscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  @override
  dispose() {
    subscription!.cancel();
    super.dispose();
  }

  void _onConnectivityChanged(ConnectivityResult result) {
    setState(() {});
  }

  Future<void> _refreshProducts(ctx) async {
    await Provider.of<Products>(ctx, listen: false)
        .fetchAndSetProducts()
        .timeout(const Duration(seconds: 10))
        .onError(
          (error, stackTrace) => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Network error! Check your connection.'),
              duration: Duration(seconds: 2),
            ),
          ),
        );
  }

  String getCurrentRoute(BuildContext context) {
    final route = ModalRoute.of(context);
    return route?.settings.name ?? '/';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      title: const Text('Shop'),
      actions: [
        PopupMenuButton(
          onSelected: (FilterOptions selectedValue) {
            setState(() {
              if (selectedValue == FilterOptions.favorites) {
                _showOnlyFavorites = true;
              } else {
                _showOnlyFavorites = false;
              }
            });
          },
          icon: const Icon(
            Icons.more_vert,
          ),
          itemBuilder: (_) => [
            const PopupMenuItem(
              value: FilterOptions.favorites,
              child: Text('Only Favorites'),
            ),
            const PopupMenuItem(
              value: FilterOptions.all,
              child: Text('Show All'),
            ),
          ],
        ),
        Consumer(
          builder: (ctx, Cart cart, ch) => badge.Badge(
            value: cart.itemCount.toString(),
            color: Theme.of(context).colorScheme.error,
            child: ch!,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.shopping_cart,
            ),
            onPressed: () {
              Navigator.of(context).pushNamed(CartScreen.routeName);
            },
          ),
        )
      ],
    );

    return Scaffold(
      appBar: appBar,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          var result = await _refreshProducts(context);
          setState(() {});
          return result;
        },
        child: FutureBuilder(
          future: Provider.of<Products>(context, listen: false)
              .fetchAndSetProducts(),
          builder: (context, snapshot) {
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
              return ProductsGrid(_showOnlyFavorites);
            }
          },
        ),
      ),
    );
  }
}
