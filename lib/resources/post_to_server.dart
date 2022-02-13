import 'dart:convert';

import 'package:dio/dio.dart';

class Post {
  late Response response;
  late String progress;
  Dio dio = Dio();

  Future<String> toServer(String url, Map<String, dynamic> data) async {
    try {
      response = await dio.post(
        url,
        data: FormData.fromMap(data),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json'
          },
        ),
        onSendProgress: (int sent, int total) {
          String percentage = (sent / total * 100).toStringAsFixed(2);

          progress =
              "$sent Bytes of " "$total Bytes - " + percentage + " % uploaded";
          // print("================$progress");
        },
      );

      if (response.statusCode == 200) {
        return response.toString();
      } else {
        return jsonEncode(
            {"error": true, "msg": "Error during connection to server."});
      }
    } catch (e) {
      return jsonEncode({
        "error": true,
        "msg": "Hmmmm 🤔"
            "\nIt's like you don't have internet access, check it and let me see."
      });
    }
  }
}
