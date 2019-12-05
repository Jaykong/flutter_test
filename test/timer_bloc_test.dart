import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timer/bloc/timer_bloc.dart';
import 'package:flutter_timer/bloc/timer_event.dart';
import 'package:flutter_timer/bloc/timer_state.dart';
import 'package:flutter_timer/ticker.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart' as kyptest;

class MockTicker extends Mock implements Ticker {}

void main() {
  TimerBloc timerBloc;
  MockTicker ticker;
  group('timer_bloc', () {
    setUp(() {
      ticker = MockTicker();
      timerBloc = TimerBloc(ticker: ticker);
    });

    test('initial state', () {
      expect(timerBloc.initialState, Ready(60));
    });

    test('ticker is null', () {
      // expect(() => TimerBloc(ticker: null), throwsA(isAssertionError));

      try {
        TimerBloc(ticker: null);
        kyptest.fail('this code should fail');
      } on Object catch (error) {
        kyptest.expect(error, isAssertionError);
      }
    });

    blocTest('Running state',
        build: () => timerBloc,
        act: (bloc) => bloc.add(Start(duration: 60)),
        expect: [Ready(60), Running(60)]);
    blocTest('ready state',
        build: () => timerBloc,
        act: (bloc) => bloc.add(Reset()),
        expect: [Ready(60)]);
    blocTest('pause state', build: () {
      when(ticker.tick(ticks: 66)).thenAnswer((_) => Stream.value(45));
      return timerBloc;
    }, act: (bloc) {
      bloc.add(Start(duration: 45));
      bloc.add(Pause());
    }, expect: [Ready(60), Running(45), Paused(60)]);
    blocTest('finished state',
        build: () => timerBloc,
        act: (bloc) => bloc.add(Tick(duration: 0)),
        expect: [Ready(60), Finished()]);

    blocTest('ticking state',
        build: () => timerBloc,
        act: (bloc) => bloc.add(Tick(duration: 1)),
        expect: [Ready(60), Running(1)]);
    blocTest('resume state',
        build: () => timerBloc,
        act: (bloc) {
          bloc.add(Start(duration: 60));
          bloc.add(Pause());
          bloc.add(Resume());
        },
        expect: [Ready(60), Running(60), Paused(60), Running(60)]);
  });
}
