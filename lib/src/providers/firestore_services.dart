import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../src/models/firestore/student.dart';
import '../models/firestore/adobj.dart';
import '../models/firestore/vendor_from_ads.dart';
import '/src/models/firestore/feed_alert.dart';
import '/src/models/firestore/feedpost.dart';
import '/src/models/firestore/fileobj.dart';
import '/src/models/firestore/followingparents.dart';
import '/src/models/firestore/productlist.dart';
import '/src/models/login_response.dart';
import '/src/models/firestore/feed_comment.dart';
import '/src/models/firestore/feed_like.dart';

class FirestoreServices {
  //FEEDSWALL

  static getFeedsWall2(int feedLimit) {
    final CollectionReference _feedsCollectionReference =
        FirebaseFirestore.instance.collection('posts');
    var pageFeedQuery = _feedsCollectionReference
        .where('verified', isEqualTo: true)
        .where('reported', isEqualTo: false)
        .where('deletedStatus', isEqualTo: false)
        .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
        .orderBy('scheduledDate', descending: true)
        .limit(feedLimit);
    return pageFeedQuery;
  }

  //User's feeds
  static getUserFeeds2(int feedLimit, int userId) {
    final CollectionReference _feedsCollectionReference =
        FirebaseFirestore.instance.collection('posts');
    var pageFeedQuery = _feedsCollectionReference
        .where('verified', isEqualTo: true)
        .where('reported', isEqualTo: false)
        .where('deletedStatus', isEqualTo: false)
        .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
        .where('postedUserID', isEqualTo: userId)
        .orderBy('scheduledDate', descending: true)
        .limit(feedLimit);
    return pageFeedQuery;
  }

  //User Feeds count
  static getUserFeedsCount(int userId) async {
    var count = 0;
    await FirebaseFirestore.instance
        .collection('posts')
        .where('deletedStatus', isEqualTo: false)
        .where('postedUserID', isEqualTo: userId)
        .where('verified', isEqualTo: true)
        .where('reported', isEqualTo: false)
        .get()
        .then((value) {
      count = value.size;
    });
    return count;
  }

  //FeedsWall
  static getFeedsWall() {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('deletedStatus', isEqualTo: false)
        .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
        .where('verified', isEqualTo: true)
        .where('reported', isEqualTo: false)
        .orderBy('scheduledDate', descending: true)
        .snapshots();
  }
  //TempAds

  static getTempAds() {
    return FirebaseFirestore.instance
        .collection('parentAdvertisements')
        .snapshots();
  }

  static getAds() async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('parentAdvertisements');

    // Get docs from collection reference
    QuerySnapshot querySnapshot = await collectionReference.get();

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs;
    final List<AdObj> loadedAds = [];
    if (allData.isNotEmpty) {
      for (var i = 0; i < allData.length; i++) {
        DocumentSnapshot feed = allData[i];
        AdObj adobj = AdObj.fromJson(feed.data() as Map<String, dynamic>);
        loadedAds.add(adobj);
      }
    }
    return loadedAds;
  }

  //User's feeds
  static getUserFeeds(int userId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .where('deletedStatus', isEqualTo: false)
        .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
        .where('postedUserID', isEqualTo: userId)
        .where('verified', isEqualTo: true)
        .where('reported', isEqualTo: false)
        .orderBy('scheduledDate', descending: true)
        .snapshots();
  }

