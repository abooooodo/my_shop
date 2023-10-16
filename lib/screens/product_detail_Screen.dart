import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  static const routeName = '/product-detail';

  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productId = (ModalRoute.of(context)!.settings.arguments as Map)['id'];
    final image = (ModalRoute.of(context)!.settings.arguments as Map)['image'];
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);

    final mediaQuery = MediaQuery.of(context);
    final sliverAppBar = SliverAppBar(
      expandedHeight: 300,
      collapsedHeight: 56,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Hero(
          tag: '${loadedProduct.id} title',
          child: Text(
            loadedProduct.title,
            style: TextStyle(
              fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
              color: Theme.of(context).textTheme.titleLarge!.color,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
                tag: loadedProduct.id,
                child: FadeInImage(
                  placeholder: image,
                  image: image,
                  fit: BoxFit.cover,
                )),
            Hero(
              tag: '${loadedProduct.id} container',
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(130, 0, 0, 0),
                      Color.fromARGB(0, 0, 0, 0),
                      Color.fromARGB(0, 255, 255, 255),
                      Color.fromARGB(0, 0, 0, 0),
                      Color.fromARGB(130, 0, 0, 0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0, 0.3, 0.5, 0.8, 1],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          sliverAppBar,
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(
                height: 10,
              ),
              Text(
                '\$${loadedProduct.price}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(
                height: mediaQuery.size.height -
                    sliverAppBar.collapsedHeight! -
                    sliverAppBar.toolbarHeight -
                    mediaQuery.padding.top,
              )
            ]),
          ),
        ],
      ),
    );
  }
}
