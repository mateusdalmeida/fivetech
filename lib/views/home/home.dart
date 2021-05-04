import 'package:fivetech/workForce.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

class Home extends StatelessWidget {
  final List<DateTime> escala;

  Home({Key key, @required this.escala}) : super(key: key);

  DateTime focusedDay = DateTime.now();
  @override
  Widget build(BuildContext context) {
    final workforce = Provider.of<WorkForce>(context);
    DateTime today = DateTime.now();
    workforce.getIndicadores(today);
    DateTime lastTime = (today.month == 12)
        ? new DateTime(today.year + 1, 2, 0)
        : new DateTime(today.year, today.month + 2, 0);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              StreamBuilder<Object>(
                  stream: workforce.escalaStream,
                  builder: (context, snapshot) {
                    return TableCalendar(
                        firstDay: today.subtract(Duration(days: 365)),
                        lastDay: lastTime,
                        focusedDay: focusedDay,
                        locale: 'pt_BR',
                        // eventLoader: (day) =>
                        //     escala.where((element) => element == day).toList(),
                        headerStyle: HeaderStyle(
                            formatButtonVisible: false, titleCentered: true),
                        holidayPredicate: (day) => escala.contains(day),
                        onPageChanged: (day) async {
                          focusedDay = day;
                          if (escala.lastIndexWhere(
                                  (element) => element.month == day.month) ==
                              -1) {
                            var bla = await workforce.getEscala(day);
                            escala.addAll(bla);
                          }
                          await workforce.getIndicadores(day);
                        },
                        calendarBuilders: CalendarBuilders(
                          todayBuilder: (context, day, focusedDay) =>
                              todayBuilder(day, context),
                          holidayBuilder: (context, day, focusedDay) =>
                              escalaBuilder(day, context),
                        ));
                  }),
              StreamBuilder(
                  stream: workforce.indicadoresStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      Map indicadores = snapshot.data;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Divider(),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "INDICADORES",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              indicator("TML", indicadores['tml']),
                              indicator("TMP", indicadores['tmp']),
                              indicator("TMA", indicadores['tma']),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              indicator("ABSENTEÍSMO", indicadores['abs']),
                              indicator("ADERÊNCIA", indicadores['adr']),
                            ],
                          ),
                          Divider(),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "MONITORIAS",
                              style: Theme.of(context).textTheme.headline6,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              indicator("ACEITAS", indicadores['aceitas']),
                              GestureDetector(
                                  onTap: () async {
                                    String _url =
                                        "http://workforce.call.inf.br:88/login.asp";
                                    await canLaunch(_url)
                                        ? await launch(_url)
                                        : throw 'Could not launch';
                                  },
                                  child: indicator(
                                      "PENDENTES", indicadores['pendentes'])),
                              indicator("NOTA", indicadores['nota']),
                            ],
                          ),
                          SizedBox(height: 8),
                        ],
                      );
                    } else
                      return SizedBox();
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget indicator(key, value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          key,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Visibility(
            visible: value == false,
            child: Shimmer.fromColors(
                baseColor: Colors.transparent,
                highlightColor: Colors.grey,
                child: Text(
                  "00000",
                  style: TextStyle(backgroundColor: Colors.grey[50]),
                )),
            replacement: Text(value.toString()))
      ],
    );
  }

  Widget escalaBuilder(DateTime day, BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Theme.of(context).primaryColor),
        width: 28.0,
        height: 28.0,
        child: Center(
            child: Text(
          day.day.toString(),
          style: TextStyle(color: Colors.white),
        )),
      ),
    );
  }

  Widget todayBuilder(DateTime day, BuildContext context) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            border: escala.contains(day)
                ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                : null,
            shape: BoxShape.circle,
            color: Theme.of(context).secondaryHeaderColor),
        width: 40.0,
        height: 40.0,
        child: Center(
            child: Text(
          day.day.toString(),
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        )),
      ),
    );
  }
}
