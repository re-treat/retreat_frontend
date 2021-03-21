import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:retreatapp/models/exercise.dart';
import 'package:retreatapp/models/story.dart';

// final host = "http://localhost:8081";
//final host = "https://re-treat.uc.r.appspot.com";
final host = "https://cddo2021.jackli.org";

Future<List<String>> getLabels(String question) async {
  var url = host+"/getLabels";
  var header = {  'Content-Type': 'application/json; charset=UTF-8' };
  var body = { "question" : question };

  var response = await http.post(url, headers: header, body: jsonEncode(body));
  if(response.statusCode == 200){
    var result = jsonDecode(response.body);
    return result.cast<String>();
  }
  else{ return null; }
}

Future<List<String>> matchExercise(List<String> labels_q1, List<String> labels_q2, List<String> labels_q3, int size) async {
  var url = host+"/matchExercise";
  var header = {  'Content-Type': 'application/json; charset=UTF-8' };
  var body = {
    "labels_q1": labels_q1,
    "labels_q2": labels_q2,
    "labels_q3": labels_q3,
    "size": size
  };

  var response = await http.post(url, headers: header, body: jsonEncode(body));
  if(response.statusCode == 200){
    var result = jsonDecode(response.body);
    return result.cast<String>();
  }
  else{ return null; }
}

Future<Exercise> getExercise(String exerciseId) async{
  var url = host + "/getExercise";
  var header = {  'Content-Type': 'application/json; charset=UTF-8' };
  var body = { "id": exerciseId };

  var response = await http.post(url, headers: header, body: jsonEncode(body));
  if(response.statusCode == 200){
    var result = jsonDecode(response.body);
    String name = result["name"];
    String reference = result["reference"];
    String image = "images/" + result["image"];

    var labels = result["labels_q1"];
    List<String> labels_q1 = List<String>();
    labels.forEach((label) => labels_q1.add(label));

    labels = result["labels_q2"];
    List<String> labels_q2 = List<String>();
    labels.forEach((label) => labels_q2.add(label));

    labels = result["labels_q3"];
    List<String> labels_q3 = List<String>();
    labels.forEach((label) => labels_q3.add(label));

    Exercise exercise = Exercise(exerciseId, name, image, labels_q1, labels_q2, labels_q3);

    exercise.addReference(reference);
    var instructions = result["instructions"];
    instructions.forEach((inst) => {
      exercise.addInstruction(inst["type"], inst["content"])
    });
    return exercise;
  }
  else { return null; }
}
/** For get stories */
Future<Story> getStoryById(String storyId) async {
  var url = host + "/getStoryById";
  var header = { 'Content-Type': 'application/json; charset=UTF-8' };
  var body = {"id": storyId};
  // Story(String id,String body, String author, String emotion, var timestamp,List<String> responses, int count)
  var response = await http.post(url, headers: header, body: jsonEncode(body));
  if (response.statusCode == 200) {
    var result = jsonDecode(response.body);
    String body = result["body"];
    String author = result["author"];
    String emotion = result["emotion"];
    var timestamp = result["timestamp"];
    List<String> responses = result["responses"];
    var count = result["count"]
    Story story = Story(storyId, body, author, emotion, timestamp, responses, count);
    return story;
  } else {
    print("get story error!");
    return null;
  }
}

/** For Create Story Sharing */
Future<void> createStory(String body, String author, String emotion) async {
  var url = host + "/createStory";
  var header = { 'Content-Type': 'application/json; charset=UTF-8' };
  // Story(String id,String body, String author, String emotion, var timestamp,List<String> responses, int count)
  var jsonBody = {"body": body, "author": author, "emotion": emotion, "timestamp": DateTime.now().millisecondsSinceEpoch, "responses": new List<String>(), "count": 0};
  var response = await http.post(url, headers: header, body: jsonEncode(jsonBody));
  // only need to handle error case
  if (response.statusCode != 200) {
      print("createStory Error!");
      return null;
  }
}


Future<List<Story>> getStoriesForEmotion(String emotionId) async {
  var url = host + '/story/query/?emotion=' + emotionId;
  var header = {  'Content-Type': 'application/json; charset=UTF-8' };
  var response = await http.get(url, headers: header);

  if(response.statusCode == 200){
    var result = jsonDecode(response.body)['result'];
    var success = result['success'];
    var data = result['data']['lst'];
    List<Story> storyList = [];
    if(success){
      data.forEach((elem) {
        Story s = Story(elem['body'], elem['author'], elem['emotion'], elem['timestamp']);
        storyList.add(s);
      });
      return storyList;
    }
  }
  else{ return null; }
}

/* For debug use
void main() {
  String emotionId = "emoji";
  getStoriesForEmotion(emotionId).thenh((value) => {print(value)});
}
 */
