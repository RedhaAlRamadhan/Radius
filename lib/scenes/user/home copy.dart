import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'dart:io' show Platform;
import 'package:flutter_svg/svg.dart';

import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:radius/model/resturant.dart';
import 'package:radius/scenes/user/menu.dart';

class Home extends StatefulWidget {
  @override
  _Home createState() => _Home();
}

class _Home extends State<Home> with WidgetsBindingObserver {
  bool found = false;
  var isRunning = true;
  final resturantsList = <Resturant>[];

  final StreamController<BluetoothState> streamController = StreamController();
  StreamSubscription<BluetoothState> _streamBluetooth;
  StreamSubscription<RangingResult> _streamRanging;
  final _regionBeacons = <Region, List<Beacon>>{};
  int d = 3;
  final _beacons = <Beacon>[];
  bool authorizationStatusOk = false;
  bool locationServiceEnabled = false;
  bool bluetoothEnabled = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);

    super.initState();

    listeningState();
  }

  listeningState() async {
    print('Listening to bluetooth state');
    _streamBluetooth = flutterBeacon
        .bluetoothStateChanged()
        .listen((BluetoothState state) async {
      print('BluetoothState = $state');
      streamController.add(state);

      switch (state) {
        case BluetoothState.stateOn:
          initScanBeacon();
          break;
        case BluetoothState.stateOff:
          await pauseScanBeacon();
          await checkAllRequirements();
          break;
      }
    });
  }

  checkAllRequirements() async {
    try {
      // if you want to manage manual checking about the required permissions
      await flutterBeacon.initializeScanning;

      // or if you want to include automatic checking permission
      await flutterBeacon.initializeAndCheckScanning;
    } on PlatformException catch (e) {
      // library failed to initialize, check code and message
      print(e);
    }

    final bluetoothState = await flutterBeacon.bluetoothState;
    final bluetoothEnabled = bluetoothState == BluetoothState.stateOn;
    final authorizationStatus = await flutterBeacon.authorizationStatus;
    final authorizationStatusOk =
        authorizationStatus == AuthorizationStatus.allowed ||
            authorizationStatus == AuthorizationStatus.always;
    final locationServiceEnabled =
        await flutterBeacon.checkLocationServicesIfEnabled;

    setState(() {
      this.authorizationStatusOk = authorizationStatusOk;
      this.locationServiceEnabled = locationServiceEnabled;
      this.bluetoothEnabled = bluetoothEnabled;
    });
  }

  initScanBeacon() async {
    await flutterBeacon.initializeScanning;
    await checkAllRequirements();
    if (!authorizationStatusOk ||
        !locationServiceEnabled ||
        !bluetoothEnabled) {
      print('RETURNED, authorizationStatusOk=$authorizationStatusOk, '
          'locationServiceEnabled=$locationServiceEnabled, '
          'bluetoothEnabled=$bluetoothEnabled');
      return;
    }
    final regions = <Region>[
      Region(
        identifier: 'KFC',
        proximityUUID: 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0',
      ),
      Region(
        identifier: 'Burger King',
        proximityUUID: 'f04cd654-871a-40e1-ba1a-a139b67dbddd',
      ),
      Region(
        identifier: 'McDonalds',
        proximityUUID: 'cce1cd20-0111-4466-9aef-37ff3d842154',
      ),
    ];

    if (_streamRanging != null) {
      if (_streamRanging.isPaused) {
        _streamRanging.resume();
        return;
      }
    }

    _streamRanging =
        flutterBeacon.ranging(regions).listen((RangingResult result) {
      // print(result.beacons[0].proximityUUID);
      // print(result);
      if (result != null && mounted) {
        print(result.beacons);
        if (result.beacons.isNotEmpty)
          setState(() {
            resturantsList.clear();

            _regionBeacons[result.region] = result.beacons;
            _beacons.clear();
            _regionBeacons.values.forEach((list) {
              found = true;
              _beacons.addAll(list);
            });
            print(_beacons.length);

            // _beacons.sort(_compareParameters);

            for (var _beacon in _beacons) {
              for (var _resturant in resturants) {
                if (_beacon.proximityUUID == _resturant.uuid) {
                  resturantsList.add(_resturant);
                  break;
                }
              }
            }
            print("KK" + resturantsList.length.toString());
          });
        // else
        // found = false;
      }
    });
  }

  pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      setState(() {
        _beacons.clear();
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('AppLifecycleState = $state');
    if (state == AppLifecycleState.resumed) {
      if (_streamBluetooth != null && _streamBluetooth.isPaused) {
        _streamBluetooth.resume();
      }
      await checkAllRequirements();
      if (authorizationStatusOk && locationServiceEnabled && bluetoothEnabled) {
        await initScanBeacon();
      } else {
        await pauseScanBeacon();
        await checkAllRequirements();
      }
    } else if (state == AppLifecycleState.paused) {
      _streamBluetooth?.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamController?.close();
    _streamRanging?.cancel();
    _streamBluetooth?.cancel();
    flutterBeacon.close;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return new Scaffold(
      backgroundColor: new Color(0xFF393e46),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: new Color(0xFF393e46),
        title: const Text('Radius'),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                return Container(
                  child: ResturantCard(
                      resturant: resturants[index % 3], onPress: null),
                );
              },
              childCount: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class BackgroundImage extends StatelessWidget {
  final String image;
  const BackgroundImage({
    Key key,
    @required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.network(
        image,
        fit: BoxFit.cover,
      ),
    );
  }
}

class ResturantCard extends StatelessWidget {
  final Resturant resturant;
  final Function onPress;
  final Function onSaved;
  final bool isSaved;

  const ResturantCard({
    Key key,
    @required this.resturant,
    @required this.onPress,
    this.onSaved,
    this.isSaved = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      height: 215,
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          BackgroundImage(image: resturant.imageURL),
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              gradient: (resturant.avaliable)
                  ? LinearGradient(
                      begin: Alignment(-0.2, 0.9),
                      end: Alignment(0.0, 0.0),
                      colors: <Color>[
                        Color(0xd0000000),
                        Color(0x00000000),
                      ],
                    )
                  : null,
              color: (resturant.avaliable) ? null : Color(0xc05e5e5f),
            ),
          ),
          (resturant.avaliable)
              ? Container()
              : Positioned(
                  top: 3,
                  left: 10,
                  child: Chip(
                    label: Text('Unavailable'),
                  ),
                ),
          BookmarkButton(
            active: resturant.isSaved,
            onPress: this.onSaved,
          ),
          TextRecent(
            size: size,
            title: resturant.title,
          ),
        ],
      ),
    );
  }
}

