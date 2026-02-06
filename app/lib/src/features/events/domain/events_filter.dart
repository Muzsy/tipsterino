import 'package:tipsterino/src/features/events/domain/user_event.dart';

enum EventsFilter {
  all,
  credits,
  social,
  challenges,
  system,
}

extension EventsFilterMatch on EventsFilter {
  bool matches(UserEvent event) {
    switch (this) {
      case EventsFilter.all:
        return true;
      case EventsFilter.credits:
        return event.type == 'tippcoin_credit';
      case EventsFilter.social:
      case EventsFilter.challenges:
      case EventsFilter.system:
        return false;
    }
  }
}
