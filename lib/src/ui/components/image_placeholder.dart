import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  ImagePlaceholder(
    this.url, {
    this.width,
    this.height,
  });

  final String url;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          color: Colors.grey.shade100,
        ),
        width: width,
        height: height,
        child: CachedNetworkImage(
          width: double.infinity,
          height: double.infinity,
          imageUrl: url ?? 'https://via.placeholder.com/150',
          placeholder: (context, url) {
            return Center(child: CircularProgressIndicator(),);
          },
          fit: BoxFit.cover,
        ));
  }
}
