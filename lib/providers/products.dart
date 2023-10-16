import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';

import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    //   Product(
    //     id: 'p1',
    //     title: 'Red Shirt',
    //     description: 'A red shirt - it is pretty red!',
    //     price: 29.99,
    //     imageUrl:
    //         'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    //   ),
    //   Product(
    //     id: 'p2',
    //     title: 'Trousers',
    //     description: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl:
    //         'https://xcdn.next.co.uk/Common/Items/Default/Default/ItemImages/Search/224x336/636902.jpg',
    //   ),
    //   Product(
    //     id: 'p3',
    //     title: 'Yellow Scarf',
    //     description: 'Warm and cozy - exactly what you need for the winter.',
    //     price: 19.99,
    //     imageUrl:
    //         'https://i.etsystatic.com/16173007/r/il/422a03/1664716452/il_fullxfull.1664716452_dkjx.jpg',
    //   ),
    //   Product(
    //     id: 'p4',
    //     title: 'A pan',
    //     description: 'Prepare any meal you want.',
    //     price: 49.99,
    //     imageUrl:
    //         'https://static01.nyt.com/images/2011/01/26/business/pan2/pan2-blog480.jpg',
    //   ),
  ];

  final String? authToken;
  final String? userId;

  Products(this.authToken, this.userId, this._items);

  // var _showFavoritesOnly = false;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite == true).toList();
  }

  Product findById(String productId) =>
      _items.firstWhere((product) => product.id == productId);

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    if (authToken != null) {
      final filterString =
          filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
      final Uri url = Uri.parse(
          'https://myshop-38edd-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
      try {
        final response = await retry(
          () => http.get(url).timeout(
                const Duration(seconds: 5),
              ),
        );
        final extractedData =
            json.decode(response.body) as Map<String, dynamic>;

        if (extractedData == null) return;

        final Uri favoritesUrl = Uri.parse(
            'https://myshop-38edd-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
        final userFavorites = await retry(
          () => http.get(favoritesUrl).timeout(
                const Duration(seconds: 5),
              ),
        );
        final favoritesData = json.decode(userFavorites.body);

        final List<Product> loadedProducts = [];
        extractedData.forEach((prodId, prodData) {
          loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            price: prodData['price'],
            isFavorite:
                favoritesData == null ? false : favoritesData[prodId] ?? false,
          ));
        });
        _items = loadedProducts;
        notifyListeners();
      } catch (err) {
        rethrow;
      }
    }
  }

  Future<void> addProduct(Product product) async {
    final Uri url = Uri.parse(
        'https://myshop-38edd-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    const r = RetryOptions(maxAttempts: 20);
    try {
      final response = await r.retry(
        () => http
            .post(url,
                body: json.encode({
                  'title': product.title,
                  'description': product.description,
                  'imageUrl': product.imageUrl,
                  'price': product.price,
                  'creatorId': userId,
                }))
            .timeout(
              const Duration(seconds: 5),
            ),
      );
      final newProduct = Product(
        title: product.title,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        id: json.decode(response.body).toString(),
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final Uri url = Uri.parse(
          'https://myshop-38edd-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      await retry(
        () => http
            .patch(url,
                body: json.encode({
                  'title': newProduct.title,
                  'description': newProduct.description,
                  'price': newProduct.price,
                  'imageUrl': newProduct.imageUrl,
                }))
            .timeout(
              const Duration(seconds: 5),
            ),
      );
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> toggleFavoriteStatus(String id) async {
    final Uri url = Uri.parse(
        'https://myshop-38edd-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken');
    const r = RetryOptions(maxAttempts: 20);
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    final product = _items[prodIndex];
    final oldStatus = product.isFavorite;
    product.isFavorite = !product.isFavorite;
    notifyListeners();
    try {
      final response = await http
          .put(
            url,
            body: json.encode(
              product.isFavorite,
            ),
          )
          .timeout(
            const Duration(seconds: 5),
          );
      if (response.statusCode >= 400) {
        product.isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (err) {
      product.isFavorite = oldStatus;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteProduct(String id) async {
    final Uri url = Uri.parse(
        'https://myshop-38edd-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    const r = RetryOptions(maxAttempts: 20);
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    Product? existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await retry(
      () => http.delete(url).timeout(
            const Duration(seconds: 5),
          ),
    );
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
    existingProduct = null;
  }
}
