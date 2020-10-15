import 'dart:convert';
import 'package:alice_video_box/models/common_utils.dart';
import 'package:http/http.dart' as http;

enum HttpMethod { GET, POST }
enum HttpBodyEncoding { JSON, PLAIN, FormURLEncoded }

class HttpResponse {
  final http.Response _response;
  final Map<String, String> _cookies;

  HttpResponse(this._response, this._cookies);

  int get statusCode => _response.statusCode;
  bool get hasError => (400 <= statusCode) && (statusCode < 600);
  bool get success => !hasError;

  Uri get requestUrl => _response.request.url;
  Map<String, String> get headers => _response.headers;
  String get contentType => _response.headers['content-type'];

  bool get isEmptyCookies => _cookies.isEmpty;
  Map<String, String> get cookies => _cookies;

  List<int> bytes() {
    return _response.bodyBytes;
  }

  String content() {
    return utf8.decode(bytes(), allowMalformed: true);
  }
}

class HttpService {
  static const int DEFAULT_TIMEOUT_SECONDS = 10;

  static Set _cookiesKeysToIgnore = Set.from([
    'samesite',
    'path',
    'domain',
    'max-age',
    'expires',
    'secure',
    'httponly'
  ]);

  http.Client _httpClient;
  Map<String, String> _cookiesMap;

  HttpService({http.Client httpClient}) {
    _httpClient = httpClient == null ? http.Client() : httpClient;
    _cookiesMap = new Map<String, String>();
  }

  static String getHostName(String url) {
    var uri = Uri.parse(url);

    return uri.host;
  }

  Map<String, String> _makeHeaders(Uri uri, Map<String, String> customHeaders) {
    Map<String, String> requestHeaders = new Map<String, String>();

    var cookies = getCookies(uri.host);
    if (cookies != null) {
      var cookiesString = 
        cookies.keys.map((key) => '$key=${cookies[key]}').join(';');
      
      requestHeaders['cookie'] = cookiesString;
    }

    if (customHeaders != null) {
      requestHeaders.addAll(customHeaders);
    }

    return requestHeaders;
  }

  Future<http.Response> _makeGetRequest(Uri uri, Map<String, String> requestHeaders, Map<String, String> params) {
    if(params != null) {
      uri = uri.replace(queryParameters: params);
    }

    return _httpClient.get(uri, headers: requestHeaders);
  }

  Future<http.Response> _makePostRequest(Uri uri, Map<String, String> requestHeaders, {HttpBodyEncoding bodyEncoding, dynamic data}) {
    String contentTypeHeader = "application/x-www-form-urlencoded";
    String requestBody;
    
    if(data != null) {
      switch(bodyEncoding) {
        case HttpBodyEncoding.JSON:
          contentTypeHeader = "application/json";
          requestBody = CommonUtils.convertToJson(data);
          break;
        case HttpBodyEncoding.FormURLEncoded:
          contentTypeHeader = "application/x-www-form-urlencoded";
          requestBody = CommonUtils.encodeMap(data);
          break;
        case HttpBodyEncoding.PLAIN:
          contentTypeHeader = "text/plain";
          requestBody = data.toString();
          break;
      }
    }

    if(!CommonUtils.hasKeyIgnoreCase(requestHeaders, 'content-type')) requestHeaders['content-type'] = contentTypeHeader;

    return _httpClient.post(uri, headers: requestHeaders, body: requestBody);
  }

  // https://stackoverflow.com/questions/52241089/how-do-i-make-an-http-request-using-cookies-on-flutter
  // https://github.com/dart-lang/http/issues/362
  static Map<String, String> _extractResponseCookies(Map<String, String> headers) {
    Map<String, String> cookies = {};

    for(var key in headers.keys) {
      if (CommonUtils.equalsIgnoreCase(key, 'set-cookie')) {
        String rawCookieString = headers[key];

        var setCookies = rawCookieString.split(new RegExp("(?<=)(,)(?=[^;]+?=)"));
        setCookies.forEach((cookieString) {
          cookieString
          .split(';')
          .map((c) => CommonUtils.split(c.trim(), '=', max: 1))
          .where((c) => c.length == 2)
          .where((c) => !_cookiesKeysToIgnore.contains(c[0].toLowerCase()))
          .forEach((c) => cookies[c[0]] = c[1]);
        });

        break;
      }
    }

    return cookies;
  }

  void setCookies(String hostName, Map<String, String> cookies) {
    var hostHash = CommonUtils.hash256String(hostName);
    var cookiesJson = CommonUtils.convertToJson(cookies);

    _cookiesMap[hostHash] = cookiesJson;
  }

  Map<String, String> getCookies(String hostName) {
    var hostHash = CommonUtils.hash256String(hostName);
    if(_cookiesMap.containsKey(hostHash)) {
      var cookiesJson = _cookiesMap[hostHash];

      var rawCookies = CommonUtils.convertFromJson(cookiesJson);
      
      return rawCookies.cast<String, String>();
    }
    else return null;
  }

  HttpResponse _handleResponse(Uri uri, http.Response rawResponse) {
    var cookies = _extractResponseCookies(rawResponse.headers);

    if (cookies.isNotEmpty) {
      setCookies(uri.host, cookies);
    }

    return new HttpResponse(rawResponse, cookies);
  }

  Future<HttpResponse> _makeRequest(
    HttpMethod httpMethod, String url,
    {
    Map<String, String> customHeaders,
    dynamic data,
    HttpBodyEncoding bodyEncoding,
    int requestTimeout,
    }
  ) async {

    var uri = Uri.parse(url);

    if (uri.scheme != 'http' && uri.scheme != 'https')
      throw ArgumentError("invalid url, must start with 'http://' or 'https://'");

    var requestHeaders = _makeHeaders(uri, customHeaders);

    Future<http.Response> futureResponse;
    switch (httpMethod) {
      case HttpMethod.GET:
        futureResponse = _makeGetRequest(uri, requestHeaders, data);
        break;
      case HttpMethod.POST:
        futureResponse = _makePostRequest(uri, requestHeaders, 
          bodyEncoding: bodyEncoding, data: data
        );
        break;
    }

    var response = await futureResponse.timeout(new Duration(seconds: requestTimeout));
    if ((response != null) && (response is http.StreamedResponse)) {
      response = await http.Response.fromStream(response as http.StreamedResponse);
    }

    return _handleResponse(uri, response);
  }

  Future<HttpResponse> getRequest(String url,
  {
    Map<String, String> customHeaders,
    Map<String, String> queryParams,
    int requestTimeout = DEFAULT_TIMEOUT_SECONDS
  }) async {
    return await _makeRequest(HttpMethod.GET, url, 
      customHeaders: customHeaders, data: queryParams, requestTimeout: requestTimeout);
  }

  Future<HttpResponse> postRequest(String url,
  {
    Map<String, String> customHeaders,
    dynamic data,
    HttpBodyEncoding bodyEncoding = HttpBodyEncoding.FormURLEncoded,
    int requestTimeout = DEFAULT_TIMEOUT_SECONDS,
  }) async {
    return await _makeRequest(HttpMethod.POST, url,
      customHeaders: customHeaders, data: data, bodyEncoding: bodyEncoding, requestTimeout: requestTimeout
    );
  }
}
