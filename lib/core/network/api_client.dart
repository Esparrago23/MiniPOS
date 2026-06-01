import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  final http.Client client;
  final String baseUrl;

  const ApiClient({required this.client, required this.baseUrl});

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final response = await _sendRequest(
      () => client.get(_uri(path), headers: _headers(token: token)),
    );

    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final response = await _sendRequest(
      () => client.post(
        _uri(path),
        headers: _headers(token: token),
        body: jsonEncode(body),
      ),
    );

    return _decodeResponse(response);
  }

  Future<http.Response> _sendRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(const Duration(seconds: 15));
    } on TimeoutException {
      throw const ApiException('El servidor tardo demasiado en responder.');
    } catch (_) {
      throw const ApiException('No se pudo conectar con el servidor.');
    }
  }

  Map<String, String> _headers({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String path) {
    return Uri.parse('$baseUrl$path');
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final dynamic decodedBody = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (decodedBody is Map<String, dynamic>) {
        return decodedBody;
      }

      throw const ApiException('Respuesta inesperada del servidor.');
    }

    if (decodedBody is Map<String, dynamic> &&
        decodedBody.containsKey('detail')) {
      throw ApiException(_formatDetail(decodedBody['detail']));
    }

    throw ApiException('Error HTTP ${response.statusCode}.');
  }

  String _formatDetail(dynamic detail) {
    if (detail is String) {
      return detail;
    }

    if (detail is List) {
      return detail.map((item) => item.toString()).join('\n');
    }

    return detail.toString();
  }
}
