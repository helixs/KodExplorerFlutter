package me.xmcf.kodproject.flutterchannel.download

data class TaskInfoRes(
        //主键id
        var primaryId: Int = 0,
        //任务id
        var taskId: String,
        //任务状态
        var status: Int = 0,
        //进度
        var progress: Int = 0,
        //任务下载地址
        var url: String,
        //文件名称
        var filename: String,
        //保存目录
        var savedDir: String,
        //header
        var headers: String,
        //文件mime
        var mimeType: String,
        //是否可恢复
        var resumable: Boolean = false,
        //显示通知栏
        var showNotification: Boolean = false,
        //打开通知栏文件
        var openFileFromNotification: Boolean = false,
        //任务创建时间
        var timeCreated: Long = 0
)