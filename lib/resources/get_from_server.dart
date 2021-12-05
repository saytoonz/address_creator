import 'dart:convert';

import 'package:dio/dio.dart';

class Get {
  late Response response;
  late String progress;
  Dio dio = new Dio();

  Future<String> fromServer(String url) async {
    try {
      response = await dio.get(
        url,
        options: Options(
          headers: {
            'Accept': 'application/json',
          },
        ),
        onReceiveProgress: (int sent, int total) {
          String percentage = (sent / total * 100).toStringAsFixed(2);

          progress = "$sent" +
              " Bytes of " "$total Bytes - " +
              percentage +
              " % uploaded";
          // print("================$progress");
        },
      );
      //print(response) != null ||
      if (response.statusCode! >= 200 && response.statusCode! < 400) {
        return response.toString();
      } else {
        return jsonEncode(
            {"error": true, "msg": "Error during connection to server."});
      }
    } catch (e) {
      // print(e.toString());
      return jsonEncode({
        "error": true,
        "msg": "Hmmmm 🤔"
            "\nIt's like you don't have internet access, check it and let me see."
      });
    }
  }
}
