import 'package:flutter/material.dart';
import 'package:kodproject/network/httpmanager.dart';
import 'package:kodproject/custom/pop.dart';

abstract class LifeState<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onStart();
      WidgetsBinding.instance.addPersistentFrameCallback((_){
        //每帧
        everyFrame();
      });
    });


  }
  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
  }
  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }

  void everyFrame(){

  }


  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
//
//  @override
//  Widget build(BuildContext context) {
//    return lifeBuild(context);
//  }



//  Widget lifeBuild(BuildContext context);

  void onStart() {}

  onResume() {}

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }
}
