/*
 *  All app settings  
 */
import 'package:package_info_plus/package_info_plus.dart';

class AppInfo {
  static Future<PackageInfo> getPackageInfo() async {
    PackageInfo _packageInfo = PackageInfo(
      appName: 'Unknown',
      packageName: 'Unknown',
      version: 'Unknown',
      buildNumber: 'Unknown',
      buildSignature: 'Unknown',
    );
    _packageInfo = await PackageInfo.fromPlatform();
    return _packageInfo;
  }
}
