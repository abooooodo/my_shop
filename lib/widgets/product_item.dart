import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_Screen.dart';
import '../providers/product.dart';
import '../providers/products.dart';
import '../providers/cart.dart';

class ProductItem extends StatelessWidget {
  ImageProvider? image;
  var loaded = false;
  var loadingFailed = false;

  ProductItem({super.key});

  ImageProvider _loadImage(String url) {
    loaded = false;
    image = NetworkImage(url)
      ..resolve(
        const ImageConfiguration(),
      ).addListener(
        ImageStreamListener(
          (imageInfo, _) {
            // Image loaded successfully
            loaded = true;
            loadingFailed = false;
          },
          onError: (exception, stackTrace) {
            // Error loading image
            loadingFailed = true;
          },
        ),
      );
    return image!;
  }

  void _showSnackBar(String message, ctx) {
    ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          leading: Consumer(
            builder: (ctx, Product product, child) => IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .toggleFavoriteStatus(product.id);
                } catch (err) {
                  if (err.toString().contains('TimeoutException')) {
                    _showSnackBar(
                        'Action failed! Check your connection.', context);
                  } else {
                    _showSnackBar('An error has occurred!', context);
                  }
                }
              },
            ),
          ),
          title: Hero(
            tag: '${product.id} title',
            child: Text(
              product.title,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.titleLarge!.color,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Added item to cart!'),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    onPressed: () {
                      cart.removeSingleItem(product.id);
                    },
                    label: 'UNDO',
                  ),
                ),
              );
            },
          ),
        ),
        child: GestureDetector(
          onTap: () {
            if (loaded) {
              Navigator.of(context).pushNamed(
                ProductDetailScreen.routeName,
                arguments: {'id': product.id, 'image': image},
              );
            } else if (loadingFailed) {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Failed to load product! Check your connection.'),
                  duration: Duration(seconds: 2),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Still loading product...'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: product.id,
                child: FadeInImage(
                  placeholder: const AssetImage(
                      'lib/assets/images/product-placeholder.png'),
                  image: _loadImage(
                    product.imageUrl,
                  ),
                  imageErrorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'lib/assets/images/connection_error.jpg',
                      fit: BoxFit.cover,
                    );
                  },
                  fit: BoxFit.cover,
                ),
              ),
              Hero(
                tag: '${product.id} container',
                child: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(0, 0, 0, 0),
                        Color.fromARGB(200, 0, 0, 0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.6, 1],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
