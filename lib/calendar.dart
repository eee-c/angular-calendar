import 'package:angular/angular.dart';
import 'dart:convert';

@NgDirective(
  selector: '[appt-controller]',
  publishAs: 'day'
)
class AppointmentController {
  List appointments = [];
  String newAppointmentText;
  AppointmentBackend _server;

  AppointmentController(this._server) {
    _server.init(this);
  }

  void add() {
    var appointment = _fetchAppointment();
    appointments.add(appointment);
    _server.add(appointment);
  }

  void remove(Map appointment) {
    appointments.remove(appointment);
    _server.remove(appointment['id']);
  }

  Map _fetchAppointment() {
    var appointment = _fromText(newAppointmentText);
    newAppointmentText = null;
    return appointment;
  }

  Map _fromText(v) {
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

class AppointmentBackend {
  Http _http;
  AppointmentBackend(this._http);

  init(AppointmentController cal) {
    _http(method: 'GET', url: '/appointments').
      then((HttpResponse res)=> cal.appointments = res.data);
  }

  add(Map record) {
    _http(method: 'POST', url: '/appointments', data: JSON.encode(record));
  }

  remove(String id) {
    _http(method: 'DELETE', url: '/appointments/${id}');
  }
}
