// import 'package:flutter/material.dart';

// /**
//  * Responive Layout Route filter ,all navigation should go through this , if kIsWeb
//  */
// class ResponsiveRouteLayout {
//   String getRoute({
//     required BuildContext context,
//     required String largeScreenRoute,
//     String? mediumScreenRoute,
//     required String smallScreenRoute,
//   }) {
//     var width = MediaQuery.of(context).size.width;

//     if (width > 1200) {
//       return largeScreenRoute;
//     } else if (width >= 800 && width <= 1200) {
//       return mediumScreenRoute ?? largeScreenRoute;
//     } else {
//       return smallScreenRoute;
//     }
//   }
// }

// /**
//  * Responive Layout filter all widgets should go through this , if kIsWeb
//  */

// class ResponsiveLayout extends StatelessWidget {
//   final Widget largeScreen;
//   final Widget? mediumScreen;
//   final Widget smallScreen;

//   ResponsiveLayout({
//     required this.largeScreen,
//     this.mediumScreen,
//     required this.smallScreen,
//   });

//   static bool isSmallScreen(BuildContext context) {
//     return MediaQuery.of(context).size.width < 800;
//   }

//   static bool isMediumScreen(BuildContext context) {
//     return MediaQuery.of(context).size.width > 800 &&
//         MediaQuery.of(context).size.width < 1200;
//   }

//   static bool isLargeScreen(BuildContext context) {
//     return MediaQuery.of(context).size.width > 800;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       if (constraints.maxWidth > 1200) {
//         return largeScreen;
//       } else if (constraints.maxWidth >= 800 && constraints.maxWidth <= 1200) {
//         return mediumScreen ?? largeScreen;
//         //    smallScreen;
//       } else {
//         return smallScreen;
//       }
//     });
//   }
// }

// // class ResponsiveLayoutRoute {
// //   String getResponsiveRoute(
// //     String largeScreenRoute,
// //     String? mediumScreenRoute,
// //     String smallScreenRoute,
// //   ) {
// //     double largeScreenSize = 1200;
// //     double mediumScreenSize =800
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return LayoutBuilder(builder: (context, constraints) {
// //       if (constraints.maxWidth > 1200) {
// //         return largeScreen;
// //       } else if (constraints.maxWidth >= 800 && constraints.maxWidth <= 1200) {
// //         return mediumScreen ?? largeScreen;
// //         //    smallScreen;
// //       } else {
// //         return smallScreen;
// //       }
// //     });
// //   }
// // }
