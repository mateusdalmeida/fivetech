import 'dart:async';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:html/parser.dart';

class WorkForce {
  HeadlessInAppWebView _headlessWebView = HeadlessInAppWebView();

  WorkForce() {
    _headlessWebView.run();
  }

  String _user;

  final StreamController _escalaController = StreamController();
  Stream get escalaStream => _escalaController.stream;

  final StreamController _indicadoresController = StreamController();
  Stream get indicadoresStream => _indicadoresController.stream;

  login(String user, String password) async {
    _user = user;

    await _getPage("/ajaxDefineDB.asp?user=$user");

    String loginHTML =
        await _getPage("/ajaxLogin.asp?user=$user&pass=$password");

    String loginStatus =
        parse(loginHTML).getElementsByTagName('body')[0].innerHtml;

    if (['-1', '-2'].contains(loginStatus)) return "Usuário ou senha inválidos";
    if (loginStatus != '1') return "Erro no login";

    String html = await _getPage("/index.producao.asp");

    var document = parse(html);

    _escalaController.sink
        .add(_convertEscala(document.getElementsByClassName("folga")));

    return _convertEscala(document.getElementsByClassName("folga"));
  }

  getEscala(DateTime date) async {
    _indicadoresController.sink.add(_indicadoresModel);

    String loginHTML =
        await _getPage("/ajaxEscala.asp?ano=${date.year}&mes=${date.month}");

    _escalaController.sink.add(_convertEscala(
        parse(loginHTML).getElementsByClassName("folga"),
        date: date));

    return _convertEscala(parse(loginHTML).getElementsByClassName("folga"),
        date: date);
  }

  getIndicadores(DateTime date) async {
    _indicadoresController.sink.add(_indicadoresModel);
    String html = await _getPage("/modIndicadores/ajaxIndicadores.asp?re=" +
        _user.substring(1) +
        "&tipo=1&vigencia=${date.month.toString().padLeft(2, '0')}-${date.year}");

    Map indicadores = {
      'tml': false,
      'tmp': false,
      'tma': false,
      'abs': false,
      'adr': false,
      'nota': false,
      'aceitas': false,
      'pendentes': false
    };

    try {
      List temp = parse(html).getElementsByTagName('td');

      indicadores.addAll({
        'tml': temp[2].innerHtml,
        'tmp': temp[3].innerHtml,
        'tma': temp[4].innerHtml,
        'abs': temp[5].innerHtml,
        'adr': temp[6].innerHtml,
        'nota': temp[7].innerHtml,
      });
      _indicadoresController.sink.add(indicadores);
    } catch (e) {
      indicadores.addAll({
        'tml': '-',
        'tmp': '-',
        'tma': '-',
        'abs': '-',
        'adr': '-',
        'nota': '-',
      });
      _indicadoresController.sink.add(indicadores);
      print(e);
    }

    Map monitorias = await _getMonitorias(date);
    indicadores.addAll(monitorias);
    _indicadoresController.sink.add(indicadores);
  }

  _getMonitorias(DateTime date) async {
    String html = await _getPage(
        "/modMonitoriaOperador/ajaxStatusMonitoria.asp?vigencia=${date.month.toString().padLeft(2, '0')}-${date.year}");

    var trs = parse(html).getElementsByTagName('tr');

    try {
      String aceitas = '-';
      String pendentes = '-';
      trs.forEach((element) {
        if (element.innerHtml.contains("ACEITA"))
          aceitas = element.children[1].innerHtml;
        if (element.innerHtml.contains("VALIDADA"))
          pendentes = element.children[1].innerHtml;
      });

      return {
        'aceitas': aceitas,
        'pendentes': pendentes == null ? '0' : pendentes
      };
    } catch (e) {
      return {'aceitas': '-', 'pendentes': '-'};
    }
  }

  static const Map _indicadoresModel = {
    'tml': false,
    'tmp': false,
    'tma': false,
    'abs': false,
    'adr': false,
    'nota': false,
    'aceitas': false,
    'pendentes': false
  };

  List<DateTime> _convertEscala(List escala, {DateTime date}) {
    try {
      if (date == null) date = DateTime.now();
      List<int> days = escala.map((e) => int.tryParse(e.innerHtml)).toList();
      days.removeLast();
      return days.map((e) => DateTime.utc(date.year, date.month, e)).toList();
    } catch (e) {
      List<DateTime> vazia = [];
      return vazia;
    }
  }

  _getPage(String url) async {
    String baseUrl = "http://workforce.call.inf.br:88";

    await _headlessWebView.webViewController
        .loadUrl(urlRequest: URLRequest(url: Uri.parse(baseUrl + url)));

    await Future.doWhile(() async =>
        await _headlessWebView.webViewController.getProgress() != 100);

    return await _headlessWebView.webViewController.getHtml();
  }
}
