import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ra7al_delivery/profile_info.dart';
import 'package:ra7al_delivery/sign_up.dart';
import 'package:url_launcher/url_launcher.dart';
import 'classies/order.dart';
import 'orders.dart';
import 'package:provider/provider.dart';






class Home extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _Home();
  }

}

class _Home extends State<Home>{

  List<order> comp_info = [];
  String comp_selected;
  String delivery_id ;
  String delivery_name ;
  String delivery_phone;
  List<order>search_orders_list = [];
  List<order>all_orders_list =[];
  List<String> statuse_list = ['استلم','شحن على الراسل','مؤجل','مرتجع جزئى','مرتجع','قيد التنفيذ'];
  TextEditingController controller_cust_phone = TextEditingController();

  get_comp(){

    delivery_id = FirebaseAuth.instance.currentUser.uid.toString();
    DocumentReference ref = FirebaseFirestore.instance.collection('deliveries').doc(delivery_id);
    ref.get().then((snapshot){

      delivery_name = snapshot.data()['name'];
      delivery_phone = snapshot.data()['phone'];

    }).whenComplete((){

      ref.collection('companies').get().then((value){
        value.docs.forEach((element) {
          setState(() {
            order Order =order.info(element['name'], element.id);
            comp_info.add(Order);
          });
        });
      });
    });
  }

