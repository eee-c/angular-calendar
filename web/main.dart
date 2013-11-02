import 'package:angular/angular.dart';
import 'package:angular/routing/module.dart';
import 'package:angular_calendar/calendar.dart';

main() {
  var calendar = new AngularModule()
    ..type(AppointmentBackend)
    ..type(AppointmentController)
    ..type(DayViewController)
    ..type(RouteInitializer, implementedBy: CalendarRouter);

  ngBootstrap(module: calendar);
}
