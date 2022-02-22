import 'package:flutter/foundation.dart';

class Urls {
  static String basedUrl = kReleaseMode
      ? "http://phplaravel-698707-2309199.cloudwaysapps.com/api"
      : "http://phplaravel-698707-2309199.cloudwaysapps.com/api";

  static String getAddresses = "$basedUrl/get-addresses";
  static String saveAddress = "$basedUrl/save-address";
}
