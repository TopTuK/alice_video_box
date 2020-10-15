import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:alice_video_box/blocs/device_list_bloc.dart';
import 'package:alice_video_box/models/navigation_service.dart';
import 'package:alice_video_box/screens/styles.dart';
import 'package:alice_video_box/screens/device_page.dart';
import 'package:easy_localization/easy_localization.dart';

class DeviceListScreen extends StatefulWidget {
  @override
  State<DeviceListScreen> createState() {
    return new _DeviceListScreen();
  }
}

class _DeviceListScreen extends State<DeviceListScreen> {  
  Widget _buildNoDevicePage(DeviceListStateBloc deviceStateBloc) {
    return new Center(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            "device_empty",
            style: cTitleStyle,
          ).tr(),
          new SizedBox(height: 10.0),
          new FlatButton(
            child: new Text("device_refresh").tr(),
            onPressed: () => deviceStateBloc.getDevices()
          ),
        ]
      ),
    );
  }

  Widget _buildDeviceListCard(Device device, DeviceListStateBloc deviceStateBloc) {
    return new Card(
      elevation: 8.0,
      margin: new EdgeInsets.symmetric(horizontal: 0.0, vertical: 5.0),
      child: new Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.4, 0.7, 0.9],
            colors: <Color>[
              Color(0xFF73AEF5),
              Color(0xFF61A4F1),
              Color(0xFF478DE0),
              Color(0xFF398AE5),
            ]
          ),
        ),
        child: new ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
          leading: new CircleAvatar(
            backgroundImage: new NetworkImage(device.iconUrl),
            backgroundColor: Colors.white,
          ),
          title: new Text(
            device.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
          ),
          subtitle: new Text(
            device.id,
            style: cHintTextStyle,
          ),
          trailing: new Icon(Icons.keyboard_arrow_right, color: Colors.white,),
          onTap: () => deviceStateBloc.selectDevice(device),
        ),
      ),
    );
  }

  Widget _buildDeviceListCards(List<Device> deviceList, DeviceListStateBloc deviceStateBloc) {
    return new Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: new Container(
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: deviceList.length,
          itemBuilder: (BuildContext ctx, int index) {
            return _buildDeviceListCard(deviceList[index], deviceStateBloc);
          }
        ),
      ),
    );
  }

  Widget _buildLoadingPage() {
    return new Expanded(
      child: new Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildHeaderPanel() {
    return new Container(
      child: new Image.asset('assets/graphics/main_logo.png')
    );
  }

  Widget _buildBodyPanel(DeviceListStateBloc deviceStateBloc) {
    return new Container(
      child: new StreamBuilder(
        stream: deviceStateBloc.deviceStateStream,
        initialData: deviceStateBloc.currentDeviceState,
        builder: (BuildContext ctx, AsyncSnapshot<DeviceListState> snapshot) {
          if(!snapshot.hasData || snapshot.data == null) return Container();
          
          var deviceState = snapshot.data;
          if (deviceState is DeviceListStateInit) {
            deviceStateBloc.getDevices();
          }
          else if (deviceState is DeviceListStateLoggedOut) {
            SchedulerBinding.instance.addPostFrameCallback((_) {
              NavigationService.openLoginScreen(ctx);
            });
          }
          else if (deviceState is DeviceListStateLoading) {
            return _buildLoadingPage();
          }
          else if (deviceState is DeviceListStateNoDevice) {
            return _buildNoDevicePage(deviceStateBloc);
          }
          else if (deviceState is DeviceListStateLoaded) {
            return _buildDeviceListCards(deviceState.devices, deviceStateBloc);
          }
          else if (deviceState is DeviceListStateSingle) {
            return new DevicePage(deviceState.device, deviceStateBloc);
          }
          else if (deviceState is DeviceListStateSelectDevice) {
            return new DevicePage(deviceState.device, deviceStateBloc);
          }
          else if (deviceState is DeviceListStateDevicePlaying) {
            return new DevicePage(deviceState.device, deviceStateBloc);
          }

          return _buildLoadingPage();
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var deviceStateBloc = Provider.of<DeviceListStateBloc>(context);

    return new Scaffold(
      appBar: new AppBar(
        elevation: 1.0,
        title: new Text("device_title").tr(),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.cloud_off), 
            onPressed: deviceStateBloc.signOut,
          ),
        ],
      ),
      body: new Container(
        decoration: new BoxDecoration(
          gradient: new LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.1, 0.4, 0.7, 0.9],
            colors: [
              Color(0xFF3594DD),
              Color(0xFF4563DB),
              Color(0xFF5036D5),
              Color(0xFF5B16D0),
            ]
          ),
        ),
        child: new Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
          child: new Container(
            child: new Column(
              children: <Widget>[
                _buildHeaderPanel(),
                _buildBodyPanel(deviceStateBloc),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
