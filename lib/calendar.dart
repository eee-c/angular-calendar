import 'package:angular/angular.dart';
import 'package:angular/routing/module.dart';
import 'dart:convert';

class CalendarRouter implements RouteInitializer {
  Scope _scope;
  CalendarRouter(this._scope);

  void init(Router router, ViewFactory view) {
    router.root
      ..addRoute(
          defaultRoute: true,
          name: 'day-list',
          enter: view('partials/day_list.html')
        )
      ..addRoute(
          name: 'day-view',
          path: '/days/:dayId',
          enter: view('partials/day_view.html')
        );
  }
}

@NgDirective(
  selector: '[day-view-controller]',
  publishAs: 'appt'
)
class DayViewController implements NgDetachAware {
  String id;
  String title = 'Default Title';
  String time = '08:00';
  AppointmentBackend _server;
  RouteHandle route;

  DayViewController(RouteProvider router, this._server) {
    route = router.route.newHandle();

    id = router.route.parameters["dayId"];
    _server.
      get(id).
      then((rec) {
        title = rec['title'];
        time = rec['time'];
      });
  }

  detach() {
    // The route handle must be discarded.
    route.discard();
  }
}

@NgDirective(
  selector: '[appt-controller]',
  publishAs: 'day'
)
class AppointmentController {
  List appointments = [];
  String newAppointmentText;
  AppointmentBackend _server;
  Router _router;

  AppointmentController(this._server, this._router) {
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

  void navigate(Map appointment) {
    _router.route('/days/${appointment["id"]}');
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

  get(String id) =>
    _http(method: 'GET', url: '/appointments/${id}').
      then((HttpResponse res)=> res.data);

  add(Map record) {
    _http(method: 'POST', url: '/appointments', data: JSON.encode(record));
  }

  remove(String id) {
    _http(method: 'DELETE', url: '/appointments/${id}');
  }
}
