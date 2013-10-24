import 'package:angular/angular.dart';
import 'package:angular_calendar/calendar.dart';

main() {
  var module = new AngularModule()
    ..type(ServerCtrl)
    ..type(AppointmentCtrl);

  bootstrapAngular([module]);
}
