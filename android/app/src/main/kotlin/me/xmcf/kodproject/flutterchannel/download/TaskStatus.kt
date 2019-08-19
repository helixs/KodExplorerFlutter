package me.xmcf.kodproject.flutterchannel.download


class  TaskStatus {
    companion object{
       const val UNDEFINED = 0
       const val ENQUEUED = 1
       const val RUNNING = 2
       const val COMPLETE = 3
       const val FAILED = 4
       const val CANCELED = 5
       const val PAUSED = 6
    }
}