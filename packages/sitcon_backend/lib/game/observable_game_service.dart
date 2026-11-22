import 'package:sitcon_backend/game/game_service.dart';

/// Listener mechanics shared by adapters; the player contract stays pure.
abstract class ObservableGameService implements GameService {
  final List<void Function()> _listeners = [];
  @override
  void addListener(void Function() listener) => _listeners.add(listener);
  @override
  void removeListener(void Function() listener) => _listeners.remove(listener);
  void notifyListeners() {
    for (final listener in List<void Function()>.of(_listeners)) {
      if (_listeners.contains(listener)) listener();
    }
  }

  @override
  void dispose() => _listeners.clear();
}
