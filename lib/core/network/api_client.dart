import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:cesizen_mobile/core/config/api_config.dart';
import 'package:cesizen_mobile/core/network/api_exception.dart';

class ApiClient {
  ApiClient({http.Client? client, Uri? baseUri})
    : _client = client ?? http.Client(),
      baseUri = baseUri ?? ApiConfig.baseUri;

  final http.Client _client;
  final Uri baseUri;

  Future<dynamic> getJson(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) {
    return _send(
      'GET',
      path,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> postJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) {
    return _send(
      'POST',
      path,
      body: body,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> putJson(
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) {
    return _send(
      'PUT',
      path,
      body: body,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> deleteJson(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) {
    return _send(
      'DELETE',
      path,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final requestHeaders = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      if (headers != null) ...headers,
    };

    late final http.Response response;
    switch (method) {
      case 'GET':
        response = await _client.get(uri, headers: requestHeaders);
        break;
      case 'POST':
        response = await _client.post(
          uri,
          headers: requestHeaders,
          body: body == null ? null : jsonEncode(body),
        );
        break;
      case 'PUT':
        response = await _client.put(
          uri,
          headers: requestHeaders,
          body: body == null ? null : jsonEncode(body),
        );
        break;
      case 'DELETE':
        response = await _client.delete(uri, headers: requestHeaders);
        break;
      default:
        throw UnsupportedError('Unsupported HTTP method: $method');
    }

    return _decodeResponse(response);
  }

  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final resolved = baseUri.resolve(path);
    if (queryParameters == null || queryParameters.isEmpty) {
      return resolved;
    }
    return resolved.replace(queryParameters: queryParameters);
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _extractMessage(response.body),
        statusCode: response.statusCode,
      );
    }

    if (response.body.isEmpty) {
      return null;
    }

    return jsonDecode(response.body);
  }

  String _extractMessage(String body) {
    if (body.trim().isEmpty) {
      return 'Erreur reseau';
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final error = decoded['error'];
        if (error is String && error.isNotEmpty) {
          return error;
        }

        final message = decoded['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }

        if (decoded.length == 1) {
          final value = decoded.values.first;
          if (value is String && value.isNotEmpty) {
            return value;
          }
        }
      }
    } catch (_) {
      // Fall back to the raw response below.
    }

    return body;
  }
}