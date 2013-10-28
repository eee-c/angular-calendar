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