//vendor profile from ads
  static getVendorProfileAd(int userId) async {
    var collection = FirebaseFirestore.instance.collection('users');

    var qs = await collection
        .where('userType', isEqualTo: 'vendor')
        .where('userID', isEqualTo: userId)
        .limit(1)
        .get();
    Map<String, dynamic>? data = null;
    for (var snapshot in qs.docs) {
      data = snapshot.data();
    }
    return data;
  }

  static getSearchedUserFeeds(String searchString) {
    // bool empty = true;
    var stream = FirebaseFirestore.instance
        .collection('posts')
        .where('deletedStatus', isEqualTo: false)
        .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
        .where('title', isEqualTo: searchString)
        .where('verified', isEqualTo: true)
        .where('reported', isEqualTo: false)
        .orderBy('scheduledDate', descending: true)
        .snapshots();
    return stream;

    // stream.isEmpty.then((value) => empty = value);

    // if (!empty) {
    //   return stream;
    // }
    // stream = FirebaseFirestore.instance
    //     .collection('posts')
    //     .where('deletedStatus', isEqualTo: false)
    //     .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
    //     .where('title', isEqualTo: searchString)
    //     //  .where('title', isGreaterThanOrEqualTo: searchString)
    //     // .where('title', isLessThan: searchString + 'z')
    //     .orderBy('scheduledDate', descending: true)
    //     .snapshots();
    // stream.isEmpty.then((value) => empty = value);

    // if (!empty) {
    //   return stream;
    // }
    // stream = FirebaseFirestore.instance
    //     .collection('posts')
    //     .where('deletedStatus', isEqualTo: false)
    //     .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
    //     .where('description', isEqualTo: searchString)
    //     // .where('description', isGreaterThanOrEqualTo: searchString)
    //     // .where('description', isLessThan: searchString + 'z')
    //     .orderBy('scheduledDate', descending: true)
    //     .snapshots();
    // stream.isEmpty.then((value) => empty = value);

    // if (!empty) {
    //   return stream;
    // } else {
    //   return null;
    // }
  }

  // static Future<List<FeedPost>> getSearchedFeeds(String searchString) async {
  //   List<FeedPost> feedPosts = await FirebaseFirestore.instance
  //       .collection('posts')
  //       .where('deletedStatus', isEqualTo: false)
  //       .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
  //       .where('postedUserName', isEqualTo: searchString)
  //       .orderBy('scheduledDate', descending: true)
  //       .snapshots()
  //       .map((snapshot) => snapshot.docs
  //           .map((document) => FeedPost.fromJson(document.data(), document))
  //           .toList())
  //       .first;
  //   if (feedPosts.isNotEmpty)
  //     return feedPosts;
  //   else {
  //     feedPosts = await FirebaseFirestore.instance
  //         .collection('posts')
  //         .where('deletedStatus', isEqualTo: false)
  //         .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
  //         .where('title', isGreaterThanOrEqualTo: searchString)
  //         .where('title', isLessThan: searchString + 'z')
  //         .orderBy('scheduledDate', descending: true)
  //         .snapshots()
  //         .map((snapshot) => snapshot.docs
  //             .map((document) => FeedPost.fromJson(document.data(), document))
  //             .toList())
  //         .first;
  //     if (feedPosts.isNotEmpty)
  //       return feedPosts;
  //     else {
  //       feedPosts = await FirebaseFirestore.instance
  //           .collection('posts')
  //           .where('deletedStatus', isEqualTo: false)
  //           .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
  //           .where('description', isGreaterThanOrEqualTo: searchString)
  //           .where('description', isLessThan: searchString + 'z')
  //           .orderBy('scheduledDate', descending: true)
  //           .snapshots()
  //           .map((snapshot) => snapshot.docs
  //               .map((document) => FeedPost.fromJson(document.data(), document))
  //               .toList())
  //           .first;
  //       if (feedPosts.isNotEmpty)
  //         return feedPosts;
  //       else
  //         return [];
  //     }
  //   }
  // }

  // static getSearchedUserFeeds1(String searchString) {
  //   return FirebaseFirestore.instance
  //       .collection('posts')
  //       .where('deletedStatus', isEqualTo: false)
  //       .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
  //       .where('postedUserName', isEqualTo: searchString)
  //       .orderBy('scheduledDate', descending: true)
  //       .get()
  //       .then((value) {
  //     if (value.size > 0) {
  //       value.docs;
  //     } else {
  //       FirebaseFirestore.instance
  //           .collection('posts')
  //           .where('deletedStatus', isEqualTo: false)
  //           .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
  //           .where('title', isGreaterThanOrEqualTo: searchString)
  //           .where('title', isLessThan: searchString + 'z')
  //           .orderBy('scheduledDate', descending: true)
  //           .get()
  //           .then((value) {
  //         if (value.size > 0) {
  //           value.docs;
  //         } else {
  //           FirebaseFirestore.instance
  //               .collection('posts')
  //               .where('deletedStatus', isEqualTo: false)
  //               .where('scheduledDate', isLessThanOrEqualTo: Timestamp.now())
  //               .where('description', isGreaterThanOrEqualTo: searchString)
  //               .where('description', isLessThan: searchString + 'z')
  //               .orderBy('scheduledDate', descending: true)
  //               .get()
  //               .then((value) {
  //             if (value.size > 0) {
  //               value.docs;
  //             } else {
  //               null;
  //             }
  //           });
  //         }
  //       });
  //     }
  //   });
  // }

  //FEEDSWALL

  //POSTS
  static Future<bool> addNewPost(FeedPost feedPost) async {
    bool retValue = false;
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('posts').doc();

    Map<String, dynamic> data = <String, dynamic>{
      'verified': false,
      'reported': false,
      'reportedReason': null,
      'achievement': feedPost.achievement,
      'categoryId': feedPost.categoryId,
      //'commentCount': feedPost.commentCount,
      'createdAt': feedPost.createdAt,
      'deleted': false,
      'deletedStatus': false,
      'description': feedPost.description,
      'discount': feedPost.discount,
      'docID': feedPost.documentId,
      'enquiryFlag': feedPost.enquiryFlag,
      'enquiryMessage': feedPost.enquiryMessage,
      'fileObj': feedPost.fileObjs == null
          ? null
          : feedPost.fileObjs!.length < 1
              ? null
              : FileObj.convertFileObjsToMap(fileObjs: feedPost.fileObjs!),
      'issuingAuthority': feedPost.issuingAuthority,
      //  'likeCount': feedPost.likeCount,
      'Liked': false,
      'moreInfo': '',
      'onlinePay': feedPost.onlinePay,
      'postType': feedPost.postType,
      'postedBy': feedPost.postedBy,
      'postedByUserCountry': feedPost.postedByUserCountry,
      'postedByUserLocation': feedPost.postedByUserLocation,
      'postedByUserState': feedPost.postedByUserState,
      'postedUserID': feedPost.postedUserID,
      'postedUserName': feedPost.postedUserName,
      'productId': feedPost.productId,
      'profileImage': feedPost.profileImage,
      'purchaseFlag':
          feedPost.purchaseFlag == null ? false : feedPost.purchaseFlag,
      'Rate': feedPost.rate,
      'scheduledDate': feedPost.scheduledDate,
      'studentDetails': feedPost.studentDetails == null
          ? null
          : feedPost.studentDetails!.length < 1
              ? null
              : Student.convertStudentsToMap(
                  studentList: feedPost.studentDetails!),
      'team': feedPost.team,
      'title': feedPost.title,
      'updatedAt': feedPost.updatedAt,
      'productList': feedPost.productList == null
          ? null
          : feedPost.productList!.length < 1
              ? null
              : Product.convertProductListsToMap(
                  productLists: feedPost.productList!),
    };
    await documentReference
        .set(data)
        .whenComplete(() => retValue = true)
        .catchError((error) {
      //String er = error.toString();
      // print("Failed to add post: $er");
    });
    //   //   .catchError((e) {
    //   // print(e.toString());
    //   // retValue = false;
    // });

    FeedAlert feedAlert = FeedAlert(
      countryName: feedPost.postedByUserCountry,
      createdAt: feedPost.createdAt,
      imageUrl: feedPost.profileImage,
      locationName: feedPost.postedByUserLocation,
      message: '${feedPost.postedUserName} has shared a new feed',
      name: feedPost.postedUserName,
      parentID: feedPost.postedUserID,
      readStatus: false,
      stateName: feedPost.postedByUserState,
      type: 5, //TODO:: It is hardcoded as per document, don't know the value
    );
    //retValue = await addAlert(feedAlert);
    await addAlert(feedAlert);
    return retValue;
  }

  //POSTS

  //PARENT BLOCKING

  static isUserBlocked(int masterUserId, int followingUserId) {
    return FirebaseFirestore.instance
        .collection('parentBlocking')
        .doc('$masterUserId')
        .collection("blocked")
        .where('userID', isEqualTo: followingUserId)
        .snapshots();
  }

  static isUserBlockedAnyOne(int masterUserId) {
    return FirebaseFirestore.instance
        .collection('parentBlocking')
        .doc('$masterUserId')
        .collection("blocked")
        .snapshots();
  }

  static Future<bool> blockParent(FeedPost? feedPost,
      FollowingParents? followingParent, LoginResponse loginResponse) async {
    bool retValue = false;
    if (feedPost == null) {
      final snapshot =
          await FirebaseFirestore.instance.collection('parentBlocking').get();
      if (snapshot.docs.length == 0) {
        DocumentReference documentReference1 = FirebaseFirestore.instance
            .collection('parentBlocking')
            .doc('${loginResponse.b2cParent!.parentID}');
        await documentReference1.set(null);
      }
      //initiated user
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('parentBlocking')
          .doc('${loginResponse.b2cParent!.parentID}')
          .collection("blocked")
          .doc('${followingParent!.userID}');

      Map<String, dynamic> data1 = <String, dynamic>{
        'userID': followingParent.userID,
      };
      await documentReference
          .set(data1)
          .whenComplete(() => retValue = true)
          .catchError((e) => retValue = false);
      //followed user
      DocumentReference documentReference2 = FirebaseFirestore.instance
          .collection('parentBlocking')
          .doc('${followingParent.userID}')
          .collection("blocked")
          .doc('${loginResponse.b2cParent!.parentID}');

      Map<String, dynamic> data2 = <String, dynamic>{
        'userID': loginResponse.b2cParent!.parentID,
      };
      await documentReference2
          .set(data2)
          .whenComplete(() => retValue = true)
          .catchError((e) => retValue = false);
      return retValue;
    } else {
      final snapshot =
          await FirebaseFirestore.instance.collection('parentBlocking').get();
      if (snapshot.docs.length == 0) {
        DocumentReference documentReference1 = FirebaseFirestore.instance
            .collection('parentBlocking')
            .doc('${loginResponse.b2cParent!.parentID}');
        await documentReference1.set(null);
      }
      //initiated user
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('parentBlocking')
          .doc('${loginResponse.b2cParent!.parentID}')
          .collection("blocked")
          .doc('${feedPost.postedUserID}');

      Map<String, dynamic> data1 = <String, dynamic>{
        'userID': feedPost.postedUserID,
      };
      await documentReference
          .set(data1)
          .whenComplete(() => retValue = true)
          .catchError((e) => retValue = false);
      //followed user
      DocumentReference documentReference2 = FirebaseFirestore.instance
          .collection('parentBlocking')
          .doc('${feedPost.postedUserID}')
          .collection("blocked")
          .doc('${loginResponse.b2cParent!.parentID}');

      Map<String, dynamic> data2 = <String, dynamic>{
        'userID': loginResponse.b2cParent!.parentID,
      };
      await documentReference2
          .set(data2)
          .whenComplete(() => retValue = true)
          .catchError((e) => retValue = false);
      return retValue;
    }
  }

  static Future<bool> unBlockParent(FeedPost? feedPost,
      FollowingParents? masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    if (feedPost == null) {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('parentBlocking')
          .doc('${loginResponse.b2cParent!.parentID}')
          .collection("blocked")
          .doc('${masterUser!.userID}');
      await documentReference
          .delete()
          .whenComplete(() => retValue = true)
          .catchError((e) => retValue = false);
      return retValue;
    } else {
      DocumentReference documentReference = FirebaseFirestore.instance
          .collection('parentBlocking')
          .doc('${loginResponse.b2cParent!.parentID}')
          .collection("blocked")
          .doc('${feedPost.postedUserID}');
      await documentReference
          .delete()
          .whenComplete(() => retValue = true)
          .catchError((e) => retValue = false);
      return retValue;
    }
  }

  //PARENT BLOCKING
  //PRODUCTS

  static getProductsWall(String searchString) {
    var stream = FirebaseFirestore.instance
        .collection('products')
        .where('deleted', isEqualTo: false)
        .where('title', isEqualTo: searchString)
        .orderBy('createdAt', descending: true)
        .snapshots();
    return stream;
  }

  static getProductsofVendor(int vendorID) {
    var stream = FirebaseFirestore.instance
        .collection('products')
        .where('deleted', isEqualTo: false)
        .where('vendorID', isEqualTo: vendorID)
        .orderBy('createdAt', descending: true)
        .snapshots();
    return stream;
  }
  //PRODUCTS

  //ALERTS
  static Future<bool> addAlert(FeedAlert feedAlert) async {
    bool retValue = false;
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection('alerts').doc();

    Map<String, dynamic> data = <String, dynamic>{
      'countryName': feedAlert.countryName,
      'createdAt': feedAlert.createdAt,
      'imageUrl': feedAlert.imageUrl,
      'locationName': feedAlert.locationName,
      'message': feedAlert.message,
      'name': feedAlert.name,
      'parentID': feedAlert.parentID,
      'readStatus': feedAlert.readStatus,
      'stateName': feedAlert.stateName,
      'type': feedAlert.type,
    };
    await documentReference
        .set(data)
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);

    return retValue;
  }
  //ALERTS

  //COMMENTS
  //Get comments
  static getComments(String feedId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(feedId)
        .collection('Comments')
        .where('reported', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  //Add comments
  static Future<bool> addComment(FeedComment feedComment) async {
    bool retValue = false;
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('posts')
        .doc(feedComment.feedId)
        .collection('Comments')
        .doc();

    Map<String, dynamic> data = <String, dynamic>{
      'comments': feedComment.comments,
      'createdAt': feedComment.createdAt,
      'userId': feedComment.userId,
      'userImage': feedComment.userImage,
      'userName': feedComment.userName,
      'reported': false,
      'reportedReason': null,
      'reportedUserID': null,
    };
    await documentReference
        .set(data)
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);
    // await _updateCommentCount(feedComment.feedId);
    return retValue;
  }

  //Update comments count
  /*static Future<void> _updateCommentCount(String feedId) async {
    DocumentReference postDocRef =
        FirebaseFirestore.instance.collection('posts').doc(feedId);
    postDocRef.update({
      "commentCount": FieldValue.increment((1)),
    });
  }*/

  //COMMENTS

  //LIKES
  //Add likes
  static Future<bool> doLike(FeedLike feedLike) async {
    bool retValue = false;
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('posts')
        .doc(feedLike.feedId)
        .collection('Likes')
        .doc();
    Map<String, dynamic> data = <String, dynamic>{
      'createdAt': feedLike.createdAt,
      'userId': feedLike.userId,
      'userImage': feedLike.userImage,
      'userName': feedLike.userName,
    };
    await documentReference
        .set(data)
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);
    // await _updateLikeCount(feedLike.feedId, true);
    return retValue;
  }

  //Delete Likes
  static Future<bool> undoLike(FeedLike feedLike) async {
    bool retValue = false;
    var collection = FirebaseFirestore.instance
        .collection('posts')
        .doc(feedLike.feedId)
        .collection('Likes');

    var snapshot =
        await collection.where('userId', isEqualTo: feedLike.userId).get();
    await snapshot.docs.first.reference
        .delete()
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);
    //await _updateLikeCount(feedLike.feedId, false);
    return retValue;
  }

  // static Future<void> _updateLikeCount(String feedId, bool liked) async {
  //   DocumentReference postDocRef =
  //       FirebaseFirestore.instance.collection('posts').doc(feedId);
  //   postDocRef.update({
  //     "likeCount": FieldValue.increment(
  //       (liked ? (1) : (-1)),
  //     ),
  //   });
  // }

  static isUserLiked(FeedLike feedLike) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(feedLike.feedId)
        .collection('Likes')
        .where('userId', isEqualTo: feedLike.userId)
        .snapshots();
  }

  static likedCount(FeedLike feedLike) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(feedLike.feedId)
        .collection('Likes')
        .snapshots();
  }

  static commentCount(FeedLike feedLike) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(feedLike.feedId)
        .collection('Comments')
        .where('reported', isEqualTo: false)
        .snapshots();
  }

  //LIKES
  //REPORT ABUSE
  static Future<bool> updateReportedStatus(
      String feedId, int reportedReason) async {
    bool retValue = false;
    DocumentReference postDocRef =
        await FirebaseFirestore.instance.collection('posts').doc(feedId);
    await postDocRef
        .update({
          "reported": true,
        })
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);
    await postDocRef
        .update({
          "reportedReason": reportedReason,
        })
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);
    return retValue;
  }

  static Future<bool> updateCommentReportedStatus(
    String feedId,
    int reportedReason,
    int feedUserID,
    int reportedUserID,
  ) async {
    bool retValue = false;
    var collection = FirebaseFirestore.instance
        .collection('posts')
        .doc(feedId)
        .collection('Comments');

    var snapshot = await collection
        .where('userId', isEqualTo: feedUserID)
        .where('reported', isEqualTo: false)
        .get();
    await snapshot.docs.first.reference
        .update({
          "reported": true,
          "reportedReason": reportedReason,
          "reportedUserID": reportedUserID,
        })
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);
    /*DocumentReference postDocRef =
    FirebaseFirestore.instance.collection('posts').doc(feedId);*/
    /*postDocRef.update({
      "commentCount": FieldValue.increment((-1)),
    });*/

    return retValue;
  }

  //REPORT ABUSE
  //FOLLOWERS AND FOLLOWING
  //ParentFollowingList
  static getFollowingParents(int ParentID) {
    //print(ParentID);
    return FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc("$ParentID")
        . // "40964" - use this to get data
        collection("following")
        .where('userType', isEqualTo: "parent")
        .snapshots();
  }

  //ParentFollowersList
  static getFollowersParents(int ParentID) {
    //print(ParentID);
    return FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc("$ParentID")
        . // "40964" - use this to get data
        collection("followers")
        .where('userType', isEqualTo: "parent")
        .snapshots();
  }

  //Check whether the parent is following or not
  static isUserFollowing(int masterUserId, int followingUserId) {
    return FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('$masterUserId')
        .collection("followers")
        .where('userID', isEqualTo: followingUserId)
        .snapshots();
  }

  static Future<bool> doFollow(
      FeedPost masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    DocumentReference documentReference1 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${masterUser.postedUserID}')
        .collection("followers")
        .doc('${loginResponse.b2cParent!.parentID}');
    // .doc('parent_${loginResponse.b2cParent!.parentID}');

    Map<String, dynamic> data1 = <String, dynamic>{
      'city': loginResponse.b2cParent!.location,
      'country': loginResponse.b2cParent!.country,
      'createdAt': DateTime.now(),
      'state': loginResponse.b2cParent!.state,
      'userID': loginResponse.b2cParent!.parentID,
      'userImage': loginResponse.b2cParent!.profileImage,
      'userName': loginResponse.b2cParent!.name,
      'userType':
          'parent' //TODO::: THIS NEEDS TO BE CHECKED //loginResponse.userType,
    };
    await documentReference1.set(data1).catchError((e) => retValue = false);

    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${loginResponse.b2cParent!.parentID}')
        .collection("following")
        .doc('parent_' + '${masterUser.postedUserID}');
    // .doc('parent_${loginResponse.b2cParent!.parentID}');

    Map<String, dynamic> data2 = <String, dynamic>{
      'city': masterUser.postedByUserLocation,
      'country': masterUser.postedByUserCountry,
      'createdAt': DateTime.now(),
      'state': masterUser.postedByUserState,
      'userID': masterUser.postedUserID,
      'userImage': masterUser.profileImage,
      'userName': masterUser.postedUserName,
      'userType':
          'parent' //TODO::: THIS NEEDS TO BE CHECKED //loginResponse.userType,
    };
    await documentReference2
        .set(data2)
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);

    return retValue;
  }

  static Future<bool> undoFollow(
      FeedPost masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${masterUser.postedUserID}')
        .collection("followers")
        .doc('${loginResponse.b2cParent!.parentID}');
    //.doc('parent_${loginResponse.b2cParent!.parentID}');
    await documentReference.delete().catchError((e) => retValue = false);
    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${loginResponse.b2cParent!.parentID}')
        .collection("following")
        .doc('parent_' + '${masterUser.postedUserID}');
    //.doc('parent_${loginResponse.b2cParent!.parentID}');
    await documentReference2
        .delete()
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);
    return retValue;
  }

  //FOLLOWERS AND FOLLOWING

  //MODIFIED FOLLOWERS AND FOLLOWING
  static Future<bool> doFollowNew(
      FollowingParents masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    DocumentReference documentReference1 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${masterUser.userID}')
        .collection("followers")
        .doc('${loginResponse.b2cParent!.parentID}');
    // .doc('parent_${loginResponse.b2cParent!.parentID}');

    Map<String, dynamic> data1 = <String, dynamic>{
      'city': loginResponse.b2cParent!.location,
      'country': loginResponse.b2cParent!.country,
      'createdAt': DateTime.now(),
      'state': loginResponse.b2cParent!.state,
      'userID': loginResponse.b2cParent!.parentID,
      'userImage': loginResponse.b2cParent!.profileImage,
      'userName': loginResponse.b2cParent!.name,
      'userType':
          'parent' //TODO::: THIS NEEDS TO BE CHECKED //loginResponse.userType,
    };
    await documentReference1.set(data1).catchError((e) => retValue = false);

    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${loginResponse.b2cParent!.parentID}')
        .collection("following")
        .doc('parent_' + '${masterUser.userID}');
    // .doc('parent_${loginResponse.b2cParent!.parentID}');

    Map<String, dynamic> data2 = <String, dynamic>{
      'city': masterUser.city,
      'country': masterUser.country,
      'createdAt': DateTime.now(),
      'state': masterUser.state,
      'userID': masterUser.userID,
      'userImage': masterUser.userImage,
      'userName': masterUser.userName,
      'userType':
          'parent' //TODO::: THIS NEEDS TO BE CHECKED //loginResponse.userType,
    };
    await documentReference2
        .set(data2)
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);

    return retValue;
  }

  static Future<bool> undoFollowNew(
      FollowingParents masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${masterUser.userID}')
        .collection("followers")
        .doc('${loginResponse.b2cParent!.parentID}');
    //.doc('parent_${loginResponse.b2cParent!.parentID}');
    await documentReference.delete().catchError((e) => retValue = false);
    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${loginResponse.b2cParent!.parentID}')
        .collection("following")
        .doc('parent_${masterUser.userID}');
    //.doc('parent_${loginResponse.b2cParent!.parentID}');
    await documentReference2
        .delete()
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);

    return retValue;
  }
  // REMOVE AND UNREMOVE FOR FOLLOWERS

  //Check whether the parent is follower or not
  static isUserFollower(int masterUserId, int followingUserId) {
    return FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('$masterUserId')
        .collection("following")
        .where('userID', isEqualTo: followingUserId)
        .snapshots();
  }

  static Future<bool> doRemoveFollowers(
      FollowingParents masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${masterUser.userID}')
        .collection("following")
        .doc('parent_${loginResponse.b2cParent!.parentID}');
    //.doc('parent_${loginResponse.b2cParent!.parentID}');
    await documentReference.delete().catchError((e) => retValue = false);
    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${loginResponse.b2cParent!.parentID}')
        .collection("followers")
        .doc('${masterUser.userID}');
    //.doc('parent_${loginResponse.b2cParent!.parentID}');
    await documentReference2
        .delete()
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);

    return retValue;
  }

  static Future<bool> undoRemove(
      FollowingParents masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    DocumentReference documentReference1 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${masterUser.userID}')
        .collection("following")
        .doc('parent_${loginResponse.b2cParent!.parentID}');
    // .doc('parent_${loginResponse.b2cParent!.parentID}');

    Map<String, dynamic> data1 = <String, dynamic>{
      'city': loginResponse.b2cParent!.location,
      'country': loginResponse.b2cParent!.country,
      'createdAt': DateTime.now(),
      'state': loginResponse.b2cParent!.state,
      'userID': loginResponse.b2cParent!.parentID,
      'userImage': loginResponse.b2cParent!.profileImage,
      'userName': loginResponse.b2cParent!.name,
      'userType':
          'parent' //TODO::: THIS NEEDS TO BE CHECKED //loginResponse.userType,
    };
    await documentReference1.set(data1).catchError((e) => retValue = false);

    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${loginResponse.b2cParent!.parentID}')
        .collection("followers")
        .doc('${masterUser.userID}');
    // .doc('parent_${loginResponse.b2cParent!.parentID}');

    Map<String, dynamic> data2 = <String, dynamic>{
      'city': masterUser.city,
      'country': masterUser.country,
      'createdAt': DateTime.now(),
      'state': masterUser.state,
      'userID': masterUser.userID,
      'userImage': masterUser.userImage,
      'userName': masterUser.userName,
      'userType':
          'parent' //TODO::: THIS NEEDS TO BE CHECKED //loginResponse.userType,
    };
    await documentReference2
        .set(data2)
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);

    return retValue;
  }

  //FOLLOWING VENDORS LIST

  static getFollowingVendors(int ParentID) {
    //print(ParentID);
    return FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc("$ParentID")
        . // "40964" - use this to get data
        collection("following")
        .where('userType', isEqualTo: "vendor")
        .snapshots();
  }

  static getFollowersVendors(int ParentID) {
    //print(ParentID);
    return FirebaseFirestore.instance
        .collection('vendorFollowers')
        .doc("$ParentID")
        . // "40964" - use this to get data
        collection("followers")
        .snapshots();
  }

  //VENDOR FOLLOW UNFOLLOW FUNCTION
