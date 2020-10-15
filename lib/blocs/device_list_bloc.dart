import 'dart:async';
import 'package:alice_video_box/models/service_locator.dart';
import 'package:meta/meta.dart';
import 'package:alice_video_box/blocs/appstate_bloc.dart';
import 'package:alice_video_box/models/alice_service.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/subjects.dart';

class Device {
  final String id;
  final String name;
  final String iconUrl;

  Device({this.id, this.name, this.iconUrl});

  factory Device.fromAliceStation(AliceStation station) {
    return new Device(
      id: station.id, 
      name: station.name, 
      iconUrl: station.iconUrl
    );
  }
}

abstract class DeviceListState {
  DeviceListState();

  factory DeviceListState.init() => new DeviceListStateInit();
  factory DeviceListState.loading() => new DeviceListStateLoading();
  factory DeviceListState.loggedOut() => new DeviceListStateLoggedOut();
  
  factory DeviceListState.loadedAlice(List<AliceStation> stationList) {
    if(stationList.length == 1) {
      return DeviceListStateSingle.fromStation(stationList[0]);
    }
    else if(stationList.length > 1) {
      return DeviceListStateLoaded.fromStationList(stationList);
    }
    else {
      return new DeviceListStateNoDevice();
    }  
  }
  
  factory DeviceListState.selectDevice(Device device) =>
    new DeviceListStateSelectDevice(device: device);

  factory DeviceListState.playingVideo(Device device, PlayResult playResult) =>
    new DeviceListStateDevicePlaying(device: device, playResult: playResult);
}

class DeviceListStateInit extends DeviceListState {}
class DeviceListStateLoading extends DeviceListState {}
class DeviceListStateLoggedOut extends DeviceListState {}
class DeviceListStateNoDevice extends DeviceListState {}

class DeviceListStateSingle extends DeviceListState {
  Device _device;
  Device get device => _device;

  DeviceListStateSingle.fromStation(AliceStation station) {
    _device = Device.fromAliceStation(station);
  }
}

class DeviceListStateLoaded extends DeviceListState {
  final List<Device> devices = new List<Device>();

  DeviceListStateLoaded.fromStationList(List<AliceStation> stationList) {
    devices.clear();
    devices.addAll(
      stationList.map<Device>(
        (station) => Device.fromAliceStation(station)
      )
    );
  }
}

class DeviceListStateSelectDevice extends DeviceListState {
  final Device device;

  DeviceListStateSelectDevice({this.device});
}

class DeviceListStateDevicePlaying extends DeviceListState {
  final Device device;
  final PlayResult playResult;

  DeviceListStateDevicePlaying({@required this.device, @required this.playResult});
}

class DeviceListStateBloc {
  BehaviorSubject<DeviceListState> _deviceListState;

  AppStateBloc _appStateBloc;
  StreamSubscription<AppState> _appStateStreamHandle;

  final AliceStationService _aliceService = gServiceLocator<AliceStationService>();

  ValueStream<DeviceListState> get deviceStateStream => _deviceListState.stream;
  DeviceListState get currentDeviceState => _deviceListState.value;

  DeviceListStateBloc({@required AppStateBloc appStateBloc}) {
    _deviceListState = BehaviorSubject.seeded(DeviceListState.init());

    _appStateBloc = appStateBloc;
    _appStateStreamHandle =
        appStateBloc.addAppStateListener(handleAppStateData);
  }

  void dispose() {
    _appStateStreamHandle?.cancel();
  }

  void handleAppStateData(AppState appState) {
    switch (appState) {
      case AppState.INIT:
      case AppState.LOADING:
      case AppState.NOCONNECTION:
      case AppState.ONBOARDING:
        break;
      case AppState.UNATHORIZED:
        _deviceListState.add(DeviceListState.loggedOut());
        break;
      case AppState.READY:
        break;
      default:
        break;
    }
  }

  Future _internalGetDevices() async {
    var stationList = await _aliceService.getDevices();
    if (stationList == null) {
      _appStateBloc.signOut();
    } else {
      _deviceListState.add(DeviceListState.loadedAlice(stationList));
    }
  }

  Future getDevices() async {
    _deviceListState.add(DeviceListState.loading());

    await _internalGetDevices();
  }

  Future selectDevice(Device device) async {
    _deviceListState.add(DeviceListState.selectDevice(device));
  }

  Future signOut() async {
    _deviceListState.add(DeviceListState.loading());
    _appStateBloc.signOut();
  }

  Future playVideo(Device device, String videoUrl) async {
    _deviceListState.add(DeviceListState.loading());

    var playResult = await _aliceService.playVideoFromUrl(device.id, videoUrl);
    _deviceListState.add(DeviceListState.playingVideo(device, playResult));
  }
}
