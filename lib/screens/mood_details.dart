import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:retreatapp/models/exercise.dart';
import 'package:retreatapp/screens/exercise_page.dart';
import 'package:retreatapp/components/httpUtil.dart';
import '../constants.dart';

final mood = moodMap['stressed'];
final exerciseId = todaysChallengeIdMap['stressed'];

final Uint8List kTransparentImage = new Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
]);

final title = RichText(
  text: TextSpan(
    // Note: Styles for TextSpans must be explicitly defined.
    // Child text spans will inherit styles from parent
    style: kTitleTextStyle,
    children: <TextSpan>[
      TextSpan(text: mood.code, style: moodDetailsEmojiStyle),
      TextSpan(text: ' #' + mood.name, style: kTitleTextStyle),
    ],
  ),
);

class moodDetails extends StatelessWidget{
  @required
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: title,
        centerTitle: false,
        titleSpacing:
        (MediaQuery.of(context).size.width * (1 - kWidthFactor)) / 2.5,
        toolbarHeight: 120.0,
        elevation: 0.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(left: 100.0, top: 20.0),
              child:
                RichText(

                  textAlign: TextAlign.left,
                  text: TextSpan(
                    style: moodDetailsSubTitleStyle,
                    text: "Today's Challenge",
                  ),
                ),
          ),
          Padding(
          padding: EdgeInsets.only(left: 80.0),
          child:
            SizedBox(
              height: MediaQuery.of(context).size.height*0.3,
              child: StaggeredGridView.countBuilder(
                primary: false,
                crossAxisCount: 6,
                mainAxisSpacing: 4.0,
                crossAxisSpacing: 4.0,
                itemBuilder: (context, index) => new _Tile(
                    index, new IntSize(100, 100), exerciseId),
                staggeredTileBuilder: (index) => new StaggeredTile.fit(2),
                itemCount: 1,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 100.0, top: 20),
            child:
              RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  style: moodDetailsSubTitleStyle,
                  text: "Shared Stories",
                ),
              ),
          )
        ]
      )
    );
  }
}

class IntSize {
  const IntSize(this.width, this.height);

  final int width;
  final int height;
}

class _Tile extends StatelessWidget {
  _Tile(this.index, this.size, this.exerciseId);

  final IntSize size;
  final int index;
  final String exerciseId;
  Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Exercise>(
        future: getExercise(exerciseId),
        builder: (BuildContext context, AsyncSnapshot<Exercise> snapshot){
          if(snapshot.hasData){
            exercise = snapshot.data;
            return InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExercisePage(
                          exercise: exercise,
                        )));
              },
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0))),
                margin: EdgeInsets.all(10.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          herb.code + ' ${exercise.name}',
                          style: kCardHeaderTextStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18.0, 0.0, 18.0, 18.0),
                      child: Row(
                        children: [
                          // image
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Stack(
                                children: <Widget>[
                                  //new Center(child: new CircularProgressIndicator()),
                                  new Center(
                                    child: new FadeInImage.memoryNetwork(
                                      placeholder: kTransparentImage,
                                      image: exercise.image,
                                      fit: BoxFit.fitWidth,
                                      imageScale: 2.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // target emotion and effect/goal text
                          Expanded(
                            flex: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: new Column(
                                children: <Widget>[
                                  CardContentText(
                                    emoji: target.code,
                                    header: 'Targeting emotion',
                                    content: exercise.labelsTargetEmotion.join(', '),
                                  ),
                                  CardContentText(
                                    emoji: trophy.code,
                                    header: 'Effect/goal',
                                    content: exercise.labelsEffectAndGoal.join(', '),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          else if(snapshot.hasError){
            return Text(
              'Error loading today\'s challenge.',
              textAlign: TextAlign.center,
            );
          }
          else{
            return RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                // Note: Styles for TextSpans must be explicitly defined.
                // Child text spans will inherit styles from parent
                style: moodDetailsSubTitleStyle,
                children: <TextSpan>[
                  TextSpan(text: "Loading...", style: moodDetailsSubTitleStyle),
                ],
              ),
            );
          }
    });
  }
}

class CardContentText extends StatelessWidget {
  const CardContentText({
    Key key,
    @required this.emoji,
    @required this.header,
    @required this.content,
  }) : super(key: key);

  final String emoji;
  final String header;
  final String content;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          // Note: Styles for TextSpans must be explicitly defined.
          // Child text spans will inherit styles from parent
          children: <TextSpan>[
            TextSpan(text: '$emoji '),
            TextSpan(text: '$header: ', style: kCardContentHeaderTextStyle),
            TextSpan(text: '$content', style: kCardContentDetailTextStyle),
          ],
        ),
      ),
    );
  }
}