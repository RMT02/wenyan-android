import 'package:dio/dio.dart';

import '../constant/wenyan.dart';

/// 闻言账户的登录结果。
typedef WenyanSession = ({String token, String userId, String username});

/// 登录 / 注册失败时抛出的异常，[message] 可直接展示给用户。
class const WenyanAuthException(
  /// 展示给用户的提示文案。
  final String message, {

  /// 服务器返回的错误码（若有）。
  final String? code,
}) implements Exception {
  @override
  String toString() => message;
}

/// 表示已进入「邮箱确认」流程，需要用户填写邮件里的验证码。
class const WenyanEmailVerificationRequired() implements Exception;

/// 直接调用闻言后端的 `signin-flow` / `signup` / `signup-pending` 接口。
///
/// 不走 MiAuth 的浏览器往返，用户名 + 密码即可在应用内完成登录；
/// `/api/signin-flow` 返回的 `i` 是 Misskey 的原生用户令牌（16 位），
/// 可直接用于后续所有 API 认证。
class const WenyanAuthRepository(final Dio _dio) {
  Uri _endpoint(List<String> segments) =>
      wenyanServerUrl.replace(pathSegments: segments);

  /// 用用户名和密码登录。
  Future<WenyanSession> signin({
    required String username,
    required String password,
  }) async {
    final response = await _post(
      ['api', 'signin-flow'],
      {'username': username, 'password': password},
    );
    final data = response.data ?? const <String, dynamic>{};
    if (data['finished'] == true) {
      return _sessionFrom(data);
    }
    final next = data['next'];
    if (next == 'totp' || next == 'password') {
      throw const WenyanAuthException('该账户启用了两步验证，暂不支持在应用内登录。');
    }
    if (next == 'passkey') {
      throw const WenyanAuthException('该账户需要使用密钥（Passkey）登录。');
    }
    if (next == 'captcha') {
      throw const WenyanAuthException('该服务器要求人机验证，请在网页端登录。');
    }
    throw const WenyanAuthException('登录失败，请重试。');
  }

  /// 注册新账户。若服务器不要求邮箱确认，会直接返回令牌。
  ///
  /// 若服务器要求邮箱确认，则抛出 [WenyanEmailVerificationRequired]，
  /// 此时应让用户填写验证码并调用 [signupPending]。
  Future<WenyanSession> signup({
    required String username,
    required String password,
    String? emailAddress,
  }) async {
    final response = await _post(
      ['api', 'signup'],
      {
        'username': username,
        'password': password,
        if (emailAddress != null && emailAddress.isNotEmpty)
          'emailAddress': emailAddress,
      },
    );
    if (response.statusCode == 204) {
      throw const WenyanEmailVerificationRequired();
    }
    final data = response.data ?? const <String, dynamic>{};
    return _sessionFrom(data);
  }

  /// 用邮件中的验证码完成注册。
  Future<WenyanSession> signupPending({required String code}) async {
    final response = await _post(['api', 'signup-pending'], {'code': code});
    final data = response.data ?? const <String, dynamic>{};
    return _sessionFrom(data);
  }

  WenyanSession _sessionFrom(Map<String, dynamic> data) {
    // `/signin-flow` 与 `/signup-pending` 返回字段为 `i`，
    // 而免邮箱确认的 `/signup` 返回的是 `token`。
    final token = data['i'] ?? data['token'];
    final id = data['id'];
    final username = data['username'];
    if (token is! String || token.isEmpty || id is! String) {
      throw const WenyanAuthException('服务器返回了异常数据，请稍后重试。');
    }
    return (
      token: token,
      userId: id,
      username: username is String ? username : '',
    );
  }

  Future<Response<Map<String, dynamic>>> _post(
    List<String> segments,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.postUri<Map<String, dynamic>>(
        _endpoint(segments),
        data: body,
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (_) => true,
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
        ),
      );
      final status = response.statusCode ?? 0;
      if (status >= 200 && status < 300) return response;
      throw _errorFrom(response);
    } on DioException catch (e) {
      throw _networkErrorFrom(e);
    }
  }

  WenyanAuthException _errorFrom(Response<Map<String, dynamic>> response) {
    final status = response.statusCode ?? 0;
    final error = response.data?['error'];
    final code = error is Map ? error['code'] as String? : null;
    final id = error is Map ? error['id'] as String? : null;
    if (status == 429) {
      return const WenyanAuthException('尝试次数过多，请稍后再试。');
    }
    switch (code) {
      case 'DUPLICATED_USERNAME':
        return const WenyanAuthException('该用户名已被使用。');
      case 'USED_USERNAME':
        return const WenyanAuthException('该用户名曾被使用过，无法再次使用。');
      case 'DENIED_USERNAME':
        return const WenyanAuthException('该用户名不可用。');
      case 'INVALID_USERNAME':
        return const WenyanAuthException('用户名格式不正确，只能使用字母、数字和下划线。');
      case 'INVALID_PASSWORD':
        return const WenyanAuthException('密码太短或格式不正确。');
      case 'EXPIRED':
        return const WenyanAuthException('验证码已过期，请重新注册。');
    }
    switch (id) {
      case '932c904e-9460-45b7-9ce6-7ed33be7eb2c':
        return const WenyanAuthException('用户名或密码错误。');
      case '6cc579cc-885d-43d8-95c2-b8c7fc963280':
        return const WenyanAuthException('该用户不存在。');
      case 'e03a5f46-d309-4865-9b69-56282d94e1eb':
        return const WenyanAuthException('该账户已被冻结。');
      case '22d05606-fbcf-421a-a2db-b32610dcfd1b':
        return const WenyanAuthException('尝试次数过多，请稍后再试。');
    }
    if (status == 400) {
      return const WenyanAuthException('填写内容有误，请检查邮箱与用户名。');
    }
    return WenyanAuthException('认证失败（HTTP $status）');
  }

  WenyanAuthException _networkErrorFrom(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const WenyanAuthException('连接服务器超时，请检查网络后重试。');
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return const WenyanAuthException('无法连接闻言服务器，请检查网络。');
      default:
        return WenyanAuthException('网络异常（${e.type.name}），请稍后重试。');
    }
  }
}
