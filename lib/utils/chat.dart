import 'massage.dart';

/// this class is used to represent massages in a chat for the open ai api chat
class Chat {
  List<Massage> massages = [];

  /// constructor for a chat adds the first massage
  Chat(String systemMassage) {
    massages.add(Massage(massage: systemMassage, role: MassageRole.system));
  }

  /// adds a user massage to the chat
  void addMessageUser(String message) {
    massages.add(Massage(massage: message, role: MassageRole.user));
  }

  void addMessage(Massage massage) {
    massages.add(massage);
  }

  /// gets all massages as list of maps
  List<Map<String, dynamic>> get massagesAsMap {
    List<Map<String, dynamic>> massagesAsMap = [];
    for (var massage in massages) {
      massagesAsMap.add(massage.getMassage());
    }
    return massagesAsMap;
  }
}