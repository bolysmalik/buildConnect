package com.example.showroom

import android.content.Context
import com.valhalla.valhalla.files.ValhallaFile
import com.valhalla.valhalla.files.copyAssetFileToStorage
import com.valhalla.valhalla.files.loadAssetFile

class TestFileUtils {
    companion object {
        fun getConfigPath(context: Context): String {
            ValhallaFile.copyAssetFileToStorage(context, "valhalla_tiles/valhalla_tiles.tar")
            return ValhallaFile.copyAssetFileToStorage(context, "valhalla_tiles/config.json")
        }
        fun getTarPath(context: Context): String {
            // Копирует файл из assets в internal storage и возвращает путь
            return ValhallaFile.copyAssetFileToStorage(context, "valhalla_tiles/valhalla_tiles.tar")
        }

        fun getExpectedResponse(context: Context): String {
            return ValhallaFile.loadAssetFile(context, "valhalla_tiles/expected.json")
        }
    }
}
