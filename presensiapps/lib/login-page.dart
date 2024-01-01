import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:presensiapps/home-page.dart';
import 'package:http/http.dart' as myHttp;
import 'package:presensiapps/models/login-reponse.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late Future<String> _name, _token;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _token = _prefs.then((SharedPreferences prefs){
      return prefs.getString("token") ?? "";
    });

    _name = _prefs.then((SharedPreferences prefs){
      return prefs.getString("name") ?? "";
    });
    checkToken(_token, _name);
  }

  checkToken(token, name) async{
    String tokenStr = await token;
    String nameStr = await name;
    if(tokenStr != "" && nameStr != ""){
      Future.delayed(Duration(seconds: 1), () async{
        Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => HomePage()))
        .then((value) => (value));
      setState(() {});
      });
    }
  }

  Future login(email, password) async{
    LoginResponseModel? loginResponseModel;
    Map<String, String> body = {"email":email, "password": password};
    //final headers = {'Content-Type': 'application/json'};
    var response = await myHttp.post(
      Uri.parse('http://127.0.0.1:8000/api/login'),
      body: body);
    if (response.statusCode == 401){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email atau Password Salah")));
    }
    else{
      loginResponseModel = LoginResponseModel.fromJson(json.decode(response.body));
      saveUser(loginResponseModel.data.token, loginResponseModel.data.name);
    }
    
  }

  Future saveUser(token, name)async{
    try {
      print("Lewat Sini");
      final SharedPreferences pref = await _prefs;
      pref.setString("name", name);
      pref.setString("token", token);
      Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => HomePage()))
        .then((value) => (value));
      setState(() {});
    } catch (err) {
      print('ERRPR : '+err.toString());
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err.toString())));
    }
    

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            colors: [Colors.purple, Colors.pink, Colors.white],)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 170,),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Login", style: TextStyle(color: Colors.white, fontSize: 40),),
                  SizedBox(height: 5,),
                  Text("Welcome to Ngabsen", style: TextStyle(color: Colors.white, fontSize: 18),),
                ],
              ),
              ),
              SizedBox(height: 60,),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60))
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 40,),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(
                              color: Color.fromRGBO(42, 79, 93, 0.992),
                              blurRadius: 20,
                              offset: Offset(0, 10)
                            )]
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey))
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: "Your Email",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none
                                  ),
                                  controller: emailController,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  border: Border(bottom: BorderSide(color: Colors.grey))
                                ),
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: "Password",
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none
                                  ),
                                  controller: passwordController,
                                  obscureText: true,
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 40,),
                        Container(
                          child: Column(
                            children:[
                            ElevatedButton(
                              onPressed: () {
                              login(emailController.text, passwordController.text);
                            },child: Text("Login", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),))
                            ]
                          ),
                        )
                      ],
                    ),
                  ),
                )
              )
          ],
        ),
      ),
    );
  }
}