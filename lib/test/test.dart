import 'dart:async';

class Person {
  String name;
  num age;

  Person(this.name, this.age);

  printInfo() {
    print('${this.name}----${this.age}');
  }

  void run() {
    print("Person Run");
  }
}

class A {
  String info = "this is A";

  void printA() {
    print("A");
  }

  void run() {
    print("A Run");
  }
}

class B {
  void printB() {
    print("B");
  }

  void run() {
    print("B Run");
  }
}

class C extends Person with B, A {
  C(String name, num age) : super(name, age);
}

Future<int> sumStream(Stream<int> stream) async {
  var sum = 0;
  await for (var value in stream) {
    sum += value;
  }
  return sum;
}
Stream<int> countStream(int to) async* {
  for (int i = 1; i <= to; i++) {
    yield i;
  }
}
void main() {
//  var aa = sumStream(Stream.fromIterable([1, 2, 3]));
//  aa.then((value) {
//    print(value);
//  });
  countStream(5).listen((data)=>print(data));
  countStream(5)
//  StreamController controller = StreamController();
//  controller.sink.add(123);
//  controller.sink.add("xyz");

//创建一条处理int类型的流
//  StreamController<int> numController = StreamController();
//  numController.sink.add(123);
//
//  StreamSubscription subscription =
//      controller.stream.listen((data) => print("$data"));
//
//  subscription.cancel();
//
//  controller.sink.add(123);
//  var c=new C('张三',20);
//  c.printInfo();
//   c.printB();
//   c.printA();
//   print(c.info);
//  c.run();

//var bbq = new BBQS("");

//var  ss = [2,1,5,3,6];
//ss.sort((a,b){
//  print("$a,$b");
//  return a-b;
//});

//print(ss);

//String sdwada =null;
//var qq = sdwada??"1";
//var bb = sdwada?:"1";
}

class BBQ {
  BBQ(String qq) {
    print("BBQ");
  }
}

class BBQS extends BBQ {
  BBQS(String qq) : super(qq) {
    print("BBQS");
  }
}
