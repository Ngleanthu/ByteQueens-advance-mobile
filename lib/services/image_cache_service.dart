import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

/// Service for caching uploaded/captured images locally
/// Images are stored in app's documents directory and referenced in SharedPreferences
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  static const String _cacheMetadataKey = 'image_cache_metadata';

  /// Cache an image file and return the cached path
  /// [originalPath] - Path to the original image file or URL for web
  /// [messageId] - Unique message ID to associate with the image
  /// Returns the cached file path or URL
  Future<String?> cacheImage(String originalPath, String messageId) async {
    try {
      // On web, just return the blob URL as-is
      // Web doesn't need file system caching
      if (kIsWeb) {
        await _saveImageMetadata(messageId, originalPath);
        print('✅ Image cached (web): $originalPath');
        return originalPath;
      }

      final file = File(originalPath);
      if (!await file.exists()) {
        print('❌ Image file does not exist: $originalPath');
        return null;
      }

      // Get app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/chat_images');

      // Create cache directory if it doesn't exist
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      // Generate unique filename based on message ID
      final extension = path.extension(originalPath);
      final cachedFileName = '$messageId$extension';
      final cachedPath = '${cacheDir.path}/$cachedFileName';

      // Copy file to cache directory
      await file.copy(cachedPath);

      // Save metadata in SharedPreferences
      await _saveImageMetadata(messageId, cachedPath);

      print('✅ Image cached: $cachedPath');
      return cachedPath;
    } catch (e) {
      print('❌ Error caching image: $e');
      return null;
    }
  }

  /// Get cached image path by message ID
  Future<String?> getCachedImagePath(String messageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = prefs.getString(_cacheMetadataKey);

      if (metadata == null) return null;

      // Parse metadata (simple JSON format)
      final Map<String, String> cache = {};
      final entries = metadata.split('|');
      for (final entry in entries) {
        if (entry.isEmpty) continue;
        final parts = entry.split(':');
        if (parts.length == 2) {
          cache[parts[0]] = parts[1];
        }
      }

      final cachedPath = cache[messageId];
      if (cachedPath != null) {
        // On web, just return the URL
        if (kIsWeb) {
          return cachedPath;
        }

        // Verify file still exists on mobile
        final file = File(cachedPath);
        if (await file.exists()) {
          return cachedPath;
        } else {
          // Clean up metadata if file is gone
          await _removeImageMetadata(messageId);
        }
      }

      return null;
    } catch (e) {
      print('❌ Error getting cached image: $e');
      return null;
    }
  }

  /// Save image metadata
  Future<void> _saveImageMetadata(String messageId, String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = prefs.getString(_cacheMetadataKey) ?? '';

      // Add new entry
      final newEntry = '$messageId:$path';
      final updatedMetadata = metadata.isEmpty
          ? newEntry
          : '$metadata|$newEntry';

      await prefs.setString(_cacheMetadataKey, updatedMetadata);
    } catch (e) {
      print('❌ Error saving image metadata: $e');
    }
  }

  /// Remove image metadata
  Future<void> _removeImageMetadata(String messageId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadata = prefs.getString(_cacheMetadataKey);

      if (metadata == null) return;

      // Remove entry for this message ID
      final entries = metadata.split('|');
      final filtered = entries
          .where((entry) => !entry.startsWith('$messageId:'))
          .join('|');

      await prefs.setString(_cacheMetadataKey, filtered);
    } catch (e) {
      print('❌ Error removing image metadata: $e');
    }
  }

  /// Clear all cached images older than specified days
  Future<void> clearOldImages({int daysOld = 7}) async {
    // Skip on web - no file system
    if (kIsWeb) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/chat_images');

      if (!await cacheDir.exists()) return;

      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      int deletedCount = 0;

      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          if (stat.modified.isBefore(cutoffDate)) {
            await entity.delete();
            deletedCount++;
          }
        }
      }

      print('🗑️ Cleared $deletedCount old cached images');
    } catch (e) {
      print('❌ Error clearing old images: $e');
    }
  }

  /// Clear all cached images
  Future<void> clearAllImages() async {
    // Skip on web - no file system
    if (kIsWeb) {
      // Clear metadata only
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_cacheMetadataKey);
        print('🗑️ Cleared all cached images metadata (web)');
      } catch (e) {
        print('❌ Error clearing metadata: $e');
      }
      return;
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/chat_images');

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheMetadataKey);

      print('🗑️ All cached images cleared');
    } catch (e) {
      print('❌ Error clearing all images: $e');
    }
  }

  /// Get total size of cached images
  Future<int> getCacheSize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/chat_images');

      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          final stat = await entity.stat();
          totalSize += stat.size;
        }
      }

      return totalSize;
    } catch (e) {
      print('❌ Error calculating cache size: $e');
      return 0;
    }
  }
}
