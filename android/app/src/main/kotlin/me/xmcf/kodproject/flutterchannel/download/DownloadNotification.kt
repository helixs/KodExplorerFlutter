package me.xmcf.kodproject.flutterchannel.download

enum class DownloadChannel( val channelId: String,val channelName: String) {
    DOWNLOADING("Downloading","下载中的任务"),
    DOWNLOAD_PAUSE("Downloading_Pause","暂停中的任务"),
    DOWNLOADED("Downloaded","下载完成的任务"),
    DOWNLOAD_FAIL("Download_fail","下载失败的任务"),

}