package com.example.fitbase

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.util.Log
import java.io.File
import java.io.FileOutputStream

object ImageProcessor {
    private const val TAG = "ImageProcessor"

    fun loadBitmapFromPathSafe(
        context: Context,
        path: String,
        reqWidth: Int = 2048,
        reqHeight: Int = 2048
    ): Bitmap? {
        return try {
            val isContent = path.startsWith("content://")
            val cleanPath = path.removePrefix("file://")

            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
                if (isContent) {
                    context.contentResolver.openInputStream(Uri.parse(path))?.use {
                        BitmapFactory.decodeStream(it, null, this)
                    }
                } else {
                    BitmapFactory.decodeFile(cleanPath, this)
                }
                inJustDecodeBounds = false
                inSampleSize = calculateInSampleSize(this, reqWidth, reqHeight)
                inPreferredConfig = Bitmap.Config.ARGB_8888
            }

            if (isContent) {
                context.contentResolver.openInputStream(Uri.parse(path))?.use {
                    BitmapFactory.decodeStream(it, null, options)
                }
            } else {
                BitmapFactory.decodeFile(cleanPath, options)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Safe load failed: $path", e)
            null
        }
    }

    fun calculateInSampleSize(options: BitmapFactory.Options, reqWidth: Int, reqHeight: Int): Int {
        val height = options.outHeight
        val width = options.outWidth
        var inSampleSize = 1

        if (height > reqHeight || width > reqWidth) {
            val halfHeight = height / 2
            val halfWidth = width / 2

            while (halfHeight / inSampleSize >= reqHeight && halfWidth / inSampleSize >= reqWidth) {
                inSampleSize *= 2
            }
        }
        return inSampleSize
    }

    fun optimizeImage(
        context: Context,
        imagePath: String,
        quality: Int = 80,
        maxWidth: Int = 1920,
        maxHeight: Int = 2560
    ): String? {
        return try {
            val originalBitmap = loadBitmapFromPathSafe(context, imagePath, maxWidth, maxHeight)
                ?: return null

            if (originalBitmap.width <= 0 || originalBitmap.height <= 0) {
                originalBitmap.recycle()
                return null
            }

            val scaledBitmap = if (originalBitmap.width > maxWidth || originalBitmap.height > maxHeight) {
                val scale = minOf(
                    maxWidth.toFloat() / originalBitmap.width,
                    maxHeight.toFloat() / originalBitmap.height
                )
                Bitmap.createScaledBitmap(
                    originalBitmap,
                    (originalBitmap.width * scale).toInt(),
                    (originalBitmap.height * scale).toInt(),
                    true
                )
            } else {
                originalBitmap
            }

            val isContent = imagePath.startsWith("content://")
            val cleanPath = imagePath.removePrefix("file://")

            val targetFile: File = if (isContent) {
                val fileName = UriHelper.getFileNameFromPath(context, imagePath)
                val name = if (fileName.isNotBlank() && fileName != "unknown_file") fileName else "optimized_${System.currentTimeMillis()}.jpg"
                File(context.cacheDir, name)
            } else {
                File(cleanPath)
            }

            targetFile.parentFile?.mkdirs()

            val tempFile = File(
                targetFile.parentFile ?: context.cacheDir,
                "temp_opt_${System.currentTimeMillis()}_${targetFile.name}"
            )

            val isPng = targetFile.extension.equals("png", ignoreCase = true)
            val compressFormat = if (isPng) Bitmap.CompressFormat.PNG else Bitmap.CompressFormat.JPEG

            FileOutputStream(tempFile).use { out ->
                scaledBitmap.compress(compressFormat, quality.coerceIn(1, 100), out)
                out.flush()
            }

            if (scaledBitmap != originalBitmap) {
                scaledBitmap.recycle()
            }
            originalBitmap.recycle()

            if (tempFile.exists() && tempFile.length() > 0) {
                if (targetFile.exists()) {
                    targetFile.delete()
                }
                val renamed = tempFile.renameTo(targetFile)
                if (!renamed) {
                    tempFile.copyTo(targetFile, overwrite = true)
                    tempFile.deleteSafely()
                }
                Log.d(TAG, "Image optimized and saved at: ${targetFile.absolutePath}")
                targetFile.absolutePath
            } else {
                tempFile.deleteSafely()
                null
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error optimizing image: $imagePath", e)
            null
        }
    }

    fun saveImageToGallery(context: Context, imagePath: String, title: String): Boolean {
        return try {
            val file = File(imagePath.removePrefix("file://"))
            if (!file.exists()) return false

            val cleanTitle = title.replace(Regex("[^a-zA-Z0-9_.-]"), "_")
            val fileName = "Fitbase_${cleanTitle}_${System.currentTimeMillis()}.jpg"

            val values = android.content.ContentValues().apply {
                put(android.provider.MediaStore.Images.Media.DISPLAY_NAME, fileName)
                put(android.provider.MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                    put(android.provider.MediaStore.Images.Media.RELATIVE_PATH, android.os.Environment.DIRECTORY_PICTURES + "/Fitbase")
                    put(android.provider.MediaStore.Images.Media.IS_PENDING, 1)
                }
            }

            val uri = context.contentResolver.insert(android.provider.MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
                ?: return false

            context.contentResolver.openOutputStream(uri)?.use { out ->
                file.inputStream().use { inp ->
                    inp.copyTo(out)
                }
            }

            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.Q) {
                values.clear()
                values.put(android.provider.MediaStore.Images.Media.IS_PENDING, 0)
                context.contentResolver.update(uri, values, null, null)
            } else {
                android.media.MediaScannerConnection.scanFile(context, arrayOf(file.absolutePath), arrayOf("image/jpeg"), null)
            }
            true
        } catch (e: Exception) {
            Log.e(TAG, "Error saving image to gallery: $imagePath", e)
            false
        }
    }
}
