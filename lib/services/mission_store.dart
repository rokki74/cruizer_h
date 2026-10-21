class MissionStore {
  static final MissionStore _instance = MissionStore._internal();
  factory MissionStore() => _instance;
  MissionStore._internal();

  final List<Map<String, dynamic>> _usedMissions = [];

  List<Map<String, dynamic>> get usedMissions => _usedMissions;

  void addMission(Map<String, dynamic> mission) {
    if (!_usedMissions.any((m) => m['id'] == mission['id'])) {
      _usedMissions.add(mission);
    }
  }
}
