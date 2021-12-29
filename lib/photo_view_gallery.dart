import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PhotoViewPageGallery extends StatefulWidget {
  const PhotoViewPageGallery({Key? key}) : super(key: key);

  @override
  State<PhotoViewPageGallery> createState() => _PhotoViewPageGalleryState();
}

class _PhotoViewPageGalleryState extends State<PhotoViewPageGallery> {
  final imageList2 = [
    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8cmFuZG9tJTIwcGVvcGxlfGVufDB8fDB8fA%3D%3D&w=1000&q=80',
    'https://media.istockphoto.com/photos/young-woman-portrait-in-the-city-picture-id1009749608?k=20&m=1009749608&s=612x612&w=0&h=3bnVp0Y1625uKkSwnp7Uh2_y_prWbgRBH6a_6jRew3g=',
    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSjidvk3DPBtaN3SXhqTDVhzve_yJEhYIE9xQ&usqp=CAU',
    'https://thumbor.forbes.com/thumbor/fit-in/1200x0/filters%3Aformat%28jpg%29/https%3A%2F%2Fspecials-images.forbesimg.com%2Fimageserve%2F5f64397931669e167fc57eaf%2F0x0.jpg',
    'https://i.insider.com/5cb8b133b8342c1b45130629?width=700',
    'https://static.independent.co.uk/2020/10/30/08/newFile-2.jpg?width=640&auto=webp&quality=75'
  ];

  var imageList = [];

  ImagePicker? imagePicker;

  @override
  void initState() {
    super.initState();
    imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Photo View Gallery'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
                onPressed: () async {
                  var photos = await imagePicker!
                      .pickMultiImage(maxWidth: 1080, maxHeight: 1080);
                  for (var item in photos!) {
                    imageList.add(item.path);
                  }
                  setState(() {});
                },
                icon: const Icon(Icons.add_circle)),
          )
        ],
      ),
      body: imageList.isNotEmpty == true
          ? GridView.builder(
              itemCount: imageList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, childAspectRatio: 1),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return PhotoViewDetail(
                            currentIndex: index,
                            imageList: imageList,
                          );
                        }));
                      },
                      child: Image.file(
                        File(imageList[index]),
                        fit: BoxFit.cover,
                      )),
                );
              })
          : Container(),
    );
  }
}

class PhotoViewDetail extends StatefulWidget {
  int? currentIndex;
  List? imageList;

  PhotoViewDetail({Key? key, this.currentIndex, this.imageList})
      : super(key: key);

  @override
  _PhotoViewDetailState createState() => _PhotoViewDetailState();
}

class _PhotoViewDetailState extends State<PhotoViewDetail> {
  PhotoViewScaleStateController? photoViewScaleStateController;
  PageController? pageController;
  CarouselController? carouselController;

  @override
  void initState() {
    super.initState();
    photoViewScaleStateController = PhotoViewScaleStateController();
    carouselController = CarouselController();
    pageController = PageController(initialPage: widget.currentIndex!);
  }

  @override
  void dispose() {
    photoViewScaleStateController!.dispose();
    pageController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Photo Gallery'),
      ),
      body: Stack(
        children: [
          buildPhotoViewGallery(),
          buildPositioned(),
        ],
      ),
    );
  }

  Positioned buildPositioned() {
    return Positioned(
      bottom: 30,
      right: 0,
      left: 0,
      child: CarouselSlider.builder(
        carouselController: carouselController,
        itemCount: widget.imageList!.length,
        itemBuilder: (context, itemIndex, pageIndex) {
          return GestureDetector(
              onTap: () {
                pageController!.jumpToPage(itemIndex);
                carouselController!.jumpToPage(itemIndex);
              },
              child: Image.file(File(widget.imageList![itemIndex])));
        },
        options: CarouselOptions(
          autoPlay: false,
          autoPlayInterval: const Duration(seconds: 1),
          viewportFraction: 0.21,
          height: 100,
          enlargeCenterPage: true,
        ),
      ),
    );
  }

  Row buildRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widget.imageList!
          .map(
            (item) => Container(
              height: 10,
              width: 10,
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 3),
              decoration: BoxDecoration(
                  color: widget.currentIndex == widget.imageList!.indexOf(item)
                      ? Colors.white
                      : Colors.grey,
                  shape: BoxShape.circle),
            ),
          )
          .toList(),
    );
  }

  PhotoViewGallery buildPhotoViewGallery() {
    return PhotoViewGallery.builder(
      itemCount: widget.imageList!.length,
      builder: (context, index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: FileImage(
            File(widget.imageList![index]),
          ),
          minScale: PhotoViewComputedScale.contained * 0.6,
          maxScale: PhotoViewComputedScale.contained * 1.6,
          scaleStateController: photoViewScaleStateController,
        );
      },
      pageController: pageController,
      scrollDirection: Axis.horizontal,
      //scrollPhysics: NeverScrollableScrollPhysics(),
      enableRotation: false,
      onPageChanged: (index) {
        setState(() {
          photoViewScaleStateController!.reset();
          widget.currentIndex = index;
          carouselController!.jumpToPage(widget.currentIndex!);
        });
      },
    );
  }
}
