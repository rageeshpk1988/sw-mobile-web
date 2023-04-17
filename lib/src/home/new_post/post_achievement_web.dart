import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../../helpers/global_variables.dart';

import '../../../../src/models/achievement_category.dart';
import '../../../../src/models/child.dart';

import '../../../adaptive/adaptive_circular_progressInd.dart';

import '../../../adaptive/adaptive_theme.dart';
import '../../../util/app_theme_cupertino.dart';
import '../../../util/ui_helpers.dart';
import '/helpers/app_info.dart';
import '/src/models/firestore/feedpost.dart';
import '/src/models/login_response.dart';
import '/src/profile/widgets/child_list_item_circle_avatar.dart';
import '/src/providers/auth.dart';
import '/src/providers/feed_posts.dart';
import '/util/dialogs.dart';

import '/util/app_theme.dart';

import 'post_image_picker_web.dart';

//TODO:This is a new screen with new image picker need to test and approve
class PostAchievementWeb extends StatefulWidget {
  const PostAchievementWeb({Key? key}) : super(key: key);

  @override
  _PostAchievementWebState createState() => _PostAchievementWebState();
}

class _PostAchievementWebState extends State<PostAchievementWeb> {
  final _formKey = GlobalKey<FormState>();
  bool isTeam = false;
  bool fb = false;
  final _titleFocusNode = FocusNode();
  final _achievementFocusNode = FocusNode();
  final _issuingAuthorityFocusNode = FocusNode();
  final _detailsFocusNode = FocusNode();
  final _categoryFocusNode = FocusNode();
  var _selectedCategory = 0;
  List<DropdownMenuItem<int>> _categoryList = [];

  final Map<String, String> _dataFields = {
    'title': '',
    'achievement': '',
    'description': '',
    'issuingAuthority': '',
    // 'team': '',
    // 'category': '',
  };
  List<File> _imageFiles = [];
  List<File> _videoFiles = [];
  List<File> _allFiles =
      []; // this is the combination of images and video as per the selected order

  List<Child> _children = [];
  bool _isInIt = true;
  bool _isLoading = false;
  bool _categoryIsSelectedOnSubmit = true;
  @override
  void dispose() {
    _titleFocusNode.dispose();
    _detailsFocusNode.dispose();
    _achievementFocusNode.dispose();
    _issuingAuthorityFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _titleFocusNode.addListener(_onOnFocusNodeEvent);
    _detailsFocusNode.addListener(_onOnFocusNodeEvent);
    _achievementFocusNode.addListener(_onOnFocusNodeEvent);
    _issuingAuthorityFocusNode.addListener(_onOnFocusNodeEvent);
    _categoryFocusNode.addListener(_onOnFocusNodeEvent);
  }

  _onOnFocusNodeEvent() {
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    if (_isInIt) {
      setState(() {
        _isLoading = true;
      });

      var _loginResponse =
          Provider.of<Auth>(context, listen: false).loginResponse;
      Provider.of<FeedPosts>(context, listen: false)
          .fetchAchievementCategories(_loginResponse.b2cParent!.parentID)
          .then((value) {
        setState(() {
          _categoryList = value
              .map((AchievementCategory val) => DropdownMenuItem<int>(
                    child: Text(val.achievementCategory),
                    value: val.achievementCategoryId,
                  ))
              .toList();
          _categoryList.insert(
              0,
              DropdownMenuItem<int>(
                child: const Text('Select Category'),
                value: 0,
              ));
          _selectedCategory = _categoryList.first.value!;

          _isLoading = false;
        });
      });
    }
    _isInIt = false;
    super.didChangeDependencies();
  }

