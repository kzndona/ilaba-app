/// GCash Receipt Service
/// Handles image upload to Supabase storage bucket

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

class GCashReceiptService {
  final SupabaseClient supabase;
  static const String BUCKET_NAME = 'gcash-receipts';
  static const String STORAGE_URL =
      'https://nkcfolnwxxnsskaerkyq.supabase.co/storage/v1/object/public/gcash-receipts';

  GCashReceiptService({required this.supabase});

  /// Convert image to JPG format
  Future<File> _convertToJpg(File imageFile) async {
    try {
      debugPrint('🖼️ GCashReceiptService: Converting image to JPG...');
      
      // Read the original image
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Failed to decode image');
      }
      
      // Encode as JPG with 85% quality
      final jpgBytes = img.encodeJpg(image, quality: 85);
      
      // Write to temporary file
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/gcash_receipt_$timestamp.jpg');
      await tempFile.writeAsBytes(jpgBytes);
      
      debugPrint('✅ GCashReceiptService: Image converted to JPG successfully');
      return tempFile;
    } catch (e) {
      debugPrint('⚠️ GCashReceiptService: Error converting to JPG: $e');
      // Return original file if conversion fails
      return imageFile;
    }
  }

  /// Upload receipt image to Supabase bucket
  /// Returns the full public URL of the uploaded file
  Future<String> uploadReceipt(File imageFile) async {
    try {
      debugPrint(
        '📸 GCashReceiptService: Uploading receipt from ${imageFile.path}',
      );

      if (!imageFile.existsSync()) {
        throw Exception('File does not exist: ${imageFile.path}');
      }

      // Convert image to JPG before uploading
      final jpgFile = await _convertToJpg(imageFile);

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName =
          '${DateTime.now().microsecondsSinceEpoch}-$timestamp.jpg';

      // Upload to Supabase storage
      await supabase.storage
          .from(BUCKET_NAME)
          .upload(
            fileName,
            jpgFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Construct public URL
      final publicUrl = '$STORAGE_URL/$fileName';

      debugPrint('✅ GCashReceiptService: Receipt uploaded successfully');
      debugPrint('   URL: $publicUrl');

      // Clean up temp file if it's different from original
      if (jpgFile.path != imageFile.path) {
        try {
          await jpgFile.delete();
        } catch (e) {
          debugPrint('⚠️ GCashReceiptService: Failed to delete temp file: $e');
        }
      }

      return publicUrl;
    } catch (e) {
      debugPrint('❌ GCashReceiptService: Error uploading receipt: $e');
      rethrow;
    }
  }

  /// Delete a receipt from storage
  Future<void> deleteReceipt(String publicUrl) async {
    try {
      // Extract filename from URL
      // URL format: https://...bucket/filename
      final fileName = publicUrl.split('/').last;

      debugPrint('🗑️ GCashReceiptService: Deleting receipt: $fileName');

      await supabase.storage.from(BUCKET_NAME).remove([fileName]);

      debugPrint('✅ GCashReceiptService: Receipt deleted successfully');
    } catch (e) {
      debugPrint('⚠️ GCashReceiptService: Error deleting receipt: $e');
      // Don't rethrow - deletion failure shouldn't block other operations
    }
  }
}
