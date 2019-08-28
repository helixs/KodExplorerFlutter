package me.xmcf.kodproject.flutterchannel.download

import android.content.Context
import android.database.DatabaseErrorHandler
import android.database.sqlite.SQLiteDatabase
import android.database.sqlite.SQLiteOpenHelper
import vn.hunghd.flutterdownloader.TaskContract
import me.xmcf.kodproject.flutterchannel.download.TaskTableColumns

class TaskDbHelper(context: Context) : SQLiteOpenHelper(context, DATABASE_NAME, null, DATABASE_VERSION) {


    companion object{
        private const val  DATABASE_NAME = "download_task.db"
        private const val  DATABASE_VERSION = 1
        private var instance: TaskDbHelper? = null
        @Synchronized
        fun getInstance(context: Context):TaskDbHelper{
            if (instance == null){
                if (instance == null) {
                    instance = TaskDbHelper(context.applicationContext)
                }
            }
            return instance !!
        }
        private const val SQL_CREATE_ENTRIES = (
                "CREATE TABLE " + TaskTableColumns.TABLE_NAME + " (" +
                        TaskTableColumns._ID + " INTEGER PRIMARY KEY," +
                        TaskTableColumns.COLUMN_NAME_TASK_ID + " VARCHAR(256), " +
                        TaskTableColumns.COLUMN_NAME_URL + " TEXT, " +
                        TaskTableColumns.COLUMN_NAME_STATUS + " INTEGER DEFAULT 0, " +
                        TaskTableColumns.COLUMN_NAME_PROGRESS + " INTEGER DEFAULT 0, " +
                        TaskTableColumns.COLUMN_NAME_ALL_LENGTH + " INTEGER DEFAULT 0, " +
                        TaskTableColumns.COLUMN_NAME_CURRENT_LENGTH + " INTEGER DEFAULT 0, " +
                        TaskTableColumns.COLUMN_NAME_FILE_NAME + " TEXT, " +
                        TaskTableColumns.COLUMN_NAME_SAVED_DIR + " TEXT, " +
                        TaskTableColumns.COLUMN_NAME_HEADERS + " TEXT, " +
                        TaskTableColumns.COLUMN_NAME_MIME_TYPE + " VARCHAR(128), " +
                        TaskTableColumns.COLUMN_NAME_RESUMABLE + " TINYINT DEFAULT 0, " +
                        TaskTableColumns.COLUMN_NAME_SHOW_NOTIFICATION + " TINYINT DEFAULT 0, " +
                        TaskTableColumns.COLUMN_NAME_OPEN_FILE_FROM_NOTIFICATION + " TINYINT DEFAULT 0, " +
                        TaskTableColumns.COLUMN_NAME_TIME_CREATED + " INTEGER DEFAULT 0"
                        + ")")
    }


    override fun onCreate(db: SQLiteDatabase) {
        db.execSQL(SQL_CREATE_ENTRIES)
    }

    override fun onUpgrade(db: SQLiteDatabase?, oldVersion: Int, newVersion: Int) {
        //todo 执行数据迁移操作 暂无
    }

}