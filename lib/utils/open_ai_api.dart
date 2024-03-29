import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:quiz/utils/massage.dart';
import 'package:quiz/utils/question.dart';
import 'dart:convert';
import 'chat.dart';
import 'team.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

/// this singleton class is used to communicate with the OpenAI API
/// it holes the API Key and is used to generate images and questions
class OpenAIApi {
  static final OpenAIApi _singleton = OpenAIApi._internal();

  // the API key for the OpenAI API
  String? _aPIKey;

  factory OpenAIApi() {
    return _singleton;
  }

  OpenAIApi._internal();

  get aPIKey => _aPIKey;

  /// sets the API key for the OpenAI API
  /// [key] the API key
  Future<void> setAPIKey(String key) async {
    _aPIKey = key;
    try{
      Chat chat = Chat("Translate to German");
      chat.addMessageUser("hi");
      await _getChatAnswer(chat, 10);
    } catch(e){
      _aPIKey = null;
      rethrow;
    }
    return;
  }

  /// returns a funny image for a team with the name [name]
  /// the image is generated by the OpenAI API
  /// image will be PNG 512x512
  Future<ImageWithDescription> getTeamImage(String name) async {
    // instruct the chat bot
    Chat getImagesChat = Chat("You are a helpful assistant that briefly describes funny profile pictures for teams. You describe the pictures in English. You must not describe any text like on signs or shirts! Also avoid using names of real persons just describe them if needed.");
    // add example to the chat
    getImagesChat.addMessageUser("Describe a picture for the team \"Inquisitive Pigs\".");
    getImagesChat.addMessage(Massage(role: MassageRole.assistant, massage: "A image of a pig dressed like a librarian."));
    // add the name of the team to the chat
    getImagesChat.addMessageUser("Describe a picture for the team \"$name\".");

    // get the description
    String imageText = await _getChatAnswer(getImagesChat, 500);

    // get the image
    Uint8List image = await _getImage(imageText, 1024, 'dall-e-3');

    // return the image and the description
    return ImageWithDescription(image, imageText);
  }

  /// explain way the answer is the only correct answer
  /// [question] the question to explain
  /// [context] the context for the localizations
  /// returns a string with the explanation for the answer and why it is the only correct answer
  Future<String> getExplanation(Question question, context) async {
    // instruct the chat bot with the localizations to get the correct language
    Chat getExplanationChat = Chat(AppLocalizations.of(context)!.explainQuestionPotInstruction);
    // add the question to the chat
    getExplanationChat.addMessageUser(AppLocalizations.of(context)!.explainQuestionUserMassage(question.getRealAnswer(context).toString(), question.getWrongAnswers(), question.questionText));

    // get the explanation
    String explanation = await _getChatAnswer(getExplanationChat, 500);
    return explanation;
  }

  /// Generates a question from the OpenAI API
  /// [category] is the category of the question which can be any string
  /// [difficulty] is the difficulty of the question 1 to 5
  /// Returns a Question object
  /// throws an error if the question could not be generated or is in the wrong format
  Future<Question> getQuestion(String category, String difficulty, context) async {
    // instruct the chat bot with the localizations to get the correct language
    Chat getQuestionChat = Chat(AppLocalizations.of(context)!.getQuestionPotInstruction);
    // add example to the chat
    getQuestionChat.addMessageUser(AppLocalizations.of(context)!.getQuestionExample1UserMassage);
    getQuestionChat.addMessage(Massage(role: MassageRole.assistant, massage: AppLocalizations.of(context)!.getQuestionExample1BotMassage));
    getQuestionChat.addMessageUser(AppLocalizations.of(context)!.getQuestionExample2UserMassage);
    getQuestionChat.addMessage(Massage(role: MassageRole.assistant, massage: AppLocalizations.of(context)!.getQuestionExample2BotMassage));
    // add the category and difficulty to the chat
    getQuestionChat.addMessageUser(AppLocalizations.of(context)!.getQuestionUserMassage(category, difficulty));

    // get the question text in the correct language and format
    String questionAndAnswerText = "";
    try{
      questionAndAnswerText = await _getChatAnswer(getQuestionChat, 300);
      questionAndAnswerText = questionAndAnswerText.trim();
    } catch(e){
      return Future.error(e.toString());
    }
    try{
      // try to parse the question
      // the expected format is:
      // Question: Question text
      // Answer: Correct answer
      // WrongAnswers:
      // 1: Wrong answer 1
      // 2: Wrong answer 2
      // 3: Wrong answer 3
      List<String> lines = questionAndAnswerText.split("\n");
      String questionText = lines[0].split("estion:")[1].trim();
      String answerText = lines[1].split("swer:")[1].trim();
      String wrongAnswerText1 = lines[3].split("1:")[1].trim();
      String wrongAnswerText2 = lines[4].split("2:")[1].trim();
      String wrongAnswerText3 = lines[5].split("3:")[1].trim();
      // shuffle the answers
      List<String> answers = [answerText, wrongAnswerText1, wrongAnswerText2, wrongAnswerText3];
      answers.shuffle();
      // get the index of the correct answer + 1
      int correctAnswer = answers.indexOf(answerText) + 1;
      return Question(questionText, answers[0], answers[1], answers[2],
          answers[3], correctAnswer);
    } catch(e){
      return Future.error("The OpenAI API returned an invalid question. Please try again.");

    }

  }

