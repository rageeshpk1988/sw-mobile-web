import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/webviews/webview_shop_web.dart';
import '../../../../src/models/child_skill.dart';
import '../../../../src/providers/child_skill_enrichment.dart';
import '../../../../util/date_util.dart';

import '../../../../adaptive/adaptive_theme.dart';
import '../../../../helpers/constants.dart';
import '../../../../helpers/route_arguments.dart';
import '../../../../webviews/webview_shop.dart';
import '../../../../util/dialogs.dart';
import '../../../../util/ui_helpers.dart';
import '../../../login/screens/login_with_pass.dart';
import '../../../models/ad_response.dart';
import '../../../models/socialaccesstoken_response.dart';
import '../../../providers/auth.dart';

class SkillEnrichmentItem extends StatefulWidget {
  final ChildSkillAssessment assessment;

  SkillEnrichmentItem(this.assessment);

  @override
  _SkillEnrichmentItemState createState() => _SkillEnrichmentItemState();
}

class _SkillEnrichmentItemState extends State<SkillEnrichmentItem> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: <Widget>[
          ListTile(
            onTap: () {
              setState(() {
                _expanded = !_expanded;
              });
            },
            title: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${widget.assessment.assessmentName}',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.black, size: 28),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
          if (_expanded)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: widget.assessment.programs!.length,
                itemBuilder: (ctx, i) => EnrichmentItem(
                  program: widget.assessment.programs![i],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class EnrichmentItem extends StatefulWidget {
  final ChildSkillProgram program;
  const EnrichmentItem({
    Key? key,
    required this.program,
  }) : super(key: key);

  @override
  State<EnrichmentItem> createState() => _EnrichmentItemState();
}

class _EnrichmentItemState extends State<EnrichmentItem> {
  var _expanded = false;

  toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _loadProductPage(BuildContext context, String product) {
    String mobileNumber =
        Provider.of<Auth>(context, listen: false).loginResponse.mobileNumber;

    ADResponse? adResponse =
        Provider.of<Auth>(context, listen: false).adResponse;
    SocialAdResponse? socialAdResponse =
        Provider.of<Auth>(context, listen: false).socialAccessTokenResponse;

    if (adResponse == null && socialAdResponse == null) {
      Navigator.of(context).pushNamed(LoginWithPassword.routeName,
          arguments: LoginWithPasswordArgs(true, mobileNumber, () {}, () {},
              true)); // updateADData, updateSocialADData));
    }

    if (adResponse != null || socialAdResponse != null) {
      String productIdHandler = 'products/${product}';
      String productUrl = adResponse == null
          ? '$SHOPIFY_URL${socialAdResponse!.token}$SHOPIFY_REDIRECT_URL$productIdHandler'
          : '$SHOPIFY_URL${adResponse.idToken}$SHOPIFY_REDIRECT_URL$productIdHandler';
      if (kIsWeb) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopifyWeb(
                  initialUrl: Uri.encodeFull(productUrl),
                  updateHandler: () {}, // updateADData,
                  socialUpdateHandler: () {})), // updateSocialADData)),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => WebViewShopify(
                  initialUrl: Uri.encodeFull(productUrl),
                  updateHandler: () {}, // updateADData,
                  socialUpdateHandler: () {})), // updateSocialADData)),
        );
      }

      //UrlLauncher.launchURL(productUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    double textScale = MediaQuery.textScaleFactorOf(context);
    return SizedBox(
      // height: _expanded ? 340 : 170,
      child: Card(
        elevation: 2.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.image, size: 50),
                  const SizedBox(width: 5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 220,
                        child: AutoSizeText(
                          widget.program.programName,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 14,
                              letterSpacing: 0.0,
                              color: AdaptiveTheme.secondaryColor(context),
                              fontWeight: FontWeight.w500),
                          maxFontSize: textScale <= 1.0 ? 14 : 11,
                          maxLines: 2,
                          minFontSize: 11,
                          stepGranularity: 1,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Program Type:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            widget.program.productType == null
                                ? ''
                                : widget.program.productType!,
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Recommended On:',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            widget.program.recommendedDate == null
                                ? ''
                                : DateUtil.formattedDate(DateTime.parse(
                                    widget.program.recommendedDate!)),
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.black,
                                fontWeight: FontWeight.w400),
                          ),
                        ],
                      ),
                      widget.program.purchasedOn != null
                          ? Row(
                              children: [
                                Text(
                                  'Purchased On:',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                ),
                                Text(
                                  widget.program.purchasedOn == null
                                      ? ''
                                      : DateUtil.formattedDate(DateTime.parse(
                                          widget.program.purchasedOn!)),
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            )
                          : SizedBox(),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: widget.program.purchasedOn != null
                            ? MainAxisAlignment.spaceBetween
                            : MainAxisAlignment.start,
                        children: [
                          if (widget.program.purchasedOn != null)
                            Text(
                              'Review & Feedback',
                              style: TextStyle(
                                fontSize: 11,
                                color: AdaptiveTheme.primaryColor(context),
                              ),
                            ),
                          if (widget.program.purchasedOn != null)
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                  _expanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: AdaptiveTheme.primaryColor(context),
                                  size: 20),
                              onPressed: () {
                                toggleExpanded();
                                // setState(() {
                                //   _expanded = !_expanded;
                                // });
                              },
                            ),
                          const SizedBox(height: 10),
                          Container(
                            width: 100,
                            height: 23,
                            child: appButton(
                              context: context,
                              width: 120,
                              height: 30,
                              titleFontSize: textScale <= 1.0 ? 12 : 10,
                              title: widget.program.purchasedOn == null
                                  ? 'Book Now'
                                  : 'Book Again',
                              titleColour: AdaptiveTheme.primaryColor(context),
                              borderColor: AdaptiveTheme.primaryColor(context),
                              onPressed: () {
                                _loadProductPage(
                                    context, widget.program.productHandle!);
                              },
                            ),
                            // child: ElevatedButton(
                            //   onPressed: () {
                            //     _loadProductPage(
                            //         context, widget.program.programName);
                            //   },
                            //   child: Text(
                            //     widget.program.purchasedOn == null
                            //         ? 'Book Now'
                            //         : 'Book Again',
                            //     style: TextStyle(
                            //         fontSize:
                            //             textScale(context) <= 1.0 ? 13 : 11,
                            //         color: AdaptiveTheme.primaryColor(context)),
                            //   ),
                            //   style: ElevatedButton.styleFrom(
                            //       padding: EdgeInsets.zero,
                            //       elevation: 0.0,
                            //       side: BorderSide(
                            //         width: 1.0,
                            //         color: Colors.red,
                            //       ),
                            //       primary: Colors.white,
                            //       shape: RoundedRectangleBorder(
                            //         borderRadius:
                            //             new BorderRadius.circular(15.0),
                            //       )),
                            // ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              if (_expanded)
                FeedBackWidget(
                  reviews: widget.program.reviews,
                  productId: widget.program.programId,
                  productName: widget.program.programName,
                  programType: widget.program.productType == null
                      ? ''
                      : widget.program.productType!,
                  toggleExpansionHandler: toggleExpanded,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeedBackWidget extends StatefulWidget {
  final List<ProductReview>? reviews;
  final int productId;
  final String productName;
  final String programType;
  final Function toggleExpansionHandler;
  const FeedBackWidget({
    Key? key,
    this.reviews,
    required this.productId,
    required this.productName,
    required this.programType,
    required this.toggleExpansionHandler,
  }) : super(key: key);

  @override
  State<FeedBackWidget> createState() => _FeedBackWidgetState();
}

class _FeedBackWidgetState extends State<FeedBackWidget> {
  final _commentController = TextEditingController();
  bool _isLoading = false;
  late double userRating = 0;
  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  updateRating(double rate) {
    userRating = rate;
  }

  Future<void> _saveReview() async {
    if (userRating < 1.0) {
      await Dialogs().ackInfoAlert(context, 'Please enter your rating...');
      return;
    }
    // if (_commentController.text.trim() == '') {
    //   await Dialogs().ackAlert(context, 'Comments', 'Enter your comments');
    //   return;
    // }

    setState(() {
      _isLoading = true;
    });
    //Save the values to the object
    var _newReview = ProductReview(
      rating: userRating,
      comment: _commentController.text,
      productId: widget.productId,
      productName: widget.productName,
      programType: widget.programType,
    );

    //Save the values to the object

    try {
      int userId = Provider.of<Auth>(context, listen: false)
          .loginResponse
          .b2cParent!
          .parentID;
      var _inserted =
          await Provider.of<ChildSkillEnrichment>(context, listen: false)
              .addReview(userId, _newReview);
      setState(() {
        _isLoading = false;
      });
      if (_inserted) {
        if (widget.reviews!.length == 0) {
          widget.reviews!.add(ProductReview(
              comment: _commentController.text, rating: userRating));
        }
        setState(() {
          _commentController.text = '';
          widget.toggleExpansionHandler();
        });
        await Dialogs().ackSuccessAlert(
            context, 'SUCCESS!!!', 'Your feedback has been saved.');
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
    double textScale = MediaQuery.textScaleFactorOf(context);
    return Container(
      //width: double.infinity,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.reviews!.length < 1)
            Text(
              'Your feedback might give some direction to other parents',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          if (widget.reviews!.length < 1)
            Text(
              'Please opt it now',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
            ),
          if (widget.reviews!.length < 1) const SizedBox(height: 10),
          if (widget.reviews!.length > 0)
            RatingBar.builder(
              initialRating: widget.reviews!.first.rating!,
              itemSize: 25,
              minRating: 1,
              direction: Axis.horizontal,
              //allowHalfRating: true,
              itemCount: 5,
              //  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {},
            ),
          if (widget.reviews!.length > 0)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(10),
              child: ListView.builder(
                  //physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: widget.reviews!.length,
                  itemBuilder: (ctx, i) => Text(widget.reviews![i].comment)),
            ),
          if (widget.reviews!.length < 1)
            AppRatingBar(
                initialRating: 0,
                direction: Axis.horizontal,
                size: 40,
                rateCallBack: updateRating),
          const SizedBox(height: 10),
          if (widget.reviews!.length < 1)
            TextField(
              cursorHeight: 25,
              inputFormatters: [
                LengthLimitingTextInputFormatter(250),
              ],
              style: TextStyle(color: Colors.black, fontSize: 17),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                hintText: ' Comments',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.white70,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: Colors.grey.shade200, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(color: Colors.grey.shade500),
                ),
              ),
              textAlignVertical: TextAlignVertical.top,
              textInputAction: TextInputAction.newline,
              //focusNode: _commentFocusNode,
              controller: _commentController,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 3,
            ),
          if (widget.reviews!.length < 1) const SizedBox(height: 10),
          if (widget.reviews!.length < 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 80,
                  height: 25,
                  child: appButton(
                    context: context,
                    width: 100,
                    height: 30,
                    titleFontSize: textScale <= 1.0 ? 12 : 10,
                    title: 'Submit',
                    titleColour: AdaptiveTheme.primaryColor(context),
                    borderColor: AdaptiveTheme.primaryColor(context),
                    onPressed: _saveReview,
                  ),
                  // child: ElevatedButton(
                  //   onPressed: _saveReview,
                  //   child: Text(
                  //     'Submit',
                  //     style: TextStyle(
                  //         fontSize: 12,
                  //         color: AdaptiveTheme.primaryColor(context)),
                  //   ),
                  //   style: ElevatedButton.styleFrom(
                  //       side: BorderSide(
                  //         width: 1.0,
                  //         color: Colors.red,
                  //       ),
                  //       primary: Colors.white,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: new BorderRadius.circular(15.0),
                  //       )),
                  // ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 80,
                  height: 25,
                  child: appButton(
                    context: context,
                    width: 100,
                    height: 30,
                    titleFontSize: textScale <= 1.0 ? 12 : 10,
                    title: 'Cancel',
                    titleColour: AdaptiveTheme.secondaryColor(context),
                    borderColor: AdaptiveTheme.secondaryColor(context),
                    onPressed: () {
                      widget.toggleExpansionHandler();
                    },
                  ),
                  // child: ElevatedButton(
                  //   onPressed: () {
                  //     widget.toggleExpansionHandler();
                  //   },
                  //   child: Text(
                  //     'Cancel',
                  //     style: TextStyle(fontSize: 12, color: Colors.grey),
                  //   ),
                  //   style: ElevatedButton.styleFrom(
                  //       side: BorderSide(
                  //         width: 1.0,
                  //         color: Colors.red,
                  //       ),
                  //       primary: Colors.white,
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: new BorderRadius.circular(15.0),
                  //       )),
                  // ),
                ),
              ],
            )
        ],
      ),
    );
  }
}
