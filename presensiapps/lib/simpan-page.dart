import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:location/location.dart';
import 'package:presensiapps/home-page.dart';
import 'package:presensiapps/models/save-presensi-response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_maps/maps.dart';
import 'package:http/http.dart' as myHttp;



class SimpanPage extends StatefulWidget {
  const SimpanPage({super.key});

  @override
  State<SimpanPage> createState() =>  SimpanPageState();
}

class SimpanPageState extends State <SimpanPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _token;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _token = _prefs.then((SharedPreferences prefs){
      return prefs.getString("token") ?? "";
    });
  }
  Future<LocationData?> currentLocation() async{
    bool serviceEnable;
    PermissionStatus permissionGranted;

    Location location = new Location();

    serviceEnable = await location.serviceEnabled();
    if(!serviceEnable){
      serviceEnable = await location.requestService();
      if(!serviceEnable){
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if(permissionGranted == PermissionStatus.denied){
      permissionGranted = await location.requestPermission();
      if(permissionGranted != PermissionStatus.granted){
        return null;
      }
    }

    return await location.getLocation();
  }

  Future savePresensi(latitude, longitude) async {
    SavePresensiResponseModel savePresensiResponseModel;
    Map<String, String> body = {
      "latitude": latitude.toString(),
      "longitude": longitude.toString()
    };

    Map<String, String> headers ={
      'Authorization': 'Bearer ' + await _token
    };

    var response = await myHttp.post(
      Uri.parse("http://127.0.0.1:8000/api/save-presensi"),
      body: body,
      headers: headers);

    savePresensiResponseModel = SavePresensiResponseModel.fromJson(json.decode(response.body));

    if(savePresensiResponseModel.success){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sukses Simpan Presensi')));
      Navigator.pop(context);
    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal Simpan Presensi')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 33, 68, 243),
        iconTheme: IconThemeData(color: Colors.black),
        title: Text("Presensi", style: TextStyle(fontWeight: FontWeight.bold),),
        ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Color.fromARGB(255, 3, 79, 244), Color.fromARGB(255, 0, 217, 255)],
            )
        ),
        child: FutureBuilder<LocationData?> (
          future: currentLocation(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if(snapshot.hasData){
              final LocationData currentLocation = snapshot.data;
              print("PETA : " + currentLocation.latitude.toString() + " | " + currentLocation.longitude.toString());
              return SafeArea(
              child: Column(
                children: [
                  Container(
                    height: 400,
                    child: Container(
                      padding: EdgeInsets.only(left: 10, right: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200)
                      ),
                      child: SfMaps(
                        layers: [MapTileLayer(
                          initialFocalLatLng: MapLatLng(currentLocation.latitude!, currentLocation.longitude!),
                          initialZoomLevel: 15,
                          initialMarkersCount: 1,
                          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png", 
                          markerBuilder: (BuildContext context, int index){
                            return MapMarker(
                              latitude: currentLocation.latitude!, 
                              longitude: currentLocation.longitude!,
                              child: Icon(
                                Icons.location_on,
                                color: const Color.fromARGB(255, 234, 24, 9),)
                                );
                          },)]),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      savePresensi(currentLocation.latitude, currentLocation.longitude);
                      Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) => HomePage()))
                        .then((value){
                          setState(() {});
                        });
                    }, child: Text("Simpan Presensi"))
                ]
              )
            );
            }
            else{
              return Center(child: CircularProgressIndicator(),);
            }
          }
        ),
      )
    );
  }
}