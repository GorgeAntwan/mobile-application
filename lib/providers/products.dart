import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutterEcommerceProject/models/http_exeption.dart';
import 'package:flutterEcommerceProject/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
      /**
       * Product(
                  id: 'p1',
                  title: 'Red Shirt',
                  description: 'A red shirt - it is pretty red!',
                  price: 29.99,
                  imageUrl:
                      'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
                ),
                Product(
                  id: 'p2',
                  title: 'Trousers',
                  description: 'A nice pair of trousers.',
                  price: 59.99,
                  imageUrl:
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
                ),
                Product(
                  id: 'p3',
                  title: 'Yellow Scarf',
                  description: 'Warm and cozy - exactly what you need for the winter.',
                  price: 19.99,
                  imageUrl:
                      'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
                ),
                Product(
                  id: 'p4',
                  title: 'A Pan',
                  description: 'Prepare any meal you want.',
                  price: 49.99,
                  imageUrl:
                      'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
                ),
       */
  ];
 final String authToken  ,userId;

  Products(this.authToken,this.userId,this._items);

  List<Product> get items {
    return [..._items];
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Future<void> fetchAndSetProduct([bool filterByUser =false]) async {
  
    try {
     
      var params = {'auth':this.authToken};
      var urlFavorite = Uri.https(
              'flutter-e-commerce-cb3f8-default-rtdb.firebaseio.com',
              'userFavorites/$userId.json',params);
      final favoriteResponse = await http.get(urlFavorite);
      final favoriteData = json.decode(favoriteResponse.body);
       
        
      var paramsFavoritefilter = {
        'auth' :this.authToken ,
        'orderBy':'"creatorId"',
        'equalTo':'"$userId"'
      };
        final  filterString =  filterByUser ? paramsFavoritefilter : params;
        print('filterByUser :$filterByUser');
        print('filterString : $filterString');
      var url = Uri.https(
          'flutter-e-commerce-cb3f8-default-rtdb.firebaseio.com',
          'products.json',filterString);
      final response = await http.get(url);
     
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      
      final List<Product> loadedProducts = [];
      if(extractedData ==null){
        return ;
      }
      extractedData.forEach((productId, productData) {
        loadedProducts.add(Product(
            id: productId,
            title: productData['title'],
            price: productData['price'],
            description: productData['description'],
            imageUrl: productData['imageUrl'],
            isFavorite: favoriteData ==null ?false : favoriteData[productId] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      print(error);
    
      throw error;
    }
  }

  Future<void> addItem(Product product) async {
    try {
      //var url = 'https://flutter-e-commerce-cb3f8-default-rtdb.firebaseio.com/products.json';
       var params = {'auth':this.authToken};
      var url = Uri.https(
          'flutter-e-commerce-cb3f8-default-rtdb.firebaseio.com',
          'products.json',params);
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId
           // 'isFavorite': product.isFavorite,
          }));
      final newProduct = new Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        imageUrl: product.imageUrl,
        price: product.price,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateItem(id, Product product) async{
    final productIndex = _items.indexWhere((prod) => prod.id == id);
    if (productIndex >= 0) {
        try {
          var params = {'auth':this.authToken};
          var url = Uri.https(
              'flutter-e-commerce-cb3f8-default-rtdb.firebaseio.com',
              'products/$id.json',params);
          await http.patch(url,
              body: json.encode({
                'title': product.title,
                'description': product.description,
                'imageUrl': product.imageUrl,
                'price': product.price,
               // 'isFavorite': product.isFavorite,
              }));
            _items[productIndex] = product;
            print(_items[productIndex].title);
            notifyListeners();
        } catch (error) {
          print(error);
          throw error;
        }
     
    } else {
      print('...');
    }
  }

  Future<void> deleteItem(id) async{
    var params = {'auth':this.authToken};
    var url = Uri.https(
              'flutter-e-commerce-cb3f8-default-rtdb.firebaseio.com',
              'products/$id.json',params);
    final existingProdutIndex = _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingProdutIndex];
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
    final response = await http.delete(url) ;
    if(response.statusCode >= 400){
        print('response.statusCode : $response.statusCode');
        _items.insert(existingProdutIndex, existingProduct);
         notifyListeners();
         throw HttpExeption('Could not Delete Product.');
    }
     existingProduct = null;
   
    
  }
}
