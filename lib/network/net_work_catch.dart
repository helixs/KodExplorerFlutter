import 'package:flutter/material.dart';
import 'package:kodproject/network/httpmanager.dart';
import 'package:kodproject/pop.dart';

import '../loginpage.dart';

void requestNetWorkOfState(Function requestFun,State state,{@required Function successFun,bool isShowLoading = false}) async{

    try {
      if(isShowLoading){
        Pop.showLoading(state.context);
      }
      var result = await requestFun();
      if(isShowLoading&&state.mounted){
        Pop.dissLoading(state.context);
      }
      successFun(result);
    }on KCodeException catch (e){
      if(isShowLoading&&state.mounted){
        Pop.dissLoading(state.context);
      }
      if(state.mounted){
        if(e.message.contains("accessToken error")){
          Pop.showToast(state.context, "用户过期重新登录");
          await new Future.delayed(Duration(milliseconds:500));
          Navigator.of(state.context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) {
                return LoginPage();
              }), (Route<dynamic> route) => false);
        }else{
          Pop.showToast(state.context, e.message);
        }
      }

    }on KNetException catch(e){
      if(isShowLoading&&state.mounted){
        Pop.dissLoading(state.context);
      }
      if(state.mounted){
        Pop.showToast(state.context, e.message);
      }
    }catch(e){
      if(isShowLoading&&state.mounted){
        Pop.dissLoading(state.context);
      }
      Pop.showToast(state.context, e.message);
    }

}
void requestNetWorkOfBuildContext(Function function,BuildContext context,{bool isShowLoading = false})async{

  try {
    if(isShowLoading){
      Pop.showLoading(context);
    }
    await function();
  }on KCodeException catch (e){
    if(context!=null){
      Pop.showToast(context, e.message);
    }

  }on KNetException catch(e){
    if(context!=null){
      Pop.showToast(context, e.message);
    }
  }finally{
    if(isShowLoading){
      Pop.dissLoading(context);
    }
  }

}