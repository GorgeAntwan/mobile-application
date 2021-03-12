import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
class Product with ChangeNotifier{
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;
 
  Product({

     @required this.id,
     @required this.title,
     @required this.description,
     @required this.price,
     @required this.imageUrl,
      this.isFavorite =false
  });
  
  Future<void> toggleFavoriteStatus(String token ,String userId)async{

    final oldStatus = isFavorite;
    isFavorite =!isFavorite;
    notifyListeners();

    try {
        var params = {'auth' :token};
        var url = Uri.https(
              'flutter-e-commerce-cb3f8-default-rtdb.firebaseio.com',
              'userFavorites/$userId/$id.json',params);
        final response = await http.put(url,body: json.encode(
             isFavorite
        ));
        if(response.statusCode>=400){
           isFavorite = oldStatus;
           notifyListeners();
        }

    } catch (error) {
        isFavorite = oldStatus;
        notifyListeners();
    }
  }
  
}
