import 'dart:io';
import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../../helpers/app_info.dart';
import '../../../helpers/global_variables.dart';
import '../../../src/models/firestore/feedpost.dart';
import '../../../src/models/login_response.dart';
import '../../../src/providers/auth.dart';
import '../../../src/providers/feed_posts.dart';
import '../../../util/app_theme_cupertino.dart';
import '../../../util/dialogs.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';
import '../../../adaptive/adaptive_custom_appbar.dart';
import '../../../adaptive/adaptive_theme.dart';
import '../../../util/ui_helpers.dart';
import '/src/home/search/screens/product_search.dart';
import '/src/models/firestore/vendor_product.dart';

import '/util/app_theme.dart';
import 'post_image_picker.dart';

//TODO:This is a new screen with new image picker need to test and approve
class PostGeneralScreen extends StatefulWidget {
  static String routeName = '/new-post-general';
  const PostGeneralScreen({Key? key}) : super(key: key);

  @override
  _PostGeneralScreenState createState() => _PostGeneralScreenState();
}

class _PostGeneralScreenState extends State<PostGeneralScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleFocusNode = FocusNode();
  final _detailsFocusNode = FocusNode();
  final Map<String, String> _dataFields = {
    'title': '',
    'description': '',
    'taggedProducts': '',
  };
  List<File> _imageFiles = [];
  List<File> _videoFiles = [];
  List<File> _allFiles =
      []; // this is the combination of images and video as per the selected order
  List<VendorProduct> _vendorProducts = [];
  int maxVendorProducts = 3;
  bool _isLoading = false;
  bool fb = false;
  @override
  void dispose() {
    _titleFocusNode.dispose();
    _detailsFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleFocusNode.addListener(_onOnFocusNodeEvent);
    _detailsFocusNode.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  void saveImage(File selectedImage) {
    setState(() {
      _imageFiles.add(selectedImage);
      _allFiles.add(selectedImage);
    });
    setState(() {});
  }

  Future<void> saveImageMultiple(List<Asset> selectedImages) async {
    for (var file in selectedImages) {
      File file1 = await getImageFileFromAssets(file);
      _imageFiles.add(File(file1.path));
      _allFiles.add(File(file1.path));
    }

    setState(() {});
  }

  void removeImage(int fileIndex) {
    setState(() {
      String filePath = _imageFiles[fileIndex].path;
      int idx = _allFiles.indexWhere(((element) => element.path == filePath));
      _imageFiles.removeAt(fileIndex);
      _allFiles.removeAt(idx);
    });
    setState(() {});
  }

  void saveVideo(File videFile) {
    setState(() {
      _videoFiles.add(videFile);
      _allFiles.add(videFile);
    });
    setState(() {});
  }

  void removeVideo(int fileIndex) {
    setState(() {
      String filePath = _videoFiles[fileIndex].path;
      int idx = _allFiles.indexWhere(((element) => element.path == filePath));
      _videoFiles.removeAt(fileIndex);
      _allFiles.removeAt(idx);
    });
    setState(() {});
  }

  Future<void> _submit() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    if ((_imageFiles.length + _videoFiles.length) < 1) {
      await Dialogs().ackInfoAlert(
          context, 'Minimum one media file is mandatory for a new post');
      return;
    }
    if (totalFileSize(_imageFiles, _videoFiles) >
        GlobalVariables.totalFileSizeForUpload) {
      Dialogs().ackInfoAlert(context,
          'All media file\'s size should not be more than ${GlobalVariables.videoFileSizeForUpload}MB');
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });
    PackageInfo _packageInfo = await AppInfo.getPackageInfo();
    LoginResponse _loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;

    //Build the object
    FeedPost feedPost = FeedPost(
      title: _dataFields['title'],
      description: _dataFields['description'],
      achievement: '',
      categoryId: '',
      issuingAuthority: '',
      team: false,
      postedUserID: _loginResponse.b2cParent!.parentID,
      postedByUserCountry: _loginResponse.b2cParent!.country,
      postedByUserLocation: _loginResponse.b2cParent!.location,
      postedByUserState: _loginResponse.b2cParent!.state,
      postedUserName: _loginResponse.b2cParent!.name,
      profileImage: _loginResponse.b2cParent!.profileImage,
    );

    try {
      // var _inserted = await Provider.of<FeedPosts>(context, listen: false)
      //     .addNewPost(feedPost, _packageInfo.version, _imageFiles,
      //         _videoFiles, _vendorProducts);

      var _inserted = await Provider.of<FeedPosts>(context, listen: false)
          .addNewPost(FeedPostType.GENERAL, feedPost, _packageInfo.version,
              _imageFiles, _videoFiles, _allFiles, _vendorProducts, null, fb);

      if (_inserted) {
        setState(() {
          _isLoading = false;
        });

        await Dialogs().ackSuccessAlert(context, 'SUCCESS!!!',
            'Your Post has been received successfully. It will be visible on the wall after review!');
        Navigator.of(context).pop();
      } else {
        setState(() {
          _isLoading = false;
        });
        await Dialogs().ackInfoAlert(context, 'Invalid user');
        Navigator.of(context).pop();
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      await Dialogs().ackAlert(context, 'An error occured', error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle _textViewStyle = kIsWeb || Platform.isAndroid
        ? AppTheme.lightTheme.textTheme.bodySmall!.copyWith(fontSize: 15)
        : AppThemeCupertino.lightTheme.textTheme.navTitleTextStyle
            .copyWith(fontSize: 15, fontWeight: FontWeight.w500);
    Widget _buildVendorProducts() {
      Widget vendorProductCard(VendorProduct prod, int prodIndex) {
        return Card(
            color: Colors.transparent,
            elevation: 0.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CachedNetworkImage(
                      imageUrl: prod.images![0].img_url!,
                      imageBuilder: (context, imageProvider) => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      ),
                      placeholder: (context, url) =>
                          Center(child: AdaptiveCircularProgressIndicator()),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.image, size: 50),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(prod.title!,
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _vendorProducts.removeAt(prodIndex);
                    });
                  },
                  icon: Icon(Icons.delete_forever, size: 30),
                ),
              ],
            ));
      }

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: double.infinity,
          child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _vendorProducts.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    vendorProductCard(_vendorProducts[index], index),
                    const SizedBox(height: 5),
                  ],
                );
              }),
        ),
      );
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
        updateHandler: null,
        title: 'General Activity',
        showMascot: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //TITLE
                  TextFormField(
                    enabled: !_isLoading,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(50),
                    ],
                    style: _textViewStyle,
                    decoration: AdaptiveTheme.textFormFieldDecoration(context,
                        'Title (maximum 50 characters)', _titleFocusNode),
                    textInputAction: TextInputAction.next,
                    focusNode: _titleFocusNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_detailsFocusNode);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return "Please provide the title of your post";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _dataFields['title'] = value!;
                    },
                  ),
                  //TITLE
                  const SizedBox(height: 10),
                  //DETAILS
                  TextFormField(
                    enabled: !_isLoading,
                    cursorHeight: 25,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(500),
                    ],
                    style: _textViewStyle,
                    decoration: AdaptiveTheme.textFormFieldDecoration(
                        context,
                        'Description (maximum 500 characters)',
                        _detailsFocusNode),
                    textInputAction: TextInputAction.newline,
                    focusNode: _detailsFocusNode,
                    keyboardType: TextInputType.multiline,
                    minLines: 1,
                    maxLines: 5,
                    validator: (value) {
                      if (value!.isEmpty || value.trim() == '') {
                        return "Please provide the description of your post";
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _dataFields['description'] = value!.trim();
                    },
                  ),
                  //DETAILS
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: [
                        Text(
                          'Tag Products',
                          style: _textViewStyle.copyWith(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        ),
                        Spacer(),
                        Card(
                          elevation: 0.0,
                          color: Colors.white, // AppTheme.secondaryColor,
                          child: Transform.rotate(
                            angle: 120 * math.pi / 230,
                            child: IconButton(
                              icon: Icon(Icons.search),
                              color: AdaptiveTheme.primaryColor(context),
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                      FocusScope.of(context)
                                          .requestFocus(FocusNode());
                                      if (_vendorProducts.length >=
                                          maxVendorProducts) {
                                        Dialogs().ackInfoAlert(context,
                                            'Maximum of $maxVendorProducts products are only allowed');
                                      } else {
                                        var prod = await Navigator.of(context)
                                            .pushNamed(
                                                ProductSearchScreen.routeName,
                                                arguments: _vendorProducts);
                                        if (prod != null) {
                                          _vendorProducts
                                              .add(prod as VendorProduct);
                                        }

                                        setState(() {});
                                      }
                                    },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_vendorProducts.isNotEmpty) _buildVendorProducts(),
                  const SizedBox(height: 30),
                  PostImagePicker(saveImage, removeImage, saveVideo,
                      removeVideo, saveImageMultiple, _isLoading),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Switch(
                        value: fb,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  fb = value;
                                });
                              },
                        activeTrackColor: Colors.grey,
                        activeColor: AppTheme.secondaryColor,
                      ),
                      Text(
                        'Also Share to Facebook',
                        style: _textViewStyle.copyWith(
                            fontSize: 16, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                    child: SizedBox(
                      width: double.infinity,
                      child: AutoSizeText(
                        GlobalVariables.feedPostWarningMessage,
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                            fontSize: 14,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w400),
                        maxFontSize: textScale(context) <= 1.0 ? 14 : 13,
                        maxLines: 4,
                        minFontSize: 13,
                        stepGranularity: 1,
                      ),
                    ),
                  ),
                  /*TextButton(
                    onPressed: _isLoading ? null : _shareFacebook,
                    child: Text(
                      'Share to Facebook',
                      style: TextStyle(color: AppTheme.secondaryColor),
                    ),
                  ),*/
                  if (_isLoading)
                    Center(child: AdaptiveCircularProgressIndicator())
                  else
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: appButton(
                          context: context,
                          width: 20,
                          height: 20,
                          title: 'Post',
                          titleColour: AdaptiveTheme.primaryColor(context),
                          onPressed: _isLoading ? null : _submit,
                          borderColor: AdaptiveTheme.primaryColor(context),
                          // borderRadius: 20
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