class BookmarkButton extends StatelessWidget {
  final Function onPress;
  final double top, right;
  final bool active;

  const BookmarkButton({
    Key key,
    @required this.onPress,
    @required this.active,
    this.top = 10,
    this.right = 10,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      width: 35,
      height: 35,
      top: 10,
      right: 10,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(50),
        ),
        alignment: Alignment.center,
        child: IconButton(
          splashColor: Colors.transparent,
          icon: SvgPicture.asset(
            "assets/icons/heart.svg",
            color: active ? Colors.red : Colors.black.withOpacity(0.6),
          ),
          onPressed: onPress,
        ),
      ),
    );
  }
}

class TextRecent extends StatelessWidget {
  final String title;
  final Size size;

  const TextRecent({
    Key key,
    @required this.title,
    @required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Positioned(
        bottom: 14,
        left: 10,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                this.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size.width * 0.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(),
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/icons/hamburger.svg",
                    height: 40,
                  ),
                  Container(
                    width: 2,
                  ),
                  SvgPicture.asset(
                    "assets/icons/chicken-leg.svg",
                    height: 40,
                  ),
                ],
              ),
              // Text(
              //   "Burger",
              //   style: TextStyle(
              //     color: Colors.white,
              //     fontSize: size.width * 0.075,
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