  void addChild(Child child) {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _children.add(child);
    });
  }

  void removeChild(Child child) {
    FocusScope.of(context).requestFocus(FocusNode());
    setState(() {
      _children.removeWhere((element) => element.childID == child.childID);
    });
  }

  void saveImage(File selectedImage) {
    setState(() {
      _imageFiles.add(selectedImage);
      _allFiles.add(selectedImage);
    });
    setState(() {});
  }

  Future<void> saveImageMultiple(List<XFile> selectedImages) async {
    setState(() {
      for (var file in selectedImages) {
        _imageFiles.add(File(file.path));
        _allFiles.add(File(file.path));
      }
    });
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

    if (_selectedCategory == 0) {
      _categoryIsSelectedOnSubmit = false;
      setState(() {});
      return;
    }

    if (!isValid) return;
    if (isValid) {
      if (_selectedCategory == 0) {
        _categoryIsSelectedOnSubmit = false;
        setState(() {});
        return;
      }
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
    if (_children.length < 1) {
      await Dialogs()
          .ackInfoAlert(context, 'Please tag one or more child to the post');
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
      achievement: _dataFields['achievement'],
      categoryId: _selectedCategory.toString(),
      issuingAuthority: _dataFields['issuingAuthority'],
      description: _dataFields['description'],
      team: isTeam,
      postedUserID: _loginResponse.b2cParent!.parentID,
      postedByUserCountry: _loginResponse.b2cParent!.country,
      postedByUserLocation: _loginResponse.b2cParent!.location,
      postedByUserState: _loginResponse.b2cParent!.state,
      postedUserName: _loginResponse.b2cParent!.name,
      profileImage: _loginResponse.b2cParent!.profileImage,
    );

    try {
      var _inserted = await Provider.of<FeedPosts>(context, listen: false)
          .addNewPost(FeedPostType.ACHIEVEMENT, feedPost, _packageInfo.version,
              _imageFiles, _videoFiles, _allFiles, null, _children, fb);
      if (_inserted) {
        setState(() {
          _isLoading = false;
        });

        await Dialogs().ackSuccessAlert(context, 'SUCCESS!!!',
            'Your Post has been received successfully. It will be visible on the wall after review! ');
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

    final _loginResponse =
        Provider.of<Auth>(context, listen: false).loginResponse;
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Post an Achievement',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                //TITLE
                TextFormField(
                  enabled: !_isLoading,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  style: _textViewStyle,
                  decoration: AdaptiveTheme.textFormFieldDecoration(
                    context,
                    screenWidth(context) > 400
                        ? 'Title (maximum 50 characters)'
                        : 'Title (max. 50 chars)',
                    _titleFocusNode,
                  ),
                  textInputAction: TextInputAction.next,
                  focusNode: _titleFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_achievementFocusNode);
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
                const SizedBox(height: 5),
                //ACHIEVEMENT
                TextFormField(
                  enabled: !_isLoading,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  style: _textViewStyle,
                  decoration: AdaptiveTheme.textFormFieldDecoration(
                      context,
                      screenWidth(context) > 400
                          ? 'Achievement (maximum 50 characters)'
                          : 'Achievement (max. 50 chars)',
                      _achievementFocusNode),
                  textInputAction: TextInputAction.next,
                  focusNode: _achievementFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_detailsFocusNode);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please provide the achievement";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _dataFields['achievement'] = value!;
                  },
                ),
                //ACHIEVEMENT
                const SizedBox(height: 5),
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
                      screenWidth(context) > 400
                          ? 'Description (maximum 500 characters)'
                          : 'Description (max. 500 chars)',
                      _detailsFocusNode),
                  textInputAction: TextInputAction.newline,
                  focusNode: _detailsFocusNode,
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: 5,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context)
                        .requestFocus(_issuingAuthorityFocusNode);
                  },
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
                const SizedBox(height: 5),
                //ISSUING AUTHORITY
                TextFormField(
                  enabled: !_isLoading,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(50),
                  ],
                  style: _textViewStyle,
                  decoration: AdaptiveTheme.textFormFieldDecoration(
                      context,
                      screenWidth(context) > 400
                          ? 'Issuing Authority (maximum 50 characters)'
                          : 'Issuing Authority (max. 50 chars)',
                      _issuingAuthorityFocusNode),
                  textInputAction: TextInputAction.next,
                  focusNode: _issuingAuthorityFocusNode,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_categoryFocusNode);
                  },
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please mention the Issuing authority";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _dataFields['issuingAuthority'] = value!;
                  },
                ),
                //ISSUING AUTHORITY
                const SizedBox(height: 5),
                //CATEGORY
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  //height: 90,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1, color: Colors.grey),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 1.0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: _categoryList.length <= 1
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: const Text(
                                      'Categories are not available'),
                                )
                              : DropdownButtonHideUnderline(
                                  child: DropdownButton(
                                    isDense: true,
                                    focusNode: _categoryFocusNode,
                                    //hint: Text('Select a category'),
                                    //focusColor: Colors.black,
                                    style: TextStyle(
                                        fontSize: screenWidth(context) > 400
                                            ? 16
                                            : 14,
                                        color: _selectedCategory == 0
                                            ? Colors.grey
                                            : Colors.black),
                                    iconSize: 40,
                                    value: _selectedCategory,
                                    items: _categoryList,
                                    onChanged: _isLoading
                                        ? null
                                        : (value) {
                                            setState(() {
                                              _selectedCategory = value as int;
                                              FocusScope.of(context)
                                                  .requestFocus(FocusNode());
                                            });
                                          },
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                //CATEGORY
                if (_formKey.currentState != null)
                  // if (_formKey.currentState!.validate() == true)
                  if (_selectedCategory == 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 5.0),
                      child: Text(
                        _categoryIsSelectedOnSubmit == false
                            ? 'Select category'
                            : '',
                        style: TextStyle(
                            color: Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                const SizedBox(height: 5),
                //TEAM
                Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: Row(
                    children: [
                      Text(
                        'Team',
                        style: _textViewStyle.copyWith(
                            fontSize: 16, fontWeight: FontWeight.w300),
                      ),
                      Switch(
                        value: isTeam,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(() {
                                  isTeam = value;
                                });
                              },
                        activeTrackColor: Colors.grey,
                        activeColor: AppTheme.secondaryColor,
                      ),
                    ],
                  ),
                ),
                //TEAM
                //IMAGE PICKER
                Padding(
                  padding: const EdgeInsets.only(left: 2.0),
                  child: PostImagePickerWeb(saveImage, removeImage, saveVideo,
                      removeVideo, saveImageMultiple, _isLoading),
                ),
                //IMAGE PICKER
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.fromLTRB(5.0, 8.0, 8.0, 8.0),
                  child: Text(
                    "Who's Achievement",
                    style: _textViewStyle.copyWith(
                        fontSize: 16, fontWeight: FontWeight.w300),
                  ),
                ),
                const SizedBox(height: 10),
                //STUDENTS LIST
                Container(
                  height: 100,
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: ListView.builder(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: ScrollPhysics(),
                      itemCount: _loginResponse.b2cParent!.childDetails!.length,
                      itemBuilder: (BuildContext context, int i) {
                        return Row(
                          children: [
                            ChildListItemCircleAvatar(
                                _loginResponse.b2cParent!.childDetails![i],
                                addChild,
                                removeChild,
                                _isLoading),
                            const SizedBox(width: 20),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                //STUDENTS LIST

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
                      maxFontSize: 14,
                      maxLines: 4,
                      minFontSize: 13,
                      stepGranularity: 1,
                    ),
                  ),
                ),

                if (_isLoading)
                  Center(child: AdaptiveCircularProgressIndicator())
                else
                  Row(
                    mainAxisAlignment: screenWidth(context) > 400
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        width: 150,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: appButton(
                            context: context,
                            width: 20,
                            height: 20,
                            title: 'Post',
                            titleColour: AdaptiveTheme.primaryColor(context),
                            onPressed: _submit,
                            borderColor: AdaptiveTheme.primaryColor(context),
                            //borderRadius: 20
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
