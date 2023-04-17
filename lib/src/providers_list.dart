import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../src/providers/child_recomendations.dart';
import '../src/providers/child_skill_summary.dart';
import '../src/providers/interest_capture.dart';
import '../src/providers/meeting.dart';
import '../src/providers/payment_gateway.dart';

import '../src/providers/feed_posts.dart';
import '../src/providers/home_static_data.dart';
import 'providers/child_skill_enrichment.dart';
import '../src/providers/shopify_products.dart';

import '/src/providers/google_signin_controller.dart';
import '/src/providers/kyc_document.dart';
import '../src/providers/children.dart';
import '../src/providers/school_config.dart';
import '../src/providers/subscriptions.dart';
import '../src/providers/user_location.dart';
import '../src/providers/auth.dart';
import '../src/providers/user.dart';
import 'providers/homestaticdata_new.dart';
import 'providers/referraldetail.dart';

List<SingleChildWidget> providersList = [
  ChangeNotifierProvider(create: (_) => Auth()),
  ChangeNotifierProvider(create: (_) => User()),
  ChangeNotifierProvider(create: (_) => UserLocation()),
  ChangeNotifierProvider(create: (_) => SchoolConfig()),
  ChangeNotifierProvider(create: (_) => Children()),
  ChangeNotifierProvider(create: (_) => Subscriptions()),
  ChangeNotifierProvider(create: (_) => GoogleSignInProvider()),
  ChangeNotifierProvider(create: (_) => KycDocument()),
  ChangeNotifierProvider(create: (_) => FeedPosts()),
  ChangeNotifierProvider(create: (_) => HomeStaticData()),
  ChangeNotifierProvider(create: (_) => PaymentGateway()),
  ChangeNotifierProvider(create: (_) => ReferralDetail()),
  Provider(create: (_) => Meeting()),
  ChangeNotifierProxyProvider<Auth, ShopifyProducts>(
    create: (context) => ShopifyProducts(),
    update: (ctx, auth, previousObject) => ShopifyProducts()
      ..update(auth.isAuth != false? auth.loginResponse.token:"",previousObject==null ?[]: previousObject.shopifyProducts),
  ),
  ChangeNotifierProxyProvider<Auth, InterestCapture>(
    create: (context) => InterestCapture(),
    update: (ctx, auth, previousObject) =>
        previousObject!..update(auth.isAuth != false? auth.loginResponse.token:""),
  ),
  ChangeNotifierProxyProvider<Auth, ChildRecomendations>(
    create: (context) => ChildRecomendations(),
    update: (ctx, auth, previousObject) =>
        previousObject!..update(auth.isAuth != false? auth.loginResponse.token:""),
  ),
  ChangeNotifierProxyProvider<Auth, ChildSkillEnrichment>(
    create: (context) => ChildSkillEnrichment(),
    update: (ctx, auth, previousObject) =>
        previousObject!..update(auth.isAuth != false? auth.loginResponse.token:""),
  ),
  ChangeNotifierProxyProvider<Auth, ChildSkillSummary>(
    create: (context) => ChildSkillSummary(),
    update: (ctx, auth, previousObject) =>
        previousObject!..update(auth.isAuth != false? auth.loginResponse.token:""),
  ),
  ChangeNotifierProxyProvider<Auth, HomeStaticDataNew>(
    create: (context) => HomeStaticDataNew(),
    update: (ctx, auth, previousObject) =>
        previousObject!..update(auth.isAuth != false? auth.loginResponse.token:""),
  ),
];
