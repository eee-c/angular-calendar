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
    /*
    setUp((){

      var module = new AngularMockModule()
        ..type(AppointmentBackend)
        ..type(AppointmentController);

      bootstrapAngular([module]);
    });
    */

    // Scope scope;
    // setUp(inject((Scope rootScope) { scope = rootScope; }));

    var server;
    setUp((){
      server = new AppointmentBackendMock();
    });

    test('adding records to server', (){
      var controller = new AppointmentController(server);
      controller.newAppointmentText = '00:00 Test!';
      controller.add();

      server.
        getLogs(callsTo('add', {'time': '00:00', 'title': 'Test!'})).
        verify(happenedOnce);
    });

    group('removing records', (){
      var controller, record;
      setUp((){
        controller = new AppointmentController(server);
        record = {'id': '42', 'title': 'Foo!'};
        controller.appointments = [record];
      });

      test('removes it from the server', (){
        controller.remove(record);

        server.
          getLogs(callsTo('remove', '42')).
          verify(happenedOnce);
      });

      test('removes it from the collection', (){
        controller.remove(record);
        expect(controller.appointments.length, 0);
      });
    });
  });

  group('Appointment Backend', (){
    var server, http_backend;
    setUp((){
      http_backend = new MockHttpBackend();
      var http = new Http(
        new UrlRewriter(),
        http_backend,
        new HttpDefaults(new HttpDefaultHeaders()),
        new HttpInterceptors()
      );
      server = new AppointmentBackend(http);
    });

    test('add will POST for persistence', (){
      http_backend.
        expectPOST('/appointments', '{"foo":42}').
        respond('{"id:"1", "foo":42}');

      server.add({'foo': 42});
    });

    test('remove will DELETE record', (){
      http_backend.
        expectDELETE('/appointments/42').
        respond('{}');

      server.remove('42');
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