import 'package:http/http.dart' as http;

class ApiMethods {
  Future<dynamic> get({
    required String url,
    required Map<String, String>? headers,
  }) async {
    final response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 200) {
      print(response.body);
      final data = response.body;
      return data;
    } else {
      print('Error Occurred status code: ${response.statusCode}');
      print('  ${response.body}');
    }
  }
}
