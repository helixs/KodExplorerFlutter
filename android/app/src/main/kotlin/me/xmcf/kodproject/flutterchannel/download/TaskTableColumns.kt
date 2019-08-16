package me.xmcf.kodproject.flutterchannel.download

import android.provider.BaseColumns

interface TaskTableColumns:BaseColumns{
    companion object{
       const val _ID = BaseColumns._ID
       const val _COUNT = BaseColumns._COUNT
       const val TABLE_NAME = "tasks"
       const val COLUMN_NAME_TASK_ID = "task_id"
       const val COLUMN_NAME_STATUS = "status"
       const val COLUMN_NAME_PROGRESS = "progress"
       const val COLUMN_NAME_URL = "url"
       const val COLUMN_NAME_SAVED_DIR = "saved_dir"
       const val COLUMN_NAME_FILE_NAME = "file_name"
       const val COLUMN_NAME_MIME_TYPE = "mime_type"
       const val COLUMN_NAME_RESUMABLE = "resumable"
       const val COLUMN_NAME_HEADERS = "headers"
       const val COLUMN_NAME_SHOW_NOTIFICATION = "show_notification"
       const val COLUMN_NAME_OPEN_FILE_FROM_NOTIFICATION = "open_file_from_notification"
       const val COLUMN_NAME_TIME_CREATED = "time_created"

    }
}