package me.xmcf.kodproject.flutterchannel.download

import android.content.ContentValues
import android.database.Cursor
import android.database.sqlite.SQLiteDatabase
import java.util.ArrayList

class TaskDao{

    companion object {
        val QUERY_CLOUMS = arrayOf(
                TaskTableColumns._ID,
                TaskTableColumns.COLUMN_NAME_TASK_ID,
                TaskTableColumns.COLUMN_NAME_PROGRESS,
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
                    mimeType, resumable == 1, showNotification == 1, clickToOpenDownloadedFile == 1, timeCreated)
        }
        fun insertOrUpdateNewTask(taskDbHelper:TaskDbHelper,taskId: String, url: String, status: Int, progress: Int, fileName: String,
                                  savedDir: String, headers: String?, showNotification: Boolean, openFileFromNotification: Boolean) {
            val db = taskDbHelper.writableDatabase

            val values = ContentValues()
            values.put(TaskTableColumns.COLUMN_NAME_TASK_ID, taskId)
            values.put(TaskTableColumns.COLUMN_NAME_URL, url)
            values.put(TaskTableColumns.COLUMN_NAME_STATUS, status)
            values.put(TaskTableColumns.COLUMN_NAME_PROGRESS, progress)
            values.put(TaskTableColumns.COLUMN_NAME_FILE_NAME, fileName)
            values.put(TaskTableColumns.COLUMN_NAME_SAVED_DIR, savedDir)
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

        fun queryAllTasks(taskDbHelper:TaskDbHelper): List<TaskInfoRes> {
            val db = taskDbHelper.readableDatabase

            val cursor = db.query(
                    TaskTableColumns.TABLE_NAME,
                    QUERY_CLOUMS,
                    null, null, null, null, null
            )

            val result = ArrayList<TaskInfoRes>()
            while (cursor.moveToNext()) {
                result.add(parseCursor(cursor))
            }
            cursor.close()

            return result
        }

        fun updateTask(taskDbHelper:TaskDbHelper,taskId: String, status: Int, progress: Int) {
            val db = taskDbHelper.writableDatabase
            val values = ContentValues()
            values.put(TaskTableColumns.COLUMN_NAME_STATUS, status)
            values.put(TaskTableColumns.COLUMN_NAME_PROGRESS, progress)

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

        fun updateTask(taskDbHelper:TaskDbHelper,currentTaskId: String, newTaskId: String, status: Int, progress: Int, resumable: Boolean) {
            val db = taskDbHelper.writableDatabase

            val values = ContentValues()
            values.put(TaskTableColumns.COLUMN_NAME_TASK_ID, newTaskId)
            values.put(TaskTableColumns.COLUMN_NAME_STATUS, status)
            values.put(TaskTableColumns.COLUMN_NAME_PROGRESS, progress)
            values.put(TaskTableColumns.COLUMN_NAME_RESUMABLE, if (resumable) 1 else 0)
            values.put(TaskTableColumns.COLUMN_NAME_TIME_CREATED, System.currentTimeMillis())

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

        fun updateTask(taskDbHelper:TaskDbHelper,taskId: String, resumable: Boolean) {
            val db = taskDbHelper.writableDatabase

            val values = ContentValues()
            values.put(TaskTableColumns.COLUMN_NAME_RESUMABLE, if (resumable) 1 else 0)

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

        fun updateTask(taskDbHelper:TaskDbHelper,taskId: String, filename: String, mimeType: String) {
            val db = taskDbHelper.writableDatabase

            val values = ContentValues()
            values.put(TaskTableColumns.COLUMN_NAME_FILE_NAME, filename)
            values.put(TaskTableColumns.COLUMN_NAME_MIME_TYPE, mimeType)

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
        fun deleteTask(taskDbHelper:TaskDbHelper,taskId: String) {
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