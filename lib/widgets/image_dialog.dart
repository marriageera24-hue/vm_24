// ignore_for_file: unnecessary_new

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- Global/Helper Definitions ---

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
      child: loadImage(imgUrl, isCached: isCachedImage),
    );
  }
}

final customCacheManager = CacheManager(Config('customCacheKey', stalePeriod: const Duration(hours: 2)));
RegExp regExp = new RegExp(r'(https://.*?.(png|jpg|jpeg))',
    caseSensitive: false, multiLine: false);

// --- MODIFIED loadImage FUNCTION ---

dynamic loadImage(String url, {isCached = true}) {
  // Define the common fallback avatar icon widget
  const Widget errorAvatar = Center(
    child: Icon(
      Icons.account_circle,
      size: 100, // Size to fit the CircleAvatar container
      color: Colors.blue,
    ),
  );

  final String? imageUrl = regExp.hasMatch(url) ? regExp.stringMatch(url) : null;

  // 1. Fallback to local asset if no valid URL is found
  if (imageUrl == null || imageUrl.isEmpty) {
    return Image.asset("assets/images/avatar.png", fit: BoxFit.cover);
  }

  // 2. Non-Cached Image (NetworkToFileImage)
  if (!isCached) {
    return Image(
      image: NetworkToFileImage(
        url: imageUrl,
        debug: true,
      ),
      fit: BoxFit.cover, 
      
      // ⭐ HANDLES 404/NETWORK ERROR by showing errorAvatar ⭐
      errorBuilder: (context, error, stackTrace) => errorAvatar,
      
      // Shows a spinner while loading
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  // 3. Cached Image (CachedNetworkImage)
  return CachedNetworkImage(
    cacheManager: customCacheManager,
    key: UniqueKey(),
    imageUrl: imageUrl,
    fit: BoxFit.cover,
    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
    
    // ⭐ HANDLES 404/NETWORK ERROR by showing errorAvatar ⭐
    errorWidget: (context, url, error) => errorAvatar,
  );
}