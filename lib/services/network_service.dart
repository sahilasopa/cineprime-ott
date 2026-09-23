import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cineprime/network/api_paths.dart';
import 'dart:async';
import 'package:cineprime/services/authentication_service.dart';

import '../platform_utils.dart';

typedef OnSuccessCallback = void Function(Map<String, dynamic> data);
typedef OnFailureCallback = void Function(dynamic error);
typedef OnProcessingCallback = void Function();

class NetworkService {
  final String platform = PlatformUtils.operatingSystem;

  static final NetworkService _singleton = NetworkService._internal();
  final Map<String, Completer<void>> _ongoingRequests = {};

  factory NetworkService() {
    return _singleton;
  }

  NetworkService._internal();

  String _generateRequestHash(
      String url, Map<String, String>? headers, dynamic body) {
    final sortedHeaders = headers != null
        ? json.encode(Map.from(headers)..removeWhere((k, v) => v == null))
        : '';
    final encodedBody = body != null ? json.encode(body) : '';
    return '$url$sortedHeaders$encodedBody';
  }

  Future<void> get(
    APIPath endpoint,
    OnSuccessCallback onSuccess,
    OnFailureCallback onFailure,
    OnProcessingCallback onProcessing, {
    Map<String, String>? headers,
    int maxRetries = 100,
  }) async {
    final url = APIPathHelper.getValue(endpoint);
    final requestHash = _generateRequestHash(url, headers, null);
    if (_ongoingRequests.containsKey(requestHash)) {
      await _ongoingRequests[requestHash]!.future;
      return;
    }

    final completer = Completer<void>();
    _ongoingRequests[requestHash] = completer;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    final versionInfo = {
      "appName": packageInfo.appName,
      "packageName": packageInfo.packageName,
      "version": packageInfo.version,
      "buildNumber": packageInfo.buildNumber,
    };

    onProcessing();
    headers ??= <String, String>{};
    final sessionId = await AuthenticationService().getSessionId();

    headers['Cookie'] = sessionId != null ? 'sessionid=$sessionId' : '';

    headers.addAll({
      'Platform': platform,
      'Version-Info': versionInfo.toString(),
      'X-Session-Id': sessionId ?? 'anonymous_user',
      'X-Country': await AuthenticationService().getCountry(),
    });

    for (var retry = 0; retry < maxRetries; retry++) {
      try {
        final response = await http.get(
          Uri.parse(APIPathHelper.getValue(endpoint)),
          headers: headers,
        );
        if (response.statusCode == 200) {
          onSuccess(_returnResponse(response));
          completer.complete();
          _ongoingRequests.remove(requestHash);
          return;
        } else {
          onFailure(_returnResponse(response));
          completer.complete();
          _ongoingRequests.remove(requestHash);
          return;
        }
      } on ClientException {
        await Future.delayed(const Duration(seconds: 3));
      } catch (e) {
        if (e.toString().contains("SocketException") ||
            e is http.ClientException ||
            e.toString().contains("Failed host lookup")) {
          await Future.delayed(const Duration(seconds: 2));
          continue;
        } else {
          rethrow;
        }
      }
    }

    completer.complete();
    _ongoingRequests.remove(requestHash);
  }

  Future<void> post(
    APIPath endpoint,
    dynamic data,
    OnSuccessCallback onSuccess,
    OnFailureCallback onFailure,
    OnProcessingCallback onProcessing, {
    List<File?>? files,
  }) async {
    final url = APIPathHelper.getValue(endpoint);
    final requestHash = _generateRequestHash(url, null, data);
    if (_ongoingRequests.containsKey(requestHash)) {
      await _ongoingRequests[requestHash]!.future;
      return;
    }

    final completer = Completer<void>();
    _ongoingRequests[requestHash] = completer;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final versionInfo = {
        "appName": packageInfo.appName,
        "packageName": packageInfo.packageName,
        "version": packageInfo.version,
        "buildNumber": packageInfo.buildNumber,
        "extra-data": "rick_roll"
      };

      onProcessing();
      final sessionId = await AuthenticationService().getSessionId();

      final headers = <String, String>{
        'Cookie': sessionId != null ? 'sessionid=$sessionId' : '',
        'Platform': platform,
        'Version-Info': json.encode(versionInfo),
        'X-Session-Id': sessionId ?? 'anonymous_user',
        'X-Country': await AuthenticationService().getCountry(),
      };
      final uri = Uri.parse(url);
      for (var retry = 0; retry < 15; retry++) {
        late dynamic response;
        try {
          headers['Content-Type'] = 'multipart/form-data';
          if (files != null && files.isNotEmpty) {
            final request = http.MultipartRequest(
              "POST",
              uri,
            );
            for (var file in files) {
              if (file == null) {
                return;
              }
              final length = await file.length();
              request.files.add(
                http.MultipartFile(
                  'file',
                  file.readAsBytes().asStream(),
                  length,
                  filename: file.path.split("/").last,
                ),
              );
              request.headers.addAll(headers);
              data.forEach((key, value) {
                request.fields[key] = value;
              });
            }
            response = await request.send();
            final convertedResponse = await http.Response.fromStream(response);

            if (convertedResponse.statusCode == 200) {
              onSuccess(_returnResponse(convertedResponse));
              return;
            } else {
              if (convertedResponse.statusCode == 401) {
                await AuthenticationService().logout();
              }
              onFailure(_returnResponse(convertedResponse));
              return;
            }
          } else {
            headers['Content-Type'] = 'application/json';
            response = await http.post(
              uri,
              headers: headers,
              body: json.encode(data),
            );
          }
          if (response.statusCode == 200) {
            onSuccess(_returnResponse(response));
            return;
          } else {
            if (response.statusCode == 401) {
              await AuthenticationService().logout();
            }
            onFailure(_returnResponse(response));
            return;
          }
        } on ClientException {
          await Future.delayed(const Duration(seconds: 3));
        } catch (e) {
          if (e.toString().contains("SocketException") ||
              e is http.ClientException ||
              e.toString().contains("Failed host lookup")) {
            await Future.delayed(const Duration(seconds: 2));
            continue;
          } else {
            rethrow;
          }
        }
      }
    } finally {
      completer.complete();
      _ongoingRequests.remove(requestHash);
    }
  }

  Map<String, dynamic> _returnResponse(http.Response response) {
    var body = {};
    var utf8Body = utf8.decode(response.bodyBytes);

    if (response.body.isNotEmpty) {
      try {
        var parsedBody = json.decode(utf8Body);

        if (parsedBody is Map<String, dynamic>) {
          body = parsedBody;
        } else if (parsedBody is List) {
          body = {"data": parsedBody};
        } else {
          body = {"content": utf8Body};
        }
      } catch (e) {
        body = {"content": utf8Body};
      }
    }

    return {
      "status": response.statusCode,
      "body": body,
    };
  }
}
