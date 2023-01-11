import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products.dart';
import '../widget/app_drawer.dart';
import '../widget/user_product_item.dart';
import '../screens/edit_product_screen.dart';

class UsreProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  // const MyWidget({Key key}) : super(key: key);

  Future<void> _refreshProducts(BuildContext ctx) async {
    await Provider.of<Products>(ctx, listen: false).fetchAndGetProduct(true);
  }

  @override
  Widget build(BuildContext context) {
    // final prodcutData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              return Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName);
            },
            icon: const Icon(Icons.add),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: ((context, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Consumer<Products>(
                        builder: ((context, prodcutData, _) => Padding(
                              padding: EdgeInsets.all(8),
                              child: ListView.builder(
                                  itemCount: prodcutData.items.length,
                                  itemBuilder: (_, i) {
                                    return Column(
                                      children: <Widget>[
                                        UserProductItem(
                                          prodcutData.items[i].id,
                                          prodcutData.items[i].imageUrl,
                                          prodcutData.items[i].title,
                                        ),
                                        Divider(),
                                      ],
                                    );
                                  }),
                            )),
                      ),
                    ),
                  )),
      ),
    );
  }
}
