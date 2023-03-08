import 'dart:convert';
import '../utils/team.dart';
import 'dart:async';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import '../utils/open_ai_api.dart';
import 'dart:html' as html;

/// Takes the images of the first 3 teams and combines them with the background image to create a podium image
/// [teams] the teams the first 3 teams will be used
/// returns the podium image as Uint8List
Future<Uint8List> getPodiumImage(List<Team> teams) async {
  // download the first 3 images from the list
  List<img.Image> images = [];
  for (int i = 0; i < 3; i++) {
    if (i < teams.length) {
      Uint8List imageUnit8 = await teams[i].image!;
      images.add(img.decodeImage(imageUnit8)!);
    }
  }

  // reduce the size of the team images
  for (int i = 0; i < images.length; i++) {
    images[i] = img.copyResize(images[i], width: 340, height: 340);
  }

  // lode the background image
  ByteData backgroundBytes =
      await rootBundle.load("assets/podium/background.png");
  Uint8List backgroundUint8 = backgroundBytes.buffer.asUint8List();
  img.Image? background = img.decodeImage(backgroundUint8);
  if (background == null) {
    // check if the background image is null
    throw Exception("background image is null");
  }

  // combine the images into one image
  // the first place team is on the middle pole
  if (images.isNotEmpty) {
    img.compositeImage(background, images[0],
        dstX: 342, dstY: 486, blend: img.BlendMode.direct);
  }
  // the second place team is on the left pole
  if (images.length > 1) {
    img.compositeImage(background, images[1],
        dstX: 1, dstY: 542, blend: img.BlendMode.direct);
  }
  // the third place team is on the right pole
  if (images.length > 2) {
    img.compositeImage(background, images[2],
        dstX: 684, dstY: 565, blend: img.BlendMode.direct);
  }

  // return the image as Uint8List
  return img.encodePng(background);
}

/// this function used Open Ai to modify the background Image based on the team names and images descriptions
/// [teams] the teams the first 3 teams will be used
/// [background] the background image that will be modified
/// returns the modified background image
Future<Uint8List> getPodiumImageWithOpenAI(
    List<Team> teams, Uint8List background) async {
  ByteData maskBytes = ByteData(0);

  // load the mask image
  if (teams.length == 1) {
    maskBytes = await rootBundle.load("assets/podium/backgroundMask1Teams.png");
  } else if (teams.length == 2) {
    maskBytes = await rootBundle.load("assets/podium/backgroundMask2Teams.png");
  } else {
    maskBytes = await rootBundle.load("assets/podium/backgroundMask3Teams.png");
  }

  // load the mask image
  Uint8List int8ListPodiumMask = maskBytes.buffer.asUint8List();

  // send the image to the open AI api
  Uint8List int8ListCompletedPodium =
      await OpenAIApi().getCompletedPodiumImage(background, int8ListPodiumMask);

  // convert the image img.Image
  img.Image? completedPodium = img.decodeImage(int8ListCompletedPodium);
  if (completedPodium == null) {
    // check if the image is null
    throw Exception("completedPodium image is null");
  }

  // load podium images
  ByteData podiumData = await rootBundle.load("assets/podium/podium.png");
  Uint8List podiumUint8 = podiumData.buffer.asUint8List();
  img.Image? podium = img.decodeImage(podiumUint8);
  if (podium == null) {
    // check if the background image is null
    throw Exception("podium image is null");
  }

  // overlay the team images on the podium
  img.compositeImage(
    completedPodium,
    podium,
    dstX: 0,
    dstY: 830,
    blend: img.BlendMode.alpha,
  );

  // return the image
  return img.encodePng(completedPodium);
}

/// downloads the image [image] as a png file
/// using html to download the image
void downloadImage(Uint8List image) async {
  html.AnchorElement(href: "data:image/png;base64,${base64Encode(image)}")
    ..setAttribute("download", "Ai-Quiz.png") // set the file name
    ..click();
}
