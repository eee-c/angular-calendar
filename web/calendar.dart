import 'package:angular/angular.dart';

@NgDirective(
  selector: '[appt-controller]'
)
class AppointmentCtrl {
  AppointmentCtrl(Scope scope) {
    scope
      ..['appointments'] = [{'time': '08:00', 'title': 'Wake Up'}]
      ..['addAppointment'] = (){print('yo');};
  }
}

main() {
  var module = new AngularModule()
    ..type(AppointmentCtrl);
  bootstrapAngular([module]);
}
