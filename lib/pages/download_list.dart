import 'package:flutter/material.dart';
import 'package:kodproject/custom/KBar.dart';
import 'package:kodproject/life/life_state.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      var index = _tabController.index;
      var previewIndex = _tabController.previousIndex;
      print('index:$index, preview:$previewIndex');
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
                    return new ItemTaskPage();
                  },
                  childCount: 50,
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
      backgroundColor: Colors.blue[50],
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

  ListView _buildList(int num) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return ItemTaskPage();
      },
      itemCount: num,
    );
  }
}

class ItemTaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        margin: EdgeInsets.only(bottom: 1),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Container(
              width: 60,
              height: 60,
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.video_library,
                color: Colors.blue,
                size: 50,
              ),
            ),
            Container(
              width: 5,
              height: 60,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("你是一头小毛驴", maxLines: 2),
                  Spacer(
                    flex: 1,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text("大小:"),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text("创建时间:"),
                      ),
                      Text("详细信息")
                    ],
                  )
                ],
              ),
            ),
            Container(
              width: 60,
              height: 50,
              child: Icon(
                Icons.video_library,
                color: Colors.blue,
              ),
            ),
          ],
        ));
  }
}
