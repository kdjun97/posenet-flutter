import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'dart:io';
import 'dart:math';
import 'package:image_picker/image_picker.dart';

class PoseNet extends StatefulWidget
{
  @override
  _PoseNetPageState createState() => new _PoseNetPageState();
}

class _PoseNetPageState extends State<PoseNet>
{
  List _recognitions;
  PickedFile _image;
  final ImagePicker _picker = ImagePicker();
  var result;
  double _imageWidth;
  double _imageHeight;
  File _img;
  List points;
  List posenetPoint;
  var res;

  Future _getImage() async{
    PickedFile image = (await _picker.getImage(source: ImageSource.gallery));
    if (this.mounted){
      setState(() {
        _image = image;
        print(_image.path);
        _img = File(_image.path);
      });
    }

    var decodedImage = await decodeImageFromList(_img.readAsBytesSync());
    print('image info : ${decodedImage.width.toString()} x ${decodedImage.height.toString()}');
    setState(() {
      _imageWidth=decodedImage.width.toDouble();
      _imageHeight=decodedImage.height.toDouble();
    });

    loadModel(_image);
  }


  void loadModel(PickedFile image) async
  {
    print('load model 진입');

    if (res == null)
    {
      res = await Tflite.loadModel(
        model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
        //labels: "assets/labels.txt"
      );
    }
    try{
      var result1 = await Tflite.runPoseNetOnImage(
          path: _image.path,     // required
          imageMean: 125.0,   // defaults to 125.0
          imageStd: 125.0,    // defaults to 125.0
          numResults: 2,      // defaults to 5
          threshold: 0.7,     // defaults to 0.5
          nmsRadius: 10,      // defaults to 20
          asynch: true        // defaults to true
      );
      setState(() {
        _recognitions = result1;
      });
    } catch(e)
    {
      print(e.message);
    }
  }

  Widget backgr()
  {
    return (_image == null) ? Text('d')
    : Image.file(File(_img.path));
  }


  List Keypoints(Size screen) {
    print('----------------KeyPoints 진입---------------');
    if (_recognitions == null || _image == null) return [];

    double factorX = screen.width;
    double factorY = _imageHeight / _imageWidth * screen.width;

    var lists = [];
    List<dynamic> results = [];
    List t = [];

    _recognitions.forEach((re) {
      var list = re["keypoints"].values.map((k) {
        if (k["score"] >= 0.5) // 정확도가 50% 이상이라면
        {
            lists.add({'part':k["part"], 'left':k["x"] * factorX - 6, 'top':k["y"] * factorY - 6, 'accuracy':k["score"]});
            //          print(k["part"].toString() + ' x = ' + k["x"].toString() + ' y = ' + k["y"].toString() + ' accuracy = ' + k["score"].toString());
        }
      }).toList();
    });

    return lists;
  }

  List Repoints()
  {
    bool changed=false;
    List delete = [];
    List equal_delete = [];
    int ct = 0;
    //print('시작할때'+points.length.toString());
    for (int i =0; i< points.length-2; i++)
    {
      for (int j=i+1; j<points.length;j++)
      {
        if (points[i]['part'] == points[j]['part'] && points[i]['accuracy'] == points[j]['accuracy'])
          equal_delete.add(j);
      }
    }

    //print(equal_delete);
    equal_delete = equal_delete.toSet().toList();
    equal_delete.sort();
    int temp=0;
    for (int i =0; i<equal_delete.length; i++)
    {
      points.removeAt(equal_delete[i]-temp);
      temp++;
    }

    for (int i=0; i<points.length; i++)
    {
      for (int j=0; j<points.length; j++)
      {
        //print(points[i]["part"]+'와'+points[j]["part"]+'를 비교');
        if (i == j) continue;

        else if ((points[i]['part'] == points[j]['part']))
        {
          if (points[i]['accuracy'] > points[j]['accuracy'])
          {
            //points.removeAt(j);
            //print(points[j]['part'] + points[i]['accuracy'].toString() + points[j]['accuracy'].toString());
            delete.add(j);
          }
          else if (points[i]['accuracy'] < points[j]['accuracy'])
          {
            //points.removeAt(i);
            //print(points[j]['part'] + points[i]['accuracy'].toString() + points[j]['accuracy'].toString());
            delete.add(i);
          }
        }
      }
    }
    delete = delete.toSet().toList();
//    print(delete);
    delete.sort();
//    print(delete);

    temp=0;
    for (int i =0; i<delete.length; i++)
    {
      points.removeAt(delete[i]-temp);
      temp++;
    }
    return points;
  }

  Widget pt(double x, double y, String part)
  {
    return Positioned(
      left: x,
      top: y,
      width: 100,
      height: 12,
      child: Text(
        "● ${part}",
        style: TextStyle(
          color: Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
              .withOpacity(1.0),
          fontSize: 8.0,
        ),
      ),
    );
  }

