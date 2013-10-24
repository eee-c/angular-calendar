import 'package:angular/angular.dart';
import 'package:angular_calendar/calendar.dart';

main() {
  var calendar = new AngularModule()
    ..type(AppointmentBackend)
    ..type(AppointmentController);

  ngBootstrap(module: calendar);
}
