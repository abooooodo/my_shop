import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:retry/retry.dart';

import 'cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.amount,
    required this.id,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? authToken;
  final String? userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final Uri url = Uri.parse(
        'https://myshop-38edd-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    try {
      final response = await retry(
        () => http.get(url).timeout(
              const Duration(seconds: 5),
            ),
      );
      final List<OrderItem> loadedOrders = [];
      if (json.decode(response.body) == null) return;
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            amount: orderData['amount'],
            id: orderId,
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    price: item['price'],
                    quantity: item['quantity'],
                    title: item['title'],
                  ),
                )
                .toList(),
            dateTime: DateTime.parse(orderData['dateTime']),
          ),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final Uri url = Uri.parse(
        'https://myshop-38edd-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp = DateTime.now();
    try {
      final response = await retry(
        () => http
            .post(
              url,
              body: json.encode({
                'amount': total,
                'dateTime': timestamp.toIso8601String(),
                'products': cartProducts
                    .map((cp) => {
                          'id': cp.id,
                          'title': cp.title,
                          'quantity': cp.quantity,
                          'price': cp.price,
                        })
                    .toList(),
              }),
            )
            .timeout(
              const Duration(seconds: 5),
            ),
      );
      _orders.insert(
          0,
          OrderItem(
            amount: total,
            id: json.decode(response.body)['name'],
            products: cartProducts,
            dateTime: timestamp,
          ));

      notifyListeners();
    } catch (err) {
      rethrow;
    }
  }
}
