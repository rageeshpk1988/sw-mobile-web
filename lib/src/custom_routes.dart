import 'package:flutter/material.dart';
import '/src/home/child/screens/child_recomendations_web.dart';
import '/src/home/child/screens/child_skill_report_web.dart';
import '/src/home/child/screens/child_skillenrichment_web.dart';
import '/src/home/child/screens/child_skillsummary_web.dart';
import '/src/home/child/screens/child_transformation_web.dart';
import '/src/home/child/screens/interest_capture_web.dart';
import '/src/home/feeds/screens/new_feeds_web.dart';
import '/src/invite_friend/screens/refer_friend_web.dart';
import '/src/kyc/screens/kyc_type_selection_web.dart';
import '/src/login/screens/email_registration_web.dart';
import '/src/login/screens/forgot_password_web.dart';
import '/src/login/screens/login_mobile_web.dart';
import '/src/login/screens/login_with_pass_web.dart';
import '/src/login/screens/migrate_account_web.dart';
import '/src/profile/screens/add_child_web.dart';
import '/src/profile/screens/edit_child_web.dart';
import '/src/profile/screens/followers_screen_web.dart';
import '/src/profile/screens/following_screen_web.dart';
import '/src/profile/screens/profile_others_web.dart';
import '/src/profile/screens/profile_update_web.dart';
import '/src/profile/screens/profile_web.dart';
import '/src/subscription/screens/mysubscriptionplan_web.dart';
import '/src/subscription/screens/stripe_success_page.dart';
import '/src/subscription/screens/subscriptionplans_web.dart';

import '/src/vendor_profile/screens/vendor_profile_web.dart';

import '../src/home/child/screens/child_coach_info_screen.dart';
import '../src/home/child/screens/child_skill_report.dart';
import '../src/home/child/screens/child_skill_report_subview.dart';
import '../src/home/child/screens/child_transformation.dart';
import '../screens/no_internet_screen.dart';
import '../src/home/child/screens/child_recomendations.dart';
import '../src/home/child/screens/child_skillenrichment.dart';
import '../src/home/child/screens/child_skillsummary.dart';

import '../src/home/feeds/screens/new_feeds.dart';
import '../src/home/landing/screens/parent_tiles_screen.dart';
import '../src/home/landing/screens/product_tiles_screen.dart';
import '../src/home/notification/notifications.dart';
import '../src/home/suggested_parents/suggestedParents.dart';
import 'home/feeds/screens/user_feeds_web.dart';
import 'home/landing/screens/coorporate_video_screen.dart';
import 'invite_friend/screens/refer_friend.dart';
import '../src/subscription/screens/mySubscriptionPlan.dart';
import '../src/subscription/screens/subcriptionsPlans.dart';
import '../src/vendor_profile/screens/vendor_profile.dart';

import 'home/child/screens/interest_capture.dart';

import '/src/home/new_post/new_post.dart';
import '/src/home/new_post/post_achievement.dart';

import '/src/home/search/screens/feed_search.dart';
import '/src/home/search/screens/product_search.dart';

import '/src/home/feeds/screens/feedDetails.dart';
import '/src/home/feeds/screens/user_feeds.dart';
import '/src/profile/screens/followers_screen.dart';
import '/src/profile/screens/following_screen.dart';
import '/src/profile/screens/profile_others.dart';

import '../src/profile/screens/edit_child.dart';
import '../../src/profile/screens/add_child.dart';
import '../../src/profile/screens/profile_update.dart';
import '../../src/login/screens/email_registration.dart';
import '../../src/intro/intro_screen.dart';
import '../../src/login/screens/forgot_password.dart';
import '../../src/login/screens/login_mobile.dart';
import '../../src/login/screens/login_with_pass.dart';
import '../../src/profile/screens/profile.dart';

import 'home/new_post/post_activity.dart';
import 'home/new_post/post_general.dart';
import 'invite_friend/screens/refer_friend_detail.dart';
import 'kyc/screens/kyc_type_selection.dart';
import 'login/screens/migrate_account.dart';

