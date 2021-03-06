import 'package:flutter/material.dart';
import 'package:flutterEcommerceProject/providers/auth.dart';
import 'package:flutterEcommerceProject/providers/cart.dart';
import 'package:flutterEcommerceProject/providers/order.dart';
import 'package:flutterEcommerceProject/providers/products.dart';
import 'package:flutterEcommerceProject/screens/splash_screen.dart';
import 'package:flutterEcommerceProject/screens/auth_screen.dart';
import 'package:flutterEcommerceProject/screens/cart_screen.dart';
import 'package:flutterEcommerceProject/screens/edit_product_screen.dart';
import 'package:flutterEcommerceProject/screens/order_screen.dart';
import 'package:flutterEcommerceProject/screens/product_details_screen.dart';
import 'package:flutterEcommerceProject/screens/product_overview_screen.dart';
import 'package:flutterEcommerceProject/screens/user_product_screen.dart';
import 'package:provider/provider.dart';

import 'helpers/custom_route.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  

  



  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (cntx) => Auth(),
        ),
         // ignore: missing_required_param
         ChangeNotifierProxyProvider<Auth, Products>(
         // create: (context)=>,
          update: (ctx, auth, previousProducts) => Products(
                auth.token,
                auth.userId,
                previousProducts == null ? [] : previousProducts.items,
              ),
        ),
        ChangeNotifierProvider(
          create: (cntx) => Cart(),
        ),
        // ignore: missing_required_param
        ChangeNotifierProxyProvider<Auth,Orders>(
          //create: '',
           update: (cntx ,auth ,previousOrders) =>Orders(
             auth.token,
             auth.userId,
             previousOrders ==null ?[]: previousOrders.orders
           )
        ),
        
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            // This is the theme of your application.
            //
            // Try running your application with "flutter run". You'll see the
            // application has a blue toolbar. Then, without quitting the app, try
            // changing the primarySwatch below to Colors.green and then invoke
            // "hot reload" (press "r" in the console where you ran "flutter run",
            // or simply save your changes to "hot reload" in a Flutter IDE).
            // Notice that the counter didn't reset back to zero; the application
            // is not restarted.
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
            // This makes the visual density adapt to the platform that you run
            // the app on. For desktop platforms, the controls will be smaller and
            // closer together (more dense) than on mobile platforms.
            visualDensity: VisualDensity.adaptivePlatformDensity,
             pageTransitionsTheme: PageTransitionsTheme(
                  builders: {
                    TargetPlatform.android: CustomPageTransitionBuilder(),
                    TargetPlatform.iOS: CustomPageTransitionBuilder(),
                  },
                ),
          ),
          home: auth.isAuth ? ProductOverviewScreen() :
            FutureBuilder(
              future: auth.tryAutoLogin(),
             builder: (ctx,authResultSnapshot)=>
               authResultSnapshot.connectionState == ConnectionState.waiting?
              SplashScreen()
              :AuthScreen()
             ) ,
          routes: {
            ProductDetailsScreen.routeName: (context) => ProductDetailsScreen(),
            CartScreen.routeName: (context) => CartScreen(),
            OrderScreen.routeName: (context) => OrderScreen(),
            UserProductScreen.routeName: (context) => UserProductScreen(),
            EditProductScreen.routeName: (context) => EditProductScreen()
          },
        ),
      ),
    );
  }
}
