import 'package:dio/dio.dart';

const serverConfig = {
  "type": "app",
  "url": "http://171.244.39.37:8000/",
};

class APIServices {
  static final APIServices _instance = APIServices._internal();

  APIServices._internal();

  late String url;

  var kGoogleMap = "AIzaSyDo2Nk9WSlqGydwmjj47QW64tlB1xiEagU";

  factory APIServices() => _instance;

  void setAppConfig() {
    url = serverConfig["url"]!;
  }

  Future<Map<String, dynamic>?> getDataCovid19() async {
    try {
      Dio dio = new Dio();
      Response response = await dio.get(
          "https://api.apify.com/v2/key-value-stores/EaCBL1JNntjR3EakU/records/LATEST?disableRedirect=true.");
      if (response.statusCode == 200) {
        return response.data["overview"].last;
      }
    } catch (e) {}
  }
}
