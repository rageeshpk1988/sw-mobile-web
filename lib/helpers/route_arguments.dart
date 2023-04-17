/* 
  All Page route arguments will go here
 */

import '/src/models/referral.dart';

import '../src/models/child_skill_summary_group.dart';

import '../src/models/firestore/feedpost.dart';
import '../src/models/firestore/followingparents.dart';

import '../src/models/child.dart';
import '../src/models/firestore/vendor_from_ads.dart';

class LoginWithPasswordArgs {
  final bool mobileValidated;
  final String mobileNumber;
  final Function updateHandler;
  final Function socialUpdateHandler;
  final bool showSocialButton;
  LoginWithPasswordArgs(
    this.mobileValidated,
    this.mobileNumber,
    this.updateHandler,
    this.socialUpdateHandler,
    this.showSocialButton,
  );
}

class UpdatePasswordArgs {
  final String mobileNumber;
  final int parentId;
  UpdatePasswordArgs(
    this.mobileNumber,
    this.parentId,
  );
}

class EditchildArgs {
  final Child child;
  final Function parentRefreshHandler;
  EditchildArgs(
    this.child,
    this.parentRefreshHandler,
  );
}

class InterestArgs {
  final Function updateHandler;
  InterestArgs(
    this.updateHandler,
  );
}

class ProfileOthersArgs {
  final AdVendorProfile? adVendorProfile;
  final FollowingParents? followingParents;
  final FeedPost? feedPost;

  ProfileOthersArgs(
    this.feedPost,
    this.followingParents,
    this.adVendorProfile,
  );
}

class UserFeedsArgs {
  final int userId;
  final bool followerFeeds;
  UserFeedsArgs(
    this.userId,
    this.followerFeeds,
  );
}

class UserFeedsWebArgs {
  final int userId;
  final bool followerFeeds;
  final List<Child> students;
  final FeedPost? feedPost;
  final FollowingParents? followingParents;
  UserFeedsWebArgs(
    this.userId,
    this.followerFeeds,
    this.students,
    this.feedPost,
    this.followingParents,
  );
}

class SkillReportDescriptionArgs {
  final ChildSkillCategory skillCategory;
  final ChildSkillSubCategory subCategory;
  SkillReportDescriptionArgs(
    this.skillCategory,
    this.subCategory,
  );
}

class SkillReportAndCategoryArgs {
  final ChildSkillCategory skillCategory;
  final ChildSkillReport? skillReport;
  SkillReportAndCategoryArgs(
    this.skillCategory,
    this.skillReport,
  );
}

class ReferralArgs {
  final bool? showBackButton;
  ReferralArgs(
    this.showBackButton,
  );
}

class ReferralDetailArgs {
  final Referral referral;
  ReferralDetailArgs(
    this.referral,
  );
}
