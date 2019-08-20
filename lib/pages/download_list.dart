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

class DownloadManagerListState extends LifeState<DownloadManagerListPage>
    with TickerProviderStateMixin {
  TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
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
              flexibleSpace: FlexibleSpaceBar(),
              bottom: TabBar(
                controller: _tabController,
                unselectedLabelColor: Colors.grey,
                tabs: <Widget>[
                  Tab(
                    text: "全部",
                    icon: Icon(Icons.home),
                  ),
                  Tab(
                    text: "下载中",
                    icon: Icon(Icons.help),
                  ),
                  Tab(
                    text: "已完成",
                    icon: Icon(Icons.home),
                  ),
                ],
              ),
            ),
          ];
        },
        body: new TabBarView(
          controller: _tabController,
          children: <Widget>[
            _buildList(),
            _buildList(),
            _buildList(),
          ],
        ),
      ),
    );
  }

  ListView _buildList() {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (BuildContext context, int index) {
        return ItemTaskPage();
      },
      itemCount: 20,
    );
  }
}

class ItemTaskPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Container(
          width: 50,
          height: 50,
          child: Icon(
            Icons.video_library,
            color: Colors.blue,
          ),
        ),
        Expanded(
          child: Column(
            children: <Widget>[Text("你是一头小毛驴", maxLines: 3)],
          ),
        )
      ],
    );
  }
}
