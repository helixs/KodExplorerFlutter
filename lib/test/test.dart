class Person{
  String name;
  num age;
  Person(this.name,this.age);
  printInfo(){
    print('${this.name}----${this.age}');
  }
  void run(){
    print("Person Run");
  }
}

class A {
  String info="this is A";
  void printA(){
    print("A");
  }
  void run(){
    print("A Run");
  }
}

class B {
  void printB(){
    print("B");
  }
  void run(){
    print("B Run");
  }
}

class C extends Person with B,A{
  C(String name, num age) : super(name, age);
}

void main(){
//  var c=new C('张三',20);
//  c.printInfo();
//   c.printB();
//   c.printA();
//   print(c.info);
//  c.run();

//var bbq = new BBQS("");

var  ss = "/sdsds/sbbb/qq";
var reuslt = ss.split("/");
print(reuslt);
}

class BBQ{
  BBQ(String qq){
    print("BBQ");
  }
}
class BBQS extends BBQ{
  BBQS(String qq) : super(qq){
    print("BBQS");
  }
  
}
