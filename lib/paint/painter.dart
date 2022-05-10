import 'package:flutter/material.dart';

class Painter extends CustomPainter {
  List posenetPoint ; // 선을 그리기 위한 좌표값을 만듬.
  Painter({Key key , @required this.posenetPoint});

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