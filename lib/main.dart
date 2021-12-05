import 'dart:convert';

import 'package:address_create/resources/post_to_server.dart';
import 'package:address_create/resources/view_addresses.dart';
import 'package:address_create/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:overlay_support/overlay_support.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return OverlaySupport.global(
      child: MaterialApp(
        title: 'Address Creator',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textEditingController = TextEditingController();
  Position? position;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((_) async {
      position = await _determinePosition();
      setState(() {});
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Latitude: ${position?.latitude}',
              ),
              Text(
                'Longitude: ${position?.longitude}',
              ),
              MaterialButton(
                child: const Text("Click to get Location"),
                onPressed: () async {
                  position = await _determinePosition();
                  setState(() {});
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _textEditingController,
                  style: Theme.of(context).textTheme.headline4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter address name....",
                  ),
                ),
              ),
              const SizedBox(
                height: 50,
              ),
              MaterialButton(
                color: Colors.black,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        child: CircularProgressIndicator(),
                      )
                    : const Text(
                        "Save Address",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                onPressed: () async {
                  if (_isLoading) return;

                  if (_textEditingController.text.isEmpty) {
                    showSimpleNotification(
                      const Text("Address is required"),
                      background: Colors.red,
                    );
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                  });
                  String resp = await Post().toServer(
                    Urls.saveAddress,
                    {
                      'lat': position?.latitude,
                      'lng': position?.latitude,
                      'address': _textEditingController.text,
                    },
                  );

                  try {
                    var jRes = jsonDecode(resp);
                    if (jRes["error"]) {
                      showSimpleNotification(
                        const Text("An error occurred please try again"),
                        background: Colors.red,
                      );
                    } else {
                      _textEditingController.clear();
                      showSimpleNotification(
                        const Text("Success"),
                        background: Colors.green,
                      );
                    }
                  } catch (e) {
                    showSimpleNotification(
                      const Text("An error occurred please try again"),
                      background: Colors.red,
                    );
                  }

                  setState(() {
                    _isLoading = false;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) {
                return const ViewAddresses();
              },
            ),
          );
        },
        tooltip: 'Addresses',
        child: const Icon(Icons.view_agenda),
      ),
    );
  }
}
