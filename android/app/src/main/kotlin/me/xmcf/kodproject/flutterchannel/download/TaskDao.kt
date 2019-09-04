package me.xmcf.kodproject.flutterchannel.download

import android.content.ContentValues
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import java.util.ArrayList

class TaskDao {

    companion object {
        val QUERY_CLOUMS = arrayOf(
                TaskTableColumns._ID,
                TaskTableColumns.COLUMN_NAME_TASK_ID,
                TaskTableColumns.COLUMN_NAME_PROGRESS,
                TaskTableColumns.COLUMN_NAME_ALL_LENGTH,
                TaskTableColumns.COLUMN_NAME_CURRENT_LENGTH,
                TaskTableColumns.COLUMN_NAME_STATUS,
                TaskTableColumns.COLUMN_NAME_URL,
                TaskTableColumns.COLUMN_NAME_FILE_NAME,
                TaskTableColumns.COLUMN_NAME_SAVED_DIR,
                TaskTableColumns.COLUMN_NAME_HEADERS,
                TaskTableColumns.COLUMN_NAME_MIME_TYPE,
                TaskTableColumns.COLUMN_NAME_RESUMABLE,
                TaskTableColumns.COLUMN_NAME_OPEN_FILE_FROM_NOTIFICATION,
                TaskTableColumns.COLUMN_NAME_SHOW_NOTIFICATION,
                TaskTableColumns.COLUMN_NAME_TIME_CREATED)

        private fun parseCursor(cursor: Cursor): TaskInfoRes {
            val primaryId = cursor.getInt(cursor.getColumnIndexOrThrow(TaskTableColumns._ID))
            val taskId = cursor.getString(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_TASK_ID))
            val status = cursor.getInt(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_STATUS))
            val progress = cursor.getInt(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_PROGRESS))
            val allLength = cursor.getLong(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_ALL_LENGTH))
            val currentLength = cursor.getLong(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_CURRENT_LENGTH))
            val url = cursor.getString(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_URL))
            val filename = cursor.getString(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_FILE_NAME))
            val savedDir = cursor.getString(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_SAVED_DIR))
            val headers = cursor.getString(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_HEADERS))
            val mimeType = cursor.getString(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_MIME_TYPE))
            val resumable = cursor.getShort(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_RESUMABLE)).toInt()
            val showNotification = cursor.getShort(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_SHOW_NOTIFICATION)).toInt()
            val clickToOpenDownloadedFile = cursor.getShort(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_OPEN_FILE_FROM_NOTIFICATION)).toInt()
            val timeCreated = cursor.getLong(cursor.getColumnIndexOrThrow(TaskTableColumns.COLUMN_NAME_TIME_CREATED))
            return TaskInfoRes(primaryId, taskId, status, progress, url, filename, savedDir, headers,
                    mimeType, resumable == 1, showNotification == 1, clickToOpenDownloadedFile == 1, timeCreated, allLength = allLength, currentLength = currentLength)
        }

        fun insertOrUpdateNewTask(taskDbHelper: TaskDbHelper, taskId: String, url: String, status: Int, progress: Int, fileName: String,
                                  savedDir: String, headers: String?, showNotification: Boolean, openFileFromNotification: Boolean, allLength: Long = 0, currentLength: Long = 0) {
            val db = taskDbHelper.writableDatabase

            val values = ContentValues()
            values.put(TaskTableColumns.COLUMN_NAME_TASK_ID, taskId)
            values.put(TaskTableColumns.COLUMN_NAME_URL, url)
            values.put(TaskTableColumns.COLUMN_NAME_STATUS, status)
            values.put(TaskTableColumns.COLUMN_NAME_PROGRESS, progress)
            values.put(TaskTableColumns.COLUMN_NAME_FILE_NAME, fileName)
            values.put(TaskTableColumns.COLUMN_NAME_SAVED_DIR, savedDir)
            values.put(TaskTableColumns.COLUMN_NAME_ALL_LENGTH, allLength)
            values.put(TaskTableColumns.COLUMN_NAME_CURRENT_LENGTH, currentLength)
            values.put(TaskTableColumns.COLUMN_NAME_HEADERS, headers)
            values.put(TaskTableColumns.COLUMN_NAME_MIME_TYPE, headers ?: "unknown")
            values.put(TaskTableColumns.COLUMN_NAME_SHOW_NOTIFICATION, if (showNotification) 1 else 0)
            values.put(TaskTableColumns.COLUMN_NAME_OPEN_FILE_FROM_NOTIFICATION, if (openFileFromNotification) 1 else 0)
            values.put(TaskTableColumns.COLUMN_NAME_RESUMABLE, 0)
            values.put(TaskTableColumns.COLUMN_NAME_TIME_CREATED, System.currentTimeMillis())

            db.beginTransaction()
            try {
                db.insertWithOnConflict(TaskTableColumns.TABLE_NAME, null, values, SQLiteDatabase.CONFLICT_REPLACE)
                db.setTransactionSuccessful()
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                db.endTransaction()
            }
        }

        fun queryAllTasks(taskDbHelper: TaskDbHelper): List<TaskInfoRes> {
            val db = taskDbHelper.readableDatabase

            val cursor = db.query(
                    TaskTableColumns.TABLE_NAME,
                    QUERY_CLOUMS,
                    null, null, null, null, TaskTableColumns._ID + " DESC"
            )

            val result = ArrayList<TaskInfoRes>()
            while (cursor.moveToNext()) {
                result.add(parseCursor(cursor))
            }
            cursor.close()

            return result
        }

        fun queryTask(taskDbHelper: TaskDbHelper, taskId: String): TaskInfoRes? {
            val db = taskDbHelper.readableDatabase

            val whereClause = TaskTableColumns.COLUMN_NAME_TASK_ID + " = ?"
            val whereArgs = arrayOf(taskId)

            val cursor = db.query(
                    TaskTableColumns.TABLE_NAME,
                    QUERY_CLOUMS,
                    whereClause,
                    whereArgs,
                    null, null,
                    TaskTableColumns._ID + " DESC",
                    "1"
            )

            var result: TaskInfoRes? = null
            while (cursor.moveToNext()) {
                result = parseCursor(cursor)
            }
            cursor.close()
            return result
        }

        fun queryAllTaskOfStatus(taskDbHelper: TaskDbHelper, status: Int): List<TaskInfoRes> {
            val db = taskDbHelper.readableDatabase

            val whereClause = TaskTableColumns.COLUMN_NAME_STATUS + " = ?"
            val whereArgs = arrayOf(status.toString())

            val cursor = db.query(
                    TaskTableColumns.TABLE_NAME,
                    QUERY_CLOUMS,
                    whereClause,
                    whereArgs,
                    null, null,
                    TaskTableColumns._ID + " DESC",
                    null
            )

            val result = arrayListOf<TaskInfoRes>()
            while (cursor.moveToNext()) {
                result.add(parseCursor(cursor))
            }
            cursor.close()
            return result
        }

        fun loadTasksWithRawQuery(taskDbHelper: TaskDbHelper, query: String): List<TaskInfoRes> {
            val db = taskDbHelper.readableDatabase
            val cursor = db.rawQuery(query, null)

            val result = ArrayList<TaskInfoRes>()
            while (cursor.moveToNext()) {
                result.add(parseCursor(cursor))
            }
            cursor.close()

            return result
        }

        fun updateTask(taskDbHelper: TaskDbHelper, taskId: String, status: Int, progress: Int, allLength: Long? = null, currentLength: Long? = null) {
            val db = taskDbHelper.writableDatabase
            val values = ContentValues()
            values.put(TaskTableColumns.COLUMN_NAME_STATUS, status)
            values.put(TaskTableColumns.COLUMN_NAME_PROGRESS, progress)
            if (allLength != null) {
                values.put(TaskTableColumns.COLUMN_NAME_ALL_LENGTH, allLength)

            }
            if (currentLength != null) {
                values.put(TaskTableColumns.COLUMN_NAME_CURRENT_LENGTH, currentLength)
            }

            db.beginTransaction()
            try {
                db.update(TaskTableColumns.TABLE_NAME, values, TaskTableColumns.COLUMN_NAME_TASK_ID + " = ?", arrayOf(taskId))
                db.setTransactionSuccessful()
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                db.endTransaction()
            }
        }

        fun updateTask(taskDbHelper: TaskDbHelper, currentTaskId: String, newTaskId: String, status: Int, progress: Int, resumable: Boolean, allLength: Long? = null, currentLength: Long? = null) {
            val db = taskDbHelper.writableDatabase

            val values = ContentValues()
            values.put(TaskTableColumns.COLUMN_NAME_TASK_ID, newTaskId)
            values.put(TaskTableColumns.COLUMN_NAME_STATUS, status)
            values.put(TaskTableColumns.COLUMN_NAME_PROGRESS, progress)
            values.put(TaskTableColumns.COLUMN_NAME_RESUMABLE, if (resumable) 1 else 0)
            values.put(TaskTableColumns.COLUMN_NAME_TIME_CREATED, System.currentTimeMillis())
            if (allLength != null) {
                values.put(TaskTableColumns.COLUMN_NAME_ALL_LENGTH, allLength)

            }
            if (currentLength != null) {
                values.put(TaskTableColumns.COLUMN_NAME_CURRENT_LENGTH, currentLength)
            }
            db.beginTransaction()
            try {
                db.update(TaskTableColumns.TABLE_NAME, values, TaskTableColumns.COLUMN_NAME_TASK_ID + " = ?", arrayOf(currentTaskId))
                db.setTransactionSuccessful()
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                db.endTransaction()
            }
        }

        fun updateTask(taskDbHelper: TaskDbHelper, taskId: String, resumable: Boolean, allLength: Long? = null, currentLength: Long? = null) {
            val db = taskDbHelper.writableDatabase

            val values = ContentValues()
            values.put(TaskTableColumns.COLUMN_NAME_RESUMABLE, if (resumable) 1 else 0)
            if (allLength != null) {
                values.put(TaskTableColumns.COLUMN_NAME_ALL_LENGTH, allLength)

            }
            if (currentLength != null) {
                values.put(TaskTableColumns.COLUMN_NAME_CURRENT_LENGTH, currentLength)
            }
            db.beginTransaction()
            try {
                db.update(TaskTableColumns.TABLE_NAME, values, TaskTableColumns.COLUMN_NAME_TASK_ID + " = ?", arrayOf(taskId))
                db.setTransactionSuccessful()
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                db.endTransaction()
            }
        }

        fun updateTask(taskDbHelper: TaskDbHelper, taskId: String, filename: String, mimeType: String, allLength: Long? = null, currentLength: Long? = null) {
            val db = taskDbHelper.writableDatabase

            val values = ContentValues()
            values.put(TaskTableColumns.COLUMN_NAME_FILE_NAME, filename)
            values.put(TaskTableColumns.COLUMN_NAME_MIME_TYPE, mimeType)
            if (allLength != null) {
                values.put(TaskTableColumns.COLUMN_NAME_ALL_LENGTH, allLength)
            }
            if (currentLength != null) {
                values.put(TaskTableColumns.COLUMN_NAME_CURRENT_LENGTH, currentLength)
            }
            db.beginTransaction()
            try {
                db.update(TaskTableColumns.TABLE_NAME, values, TaskTableColumns.COLUMN_NAME_TASK_ID + " = ?", arrayOf(taskId))
                db.setTransactionSuccessful()
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                db.endTransaction()
            }
        }

        fun deleteTask(taskDbHelper: TaskDbHelper, taskId: String) {
            val db = taskDbHelper.writableDatabase

            db.beginTransaction()
            try {
                val whereClause = TaskTableColumns.COLUMN_NAME_TASK_ID + " = ?"
                val whereArgs = arrayOf(taskId)
                db.delete(TaskTableColumns.TABLE_NAME, whereClause, whereArgs)
                db.setTransactionSuccessful()
            } catch (e: Exception) {
                e.printStackTrace()
            } finally {
                db.endTransaction()
            }
        }

    }


}