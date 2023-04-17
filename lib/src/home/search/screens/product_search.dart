import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../../../src/models/firestore/vendor_product.dart';
import '../../../../adaptive/adaptive_custom_appbar.dart';
import '../../../../adaptive/adaptive_theme.dart';
import '../../../../util/app_theme.dart';
import '../../../../util/app_theme_cupertino.dart';
import '/src/home/search/widgets/products_wall_list.dart';

class ProductSearchScreen extends StatefulWidget {
  static String routeName = '/product-search';
  const ProductSearchScreen({Key? key}) : super(key: key);

  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  // bool isSwitched = false;
  final _searchController = TextEditingController();
  String _searchString = '';
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle? _inputStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!
            .copyWith(fontWeight: FontWeight.w400)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontWeight: FontWeight.w400);

    List<VendorProduct> savedProductList =
        ModalRoute.of(context)!.settings.arguments as List<VendorProduct>;
    void _setSearchString() {
      setState(() {
        _searchString = _searchController.text;
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AdaptiveCustomAppBar(
          showShopifyHomeButton: false,
          showShopifyCartButton: false,
          showKycButton: false,
          showProfileButton: false,
          showHamburger: false,
          scaffoldKey: null,
          adResponse: null,
          loginResponse: null,
          updateHandler: null),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  style: _inputStyle,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    focusColor: AdaptiveTheme.primaryColor(context),
                    focusedBorder: AdaptiveTheme.underlineInputBorder(context),
                    suffixIcon: IconButton(
                      onPressed: _setSearchString,
                      icon: Icon(
                        Icons.search,
                        color: AdaptiveTheme.primaryColor(context),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                if (_searchString != '')
                  ProductsWallList(
                    searchString: _searchString,
                    savedProductList: savedProductList,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