  /// Generates an image for the question
  /// [question] is the question for which the image should be generated
  /// [category] is the category of the question
  ///  returns a Uint8List with the png image 512x512
  Future<Uint8List> getQuestionImage(Future<Question> question, String category) async {
    // wait for the question to be generated
    Question q = await question;

    // instruct the chat bot
    Chat getImagesChat = Chat("You are a helpful assistant that briefly describes a charcoal drawing of for questions. You describe the images in English. You must not describe any text like on signs or shirts! Do not spoil the answer in the image.");
    // add example to the chat
    getImagesChat.addMessageUser("Describe a charcoal drawing for the question \"What is the name of the first person to walk on the moon?\".");
    getImagesChat.addMessage(Massage(role: MassageRole.assistant, massage: "A charcoal drawing of a full moon hangs low in the sky, casting an eerie glow."));
    getImagesChat.addMessageUser("Describe a charcoal drawing for the question \"Welches ist das größte Tier, das jemals auf der Erde gelebt hat?\".");
    getImagesChat.addMessage(Massage(role: MassageRole.assistant, massage: "A charcoal of a tiny giraffe standing next to a huge elephant."));
    // add the question to the chat
    getImagesChat.addMessageUser("Describe a charcoal drawing for the question \"${q.questionText}\".");

    String imageText = await _getChatAnswer(getImagesChat, 500);

    Uint8List image = await _getImage(imageText, 512);
    return image;
  }

  /// Generates an image with the teams on a podium
  /// [image] is the image of the podium must be 1024x1024 pixels and a png with RGBA
  /// [mask] is the mask 1024x1024 pixels and a png with RGBA
  /// [teamNames] is a list of the names of the teams in sorted order first the first place team
  /// [teamDescription] is a list of the descriptions of the teams in sorted order first the first place team
  /// returns a Uint8List with the png image 1024x1024
  Future<Uint8List> getCompletedPodiumImage(Uint8List image, Uint8List mask) async {
    // instruct the chat bot
    Chat getImagesChat = Chat("You are a helpful assistant that briefly describes a crazy and funny image. You must not describe any text like on signs or shirts! Always describe a funny event happening in the background.");
    getImagesChat.addMessageUser("Describe a image of an award ceremony.");
    getImagesChat.addMessage(Massage(role: MassageRole.assistant, massage: "A image of a group of people standing on a stage. A lage space ship is landing in the background."));
    getImagesChat.addMessageUser("Describe a image of an award ceremony.");

    String imageText = await _getChatAnswer(getImagesChat, 200);

    Uint8List completedImage =
        await _getCompletedImage(image, mask, imageText, 1024);
    return completedImage;
  }

  /// used to complete an existing image based on a prompt and a mask
  /// it uses the OpenAI API Image edits endpoint see https://platform.openai.com/docs/guides/images/usage
  /// [size] is the size of the image in pixels must be 256, 512, or 1024.
  /// [prompt] is the text that describes the entire image
  /// [image] is the image to be completed in base64 format PNG in RGBA format
  /// [mask] is the mask to be used in base64 format PNG in RGBA format the transparent pixels are the pixels that will be completed
  Future<Uint8List> _getCompletedImage(
      Uint8List image, Uint8List mask, String prompt, int size) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.openai.com/v1/images/edits'),
    )
      ..headers["Authorization"] = 'Bearer $_aPIKey'
      ..fields.addAll({
        'size': '${size}x$size',
        'n': '1', // just  get one image
        'prompt': prompt,
        'response_format': 'b64_json' // return the image as base64
      })
      ..files.addAll([
        http.MultipartFile.fromBytes(
          'image',
          image,
          filename: 'image.png',
        ),
        http.MultipartFile.fromBytes(
          'mask',
          mask,
          filename: 'mask.png',
        ),
      ]);
    final response = await http.Response.fromStream(await request.send());

    if (response.statusCode == 201 || response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      var b64 = data["data"][0]["b64_json"];
      return const Base64Codec().decode(b64);
    } else {
      throw Exception(['http.post error', response.statusCode, response.body]);
    }
  }

  /// Generates a Image with the OpenAI API Image generations endpoint see https://platform.openai.com/docs/guides/images/usage
  /// based on the description in [prompt]
  /// [size] is the size of the image in pixels must be 256, 512, or 1024. for dall e 2 and 1024 for dall e 3
  Future<Uint8List> _getImage(String prompt, int size, [String model='dall-e-2']) async {
    http.Response response = await http.post(
      Uri.parse('https://api.openai.com/v1/images/generations'),
      headers: <String, String>{
        'Authorization': 'Bearer $_aPIKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, dynamic>{
        "model": model,
        'size': '${size}x$size',
        'n': 1, // just  get one image
        'prompt': prompt,
        'response_format': 'b64_json' // return the image as base64
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      var b64 = data["data"][0]["b64_json"];
      return const Base64Codec().decode(b64);
    } else {
      throw Exception(['http.post error', response.statusCode, response.body]);
    }
  }

  /// Generates the next answer for the [chat] from the OpenAI API Text completions endpoint see https://platform.openai.com/docs/guides/chat
  /// it uses the GPT-3.5-turbo model this makes this function 10 times cheaper than _getText with text-davinci-003
  /// [maxTokens] is the maximum number of tokens to generate
  /// [temperature] is the temperature of the model defaults to 0.4
  /// returns the answer as a String
  Future<String> _getChatAnswer(Chat chat,  int maxTokens, [double? temperature]) async {
    http.Response response = await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: <String, String>{
        'Authorization': 'Bearer $_aPIKey',
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: jsonEncode(<String, dynamic>{
        'model': 'gpt-3.5-turbo',
        'messages': chat.massagesAsMap,
        'max_tokens': maxTokens,
        'temperature': temperature ?? 0.4,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      String body = utf8.decode(response.bodyBytes);
      Map<String, dynamic> data = jsonDecode(body);
      String massageText =  data["choices"][0]["message"]["content"];
      return massageText;
    } else {
      throw Exception(['http.post error', response.statusCode, response.body]);
    }
  }
}
