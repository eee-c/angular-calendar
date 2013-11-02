import 'package:scheduled_test/scheduled_test.dart';
import 'package:unittest/mock.dart';
import 'dart:html';
import 'dart:async';

import 'package:angular/angular.dart';
import 'package:angular/mock/module.dart';

import 'package:angular_calendar/calendar.dart';

class AppointmentBackendMock extends Mock implements AppointmentBackend {}

const HTML =
'''<div appt-controller>
     <ul>
       <li ng-repeat="appt in day.appointments">
         {{appt.time}} {{appt.title}}
         <a ng-click="day.remove(appt)">
           <i class="icon-remove" ></i>
         </a>
       </li>
     </ul>
     <form onsubmit="return false;">
       <input ng-model="day.newAppointmentText" type="text">
       <input ng-click="day.add()" type="submit" value="add">
     </form>
   </div>''';

main(){
  group('Appointment Application', (){

    var tb, http;

    setUp((){
      // 1. Setup and teardown test injector
      setUpInjector();
      currentSchedule.onComplete.schedule(tearDownInjector);

      // 2. Build test module, including application classes
      module((Module _) => _
        ..type(TestBed)
        ..type(MockHttpBackend)
        ..type(AppointmentBackend)
        ..type(AppointmentController)
      );

      // 3. Inject test bed and Http for test expectations and HTTP stubbing
      inject((TestBed _t, HttpBackend _h) {tb = _t; http = _h;});

      // 4. Associate test module with HTML
      tb.compile(HTML);

      // 5. Stub HTTP request made on module initialization
      http.
        whenGET('/appointments').
        respond(200, '[{"id":"42", "title":"Test Appt #1", "time":"00:00"}]');

      // 6. Flush the response stubbed for the initial request
      schedule(()=> http.flush());

      // 7. Trigger updates of bound variables in the HTML
      schedule(()=> tb.rootScope.$digest());
    });

    test('Retrieves records from HTTP backend', (){
      schedule((){
        expect(
          tb.rootElement.query('ul').text,
          contains('Test Appt #1')
        );
      });
    });

    test('Add a record', (){
      http.
        whenPOST('/appointments', '{"time":"23:59","title":"Go to bed"}').
        respond(201, '{"id":"42", "title":"Go to bed", "time":"23:59"}');

      schedule((){
        var el = tb.rootElement.query('input[type=text]')
          ..value = '23:59 Go to bed';
        tb.triggerEvent(el, 'change');

        tb.rootElement.
          query('input[type=submit]').
          click();
      });
      schedule(()=> http.flush());
      schedule(()=> tb.rootScope.$digest());
      schedule((){
        expect(
          tb.rootElement.query('ul').text,
          contains('Go to bed')
        );
      });
    });

  });

  group('Appointment controller', (){
    setUp((){
      setUpInjector();
      var server = new AppointmentBackendMock();
      module((Module _) => _
        ..value(AppointmentBackend, server)
        ..type(AppointmentController)
      );
      currentSchedule.onComplete.schedule(tearDownInjector);
    });

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
      currentSchedule.onComplete.schedule(tearDownInjector);
    });

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
