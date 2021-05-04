import 'package:fivetech/views/home/home.dart';
import 'package:fivetech/workForce.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController userController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String loginError = '';
  bool keepConnected = false;
  @override
  Widget build(BuildContext context) {
    final workforce = Provider.of<WorkForce>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("FIVETECH",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              TextField(
                enabled: !isLoading,
                controller: userController,
                decoration: InputDecoration(labelText: "Login"),
              ),
              TextField(
                  enabled: !isLoading,
                  controller: passwordController,
                  decoration: InputDecoration(labelText: "Senha"),
                  obscureText: true),
              CheckboxListTile(
                dense: true,
                title: Text("Manter Conectado"),
                contentPadding: const EdgeInsets.all(0),
                value: keepConnected,
                onChanged: isLoading
                    ? null
                    : (bool value) {
                        setState(() {
                          keepConnected = value;
                        });
                      },
              ),
              Visibility(
                  visible: loginError.isNotEmpty,
                  child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Center(
                          child: Text(loginError,
                              style: TextStyle(color: Colors.red))))),
              // SizedBox(height: 16),
              Visibility(
                visible: !isLoading,
                replacement: Center(child: CircularProgressIndicator()),
                child: OutlinedButton(
                    onPressed: () async {
                      setState(() {
                        loginError = '';
                        isLoading = true;
                      });
                      var response = await workforce.login(
                          userController.text, passwordController.text);

                      if (response.runtimeType == String) {
                        setState(() {
                          loginError = response;
                          isLoading = false;
                        });
                      } else {
                        if (keepConnected) {
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString("user", userController.text);
                          prefs.setString("password", passwordController.text);
                        }
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => Home(
                                      escala: response,
                                    )));
                      }
                    },
                    child: Text("Entrar")),
              ),
              SizedBox(height: 16),
              Visibility(
                visible: !isLoading,
                replacement: SizedBox(),
                child: GestureDetector(
                    onTap: () async {
                      String _url =
                          "http://workforce.call.inf.br:88/reset_Senha.asp";
                      await canLaunch(_url)
                          ? await launch(_url)
                          : throw 'Could not launch';
                    },
                    child: Center(child: Text("Esqueci minha senha"))),
              )
            ],
          ),
        ),
      ),
    );
  }
}
