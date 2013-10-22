import 'package:angular/angular.dart';
import 'package:angular/playback/playback_http.dart';
import 'dart:html';
import 'dart:convert';

@NgDirective(
  selector: '[appt-controller]',
  publishAs: 'day'
)
class AppointmentCtrl {
  List appointments = [];
  String newAppointmentText;

  AppointmentCtrl(ServerCtrl server) {
    server.init(this);
  }

  void add() {
    var newAppt = fromText(newAppointmentText);
    appointments.add(newAppt);
    newAppointmentText = null;
    HttpRequest.
      request(
        '/appointments',
        method: 'POST',
        sendData: JSON.encode(newAppt)
      );
  }

  // _loadAppointments() {
  //   HttpRequest.
  //     getString('/appointments').
  //     then((responseText){
  //       appointments = JSON.decode(responseText);
  //     });
  // }

  Map fromText(v) {
    var appt = {'time': '00:00', 'title': 'New Appointment'};
    if (v == null || v == '') return appt;

    var time_re = new RegExp(r"^\s*(\d\d:\d\d)\s*$");
    if (time_re.hasMatch(v)) {
      appt['time'] = time_re.firstMatch(v)[1];
      return appt;
    }

    time_re = new RegExp(r"^\s*(\d\d:\d\d)\s+(.+)$");
    if (time_re.hasMatch(v)) {
      appt['time'] = time_re.firstMatch(v)[1];
      appt['title'] = time_re.firstMatch(v)[2];
      return appt;
    }

    appt['title'] = v;
    return appt;
  }
}

class ServerCtrl {
  Http _http;
  ServerCtrl(this._http);

  init(AppointmentCtrl cal) {
    _http(method: 'GET', url: '/appointments').
      then((HttpResponse res) {
        res.data.forEach((d) {
          cal.appointments.add(d);
        });
      });
  }
}

main() {
  var module = new AngularModule()
    ..type(ServerCtrl)
    ..type(AppointmentCtrl);

  bootstrapAngular([module]);
}