  Widget posePaint(double sx, double sy)
  {
    return CustomPaint(
      size: Size(sx, sy), // 위젯의 크기를 정함.
      painter: MyPainter(posenetPoint:posenetPoint), // painter에 그리기를 담당할 클래스를 넣음.
    );
  }

  Widget build(BuildContext context)
  {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];
    if (!(_image == null))
    {
      points = Keypoints(size);
      print(points);
      posenetPoint = Repoints();

      print(posenetPoint.length.toString());

      posenetPoint.forEach((element)
      {
        print(element);
      });
      print(_imageWidth.toString() + 'x' +_imageHeight.toString());

      stackChildren.add(backgr());

      for (int i=0; i<posenetPoint.length; i++)
        stackChildren.add(pt(posenetPoint[i]['left'],posenetPoint[i]['top'],posenetPoint[i]['part']));

      //stackChildren.addAll(makePoint(size));
      stackChildren.add(posePaint(_imageWidth, _imageHeight));

    }

    //(_image == null) ? Text('d') : Image.file(File(_img.path)),
    return Scaffold(
      appBar: AppBar(
        title: Text('test'),
        actions: <Widget> [
          IconButton(
            icon: Icon(Icons.person_outline),
            onPressed:() async {
             await _getImage();
            }
          )
        ]
      ),
      body:
        (_image == null && stackChildren.isEmpty) ? Text('No Image')
        : Stack(
          children: stackChildren,
        ),
    );
  }
}

class MyPainter extends CustomPainter {
  List posenetPoint ; // 선을 그리기 위한 좌표값을 만듬.
  MyPainter({Key key , @required this.posenetPoint});

  double ax=5;
  double ay=6;

  @override
  void paint(Canvas canvas, Size size)
  {
    Paint paint = Paint() // Paint 클래스는 어떤 식으로 화면을 그릴지 정할 때 쓰임.
      ..color = Colors.deepPurpleAccent // 색은 보라색
      ..strokeCap = StrokeCap.round // 선의 끝은 둥글게 함.
      ..strokeWidth = 2.5; // 선의 굵기


    for (int i=0; i<posenetPoint.length; i++)
    {
      switch (posenetPoint[i]['part'])
      {
        case 'leftShoulder':
        {
          for (int j=0; j<posenetPoint.length; j++)
          {
            if (posenetPoint[j]['part'] == 'rightShoulder')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
            else if (posenetPoint[j]['part'] == 'leftElbow')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
            else if (posenetPoint[j]['part'] == 'leftHip')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
          }
        }
        break;

        case 'rightShoulder':
        {
          for (int j=0; j<posenetPoint.length; j++)
          {
            if (posenetPoint[j]['part'] == 'leftShoulder')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
            else if (posenetPoint[j]['part'] == 'rightElbow')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
            else if (posenetPoint[j]['part'] == 'rightHip')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
          }
        }
        break;

        case 'leftElbow':
        {
          for (int j=0; j<posenetPoint.length; j++)
          {
            if (posenetPoint[j]['part'] == 'leftWrist')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
          }
        }
        break;

        case 'rightElbow':
        {
          for (int j=0; j<posenetPoint.length; j++)
          {
            if (posenetPoint[j]['part'] == 'rightWrist')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
          }
        }
        break;

        case 'leftHip':
        {
          for (int j=0; j<posenetPoint.length; j++)
          {
            if (posenetPoint[j]['part'] == 'rightHip')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
            else if (posenetPoint[j]['part'] == 'leftShoulder')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
            else if (posenetPoint[j]['part'] == 'leftKnee')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
          }
        }
        break;

        case 'rightHip':
        {
          for (int j=0; j<posenetPoint.length; j++)
          {
            if (posenetPoint[j]['part'] == 'leftHip')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
            else if (posenetPoint[j]['part'] == 'rightShoulder')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
            else if (posenetPoint[j]['part'] == 'rightKnee')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
          }
        }
        break;

        case 'leftKnee':
          {
            for (int j=0; j<posenetPoint.length; j++)
            {
              if (posenetPoint[j]['part'] == 'leftAnkle')
                canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                    Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
            }
          }
          break;

        case 'rightKnee':
        {
          for (int j=0; j<posenetPoint.length; j++)
          {
            if (posenetPoint[j]['part'] == 'rightAnkle')
              canvas.drawLine(Offset(posenetPoint[i]['left']+ax,posenetPoint[i]['top']+ay),
                  Offset(posenetPoint[j]['left']+ax,posenetPoint[j]['top']+ay), paint); // 선을 그림.
          }
        }
        break;

      }

    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }

}

