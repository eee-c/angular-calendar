import 'package:angular/angular.dart';
import 'package:angular_calendar/calendar.dart';

main() {
  var module = new AngularModule()
    ..type(AppointmentBackend)
    ..type(AppointmentController);

  ngBootstrap(module: module);
}
