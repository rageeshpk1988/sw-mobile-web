import '../../../adaptive/adaptive_theme.dart';

import '../../home/landing/screens/landing_page.dart';
import '/util/ui_helpers.dart';
import '/util/app_theme.dart';
import 'package:flutter/material.dart';

class KycOnlineConfirmed extends StatelessWidget {
  final String aadharname;
  final String aadharnumber;
  KycOnlineConfirmed(this.aadharname, this.aadharnumber);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: SizedBox(
                  height: 470,
                  width: double.infinity,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 30,
                      ),
                      Center(
                          child: Image.asset(
                              'assets/icons/onlinekyc_success.png')),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Thank You',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Your Aadhaar Card',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.green[900]!,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                      verticalSpaceSmall,
                      Text(
                        'Has been Verified',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.green[900]!,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                      verticalSpaceSmall,
                      Text(
                        'Successfully',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.green[900]!,
                            fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                      verticalSpaceMedium,
                      Text('Aadhaar Name: $aadharname',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.green[900]!,
                                  fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center),
                      verticalSpaceSmall,
                      Text('Aadhaar Number: $aadharnumber',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Colors.green[900]!,
                                  fontWeight: FontWeight.normal),
                          textAlign: TextAlign.center),
                      const SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: screenWidthPercentage(context, percentage: .9),
                          height: 50,
                          child: appButton(
                              context: context,
                              width: 20,
                              height: 20,
                              title: 'OK',
                              titleColour: AdaptiveTheme.primaryColor(context),
                              borderColor: AdaptiveTheme.primaryColor(context),
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LandingPage()),
                                );
                              }), /*RoundButton(
                                title: 'OK',
                                color: AppTheme.primaryColor,
                                onPressed: () {

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (context) => LandingPage()),
                                  );
                                },
                              ),*/
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ))),
    );
  }
}
//
