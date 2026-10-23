package com.example.fitbase

import android.content.Context
import android.net.Uri
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.OutputStream

object FileUtils {
    private const val TAG = "FileUtils"

    fun createOutputFile(
        context: Context,
        dirPath: String,
        fileName: String
    ): Pair<OutputStream, String>? {
        return try {
            if (dirPath.startsWith("content://")) {
                val uri = Uri.parse(dirPath)
                val outputStream = context.contentResolver.openOutputStream(uri)
                    ?: throw IllegalArgumentException("Cannot open output stream for: $uri")
                Pair(outputStream, uri.toString())
            } else {
                val dir = File(dirPath)
                dir.mkdirs()
                val file = File(dir, fileName)
                Pair(FileOutputStream(file), file.absolutePath)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error creating output file: $fileName in $dirPath", e)
            null
        }
    }

    fun createSubfolder(context: Context, parentDirPath: String, folderName: String): String? {
        return try {
            val parentDir = File(parentDirPath.removePrefix("file://"))
            val subfolder = File(parentDir, folderName)
            if (!subfolder.exists()) {
                subfolder.mkdirs()
            }
            subfolder.absolutePath
        } catch (e: Exception) {
            Log.e(TAG, "Error creating subfolder: $folderName in $parentDirPath", e)
            null
        }
    }

    fun setExecutable(filePath: String?): Boolean {
        return try {
            filePath?.let { path ->
                File(path.removePrefix("file://")).apply {
                    setExecutable(true, false)
                    setReadable(true, false)
                    setWritable(true, false)
                }
                true
            } ?: false
        } catch (e: Exception) {
            Log.e(TAG, "Error setting executable: $filePath", e)
            false
        }
    }
}

fun File.deleteSafely() {
    try {
        if (exists()) delete()
    } catch (e: Exception) {
        Log.e("FileUtils", "Delete failed: $absolutePath", e)
    }
}
