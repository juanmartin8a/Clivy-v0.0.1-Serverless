
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class CustomCacheManager {
  static const key = 'customCacheKey';
  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 1),
      maxNrOfCacheObjects: 5000,
      repo: JsonCacheInfoRepository(databaseName: key),
      //fileSystem: IOFileSystem(key),
      fileService: HttpFileService(),
    ),
  );
}