import 'dart:convert';
import 'package:alice_video_box/models/common_utils.dart';
import 'package:alice_video_box/models/http_service.dart';
import 'package:alice_video_box/models/service_locator.dart';
import 'package:meta/meta.dart';
import 'package:requests/requests.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AuthResult {
  SUCCESS,
  NOREDIRECT,
  NOSESSIONID,
  NOCSRFTOKEN,
  UNKNOWN,
}

enum LoadResult { SUCCESS, FAIL }
enum SaveResult { SUCCESS, FAIL }
enum PlayResult { SUCCESS, FAIL }

class AliceStation {
  final String id;
  final String iconUrl;
  final String name;
  final bool online;

  AliceStation({this.id, this.iconUrl, this.name, this.online});

  factory AliceStation.fromJson(Map<String, dynamic> jsonObj) {
    var id = jsonObj['id'] as String;
    var iconUrl = jsonObj['icon'] as String;
    var name = jsonObj['name'] as String;
    var online = jsonObj['online'] as bool;

    return AliceStation(id: id, iconUrl: iconUrl, name: name, online: online);
  }
}

class AliceStationService {
  static const Map<String, String> _customHeaders = {
    'Connection': 'keep-alive',
    'Accept':
        'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
    'User-agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_5) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.1.1 Safari/605.1.15',
    'Accept-language': 'ru',
    'Referer': '',
    'Accept-encoding': 'gzip, deflate, br'
  };
  static const String _authUrl = 'https://passport.yandex.ru/passport?mode=auth&retpath=https://yandex.ru';
  static const String _csrfUrl = 'https://frontend.vh.yandex.ru/csrf_token';
  static const String _deviceUrl = 'https://quasar.yandex.ru/devices_online_stats';
  static const String _playVideoUrl = 'https://yandex.ru/video/station';

  static const String _userSessionKey = "_userSessionCookies";

  HttpService _httpService;
  Map<String, String> _cookies;
  String _csrfToken;

  bool get isLogged => (_cookies != null) && ((_csrfToken != null) && (_csrfToken.isNotEmpty));

  AliceStationService() {
    _httpService = gServiceLocator<HttpService>();
  }

  Future<AuthResult> _getCsrfToken(Map<String, String> cookies) async {
    Uri csrfUrl = Uri.parse(_csrfUrl);
    _httpService.setCookies(csrfUrl.host, cookies);

    var csrfResponse = await _httpService.getRequest(_csrfUrl);
    if(csrfResponse.success) {
      _cookies = cookies;
      _csrfToken = csrfResponse.content();

      return AuthResult.SUCCESS;
    }

    return AuthResult.NOCSRFTOKEN;
  }

  Future<AuthResult> login({@required String login, @required String passwd}) async {
    // Make auth map struct
    Map<String, String> authData = {
      'login': login,
      'passwd': passwd
    };

    // HttpBodyEncoding = FormURLEncoded
    var authResponse = await _httpService.postRequest(_authUrl, data: authData);
    if(authResponse.success) {
      if (authResponse.cookies.containsKey('Session_id')) {
        // Get CSRF token
        return await _getCsrfToken(authResponse.cookies);
      }
      else return AuthResult.NOSESSIONID;
    }

    return AuthResult.UNKNOWN;
  }

  void clearUserSession() {
    _cookies.clear();
    _csrfToken = null;
  }

  Future<List<AliceStation>> getDevices() async {
    if(!isLogged) return null;

    var deviceUri = Uri.parse(_deviceUrl);
    _httpService.setCookies(deviceUri.host, _cookies);

    var deviceResponse = await _httpService.getRequest(_deviceUrl);
    if (deviceResponse.success) {
      var deviceJson = deviceResponse.content();
      Map<String, dynamic> jsonContent = jsonDecode(deviceJson);

      List<AliceStation> stationList = new List<AliceStation>();
      for(var jsonItem in jsonContent['items']) {
        stationList.add(AliceStation.fromJson(jsonItem));
      }

      return stationList;
    }

    return null;
  }

  Future<SaveResult> saveUserSession() async {
    // save cookies in shared preferences
    if(isLogged) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var cookieString = CommonUtils.convertToJson(_cookies);
      return await prefs.setString(_userSessionKey, cookieString) ? SaveResult.SUCCESS : SaveResult.FAIL;
    }

    return SaveResult.FAIL;
  }

  Future<AuthResult> getUserSession() async {
    if(isLogged) return AuthResult.SUCCESS;
    
    // get cookies from shared preferenses
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(prefs.containsKey(_userSessionKey)) {
      var cookieString = prefs.getString(_userSessionKey);
      var cookies = CommonUtils.convertFromJson(cookieString).cast<String, String>();

      // try to get csrf token
      var csrfResult = await _getCsrfToken(cookies);
      if (csrfResult != AuthResult.SUCCESS) {
        await prefs.remove(_userSessionKey);
      }

      return csrfResult;
    }
    
    return AuthResult.NOSESSIONID;
  }

  Future<PlayResult> playVideoFromUrl(String deviceId, String videoUrl) async {
    var bodyData = {
      "msg": {
        "provider_item_id": videoUrl,
        "player_id": "youtube"
      },
      "device": deviceId
    };

    var headers = {
      'x-csrf-token': _csrfToken
    };

    Uri playUri = Uri.parse(_playVideoUrl);
    _httpService.setCookies(playUri.host, _cookies);

    var playResponse = await _httpService.postRequest(
      _playVideoUrl,
      customHeaders: headers,
      bodyEncoding: HttpBodyEncoding.JSON,
      data: bodyData,
      requestTimeout: 20
    );

    return playResponse.success ? PlayResult.SUCCESS : PlayResult.FAIL;
  }
}