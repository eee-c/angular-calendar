import 'dart:io';
import 'dart:convert';

import 'package:dirty/dirty.dart';
import 'package:uuid/uuid.dart';
import 'package:ansicolor/ansicolor.dart';

main() {
  var port = Platform.environment['PORT'] == null ?
    8000 : int.parse(Platform.environment['PORT']);

  HttpServer.bind('127.0.0.1', port).then((app) {
    app.listen((req) {
      log(req);

      if (req.method == 'GET' && req.uri.path == '/appointments') {
        return Appointments.index(req);
      }

      if (req.method == 'POST' && req.uri.path == '/appointments') {
        return Appointments.post(req);
      }

      if (req.method == 'DELETE' &&
          new RegExp(r"^/appointments/[-\w\d]+$").hasMatch(req.uri.path)) {
        return Appointments.delete(req);
      }

      if (Public.matcher(req)) {
        return Public.handler(req);
      }

      HttpResponse res = req.response;
      res.statusCode = HttpStatus.NOT_FOUND;
      res.write("Not found.");
      res.close();
    });

    print('Server started on port: ${port}');
  });
}


class Appointments {
  static Uuid uuid = new Uuid();
  static Dirty db = new Dirty('dart_appointments.db');

  static index(HttpRequest req) {
    // print(db.values.toList());
    HttpResponse res = req.response;
    res.headers.contentType
      = new ContentType("application", "json", charset: "utf-8");

    res.write(JSON.encode(db.values.toList()));
    res.close();
  }

  static post(HttpRequest req) {
    HttpResponse res = req.response;
    req.toList().then((list) {
      var post_data = new String.fromCharCodes(list[0]);
      // print(post_data);
      var graphic_novel = JSON.decode(post_data);
      graphic_novel['id'] = uuid.v1();

      db[graphic_novel['id']] = graphic_novel;

      res.statusCode = 201;
      res.headers.contentType
        = new ContentType("application", "json", charset: "utf-8");

      res.write(JSON.encode(graphic_novel));
      res.close();
    });
  }

  static delete(HttpRequest req) {
    HttpResponse res = req.response;
    var r = new RegExp(r"^/appointments/([-\w\d]+)");
    var id = r.firstMatch(req.uri.path)[1];

    db.remove(id);

    res.write('{}');
    res.close();
  }
}

class Public {
  static matcher(HttpRequest req) {
    if (req.method != 'GET') return false;

    String path = publicPath(req.uri.path);
    if (path == null) return false;

    req.session['path'] = path;
    return true;
  }

  static handler(req) {
    var file = new File(req.session['path']);
    var stream = file.openRead();
      stream.pipe(req.response);
  }

  static String publicPath(String path) {
    if (pathExists("web$path")) return "web$path";
    if (pathExists("web$path/index.html")) return "web$path/index.html";
  }

  static bool pathExists(String path) => new File(path).existsSync();
}

log(req) {
  req.response.done.then((res){
    var now = new DateTime.now();
    print('[${now}] "${req.method} ${req.uri.path}" ${logStatusCode(res)}');
  });
}

final AnsiPen red = new AnsiPen()..red(bold: true);
final AnsiPen green = new AnsiPen()..green(bold: true);

logStatusCode(HttpResponse res) {
  var code = res.statusCode;
  if (code > 399) return red(code);
  return green(code);
}
