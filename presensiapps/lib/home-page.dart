import 'dart:convert';
//import 'dart:html';
import 'package:flutter/material.dart';
import 'package:presensiapps/models/home_response.dart';
import 'package:presensiapps/simpan-page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as myHttp;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<String> _name, _token;
  HomeResponseModel? homeResponseModel;
  Datum? hariIni;
  List<Datum> riwayat = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _token = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs) {
      return prefs.getString("name") ?? "";
    });
  }

  Future getData() async {
    final Map<String, String> headers = {
      'Authorization': 'Bearer ' + await _token
    };
    var response = await myHttp.get(
        Uri.parse('http://127.0.0.1:8000/api/get-presensi'),
        headers: headers);
    homeResponseModel = HomeResponseModel.fromJson(json.decode(response.body));
    riwayat.clear();
    homeResponseModel!.data.forEach((element) {
      if(element.isHariIni){
        hariIni = element;
      }
      else{
        riwayat.add(element);
      }
    });
    print('DATA : ' + response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Color.fromARGB(255, 3, 79, 244), Colors.lightBlue],
            )
        ),
        child: FutureBuilder(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                return SafeArea(
                    child: Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: _name,
                          builder: (BuildContext context,
                              AsyncSnapshot<String> snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else {
                              if (snapshot.hasData) {
                                return 
                                Text("Halo.. "+snapshot.data!,
                                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold));
                              } else {
                                return Text("-", style: TextStyle(fontSize: 20));
                              }
                            }
                          }),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [BoxShadow(
                            color: Color.fromRGBO(42, 79, 93, 0.992),
                            blurRadius: 10,
                            offset: Offset(0, 10)
                          )],
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            colors: [Colors.purple, Colors.pink, const Color.fromARGB(255, 245, 54, 118), Colors.white],
                            ),
                          ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(children: [
                            Text(hariIni?.tanggal ?? '-',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            SizedBox(
                              height: 30,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    Text(hariIni?.masuk ?? '-',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 24)),
                                    Text("Masuk",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16))
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(hariIni?.pulang ?? '-',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 24)),
                                    Text("Pulang",
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 16))
                                  ],
                                )
                              ],
                            )
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Container(
                        child: Text("Riwayat Presensi", style: TextStyle(color: Colors.white),)),
                      Expanded(
                        child: ListView.builder(
                          itemCount: riwayat.length,
                          itemBuilder: (context, index) => Card(
                            child: ListTile(
                              leading: Text(riwayat[index].tanggal),
                              title: Row(
                                children: [
                                  SizedBox(width: 50,),
                                  Column(
                                    children: [
                                      Text(riwayat[index].masuk, style: TextStyle(fontSize: 18)),
                                      Text("Masuk", style: TextStyle(fontSize: 14))
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
                                    children: [
                                      Text(riwayat[index].pulang, style: TextStyle(fontSize: 18)),
                                      Text("Pulang", style: TextStyle(fontSize: 14))
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ));
              }
            }),
      ),
      floatingActionButton: Container(
        padding: EdgeInsets.all(50),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.of(context)
                .push(MaterialPageRoute(builder: (context) => SimpanPage()))
                .then((value){
                  setState(() {});
                });
          },
          child: Icon(
            Icons.add_location
            ),
        ),
      ),
    );
  }
}
