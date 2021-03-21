import "package:http/http.dart" as http;
import 'dart:convert';
import 'package:retreatapp/models/exercise.dart';
import 'package:retreatapp/models/story.dart';

final host = "https://cddo2021.jackli.org";
//final host = "http://localhost:8081";
//final host = "https://re-treat.uc.r.appspot.com";

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
        List<String> response = (elem['responses'] as List)?.map((
            item) => item as String)?.toList();
        Story s = Story(elem['id'].toString(),elem['body'], elem['author'], elem['emotion'], elem['timestamp'],response,elem['resp_count']);
        storyList.add(s);
      });
      return storyList;
    }
  }
  else{ return null; }
}


void logVisit(String pageName, Map<String, Object> data) async {
  var url = host + '/log/';
  var header = { 'Content-Type': 'application/json; charset=UTF-8'};
  var body = { "pageName": pageName, "data": data};
  var response = await http.post(url, headers: header, body: jsonEncode(body));
  return;
}

void sendResponse(String pageName, String resp) async {
  var url = host + '/story/response/';
  var header = { 'Content-Type': 'application/json; charset=UTF-8'};
  var body = { "storyId": pageName, "response": resp};
  var response = await http.post(url, headers: header, body: jsonEncode(body));
  return;
}
/* For debug use
void main() {
  String emotionId = "emoji";
  getStoriesForEmotion(emotionId).thenh((value) => {print(value)});
}
 */
