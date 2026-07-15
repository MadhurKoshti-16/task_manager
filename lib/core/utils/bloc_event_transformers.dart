import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';

EventTransformer<Event> debounceRestartable<Event>({
  Duration duration = const Duration(milliseconds: 450),
}) {
  return (events, mapper) {
    return restartable<Event>().call(events.debounceTime(duration), mapper);
  };
}