  @override
  void initState() {
    get_comp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            Draw_header(),

            SizedBox(height: 10,),
            FlatButton(
              child: Text("تقفيل الاوردارات", style: TextStyle(fontSize: 25,color: Colors.black)),
              color: Colors.grey.withOpacity(0),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder:(context)=> Orders(delivery_name,delivery_phone,delivery_id,comp_info)));
              },
            ),

            SizedBox(height: 10,),
            FlatButton(
              child: Text("الملف الشخصى", style: TextStyle(fontSize: 25,color: Colors.black)),
              color: Colors.grey.withOpacity(0),
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder:(context)=> Profile_info(delivery_name,delivery_phone,delivery_id,comp_info)));
              },
            ),

            SizedBox(height: 20,),
            FlatButton(
              child: Text("تسجيل الخروج" , style: TextStyle(fontSize: 22,color: Colors.black),),
              color: Colors.grey.withOpacity(0),
              onPressed: (){
                 FirebaseAuth.instance.signOut().whenComplete((){
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (c)=>Sign_up()), (route) => false);
                });
              },
            ),
          ],
        ),

      ),

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Ra7al',style: TextStyle(fontSize: 35,color: Colors.white),textAlign: TextAlign.center,),

      ),

      body: Column(
        children: [
          SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(width: 20,),
              DropdownButton(
                  hint: Text("اختار الشركه"),
                  items: comp_info.map((val){
                    return DropdownMenuItem(child: Text(val.comp_name),value: val.comp_id,);
                  }).toList(),
                  value: comp_selected,
                  onChanged: (val){
                    setState(() {
                      comp_selected = val;
                      get_orders();
                      print(val);
                    });
                  }),

              SizedBox(width: 10,),
              Flexible(
                child: TextFormField(
                  keyboardType:TextInputType.number,
                  decoration: InputDecoration(hintText: 'التليفون',
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                    suffixIcon: Icon(Icons.search,color: Colors.black,)
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black,fontSize: 20),
                  controller: controller_cust_phone,
                  onChanged: (val){
                    setState(() {
                      search_orders_list.clear();
                      search_orders_list.addAll(all_orders_list.where((element) => element.cust_phone.contains(val)));
                    });
                  },
                ),
              ),
              SizedBox(width: 10,),

            ],
          ),

          SizedBox(height: 20,),
          Flexible(
            child: ListView.builder(
                itemCount: search_orders_list.length,
                itemBuilder:(context,index){
                  return GestureDetector(
                    child: Row_style(index, search_orders_list[index].cust_name, search_orders_list[index].cust_phone,
                        search_orders_list[index].cust_address, search_orders_list[index].cust_note, search_orders_list[index].cust_price,
                        search_orders_list[index].cust_city) ,
                    onTap: (){
                      show_order_statuse(index);
                    },
                  );
                }),
          )
        ],
      ),
    );
  }


  get_orders(){
    all_orders_list.clear();
    search_orders_list.clear();
    FirebaseFirestore.instance.collection('companies').doc(comp_selected).collection('waiting_orders').where('delivery_id',isEqualTo: delivery_id)
        .where('statuse',whereIn: ['قيد التنفيذ','مؤجل']).get().then((snapshot){
          snapshot.docs.forEach((element) {
            order Order = order(element['cust_name'], element['cust_phone'], element['cust_city'], element['cust_address'],
                element['cust_price'], element['cust_note'], element['seller_id'], element['delivery_fee_plus'],
                element.id, element['statuse'], element['cust_delivery_price'], delivery_id);
            setState(() {
              search_orders_list.add(Order);
              all_orders_list.add(Order);
            });
          });
    });
  }


  Widget Draw_header(){
    return DrawerHeader(
      decoration: BoxDecoration(color: Colors.black),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        //mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 100,
            width: 110,
            child:CircleAvatar(backgroundImage: NetworkImage("https://images.squarespace-cdn.com/content/v1/5c528d9e96d455e9608d4c63/1586379635937-DUGHB6LHU59QIVDH2QHZ/ke17ZwdGBToddI8pDm48kHTW22EZ3GgW4oVLBBkxXg1Zw-zPPgdn4jUwVcJE1ZvWQUxwkmyExglNqGp0IvTJZUJFbgE-7XRK3dMEBRBhUpwEg94W6zd8FBNj5MCw-Ij7INTc0XdOQR2FYhNzGmPXJN9--qDehzI3YAaYB5CQ-LA/Hiker.gif?format=500w"),),
          ),

          SizedBox(width: 20,),

          Expanded(
            child: Text('Ra7al',style: TextStyle(fontSize: 30,color: Colors.white,fontWeight: FontWeight.bold),),
          ),

        ],
      ),
    );
  }

  Widget Row_style(index,cust_name,cust_phone,cust_address,cust_note,cust_price,String cust_city){


    return Card(
      color:Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 8,
      shadowColor: Colors.black,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [

            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlatButton(
                      color: Colors.grey.withOpacity(.08),
                      child: Text(cust_phone , style: TextStyle(fontSize: 20,color: Colors.black),),
                      onPressed: (){
                        launch(('tel://${search_orders_list[index].cust_phone}'));
                      },
                    ),
                    Icon(Icons.phone,color: Colors.black,size: 30,)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_name , style: TextStyle(fontSize: 20,color: Colors.black),),
                    Icon(Icons.person,color: Colors.black,size: 30,)
                  ],
                )

              ],
            ),

            //--------------------------------------------------------------------------------

            Container(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_price,style: TextStyle(fontSize: 20,color: Colors.green),),
                    SizedBox(width: 10,),
                    Icon(Icons.attach_money,color: Colors.green,size: 30,)
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_city, style: TextStyle(fontSize: 20,color: Colors.black),textAlign: TextAlign.center,),
                    Icon(Icons.map,color: Colors.black,size: 30,)
                  ],
                )

              ],
            ),

            //---------------------------------------------------------------------------------

            Text(cust_address,style: TextStyle(fontSize: 20,color: Colors.black),),

            Container(height: 15,),
            FlatButton(
              color: Colors.grey.withOpacity(.08),
              child: Text(cust_note,style: TextStyle(fontSize: 20,color: Colors.black),),
              onPressed: (){
                show_note(index);
              },
            ),

          ],
        ),
      ),
    );
  }

  show_note(int index){
    showDialog(
        context: context,
        builder: (context){
          TextEditingController controller_cust_note = TextEditingController();
          controller_cust_note.text = search_orders_list[index].cust_note;
          return AlertDialog(
            title: Text('كتابه ملاحظه'),
            content: Center(
              child: TextFormField(
                decoration: InputDecoration(hintText: 'ملاحظه',
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
            borderRadius: BorderRadius.all(Radius.circular(30))),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
            borderRadius: BorderRadius.all(Radius.circular(30))),
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black,fontSize: 20),
            controller: controller_cust_note,
            )),
            actions: [
          FlatButton(
          child: Text('تعديل', style: TextStyle(fontSize: 30, color: Colors.white), textAlign: TextAlign.center,),
              color: Colors.black,
              shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: Colors.black)
              ),
              onPressed: () {
                search_orders_list[index].cust_note = controller_cust_note.text;
                FirebaseFirestore.instance.collection('companies').doc(comp_selected).collection('waiting_orders')
                    .doc(search_orders_list[index].order_id).update(search_orders_list[index].to_map()).whenComplete((){
                      setState(() {
                        search_orders_list = search_orders_list;
                        Navigator.pop(context);
                      });
                });
              })
            ],
          );
        });
  }

  show_order_statuse(int index){

    showDialog(
      context: context,
      builder: (context){
        String statuse_selected ;
        TextEditingController delivery_price = TextEditingController();
        String msg = '';
        return StatefulBuilder(
          builder: (context,StateSetter setState) {
            return AlertDialog(
              title: Text('اختار حاله الاوردر'),
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton(
                      hint: Text("اختار الحاله"),
                      items: statuse_list.map((val) {
                        return DropdownMenuItem(
                          child: Text(val), value: val,);
                      }).toList(),
                      value: statuse_selected,
                      onChanged: (val) {
                        setState(() {
                          statuse_selected = val;
                          msg = '';
                        });
                      }),
                  SizedBox(height: 20,),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: 'سعر استلام',
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.black,width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black,fontSize: 20),
                    controller: delivery_price,
                  ),

                  Text(msg,style: TextStyle(color: Colors.red),),
                ],
              ),
              actions: [
                FlatButton(
                child: Text('ارسال', style: TextStyle(fontSize: 30, color: Colors.white), textAlign: TextAlign.center,),
                color: Colors.black,
                shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(color: Colors.black)
                ),
                onPressed: () {

                  setState((){
                    msg = '';
                  });

                  if(statuse_selected != null) {
                    if(delivery_price.text.isNotEmpty) {
                      search_orders_list[index].cust_delivery_price = delivery_price.text;
                      search_orders_list[index].statuse = statuse_selected;
                      FirebaseFirestore.instance.collection('companies').doc(comp_selected).collection('waiting_orders')
                          .doc(search_orders_list[index].order_id).update(search_orders_list[index].to_map()).whenComplete((){

                            if(statuse_selected != 'قيد التنفيذ'|| statuse_selected != 'مؤجل') {
                              all_orders_list.removeWhere((element) => element.order_id == search_orders_list[index].order_id);
                              search_orders_list.removeAt(index);
                            }

                            Navigator.pop(context);
                            update_ui();
                      });
                    }else{
                      setState((){
                        msg = 'يجب كتابه سعر الاستلام';
                      });
                    }
                  }else{
                    setState((){
                      print(statuse_selected);
                      msg = 'يجب اختيار حاله الاوردر';
                    });
                  }
                })
              ],
            );
          }
        );
      });
  }

  update_ui(){
    setState(() {
      search_orders_list = search_orders_list;
    });
  }

}