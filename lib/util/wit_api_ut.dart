import 'package:http/http.dart' as http;
import 'dart:convert';

/**
 * POST 방식 통신
 * @param restId
 * @param Json
 * @return dynamic
 */
Future<dynamic> sendPostRequest(String restId, dynamic param) async {

  Uri uri = Uri.parse("http://192.168.45.222:9090/wit/" + restId);

  // Head
  final headers = {
    "Content-Type": "application/json",
    "Accept": "application/json",
    'Authorization': 'b13cd958-d0ad-47b2-b0fb-7076767594cb',
  };

  // API 호출
  final response = await http.post(uri, headers : headers, body : param ?? "");

  // 호출 성공
  if (response.statusCode == 200) {
    // 성공적으로 데이터를 전송했을 때의 처리
    return json.decode(utf8.decode(response.bodyBytes));

  // 호출 실패
  } else {
    throw Exception('Request failed with status: ${response.statusCode}');

  }

}