import 'package:fivetech/colors.dart';
import 'package:fivetech/views/home/home.dart';
import 'package:fivetech/views/loading.dart';
import 'package:fivetech/views/login/login.dart';
import 'package:fivetech/workForce.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences prefs;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();
  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (_) => WorkForce(),
      lazy: false,
      child: MaterialApp(
          title: 'WorkForce',
          theme: ThemeData(
            primarySwatch: color(Color(0xff1ea28b)),
          ),
          darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: color(Color(0xff1ea28b)),
              primaryColor: Color(0xff1ea28b),
              accentColor: Color(0xff1ea28b)),
          themeMode: ThemeMode.system,
          home: App()),
    );
  }
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final workforce = Provider.of<WorkForce>(context);
    return FutureBuilder(
      future: prefs.containsKey("user")
          ? workforce.login(
              prefs.getString('user'), prefs.getString('password'))
          : Future.wait([]),
      builder: (context, snapshot) {
        if (prefs.containsKey("user")) {
          if (!snapshot.hasData) {
            return Loading();
          } else
            return Home(escala: snapshot.data);
        } else {
          return Login();
        }
      },
    );
  }
}
