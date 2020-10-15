import 'package:alice_video_box/blocs/device_list_bloc.dart';
import 'package:alice_video_box/models/alice_service.dart';
import 'package:alice_video_box/screens/styles.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/scheduler.dart';

class DevicePage extends StatefulWidget {
  final Device device;
  final DeviceListStateBloc deviceBloc;

  DevicePage(this.device, this.deviceBloc);

  @override
  _DevicePage createState() {
    return new _DevicePage();
  }
}

class _DevicePage extends State<DevicePage> {
  final TextEditingController _videoUrlController = new TextEditingController();

  Widget _buildUrlTextField() {
    return new Container(
      margin: new EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      padding: new EdgeInsets.all(10.0),
      child: new TextField(
        cursorColor: Colors.white,
        textAlignVertical: TextAlignVertical.center,
        decoration: new InputDecoration(
          border: new OutlineInputBorder(
            borderSide: new BorderSide(
              color: Colors.blueAccent,
              width: 4.0,
            ),
          ),
          hintText: tr("device_video_url"),
          hintStyle: new TextStyle(
            color: Colors.white,
          ),
          contentPadding: EdgeInsets.all(3.0),
          prefixIcon: new Icon(
            Icons.video_label_rounded,
            color: Colors.white,
          ),
        ),
        style: new TextStyle(
          color: Colors.white,
          fontFamily: 'OpenSans'
        ),
        controller: _videoUrlController,
      ),
    );
  }

  Widget _buildDeviceCard(Device device, DeviceListStateBloc deviceBloc) {
    return new Padding(
      padding: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: new ListTile(
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
        trailing: new RawMaterialButton(
          onPressed: () => deviceBloc.playVideo(device, _videoUrlController.text),
          elevation: 2.0,
          fillColor: Colors.greenAccent,
          child: new Icon(
            Icons.play_arrow,
            size: 25.0,
          ),
          padding: EdgeInsets.all(15.0),
          shape: const CircleBorder(),
        ),
      ),
    );
  }

  Widget _buildRefreshButton(DeviceListStateBloc deviceBloc) {
    return new Center(
      child: new FlatButton(
        onPressed: () => deviceBloc.getDevices(), 
        child: new Text(
          'device_refresh',
          style: null,
        ).tr(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPlaying = widget.deviceBloc.currentDeviceState is DeviceListStateDevicePlaying;
    if (isPlaying) {
      var deviceState = widget.deviceBloc.currentDeviceState as DeviceListStateDevicePlaying;
      var playResult = deviceState.playResult;
      Text playText;

      switch (playResult) {
        case PlayResult.SUCCESS:
          playText = const Text('device_play_success');
          break;
        case PlayResult.FAIL:
          playText = const Text('device_play_fail');
          break;
        default:
          playText = const Text('UNKNOWN PLAY RESULT');
      }

      SchedulerBinding.instance.addPostFrameCallback((_) {
        Scaffold.of(context).showSnackBar(new SnackBar(
          content: playText.tr(),
        ));
      });
    }

    return new Expanded(
      child: new Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0),
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
              ],
            ),
          ),
          child: new Column(
            children: <Widget>[
              new SizedBox(height: 10.0,),
              new Text(
                'device_play_video',
                style: cTitleStyle,
              ).tr(),
              _buildUrlTextField(),
              new SizedBox(height: 10.0,),
              _buildDeviceCard(widget.device, widget.deviceBloc),
              new SizedBox(height: 10.0,),
              _buildRefreshButton(widget.deviceBloc),
            ],
          ),
        ),
      )
    );
  }
}
