@JS()
library stripe;

import 'package:flutter/material.dart';
import 'package:js/js.dart';

// void redirectToCheckout(BuildContext _) async {
//   String apiKey =
//       'pk_test_51MYPI8SHGXtUJ2HUdV60P8cOpMXItNPX7D3wqUnYVfTgApvHlmdyrX3ffvVrFm4zg3q91QC0e0Im1azHr1OI20VH00Ah8wwzCb';
//   String unFoldPriceId = 'price_1MawGuSHGXtUJ2HUDN45IbzO';
//   final stripe = Stripe(apiKey);
//   stripe.redirectToCheckout(CheckoutOptions(
//     lineItems: [
//       LineItem(
//         price: unFoldPriceId,
//         quantity: 1,
//       )
//     ],
//     mode: 'payment',
//     successUrl: 'http://localhost:58828/#',
//     cancelUrl: 'http://localhost:58828/cancel.html',
//     customerEmail: 'jayakumar@zoftsolutions.com',
//   ));
// }
void redirectToCheckout(
    BuildContext _, String packageStripeId, String parentEmailId) async {
  String apiKey =
      'pk_test_51MYPI8SHGXtUJ2HUdV60P8cOpMXItNPX7D3wqUnYVfTgApvHlmdyrX3ffvVrFm4zg3q91QC0e0Im1azHr1OI20VH00Ah8wwzCb';

  final stripe = Stripe(apiKey);
  stripe.redirectToCheckout(CheckoutOptions(
    lineItems: [
      LineItem(
        price: packageStripeId,
        quantity: 1,
      )
    ],
    mode: 'payment',
    successUrl: 'http://localhost:52868/#/stripe-success-page',
    cancelUrl: 'http://localhost:58828/cancel.html',
    customerEmail: parentEmailId,
  ));
}

@JS()
class Stripe {
  external Stripe(String key);

  external redirectToCheckout(CheckoutOptions options);
}

@JS()
@anonymous
class CheckoutOptions {
  external List<LineItem> get lineItems;
  external String get mode;
  external String get successUrl;
  external String get cancelUrl;
  external String get sessionId;
  external String get customerEmail;

  external factory CheckoutOptions({
    List<LineItem> lineItems,
    String mode,
    String successUrl,
    String cancelUrl,
    String sessionId,
    String customerEmail,
  });
}

@JS()
@anonymous
class LineItem {
  external String get price;
  external int get quantity;
  external factory LineItem({
    String price,
    int quantity,
  });
}
