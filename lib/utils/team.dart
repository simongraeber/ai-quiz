import 'dart:typed_data';
import 'open_ai_api.dart';


/// This class is used to represent a team.
/// ech team has a name and a number of points
/// the image and the image description are loaded async
class Team {
  String name;
  int points;
  Future<Uint8List>? image;
  Future<String>? imageDescription;
  int? place;

  Team({required this.name, this.points = 0});

  /// loads the image and the image description async
  /// context is needed for localizations
  void setImage(){
    final img = OpenAIApi().getTeamImage(name);
    image = img.then((value) => value.image);
    imageDescription = img.then((value) => value.description);
  }

  /// adds points to the team
  void addPoints(int points){
    this.points += points;
  }
}

/// This class is used to represent to uns image and its description as a single object
class ImageWithDescription {
  Uint8List image;
  String description;

  ImageWithDescription(this.image, this.description);
}