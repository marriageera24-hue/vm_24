// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageDialog extends StatelessWidget {
  final imgUrl;
  bool isCachedImage = false;
  ImageDialog({super.key, this.imgUrl, required this.isCachedImage});
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(),
            borderRadius: BorderRadius.circular(20)),
        child: loadImage(imgUrl, isCached: isCachedImage));
  }
}

final customCacheManager = CacheManager(Config('customCacheKey', stalePeriod: const Duration(hours: 2)));
RegExp regExp = new RegExp(r'(https://.*?.(png|jpg|jpeg))',
    caseSensitive: false, multiLine: false);

dynamic loadImage(String url, {isCached = true}) {
  if (!isCached) {
    return (regExp.hasMatch(url))
        ? Image(
            image: NetworkToFileImage(
            url: regExp.stringMatch(url.toString()),
            debug: true,
          ))
        : Image.asset("assets/images/avatar.png");
  }
  return (regExp.hasMatch(url))
      ? CachedNetworkImage(
          cacheManager: customCacheManager,
          key: UniqueKey(),
          placeholder: (context, url) => const CircularProgressIndicator(),
          imageUrl: regExp.stringMatch((url)).toString(),
        )
      : Image.asset("assets/images/avatar.png");
}
