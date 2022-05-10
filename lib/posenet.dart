import 'dart:async';
import 'package:flutter/material.dart';
import 'package:posenet/paint/painter.dart';
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

  // Image를 받아오는 함수
  Future _getImage() async {
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

  // tflite Model Load
  void loadModel(PickedFile image) async
  {
    print('load model 진입');

    if (res == null) {
      res = await Tflite.loadModel(
        model: "assets/posenet_mv1_075_float_from_checkpoints.tflite",
        //labels: "assets/labels.txt"
      );
    }
    try {
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
    } catch(e) {
      print(e.message);
    }
  }

  // Background image
  Widget backgr() {
    return (_image == null) ? Text('d')
    : Image.file(File(_img.path));
  }

  // point의 list를 반환해주는 함수
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
        if (k["score"] >= 0.5) { // 정확도가 50% 이상이라면
          lists.add({'part':k["part"], 'left':k["x"] * factorX - 6, 'top':k["y"] * factorY - 6, 'accuracy':k["score"]});
        }
      }).toList();
    });

    return lists;
  }

  // 전처리 (같은 항목 제거)
  List Repoints()
  {
    bool changed=false;
    List delete = [];
    List equal_delete = [];
    int ct = 0;
    for (int i =0; i< points.length-2; i++) {
      for (int j=i+1; j<points.length;j++) {
        if (points[i]['part'] == points[j]['part'] && points[i]['accuracy'] == points[j]['accuracy'])
          equal_delete.add(j);
      }
    }

    equal_delete = equal_delete.toSet().toList();
    equal_delete.sort();
    int temp=0;
    for (int i =0; i<equal_delete.length; i++)
    {
      points.removeAt(equal_delete[i]-temp);
      temp++;
    }

    // 같은 포인트에 값이 2개 이상 있으면, 정확도가 높은 point만 살아남음
    for (int i=0; i<points.length; i++) {
      for (int j=0; j<points.length; j++) {
        if (i == j) continue;

        else if ((points[i]['part'] == points[j]['part'])) {
          if (points[i]['accuracy'] > points[j]['accuracy'])
            delete.add(j);
          else if (points[i]['accuracy'] < points[j]['accuracy'])
            delete.add(i);
        }
      }
    }

    delete = delete.toSet().toList();
    delete.sort();

    temp=0;
    for (int i =0; i<delete.length; i++)
    {
      points.removeAt(delete[i]-temp);
      temp++;
    }
    return points;
  }

  // point를 표시해주는 위젯
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

  // Stack을 위한 paint 위젯
  Widget posePaint(double sx, double sy)
  {
    return CustomPaint(
      size: Size(sx, sy), // 위젯의 크기를 정함.
      painter: Painter(posenetPoint:posenetPoint), // painter에 그리기를 담당할 클래스를 넣음.
    );
  }

  Widget build(BuildContext context)
  {
    Size size = MediaQuery.of(context).size;
    List<Widget> stackChildren = [];
    if (!(_image == null))
    {
      points = Keypoints(size);
      posenetPoint = Repoints();

      posenetPoint.forEach((element) {
        print(element);
      });
      print(_imageWidth.toString() + 'x' +_imageHeight.toString());

      // stack에 배경을 넣어줌
      stackChildren.add(backgr());

      // point(점)을 찍어줌
      for (int i=0; i<posenetPoint.length; i++)
        stackChildren.add(pt(posenetPoint[i]['left'],posenetPoint[i]['top'],posenetPoint[i]['part']));

      // 선을 그려줌
      stackChildren.add(posePaint(_imageWidth, _imageHeight));
    }

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