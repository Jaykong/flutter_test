import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_timer/bloc/timer_bloc.dart';
import 'package:flutter_timer/bloc/timer_event.dart';
import 'package:flutter_timer/bloc/timer_state.dart';
import 'package:flutter_timer/ticker.dart';
import 'package:test/test.dart' as kyptest;

void main() {
  TimerBloc timerBloc;
  Ticker ticker;
  group('timer_bloc', () {
    setUp(() {
      ticker = Ticker();
      timerBloc = TimerBloc(ticker: ticker);
    });

    test('initial state', () {
      expect(timerBloc.initialState, Ready(60));
    });

    test('ticker is null', () {
      expect(() => TimerBloc(ticker: null), throwsA(isAssertionError));
    });

    blocTest('Running state',
        build: () => timerBloc,
        act: (bloc) => bloc.add(Start(duration: 60)),
        expect: [Ready(60), Running(60)]);
    blocTest('ready state',
        build: () => timerBloc,
        act: (bloc) => bloc.add(Reset()),
        expect: [Ready(60)]);
    blocTest('pause state',
        build: () => timerBloc,
        act: (bloc) {
          bloc.add(Start(duration: 60));
          bloc.add(Pause());
        },
        expect: [Ready(60), Running(60), Paused(60)]);
    blocTest('finished state',
        build: () => timerBloc,
        act: (bloc) => bloc.add(Tick(duration: 0)),
        expect: [Ready(60), Finished()]);
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
