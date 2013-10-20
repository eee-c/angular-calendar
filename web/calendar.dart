import 'package:angular/angular.dart';

@NgDirective(
  selector: '[appt-controller]',
  publishAs: 'day'
)
class AppointmentCtrl {
  List appointments = [{'time': '08:00', 'title': 'Wake Up'}];
  String newAppointmentText;

  void add() {
    var newAppt = fromText(newAppointmentText);
    appointments.add(newAppt);
    newAppointmentText = null;
  }

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

main() {
  var module = new AngularModule()
    ..type(AppointmentCtrl);
  bootstrapAngular([module]);
}
