import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

List<String> imgList() {
  List<String> imagesUrl = [];
  for (int i = 1; i <= 3; i++) {
    imagesUrl.add('assets/images/loginScreen/carousel' + i.toString() + '.png');
  }
  return imagesUrl;
}

Future<List<dynamic>> loadJson() async {
  String data = await rootBundle.loadString('assets/json/landing.json');
  final jsonResult = json.decode(data);
  return jsonResult;
}

final List<Widget> imageSliders = imgList()
    .map((item) => FutureBuilder<List<dynamic>>(
        future: loadJson(),
        builder: (BuildContext context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.hasData) {
            return Container(
              padding: EdgeInsets.symmetric(vertical: 0.0, horizontal: 40.0),
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 20.0, bottom: 40),
                    child: Text(
                      '${snapshot.data[imgList().indexOf(item)]}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                      child: new Image(
                    image: AssetImage(item),
                    fit: BoxFit.fitWidth,
                    alignment: Alignment.topCenter,
                  )),
                ],
              ),
            );
          } else {
            return Text("loading");
          }
        }))
    .toList();

class CarouselWithIndicatorDemo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CarouselWithIndicatorState();
  }
}

class CarouselWithIndicatorState extends State<CarouselWithIndicatorDemo> {
  List<dynamic> textList;
  List<Image> imagesList;
  int current;
  CarouselController buttonCarouselController = CarouselController();

  // void loadAssets() {
  //   List<Image> images = [];
  //   for (int i = 1; i <= 3; i++) {
  //     images.add(new Image(
  //         image: AssetImage(
  //             'assets/images/loginScreen/carousel' + i.toString() + '.png')));
  //   }
  //   imagesList = (images);
  // }

  @override
  void initState() {
    super.initState();
    current = 0;
    new Future(() => loadJson()).then((returnedData) => {
          setState(() {
            textList = returnedData;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    if (textList == null) {
      return new Text("Loading...");
    } else {
      return Column(children: [
        CarouselSlider(
          items: imageSliders,
          carouselController: buttonCarouselController,
          options: CarouselOptions(
              height: 420.0,
              viewportFraction: 1.0,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  current = index;
                });
              }),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [0, 1, 2].map((url) {
              return AnimatedContainer(
                width: current == url ? 25.0 : 15.0,
                height: 4.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    shape: BoxShape.rectangle,
                    color: current == url
                        ? Colors.orange
                        : Color.fromRGBO(0, 0, 0, 0.4)),
                duration: Duration(milliseconds: 375),
                curve: Curves.fastOutSlowIn,
              );
            }).toList())
      ]);
    }
  }
}
