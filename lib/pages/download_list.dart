import 'package:flutter/material.dart';
import 'package:kodproject/custom/KBar.dart';
import 'package:kodproject/life/life_state.dart';
import 'package:kodproject/plugin/downloader.dart';
import 'package:kodproject/tools/calc_size.dart';

class DownloadManagerListPage extends StatefulWidget {
  final String _title = "下载管理";

  @override
  State<StatefulWidget> createState() {
    return DownloadManagerListState();
  }
}

enum _TASK_TAB { DOWNLOADING, DOWNLOADED, ALL }

class DownloadManagerListState extends LifeState<DownloadManagerListPage>
    with TickerProviderStateMixin {
  TabController _tabController;
  static const Map<String, _TASK_TAB> _TABS = {
    "全部": _TASK_TAB.ALL,
    "下载中": _TASK_TAB.DOWNLOADING,
    "已完成": _TASK_TAB.DOWNLOADED
  };

  List<DownloadTask> _allTasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      var index = _tabController.index;
      var previewIndex = _tabController.previousIndex;
      print('index:$index, preview:$previewIndex');
    });
    _queryList();
  }

  void _queryList() async {
    List<DownloadTask> tasks = await FlutterDownloader.loadTasks();
    setState(() {
      _allTasks = tasks??[];
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Tab> _getTabs() {
    List<Tab> tabs = [];
    _TABS.forEach((name, tab) {
      tabs.add(Tab(text: name, icon: Icon(Icons.apps)));
    });
    return tabs;
  }

  List<Widget> _getTabViews() {
    List<Widget> safeTabs = [];
    _TABS.forEach((name, tab) {
      safeTabs.add(
        Builder(builder: (BuildContext buildContext) {
          return new CustomScrollView(
            key: new PageStorageKey<String>(name),
            slivers: <Widget>[
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    buildContext),
              ),
              SliverFixedExtentList(
                //item高度48像素
                itemExtent: 80.0,
                delegate: SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                    return new ItemTaskPage(_allTasks[index]);
                  },
                  childCount: _allTasks.length,
                ),
              )
            ],
          );
        }),
      );
    });
    return safeTabs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverOverlapAbsorber(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
              child: SliverAppBar(
                expandedHeight: 200,
                floating: false,
                //标题是否在滑动时候隐藏
                pinned: true,
                //标题是否固定在顶部
                snap: false,
                //是否提前滚动
                title: Text(widget._title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    )),
//                flexibleSpace: FlexibleSpaceBar(),
                bottom: TabBar(
                  controller: _tabController,
                  unselectedLabelColor: Colors.grey,
                  tabs: _getTabs(),
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: _getTabViews(),
        ),
      ),
    );
  }
}

class ItemTaskPage extends StatefulWidget {
  final DownloadTask downloadTask;

  const ItemTaskPage(this.downloadTask, {Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ItemTaskState();
  }
}

class ItemTaskState extends State<ItemTaskPage> {
  int _progress = 0;
  DownloadTaskStatus _status = DownloadTaskStatus.undefined;
  int _currentLength = 0;
  int _allLength = 0;

  @override
  void initState() {
    super.initState();
    _progress = widget.downloadTask.progress;
    _status = widget.downloadTask.status;
    FlutterDownloader.registerCallback(
        (String id, DownloadTaskStatus status, int progress,{int currentLength,int allLength}) {
      if (id == widget.downloadTask.taskId) {
        setState(() {
          _progress = progress;
          _status = status;
          _currentLength = currentLength??0;
          _allLength = allLength??0;
        });
      }
    });
  }

  String _getStatus(DownloadTaskStatus status, int progress) {
    if (status == DownloadTaskStatus.undefined) {
      return "未知";
    }
    if (status == DownloadTaskStatus.canceled) {
      return "已取消";
    }
    if (status == DownloadTaskStatus.complete) {
      return "已完成";
    }
    if (status == DownloadTaskStatus.enqueued) {
      return "准备中";
    }
    if (status == DownloadTaskStatus.paused) {
      return "已暂停";
    }
    if (status == DownloadTaskStatus.failed) {
      return "出错";
    }
    if (status == DownloadTaskStatus.running) {
      return "下载中";
    }
    return "未知";
  }

  @override
  Widget build(BuildContext context) {
    String currentStatus = _getStatus(_status, _progress);

    return Container(
        margin: EdgeInsets.only(bottom: 5),
        child: Card(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
            child: Stack(
              children: <Widget>[
                SizedBox.expand(
                    child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: LinearProgressIndicator(
                    value: _progress * 0.01,
                    backgroundColor: Colors.white,
                    valueColor: AlwaysStoppedAnimation(Colors.blue[100]),
                  ),
                )),
                Container(
                  padding: EdgeInsets.only(top: 2, bottom: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: 60,
                        height: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Spacer(
                              flex: 1,
                            ),
                            Expanded(
                              flex: 2,
                              child: Icon(
                                Icons.play_arrow,
                                color: Colors.cyan,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(currentStatus),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 5,
                        height: double.infinity,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(widget.downloadTask.filename, maxLines: 2),
                            Spacer(flex: 1),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text(currentStatus),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(""),
                                ),
                                Text("详细信息")
                              ],
                            )
                          ],
                        ),
                      ),
                      Container(
                          width: 100,
                          height: double.infinity,
                          child: Stack(
                            children: <Widget>[
                              Align(
                                alignment: Alignment.center,
                                child: Text("${CalcSize.getSizeToString(_currentLength,false)}/${CalcSize.getSizeToString(_allLength,true)}"),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(_progress.toString() + "%"),
                              ),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            )));
  }
}
