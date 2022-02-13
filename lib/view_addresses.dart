import 'dart:convert';

import 'package:address_create/address_model.dart';
import 'package:address_create/resources/get_from_server.dart';
import 'package:address_create/urls.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:overlay_support/overlay_support.dart';

class ViewAddresses extends StatefulWidget {
  const ViewAddresses({Key? key}) : super(key: key);

  @override
  _ViewAddressesState createState() => _ViewAddressesState();
}

class _ViewAddressesState extends State<ViewAddresses> {
  final List<Address> _addressList = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((_) async {
      setState(() {
        _isLoading = true;
      });
      String resp = await Get().fromServer(Urls.getAddresses);

      try {
        var jRes = jsonDecode(resp);
        if (jRes["error"]) {
          showSimpleNotification(
            const Text("An error occurred please try again"),
            background: Colors.red,
          );
        } else {
          for (var i = 0; i < jRes["data"].length; i++) {
            Address addr = Address.fromMap(jRes["data"][i]);
            _addressList.add(addr);
          }
          setState(() {});
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: _addressList.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("${_addressList[index].address}"),
                    subtitle: Text(
                        "lat: ${_addressList[index].lat} lng: ${_addressList[index].lng}"),
                  );
                },
              ),
      ),
    );
  }
}
