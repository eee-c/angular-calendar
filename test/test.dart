import 'package:unittest/unittest.dart';
import 'package:unittest/mock.dart';
import 'dart:html';
import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';

import 'package:angular_calendar/calendar.dart';

class AppointmentBackendMock extends Mock implements AppointmentBackend {}

main(){
  group('Appointment controller', (){
    setUp((){
      setUpInjector();
      var server = new AppointmentBackendMock();
      module((Module _) => _
        ..value(AppointmentBackend, server)
        ..type(AppointmentController)
      );
    });
    tearDown(tearDownInjector);

    test('adding records to server', (){
      inject((AppointmentController controller, AppointmentBackend server) {
        controller.newAppointmentText = '00:00 Test!';
        controller.add();

        server.
          getLogs(callsTo('add', {'time': '00:00', 'title': 'Test!'})).
          verify(happenedOnce);
      });
    });

    group('removing records', (){
      var record = {'id': '42', 'title': 'Foo!'};

      test('removes it from the server', (){
        inject((AppointmentController controller, AppointmentBackend server) {
          controller.appointments = [record];
          controller.remove(record);

          server.
            getLogs(callsTo('remove', '42')).
            verify(happenedOnce);
        });
      });

      test('removes it from the collection', (){
        inject((AppointmentController controller, AppointmentBackend server) {
          controller.appointments = [record];
          controller.remove(record);

          expect(controller.appointments.length, 0);
        });
      });
    });
  });

  group('Appointment Backend', (){
    setUp(() {
      setUpInjector();
      module((Module _) => _
        ..type(MockHttpBackend)
        ..type(AppointmentBackend)
      );
    });

    tearDown(tearDownInjector);

    test('add will POST for persistence', (){
      inject((AppointmentBackend server, HttpBackend http) {
        http.
          expectPOST('/appointments', '{"foo":42}').
          respond('{"id:"1", "foo":42}');

        server.add({'foo': 42});
      });
    });

    test('remove will DELETE record', (){
      inject((AppointmentBackend server, HttpBackend http) {
        http.
          expectDELETE('/appointments/42').
          respond('{}');

        server.remove('42');
      });

    });
  });

  pollForDone(testCases);
}

pollForDone(List tests) {
  if (tests.every((t)=> t.isComplete)) {
    window.postMessage('dart-main-done', window.location.href);
    return;
  }

  var wait = new Duration(milliseconds: 100);
  new Timer(wait, ()=> pollForDone(tests));
}