var customRoutes = <String, WidgetBuilder>{
  //'/': (ctx) => NewFeedScreen(),
  //LandingPage.routeName: (ctx) => LandingPage(),
  NoInternetScreen.routeName: (ctx) => NoInternetScreen(),
  NewFeedScreen.routeName: (ctx) => NewFeedScreen(),
  NewFeedScreenWeb.routeName: (ctx) => NewFeedScreenWeb(),
  IntroScreen.routeName: (ctx) => IntroScreen(),
  LoginWithPassword.routeName: (ctx) => LoginWithPassword(),
  LoginWithPasswordWeb.routeName: (ctx) => LoginWithPasswordWeb(),
  EmailRegistration.routeName: (ctx) => EmailRegistration(),
  EmailRegistrationWeb.routeName: (ctx) => EmailRegistrationWeb(),
  ForgotPassword.routeName: (ctx) => ForgotPassword(),
  ForgotPasswordWeb.routeName: (ctx) => ForgotPasswordWeb(),
  LoginMobile.routeName: (ctx) => LoginMobile(),
  LoginMobileWeb.routeName: (ctx) => LoginMobileWeb(),
  ProfileScreen.routeName: (ctx) => ProfileScreen(),
  ProfileScreenWeb.routeName: (ctx) => ProfileScreenWeb(),
  ProfileOthersScreen.routeName: (ctx) => ProfileOthersScreen(),
  ProfileOthersScreenWeb.routeName: (ctx) => ProfileOthersScreenWeb(),
  ProfileUpdateScreen.routeName: (ctx) => ProfileUpdateScreen(),
  ProfileUpdateScreenWeb.routeName: (ctx) => ProfileUpdateScreenWeb(),
  AddChildScreen.routeName: (ctx) => AddChildScreen(),
  AddChildScreenWeb.routeName: (ctx) => AddChildScreenWeb(),
  EditChildScreen.routeName: (ctx) => EditChildScreen(),
  EditChildScreenWeb.routeName: (ctx) => EditChildScreenWeb(),
  SubscriptionPlansScreen.routeName: (ctx) => SubscriptionPlansScreen(),
  SubscriptionPlansScreenWeb.routeName: (ctx) => SubscriptionPlansScreenWeb(),
  FeedDetailsScreen.routeName: (ctx) => FeedDetailsScreen(),
  KycTypeSelectionScreen.routeName: (ctx) => KycTypeSelectionScreen(),
  KycTypeSelectionScreenWeb.routeName: (ctx) => KycTypeSelectionScreenWeb(),
  FollowersScreen.routeName: (ctx) => FollowersScreen(),
  FollowersScreenWeb.routeName: (ctx) => FollowersScreenWeb(),
  FollowingScreen.routeName: (ctx) => FollowingScreen(),
  FollowingScreenWeb.routeName: (ctx) => FollowingScreenWeb(),
  UserFeedsScreen.routeName: (ctx) => UserFeedsScreen(),
  UserFeedsScreenWeb.routeName: (ctx) => UserFeedsScreenWeb(),
  NewPostScreen.routeName: (ctx) => NewPostScreen(),
  PostGeneralScreen.routeName: (ctx) => PostGeneralScreen(),
  PostActivityScreen.routeName: (ctx) => PostActivityScreen(),

  FeedSearchScreen.routeName: (ctx) => FeedSearchScreen(),
  ProductSearchScreen.routeName: (ctx) => ProductSearchScreen(),

  VendorProfileScreen.routeName: (ctx) => VendorProfileScreen(),

  VendorProfileScreenWeb.routeName: (ctx) => VendorProfileScreenWeb(),
  InterestCaptureScreen.routeName: (ctx) => InterestCaptureScreen(),
  InterestCaptureScreenWeb.routeName: (ctx) => InterestCaptureScreenWeb(),
  ParentTilesScreen.routeName: (ctx) => ParentTilesScreen(),
  ProductTilesScreen.routeName: (ctx) => ProductTilesScreen(),
  ReferFriend.routeName: (ctx) => ReferFriend(),
  ReferFriendWeb.routeName: (ctx) => ReferFriendWeb(),
  ReferralDetailScreen.routeName: (ctx) => ReferralDetailScreen(),
  SuggestedParentsScreen.routeName: (ctx) => SuggestedParentsScreen(),
  MySubscriptionPlanScreen.routeName: (ctx) => MySubscriptionPlanScreen(),
  MySubscriptionPlanScreenWeb.routeName: (ctx) => MySubscriptionPlanScreenWeb(),
  NotificationScreen.routeName: (ctx) => NotificationScreen(),
  CorporateVideoScreen.routeName: (ctx) => CorporateVideoScreen(),

  ChildRecomendationsScreen.routeName: (ctx) => ChildRecomendationsScreen(),
  ChildRecomendationsScreenWeb.routeName: (ctx) =>
      ChildRecomendationsScreenWeb(),
  ChildSkillsummaryScreen.routeName: (ctx) => ChildSkillsummaryScreen(),
  ChildSkillsummaryScreenWeb.routeName: (ctx) => ChildSkillsummaryScreenWeb(),
  ChildSkillEnrichmentScreen.routeName: (ctx) => ChildSkillEnrichmentScreen(),
  ChildSkillEnrichmentScreenWeb.routeName: (ctx) =>
      ChildSkillEnrichmentScreenWeb(),
  PostAchievementScreen.routeName: (ctx) => PostAchievementScreen(),
  ChildSkillReportScreen.routeName: (ctx) => ChildSkillReportScreen(),
  ChildSkillReportScreenWeb.routeName: (ctx) => ChildSkillReportScreenWeb(),
  ChildTransformationScreen.routeName: (ctx) => ChildTransformationScreen(),
  ChildTransformationScreenWeb.routeName: (ctx) =>
      ChildTransformationScreenWeb(),
  ChildCoachInfoScreen.routeName: (ctx) => ChildCoachInfoScreen(),
  ChildSkillReportSubViewScreen.routeName: (ctx) =>
      ChildSkillReportSubViewScreen(),
  MigrateAccount.routeName: (ctx) => MigrateAccount(),
  MigrateAccountWeb.routeName: (ctx) => MigrateAccountWeb(),
  StripeSuccessPage.routeName: (ctx) => StripeSuccessPage(),
};
//
