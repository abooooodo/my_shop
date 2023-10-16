import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future<void> _refreshOrders(ctx) async {
    await Provider.of<Orders>(ctx, listen: false)
        .fetchAndSetOrders()
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
      title: const Text('Your Orders'),
    );

    return Scaffold(
      appBar: appBar,
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          var result = await _refreshOrders(context);
          setState(() {});
          return result;
        },
        child: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: ((context, snapshot) {
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
              return Consumer<Orders>(
                builder: (ctx, orderData, child) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                ),
              );
            }
          }),
        ),
      ),
    );
  }
}
