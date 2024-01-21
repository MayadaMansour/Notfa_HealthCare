import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/utils/images.dart';



class SliderPannar extends StatelessWidget {
  final List<String> imgList = [
    'images/filesFormat/cover.jpg'

  ];
  CarouselController buttonCarouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      carouselController: buttonCarouselController,
      items: imgList
          .map((e) => Stack(children: [
                Stack(
                  children: [
                    InkWell(
                      onTap: () {},
                      child: Container(
                        width: double.infinity,
                        decoration: ShapeDecoration(
                          image: DecorationImage(
                              image: AssetImage(icPannar),
                              fit: BoxFit.fill,
                              alignment: Alignment.centerLeft),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),

                          ),
                        ),
                      ),
                    ),
                  ],
                ),


              ]))
          .toList(),
      options: CarouselOptions(
        height: 200,
        initialPage: 0,
        viewportFraction: 1.0,
        enableInfiniteScroll: true,
        reverse: false,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 5),
        autoPlayAnimationDuration: Duration(seconds: 1),
        autoPlayCurve: Curves.fastOutSlowIn,
        scrollDirection: Axis.horizontal,
        aspectRatio: 16 / 9,
        enlargeCenterPage: true,
        enlargeFactor: 0.3,
      ),
    );
  }
}
