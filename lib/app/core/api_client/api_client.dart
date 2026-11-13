
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import '../constants/api constants.dart';
import '../storage/storage.dart';

class ApiClient {
  late Dio dio;

  ApiClient() {
    _initDio();
  }

  void _initDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 3000),
        receiveTimeout: const Duration(seconds: 3000),
        followRedirects: true,
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.acceptHeader: 'application/json',
        },
        responseType: ResponseType.json,
        receiveDataWhenStatusError: true,
      ),
    );

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient(
          context: SecurityContext(withTrustedRoots: false),
        );
        client.badCertificateCallback = (_, __, ___) => true;
        return client;
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) => handler.next(options),
        onError: (error, handler) => handler.next(error),
      ),
    );
  }

  /// Adds Authorization header from the locally saved token.
  Future<Options> _authOptions() async {
    final token = await TokenStorage.readToken();
    final tokenType = await TokenStorage.readTokenType() ?? 'Bearer';
    return Options(
      headers: {
        if (token != null && token.isNotEmpty)
          "Authorization": "$tokenType $token",
      },
    );
  }


  /// GET /profile
  Future<Response> getProfile() async => dio.get(
    ApiConstants.profile,
    options: await _authOptions(),
  );


}
