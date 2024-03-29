//import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // const ProductItem({Key? key}) : super(key: key);
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.imageUrl, this.title);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () => Navigator.of(context)
              .pushNamed(ProductDetailScreen.routeName, arguments: product.id),
          child: Hero(
            tag: product.id,
            child: FadeInImage(
              fit: BoxFit.cover,
              placeholder: AssetImage('assets/images/product-placeholder.png'),
              image: NetworkImage(
                product.imageUrl,
              ),
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: ((ctx, product, _) => IconButton(
                  icon: Icon(product.isFavourite
                      ? Icons.favorite
                      : Icons.favorite_border),
                  color: Theme.of(context).accentColor,
                  onPressed: () {
                    product.toggleFavouriteStatus(
                        authData.token, authData.userId);
                  },
                )),
            // child:
          ),
          title: FittedBox(
            child: Text(
              product.title,
              textAlign: TextAlign.center,
              // maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.fade,
            ),
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            color: Theme.of(context).accentColor,
            onPressed: () {
              cart.addItem(
                product.id,
                product.price,
                product.title,
              );
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Added to the cart!'),
                duration: Duration(seconds: 2),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () => cart.removeSingleItem(product.id),
                ),
              ));
            },
          ),
        ),
      ),
    );
  }
}