//TODO::: THIS NEEDS TO BE Merged

  static Future<bool> doFollowNewVendor(
      FollowingParents masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    DocumentReference documentReference1 = FirebaseFirestore.instance
        .collection('vendorFollowers')
        .doc('${masterUser.userID}')
        .collection("followers")
        .doc('${loginResponse.b2cParent!.parentID}');
    // .doc('parent_${loginResponse.b2cParent!.parentID}');

    Map<String, dynamic> data1 = <String, dynamic>{
      'city': loginResponse.b2cParent!.location,
      'country': loginResponse.b2cParent!.country,
      'createdAt': DateTime.now(),
      'state': loginResponse.b2cParent!.state,
      'parentID': loginResponse.b2cParent!.parentID,
      'parentImage': loginResponse.b2cParent!.profileImage,
      'parentName': loginResponse.b2cParent!.name,
    };
    await documentReference1.set(data1).catchError((e) => retValue = false);

    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${loginResponse.b2cParent!.parentID}')
        .collection("following")
        .doc('vendor_' + '${masterUser.userID}');
    // .doc('parent_${loginResponse.b2cParent!.parentID}');

    Map<String, dynamic> data2 = <String, dynamic>{
      'city': masterUser.city,
      'country': masterUser.country,
      'createdAt': DateTime.now(),
      'state': masterUser.state,
      'userID': masterUser.userID,
      'userImage': masterUser.userImage,
      'userName': masterUser.userName,
      'userType':
          'vendor' //TODO::: THIS NEEDS TO BE CHECKED //loginResponse.userType,
    };
    await documentReference2
        .set(data2)
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);

    return retValue;
  }

  static Future<bool> doFollowNewVendor2(
      AdVendorProfile masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    DocumentReference documentReference1 = FirebaseFirestore.instance
        .collection('vendorFollowers')
        .doc('${masterUser.userID}')
        .collection("followers")
        .doc('${loginResponse.b2cParent!.parentID}');
    // .doc('parent_${loginResponse.b2cParent!.parentID}');

    Map<String, dynamic> data1 = <String, dynamic>{
      'city': loginResponse.b2cParent!.location,
      'country': loginResponse.b2cParent!.country,
      'createdAt': DateTime.now(),
      'state': loginResponse.b2cParent!.state,
      'parentID': loginResponse.b2cParent!.parentID,
      'parentImage': loginResponse.b2cParent!.profileImage,
      'parentName': loginResponse.b2cParent!.name,
    };
    await documentReference1.set(data1).catchError((e) => retValue = false);

    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${loginResponse.b2cParent!.parentID}')
        .collection("following")
        .doc('vendor_' + '${masterUser.userID}');
    // .doc('parent_${loginResponse.b2cParent!.parentID}');

    Map<String, dynamic> data2 = <String, dynamic>{
      'city': masterUser.city,
      'country': masterUser.country,
      'createdAt': DateTime.now(),
      'state': masterUser.state,
      'userID': masterUser.userID,
      'userImage': masterUser.userImage,
      'userName': masterUser.userName,
      'userType':
          'vendor' //TODO::: THIS NEEDS TO BE CHECKED //loginResponse.userType,
    };
    await documentReference2
        .set(data2)
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);

    return retValue;
  }

  static Future<bool> undoFollowNewVendor(
      FollowingParents masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('vendorFollowers')
        .doc('${masterUser.userID}')
        .collection("followers")
        .doc('${loginResponse.b2cParent!.parentID}');
    //.doc('parent_${loginResponse.b2cParent!.parentID}');
    await documentReference.delete().catchError((e) => retValue = false);
    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${loginResponse.b2cParent!.parentID}')
        .collection("following")
        .doc('vendor_${masterUser.userID}');
    //.doc('parent_${loginResponse.b2cParent!.parentID}');
    await documentReference2
        .delete()
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);

    return retValue;
  }

  static Future<bool> undoFollowNewVendor2(
      AdVendorProfile masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('vendorFollowers')
        .doc('${masterUser.userID}')
        .collection("followers")
        .doc('${loginResponse.b2cParent!.parentID}');
    //.doc('parent_${loginResponse.b2cParent!.parentID}');
    await documentReference.delete().catchError((e) => retValue = false);
    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${loginResponse.b2cParent!.parentID}')
        .collection("following")
        .doc('vendor_${masterUser.userID}');
    //.doc('parent_${loginResponse.b2cParent!.parentID}');
    await documentReference2
        .delete()
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);

    return retValue;
  }

  static Future<bool> doFollowVendor(
      FeedPost masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    DocumentReference documentReference1 = FirebaseFirestore.instance
        .collection('vendorFollowers')
        .doc('${masterUser.postedUserID}')
        .collection("followers")
        .doc('${loginResponse.b2cParent!.parentID}');
    // .doc('parent_${loginResponse.b2cParent!.parentID}');

    Map<String, dynamic> data1 = <String, dynamic>{
      'city': loginResponse.b2cParent!.location,
      'country': loginResponse.b2cParent!.country,
      'createdAt': DateTime.now(),
      'state': loginResponse.b2cParent!.state,
      'parentID': loginResponse.b2cParent!.parentID,
      'parentImage': loginResponse.b2cParent!.profileImage,
      'parentName': loginResponse.b2cParent!.name,
    };
    await documentReference1.set(data1).catchError((e) => retValue = false);

    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${loginResponse.b2cParent!.parentID}')
        .collection("following")
        .doc('vendor_' + '${masterUser.postedUserID}');
    // .doc('parent_${loginResponse.b2cParent!.parentID}');

    Map<String, dynamic> data2 = <String, dynamic>{
      'city': masterUser.postedByUserLocation,
      'country': masterUser.postedByUserCountry,
      'createdAt': DateTime.now(),
      'state': masterUser.postedByUserState,
      'userID': masterUser.postedUserID,
      'userImage': masterUser.profileImage,
      'userName': masterUser.postedUserName,
      'userType':
          'vendor' //TODO::: THIS NEEDS TO BE CHECKED //loginResponse.userType,
    };
    await documentReference2
        .set(data2)
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);

    return retValue;
  }

  static Future<bool> undoFollowVendor(
      FeedPost masterUser, LoginResponse loginResponse) async {
    bool retValue = false;
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('vendorFollowers')
        .doc('${masterUser.postedUserID}')
        .collection("followers")
        .doc('${loginResponse.b2cParent!.parentID}');
    //.doc('parent_${loginResponse.b2cParent!.parentID}');
    await documentReference.delete().catchError((e) => retValue = false);
    DocumentReference documentReference2 = FirebaseFirestore.instance
        .collection('parentFollowers')
        .doc('${loginResponse.b2cParent!.parentID}')
        .collection("following")
        .doc('vendor_${masterUser.postedUserID}');
    //.doc('parent_${loginResponse.b2cParent!.parentID}');
    await documentReference2
        .delete()
        .whenComplete(() => retValue = true)
        .catchError((e) => retValue = false);

    return retValue;
  }

  static isVendorFollowing(int masterUserId, int followingUserId) {
    return FirebaseFirestore.instance
        .collection('vendorFollowers')
        .doc('$masterUserId')
        .collection("followers")
        .where('parentID', isEqualTo: followingUserId)
        .snapshots();
  }
}
