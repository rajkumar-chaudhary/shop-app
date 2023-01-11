import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// import '../models/product.dart';
// import '../providers/products.dart';
import '../widget/product_grid.dart';
import '../providers/cart.dart';
import '../widget/app_drawer.dart';
import '../widget/badge.dart';
import '../screens/cart_screen.dart';
import '../providers/products.dart';

enum FilterOptions {
  Favorites,
  All,
}

class productOverviewScreen extends StatefulWidget {
  @override
  State<productOverviewScreen> createState() => _productOverviewScreenState();
}

class _productOverviewScreenState extends State<productOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLOading = false;
  @override
  void initState() {
    // Provider.of<Products>(context).fetchAndGetProduct(); //***this wont WORK;;;;
    // Future.delayed(Duration.zero).then((value) {
    //   return Provider.of<Products>(context).fetchAndGetProduct();
    // }); ***THIS WILL WORK BUT IT"S A HACKe;

    // TODO: implement initState
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLOading = true;
      });

      Provider.of<Products>(context).fetchAndGetProduct().then((value) {
        setState(() {
          _isLOading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final productsCOntainer = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('MY Shopping App'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: ((FilterOptions selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                  // productsCOntainer.showFavoritesOnly();
                } else {
                  _showOnlyFavorites = false;
                  // productsCOntainer.showAll();
                }
              });
            }),
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: ((_, cart, ch) => Badge(
                  child: ch,
                  value: cart.itemCount.toString(),
                )),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: (() {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              }),
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isLOading
          ? Center(
              child: CircularProgressIndicator(semanticsLabel: 'Loading'),
            )
          : ProductGrid(_showOnlyFavorites),
    );
  }
}
