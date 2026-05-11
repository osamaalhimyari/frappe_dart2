import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:frappe_dart/frappe_dart.dart';
import 'package:frappe_dart/src/frappe_api.dart';
import 'package:frappe_dart/src/models/error_response.dart';
import 'package:frappe_dart/src/models/report_view_request.dart';
import 'package:frappe_dart/src/models/report_view_response.dart';
import 'package:frappe_dart/src/models/savedocs_response/savedocs_response.dart';
import 'package:frappe_dart/src/models/send_email_response.dart';

/// A class that implements the Frappe API for version 15.
class FrappeV15 implements FrappeApi {
  /// Creates a new instance of [FrappeV15].
  FrappeV15({
    required String baseUrl,
    String? siteName,
    Dio? dio,
    String? cookie,
    String? apiKey,
    String? apiSecret,
  })  : _baseUrl = baseUrl,
        _siteName = siteName ?? '',
        _cookie = cookie,
        _apiKey = apiKey,
        _apiSecret = apiSecret,
        _dio = dio ?? Dio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_apiKey != null && _apiSecret != null) {
            options.headers['Authorization'] = 'token $_apiKey:$_apiSecret';
          }
          handler.next(options);
        },
      ),
    );
  }

  String _baseUrl;
  String _siteName;
  String? _cookie;
  String? _apiKey;
  String? _apiSecret;
  final Dio _dio;

  // Realtime client instance
  FrappeRealtimeClient? _socketio;

  /// The base URL of the Frappe instance.
  String get baseUrl => _baseUrl;

  /// The site name of the Frappe instance.
  String get siteName => _siteName;

  /// The cookie used for authentication.
  String? get cookie => _cookie;

  set baseUrl(String newBaseUrl) {
    _baseUrl = newBaseUrl;
  }

  set cookie(String? newCookie) {
    _cookie = newCookie;
  }

  ///getter of dio
  Dio get dio => _dio;

  /// Get the socketio instance for realtime communication (similar to frappe.socketio in JavaScript)
  FrappeRealtimeClient get socketio {
    if (_siteName.isEmpty) {
      throw Exception('Site name is required to initialize socketio');
    }

    if (_cookie == null || _cookie!.isEmpty) {
      throw Exception('Cookie is required to initialize socketio');
    }

    _socketio ??= FrappeRealtimeClient(
      baseUrl: _baseUrl,
      siteName: _siteName,
      cookie: _cookie ?? '',
      // port: 9000,
    );
    return _socketio!;
  }

  @override
  Future<LoginResponse> login(LoginRequest loginRequest) async {
    final url = '$_baseUrl/api/method/login';
    try {
      // Sending the POST request
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: loginRequest.toMap(),
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
      );

      // Checking the response status
      if (response.statusCode == HttpStatus.ok) {
        final responseBody = response.data!;

        final Map<String, dynamic> headers = response.headers.map;
        if (headers['set-cookie'] != null &&
            headers['set-cookie']![3] != null) {
          responseBody['user_id'] =loginRequest.usr;
              // headers['set-cookie']![3].split(';')[0].split('=')[1];
          responseBody['cookie'] = headers['set-cookie']![0];
        }

        // Returning the parsed response
        return LoginResponse.fromJson(responseBody);
      } else {
        throw Exception(
          '''Failed to login. Response Status: ${response.statusCode}, Body: ${response.data}''',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An unknown error occurred during login: $e');
    }
  }

  @override
  Future<LogoutResponse> logout() async {
    final url = '$_baseUrl/api/method/logout';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(headers: {if (cookie != null) 'Cookie': cookie}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return LogoutResponse.fromMap(response.data!);
      } else {
        throw Exception('Failed to logout. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An unknown error occurred during logout: $e');
    }
  }


  @override
  Future<DeskSidebarItemsResponse> getDeskSideBarItems() async {
    final url =
        '$_baseUrl/api/method/frappe.desk.desktop.get_workspace_sidebar_items';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return DeskSidebarItemsResponse.fromMap(response.data!);
      } else {
        throw Exception(
          '''Failed to get desk sidebar items. Response Status: ${response.statusCode}''',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while retrieving desk sidebar items: $e''',
      );
    }
  }

  @override
  Future<DesktopPageResponse> getDesktopPage(
    DesktopPageRequest deskPageRequest,
  ) async {
    final url = '$_baseUrl/api/method/frappe.desk.desktop.get_desktop_page';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: {'page': deskPageRequest.toJson()},
      );

      if (response.statusCode == HttpStatus.ok) {
        return DesktopPageResponse.fromMap(response.data!);
      } else {
        throw Exception(
          'Failed to get desk page. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while retrieving desk page: $e''',
      );
    }
  }

  @override
  Future<NumberCardResponse> getNumberCard(String doc, String filters) async {
    final url =
        '$_baseUrl/api/method/frappe.desk.doctype.number_card.number_card.get_result';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: {
          'doc': doc,
          'filters': filters,
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        return NumberCardResponse.fromMap(response.data!);
      } else {
        throw Exception(
          '''Failed to get desk number card. Response Status: ${response.statusCode}''',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while retrieving number card: $e''',
      );
    }
  }

  @override
  Future<NumberCardPercentageDifferenceResponse>
      getNumberCardPercentageDifference(
          String doc, String filters, String result) async {
    final url =
        '$_baseUrl/api/method/frappe.desk.doctype.number_card.number_card.get_percentage_difference';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: {
          'doc': doc,
          'filters': filters,
          'result': result,
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        return NumberCardPercentageDifferenceResponse.fromMap(response.data!);
      } else {
        throw Exception(
          '''Failed to get desk number card. Response Status: ${response.statusCode}''',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while retrieving number card: $e''',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getFieldsForTable(String doctype) async {
    final url =
        '$_baseUrl/api/resource/DocType/$doctype';
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data??{};
      } else {
        throw Exception(
          'Failed to get doc. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while retrieving doc: $e''');
    }
  }

  //
  @override
  Future<GetDoctypeResponse> getDoctype(String doctype) async {
    final url =
        '$_baseUrl/api/method/frappe.desk.form.load.getdoctype?doctype=$doctype&with_parent=1';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: {'doctype': doctype},
      );

      if (response.statusCode == HttpStatus.ok) {
        return GetDoctypeResponse.fromMap(response.data!);
      } else {
        throw Exception(
          'Failed to get doc. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while retrieving doc: $e''');
    }
  }

  @override
  Future<Map<String, dynamic>> getList({
    required String doctype,
    List<String>? fields,
    int? limitStart,
    int? limitPageLength,
    String? orderBy,
    String? parent,
    Map<String, dynamic>? filters,
    String? groupBy,
    bool? debug,
    bool? asDict,
    Map<String, dynamic>? orFilters,
  }) async {
    final url = '$_baseUrl/api/method/frappe.client.get_list';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: {
          'doctype': doctype,
          if (fields != null) 'fields': jsonEncode(fields),
          if (filters != null) 'filters': jsonEncode(filters),
          if (groupBy != null) 'group_by': groupBy,
          if (orderBy != null) 'order_by': orderBy,
          if (limitStart != null) 'limit_start': limitStart.toString(),
          if (limitPageLength != null)
            'limit_page_length': limitPageLength.toString(),
          if (parent != null) 'parent': parent,
          if (debug != null) 'debug': debug.toString(),
          if (asDict != null) 'as_dict': asDict.toString(),
          if (orFilters != null) 'or_filters': jsonEncode(orFilters),
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data ?? {};
      } else {
        throw Exception(
          'Failed to get doc. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while retrieving doc: $e''');
    }
  }

  @override
  Future<GetDocResponse> getdoc(String doctype, String name) async {
    final url = '$_baseUrl/api/method/frappe.desk.form.load.getdoc';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: {'doctype': doctype, 'name': name},
      );

      if (response.statusCode == HttpStatus.ok) {
        return GetDocResponse.fromMap(response.data!);
      } else {
        throw Exception(
          'Failed to get doc. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while retrieving doc: $e''');
    }
  }
  @override
  Future<Map<String,dynamic>> getdocData(String doctype, String name) async {
    final url = '$_baseUrl/api/resource/$doctype/$name';
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        // data: {'doctype': doctype, 'name': name},
      );

      if (response.statusCode == HttpStatus.ok) {
        return (response.data!);
      } else {
        throw Exception(
          'Failed to get doc. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while retrieving doc: $e''');
    }
  }

  @override
  Future<GetCountResponse> getCount(GetCountRequest getCountRequest) async {
    final url =
        '$_baseUrl/api/method/frappe.client.get_count?doctype=${getCountRequest.doctype}';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: getCountRequest.toMap(),
      );

      if (response.statusCode == HttpStatus.ok) {
        return GetCountResponse.fromMap(response.data!);
      } else {
        throw Exception(
          'Failed to get doc. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while retrieving doc: $e''');
    }
  }

  @override
  Future<SavedocsReponse<T>> savedocs<T>({
    required T document,
    required String action,
    required String Function() toJson,
    required T Function(Map<String, dynamic>) fromMap,
  }) async {
    final url = '$_baseUrl/api/method/frappe.desk.form.save.savedocs';

    try {
      final response = await dio.post<Map<String, dynamic>>(
        url,
        data: {'doc': toJson(), 'action': action},
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return SavedocsReponse.fromMap<T>(response.data!, fromMap);
      } else {
        throw Exception('Failed to save doc. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An unknown error occurred while saving doc: $e');
    }
  }

  @override
  Future<SearchLinkResponse> searchLink(
    SearchLinkRequest searchLinkRequest,
  ) async {
    final url = '$_baseUrl/api/method/frappe.desk.search.search_link';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(headers: {if (cookie != null) 'Cookie': cookie}),
        data: searchLinkRequest.toMap(),
      );

      if (response.statusCode == HttpStatus.ok) {
        return SearchLinkResponse.fromMap(response.data!);
      } else {
        throw Exception(
          'Failed to search link. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while searching link: $e''');
    }
  }

  @override
  Future<Map<String, dynamic>> validateLink(
    ValidateLinkRequest validateLinkRequest,
  ) async {
    final url = '$_baseUrl/api/method/frappe.client.validate_link';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: validateLinkRequest.toMap(),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data!;
      } else {
        throw Exception(
          'Failed to search link. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while searching for link: $e''',
      );
    }
  }

  @override
  Future<SystemSettingsResponse> getSystemSettings() async {
    final url =
        '$_baseUrl/api/method/frappe.core.doctype.system_settings.system_settings.load';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(headers: {if (cookie != null) 'Cookie': cookie}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return SystemSettingsResponse.fromMap(response.data!);
      } else {
        throw Exception(
          '''Failed to get system settings. Response Status: ${response.statusCode}''',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while retrieving system settings: $e''',
      );
    }
  }

  @override
  Future<GetVersionsResponse> getVersions() async {
    final url = '$_baseUrl/api/method/frappe.utils.change_log.get_versions';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(headers: {if (cookie != null) 'Cookie': cookie}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return GetVersionsResponse.fromMap(response.data!);
      } else {
        throw Exception(
          'Failed to get versions. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while retrieving versions: $e''',
      );
    }
  }

  @override
  Future<LoggedUserResponse> getLoggerUser() async {
    final url = '$_baseUrl/api/method/frappe.auth.get_logged_user';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(headers: {if (cookie != null) 'Cookie': cookie}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return LoggedUserResponse.fromMap(response.data!);
      } else {
        throw Exception(
          'Failed to get logged user. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while retrieving logged user: $e''',
      );
    }
  }
  @override
  Future<Map<String, dynamic>> getSessionDefaultValues() async {
    final url = '$_baseUrl/api/method/frappe.core.doctype.session_default_settings.session_default_settings.get_session_default_values';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(headers: {if (cookie != null) 'Cookie': cookie}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data??{};
      } else {
        throw Exception(
          'Failed to get session default values. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while retrieving session default values: $e''',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> notificationsLog() async {
    final url = '$_baseUrl/api/method/frappe.desk.doctype.notification_log.notification_log.get_notification_logs';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(headers: {if (cookie != null) 'Cookie': cookie}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data??{};
      } else {
        throw Exception(
          'Failed to get notification logs. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while retrieving notification logs: $e''',
      );
    }
  }


  @override
  Future<AppsResponse> getApps() async {
    final url = '$_baseUrl/api/method/frappe.apps.get_apps';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(headers: {if (cookie != null) 'Cookie': cookie}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return AppsResponse.fromMap(response.data!);
      } else {
        throw Exception(
          'Failed to get apps. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while retrieving apps: $e''',
      );
    }
  }

  @override
  Future<UserInfoResponse> getUserInfo() async {
    final url = '$_baseUrl/api/method/frappe.realtime.get_user_info';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(headers: {if (cookie != null) 'Cookie': cookie}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return UserInfoResponse.fromMap(response.data!);
      } else {
        throw Exception(
          'Failed to get apps. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while retrieving apps: $e''',
      );
    }
  }

  @override
  Future<PingResponse> ping() async {
    final url = '$_baseUrl/api/method/ping';
    try {
      final response = await _dio.post<Map<String, dynamic>>(url);

      if (response.statusCode == HttpStatus.ok) {
        return PingResponse.fromMap(response.data!);
      } else {
        throw Exception(
          'Failed to ping. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while pinging: $e''');
    }
  }

  @override
  Future<Map<String, dynamic>> save(Map<String, dynamic> doc) async {
    final url = '$_baseUrl/api/method/frappe.client.save';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: {'doc': json.encode(doc)},
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data ?? {};
      } else {
        throw Exception(
          'Failed to save doc. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while saving doc: $e''');
    }
  }

  @override
  Future<Map<String, dynamic>> deleteDoc(
    DeleteDocRequest deleteDocRequest,
  ) async {
    final url = '$_baseUrl/api/method/frappe.client.delete';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: deleteDocRequest.toMap(),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data ?? {};
      } else {
        throw Exception(
          'Failed to delete doc. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while deleting doc: $e''');
    }
  }

  @override
  Future<Map<String, dynamic>> getValue({
    required String doctype,
    required String fieldname,
  }) async {
    final url =
        '$_baseUrl/api/method/frappe.client.get_value?doctype=$doctype&fieldname=$fieldname';

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        options: Options(headers: {if (cookie != null) 'Cookie': cookie}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data ?? {};
      } else {
        throw Exception(
          'Failed to get value. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while getting value: $e''');
    }
  }

  @override
  Future<Map<String, dynamic>> get(GetRequest getRequest) async {
    final url = '$_baseUrl/api/method/frappe.client.get';

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            if (cookie != null) 'Cookie': cookie,
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
        data: getRequest.toMap(),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data ?? {};
      } else {
        throw Exception(
          'Failed to get value. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while getting value: $e''');
    }
  }

  @override
  Future<Map<String, dynamic>> call({
    required String method,
    required String type,
    Map<String, dynamic>? args,
    String? url,
  }) async {
    final apiUrl = url ?? '$_baseUrl/api/method/$method';
    try {
      final response = await _dio.request<Map<String, dynamic>>(
        apiUrl,
        options: Options(
          method: type,
          headers: {if (cookie != null) 'Cookie': cookie},
        ),
        data: args,
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data ?? {};
      } else {
        throw Exception(
          'Failed to call. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while calling: $e''');
    }
  }

  @override
  Future<Map<String, dynamic>> getDashboardChart(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$baseUrl/api/method/frappe.desk.doctype.dashboard_chart.dashboard_chart.get',
        data: payload,
        options: Options(headers: {if (cookie != null) 'Cookie': cookie}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data!;
      } else {
        throw Exception(
          'Failed to get dashboard chart. Response Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception(
        '''An unknown error occurred while retrieving dashboard chart: $e''',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getReportRun(
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        '$baseUrl/api/method/frappe.desk.query_report.run',
        data: payload,
        options: Options(headers: {if (cookie != null) 'Cookie': cookie}),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data!;
      } else {
        throw Exception('Failed to get report run');
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while calling: $e''');
    }
  }

  @override
  Future<SendEmailResponse> sendEmail({
    required String recipients,
    required String subject,
    required String content,
    required String doctype,
    required String name,
    required String sendEmail,
    required String printFormat,
    required String senderFullName,
    required String lang,
  }) async {
    final url =
        '$baseUrl/api/method/frappe.core.doctype.communication.email.make';

    try {
      final response = await dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: {
          'recipients': recipients,
          'subject': subject,
          'content': content,
          'doctype': doctype,
          'name': name,
          'send_email': sendEmail,
          'print_format': printFormat,
          'sender_full_name': senderFullName,
          '_lang': lang,
        },
      );

      if (response.statusCode == HttpStatus.ok) {
        return SendEmailResponse.fromMap(response.data!);
      } else {
        final res = ErrorResponse.fromMap(response.data!);
        throw Exception(
          'Failed to send email. HTTP Status: ${response.statusCode}, data: ${res.exception}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred while sending email: $e');
    }
  }

  Future<ReportViewResponse> getReportView(
    ReportViewRequest reportViewRequest,
  ) async {
    final url = '$baseUrl/api/method/frappe.desk.reportview.get_list';

    try {
      final response = await dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: jsonEncode(reportViewRequest.toMap()),
      );

      if (response.statusCode == 200) {
        // Decode the response body into a Map and explicitly cast it
        return ReportViewResponse.fromJson(response.data!);
      } else {
        throw Exception(
          'Failed to get list. HTTP Status: ${response.statusCode}, Response: ${response.data!}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred while fetching the list: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> mapDocs({
    required List<String> sourceName,
    required Map<String, dynamic> targetDoc,
    required String method,
  }) async {
    try {
      final payload = 'method=$method'
          '&source_names=${Uri.encodeComponent(jsonEncode(sourceName))}'
          '&target_doc=${Uri.encodeComponent(json.encode(targetDoc))}';

      final response = await dio.post<Map<String, dynamic>>(
        '$baseUrl/api/method/frappe.model.mapper.map_docs',
        data: payload,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {if (cookie != null) 'Cookie': cookie},
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data!;
      } else {
        print('Server error: ${response.statusCode}');
        throw Exception('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('An error occurred: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> switchTheme({required String theme}) async {
    final url =
        '$baseUrl/api/method/frappe.core.doctype.user.user.switch_theme';

    try {
      final payload = {'theme': theme};
      final response = await dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: payload,
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data!;
      } else {
        throw Exception(
          'Failed to switch theme. HTTP Status: ${response.statusCode}, data: ${response.data!}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred while switching theme: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> searchWidget({
    required String doctype,
    required String txt,
    required String query,
    required Map<String, dynamic> filters,
    List<String>? filterFields,
    String? searchField,
    String start = '0',
    String pageLength = '10',
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '$baseUrl/api/method/frappe.desk.search.search_widget',
        queryParameters: {
          'doctype': doctype,
          'txt': txt,
          'filters': jsonEncode(filters),
          if (filterFields != null) 'filter_fields': jsonEncode(filterFields),
          'page_length': '25',
          'as_dict': '1',
          if (query.isNotEmpty) 'query': query,
          if (searchField != null) 'search_field': searchField,
          if (start != '0') 'start': start,
          if (pageLength != '10') 'page_length': pageLength,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data!;
      } else {
        throw Exception('''An unknown error occurred while calling''');
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('''An unknown error occurred while calling: $e''');
    }
  }

  @override
  Future<Map<String, dynamic>> runDocMethod({
    required Map<String, dynamic> data,
    required String method,
  }) async {
    final url = '$baseUrl/api/method/run_doc_method';

    try {
      final response = await dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
            if (cookie != null) 'Cookie': cookie,
          },
        ),
        data: {'docs': json.encode(data), 'method': method},
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data!;
      } else {
        throw Exception(
          'Failed to run doc method. HTTP Status: ${response.statusCode}, data: ${response.data!}',
        );
      }
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred while running doc method: $e');
    }
  }

  // ===========================================================================
  // Token auth
  // ===========================================================================

  @override
  void setApiToken({String? apiKey, String? apiSecret}) {
    _apiKey = apiKey;
    _apiSecret = apiSecret;
  }

  /// Builds the Cookie/Authorization headers used by request helpers.
  ///
  /// The Dio interceptor already injects the `Authorization` header for
  /// API-key/secret auth; this helper just keeps existing cookie behaviour
  /// for the new methods.
  Map<String, String> _authHeaders([Map<String, String>? extra]) {
    return {
      if (_cookie != null) 'Cookie': _cookie!,
      if (extra != null) ...extra,
    };
  }

  Future<Map<String, dynamic>> _postForm(
    String method,
    Map<String, dynamic> body,
  ) async {
    final url = '$_baseUrl/api/method/$method';
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        url,
        options: Options(
          headers: _authHeaders({
            'Content-Type': 'application/x-www-form-urlencoded',
          }),
        ),
        data: body,
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data ?? <String, dynamic>{};
      }
      throw Exception(
        'Failed to call $method. Status: ${response.statusCode}, '
        'data: ${response.data}',
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An unknown error occurred while calling $method: $e');
    }
  }

  // ===========================================================================
  // Client CRUD parity
  // ===========================================================================

  @override
  Future<Map<String, dynamic>> insert(Map<String, dynamic> doc) {
    return _postForm('frappe.client.insert', {'doc': json.encode(doc)});
  }

  @override
  Future<Map<String, dynamic>> insertMany(
    List<Map<String, dynamic>> docs,
  ) {
    return _postForm(
      'frappe.client.insert_many',
      {'docs': json.encode(docs)},
    );
  }

  @override
  Future<Map<String, dynamic>> setValue({
    required String doctype,
    required String name,
    required Object fieldname,
    Object? value,
  }) {
    return _postForm('frappe.client.set_value', {
      'doctype': doctype,
      'name': name,
      'fieldname':
          fieldname is String ? fieldname : json.encode(fieldname),
      if (value != null) 'value': value is String ? value : json.encode(value),
    });
  }

  @override
  Future<Map<String, dynamic>> bulkUpdate(List<Map<String, dynamic>> docs) {
    return _postForm(
      'frappe.client.bulk_update',
      {'docs': json.encode(docs)},
    );
  }

  @override
  Future<Map<String, dynamic>> renameDoc({
    required String doctype,
    required String oldName,
    required String newName,
    bool merge = false,
  }) {
    return _postForm('frappe.client.rename_doc', {
      'doctype': doctype,
      'old_name': oldName,
      'new_name': newName,
      'merge': merge ? 1 : 0,
    });
  }

  @override
  Future<Map<String, dynamic>> submit(Map<String, dynamic> doc) {
    return _postForm('frappe.client.submit', {'doc': json.encode(doc)});
  }

  @override
  Future<Map<String, dynamic>> cancel({
    required String doctype,
    required String name,
  }) {
    return _postForm('frappe.client.cancel', {
      'doctype': doctype,
      'name': name,
    });
  }

  @override
  Future<Map<String, dynamic>> getSingleValue({
    required String doctype,
    required String field,
  }) async {
    final url = '$_baseUrl/api/method/frappe.client.get_single_value'
        '?doctype=${Uri.encodeQueryComponent(doctype)}'
        '&field=${Uri.encodeQueryComponent(field)}';
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        options: Options(headers: _authHeaders()),
      );
      if (response.statusCode == HttpStatus.ok) {
        return response.data ?? <String, dynamic>{};
      }
      throw Exception(
        'Failed to get single value. Status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred while getting single value: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> hasPermission({
    required String doctype,
    required String docname,
    String permType = 'read',
  }) {
    return _postForm('frappe.client.has_permission', {
      'doctype': doctype,
      'docname': docname,
      'perm_type': permType,
    });
  }

  @override
  Future<Map<String, dynamic>> getPassword({
    required String doctype,
    required String name,
    required String fieldname,
  }) {
    return _postForm('frappe.client.get_password', {
      'doctype': doctype,
      'name': name,
      'fieldname': fieldname,
    });
  }

  // ===========================================================================
  // Files
  // ===========================================================================

  @override
  Future<Map<String, dynamic>> uploadFile({
    required List<int> fileBytes,
    required String fileName,
    String? doctype,
    String? docname,
    String? fieldname,
    bool isPrivate = false,
    String? folder,
    bool optimize = false,
  }) async {
    final url = '$_baseUrl/api/method/upload_file';
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
        'file_name': fileName,
        'is_private': isPrivate ? 1 : 0,
        if (doctype != null) 'doctype': doctype,
        if (docname != null) 'docname': docname,
        if (fieldname != null) 'fieldname': fieldname,
        if (folder != null) 'folder': folder,
        if (optimize) 'optimize': 1,
      });

      final response = await _dio.post<Map<String, dynamic>>(
        url,
        data: formData,
        options: Options(headers: _authHeaders()),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data ?? <String, dynamic>{};
      }
      throw Exception(
        'Failed to upload file. Status: ${response.statusCode}, '
        'data: ${response.data}',
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred while uploading file: $e');
    }
  }

  @override
  Future<List<int>> downloadFile(String fileUrl) async {
    final url = fileUrl.startsWith('http') ? fileUrl : '$_baseUrl$fileUrl';
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(
          headers: _authHeaders(),
          responseType: ResponseType.bytes,
        ),
      );
      if (response.statusCode == HttpStatus.ok) {
        return response.data ?? const <int>[];
      }
      throw Exception(
        'Failed to download file. Status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred while downloading file: $e');
    }
  }

  // ===========================================================================
  // Collaboration
  // ===========================================================================

  @override
  Future<Map<String, dynamic>> assignTo({
    required List<String> assignTo,
    required String doctype,
    required String name,
    String? description,
    String? priority,
    String? dateOfAssignment,
    bool notify = false,
  }) {
    return _postForm('frappe.desk.form.assign_to.add', {
      'assign_to': json.encode(assignTo),
      'doctype': doctype,
      'name': name,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (dateOfAssignment != null) 'date': dateOfAssignment,
      'notify': notify ? 1 : 0,
    });
  }

  @override
  Future<Map<String, dynamic>> removeAssign({
    required String doctype,
    required String name,
    required String assignTo,
  }) {
    return _postForm('frappe.desk.form.assign_to.remove', {
      'doctype': doctype,
      'name': name,
      'assign_to': assignTo,
    });
  }

  @override
  Future<Map<String, dynamic>> addComment({
    required String referenceDoctype,
    required String referenceName,
    required String content,
    String? commentEmail,
    String? commentBy,
  }) {
    return _postForm('frappe.desk.form.utils.add_comment', {
      'reference_doctype': referenceDoctype,
      'reference_name': referenceName,
      'content': content,
      if (commentEmail != null) 'comment_email': commentEmail,
      if (commentBy != null) 'comment_by': commentBy,
    });
  }

  @override
  Future<Map<String, dynamic>> addTag({
    required String tag,
    required String doctype,
    required String docname,
  }) {
    return _postForm('frappe.desk.doctype.tag.tag.add_tag', {
      'tag': tag,
      'dt': doctype,
      'dn': docname,
    });
  }

  @override
  Future<Map<String, dynamic>> removeTag({
    required String tag,
    required String doctype,
    required String docname,
  }) {
    return _postForm('frappe.desk.doctype.tag.tag.remove_tag', {
      'tag': tag,
      'dt': doctype,
      'dn': docname,
    });
  }

  @override
  Future<Map<String, dynamic>> shareAdd({
    required String doctype,
    required String name,
    required String user,
    bool read = true,
    bool write = false,
    bool share = false,
    bool everyone = false,
    bool notify = false,
  }) {
    return _postForm('frappe.share.add', {
      'doctype': doctype,
      'name': name,
      'user': user,
      'read': read ? 1 : 0,
      'write': write ? 1 : 0,
      'share': share ? 1 : 0,
      'everyone': everyone ? 1 : 0,
      'notify': notify ? 1 : 0,
    });
  }

  @override
  Future<Map<String, dynamic>> shareRemove({
    required String doctype,
    required String name,
    required String user,
  }) {
    return _postForm('frappe.share.remove', {
      'doctype': doctype,
      'name': name,
      'user': user,
    });
  }

  // ===========================================================================
  // Workflow
  // ===========================================================================

  @override
  Future<Map<String, dynamic>> applyWorkflow({
    required Map<String, dynamic> doc,
    required String action,
  }) {
    return _postForm('frappe.model.workflow.apply_workflow', {
      'doc': json.encode(doc),
      'action': action,
    });
  }

  @override
  Future<Map<String, dynamic>> getWorkflowTransitions(
    Map<String, dynamic> doc,
  ) {
    return _postForm(
      'frappe.model.workflow.get_transitions',
      {'doc': json.encode(doc)},
    );
  }

  // ===========================================================================
  // Print / PDF
  // ===========================================================================

  @override
  Future<List<int>> downloadPdf({
    required String doctype,
    required String name,
    String format = 'Standard',
    bool noLetterhead = false,
    String? lang,
    String? letterhead,
  }) async {
    final url = '$_baseUrl/api/method/frappe.utils.print_format.download_pdf';
    try {
      final response = await _dio.get<List<int>>(
        url,
        queryParameters: {
          'doctype': doctype,
          'name': name,
          'format': format,
          'no_letterhead': noLetterhead ? 1 : 0,
          if (lang != null) '_lang': lang,
          if (letterhead != null) 'letterhead': letterhead,
        },
        options: Options(
          headers: _authHeaders(),
          responseType: ResponseType.bytes,
        ),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data ?? const <int>[];
      }
      throw Exception(
        'Failed to download PDF. Status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred while downloading PDF: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPrintHtml({
    required String doctype,
    required String name,
    String format = 'Standard',
    bool noLetterhead = false,
    String? lang,
    String? letterhead,
  }) async {
    final url =
        '$_baseUrl/api/method/frappe.www.printview.get_html_and_style';
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        url,
        queryParameters: {
          'doctype': doctype,
          'name': name,
          'print_format': format,
          'no_letterhead': noLetterhead ? 1 : 0,
          if (lang != null) '_lang': lang,
          if (letterhead != null) 'letterhead': letterhead,
        },
        options: Options(headers: _authHeaders()),
      );

      if (response.statusCode == HttpStatus.ok) {
        return response.data ?? <String, dynamic>{};
      }
      throw Exception(
        'Failed to get print html. Status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      throw Exception(handleDioError(e));
    } catch (e) {
      throw Exception('An error occurred while getting print html: $e');
    }
  }
}
