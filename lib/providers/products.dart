import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];

  // var _showFavoritesOnly = false;

  final String authToken;
  final String userId;
  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((element) => element.isFavourite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavourite).toList();
  }

  Product findById(String ID) {
    return _items.firstWhere((prod) => prod.id == ID);
  }

  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  void additems() {
    //....
    notifyListeners();
  }

  Future<void> fetchAndGetProduct([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="createrId"&equalTo="$userId"' : '';
    var url = Uri.parse(
        'https://flutter-updated-4107c-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken&$filterString');
    try {
      final responce = await http.get(url);
      // print(json.decode(responce.body));
      final extractedData = json.decode(responce.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return null;
      }
      url = Uri.parse(
          'https://flutter-updated-4107c-default-rtdb.asia-southeast1.firebasedatabase.app/userFavourites/$userId.json?auth=$authToken');
      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedProduct = [];
      extractedData.forEach((prodId, prodDAta) {
        loadedProduct.add(Product(
          description: prodDAta['description'],
          id: prodId,
          imageUrl: prodDAta['imageUrl'],
          price: prodDAta['price'],
          title: prodDAta['title'],
          isFavourite:
              favouriteData == null ? false : favouriteData[prodId] ?? false,
        ));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProducts(Product prod) async {
    final url = Uri.parse(
        'https://flutter-updated-4107c-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': prod.title,
          'description': prod.description,
          'imageUrl': prod.imageUrl,
          'price': prod.price,
          'createrId': userId,
          // 'isFavourite': prod.isFavourite,
        }),
      );

      //  print(json.decode(response.body));
      final newProduct = Product(
          description: prod.description,
          id: json.decode(response.body)['name'],
          imageUrl: prod.imageUrl,
          price: prod.price,
          title: prod.title);
      // _items.add(newProduct);
      _items.insert(0, newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }

    // .catchError((error) {
    //   print(error);
    //   throw error;
  }

  void updateProduct(String ID, Product newProduct) async {
    final ProdIndex = _items.indexWhere((element) => element.id == ID);
    if (ProdIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-updated-4107c-default-rtdb.asia-southeast1.firebasedatabase.app/products/$ID.json?auth=$authToken');
      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
            // 'isFavourite': newProduct.isFavourite,
          }));
      _items[ProdIndex] = newProduct;
      notifyListeners();
    } else {
      print('....');
    }
  }

  Future<void> deleteProduct(String ID) async {
    final url = Uri.parse(
        'https://flutter-updated-4107c-default-rtdb.asia-southeast1.firebasedatabase.app/products/$ID.json?auth=$authToken');
    final existingProductIndex =
        _items.indexWhere((element) => element.id == ID);
    var existingProduct = _items[existingProductIndex];
    _items.removeWhere((element) => element.id == ID);
    notifyListeners();
    final responce = await http.delete(url);
    if (responce.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw Exception('Could not delete Product!');
    }
    existingProduct = null;
  }
}
