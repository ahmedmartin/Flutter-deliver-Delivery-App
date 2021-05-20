import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'classies/order.dart';




class Orders extends StatefulWidget{

  List<order> comp_info = [];
  String delivery_name ;
  String delivery_phone ;
  String delivery_id ;
  Orders(this.delivery_name, this.delivery_phone, this.delivery_id,this.comp_info);


  @override
  State<StatefulWidget> createState() {
    return _Orders(this.delivery_name, this.delivery_phone, this.delivery_id,this.comp_info);
  }


}

class _Orders extends State<Orders>{

  List<order> comp_info = [];
  String delivery_id = 'delivery_id';
  String delivery_name = 'ddddddddd';
  String delivery_phone = '01111111111111';
  _Orders(this.delivery_name, this.delivery_phone, this.delivery_id,this.comp_info);

  String comp_selected;
  bool uploading = false;
  List<order>search_orders_list = [];
  List<order>all_orders_list =[];
  List<String> statuse_list = ['استلم','شحن على الراسل','مؤجل','مرتجع جزئى','مرتجع','قيد التنفيذ'];
  TextEditingController controller_cust_phone = TextEditingController();

  /*get_comp(){
    FirebaseFirestore.instance.collection('deliveries').doc(delivery_id).collection('companies').get().then((value){
      value.docs.forEach((element) {
        setState(() {
          order Order =order.info(element['name'], element.id);
          comp_info.add(Order);
        });
      });

    });
  }

  @override
  void initState() {
    get_comp();
    super.initState();
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

          SizedBox(height: 55,),
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
                        search_orders_list[index].cust_city,search_orders_list[index].statuse,search_orders_list[index].cust_delivery_price) ,
                    onTap: (){
                      show_order_statuse(index);
                    },
                  );
                }),
          ),
          uploading? CircularProgressIndicator():Container(height: 10,),
          RaisedButton(
              child: Text('التقفيل مع الشركه', style: TextStyle(fontSize: 30, color: Colors.white), textAlign: TextAlign.center,),
              color: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: Colors.black)
              ),
              onPressed: () {
                // check if he have any orders deliveed
                //لو هو مسلمش ولا اوردر يبقى معنى كده انه قفل مع الشركه خلاص علشان ميحصلش و يقفل مع الشركه تانى
                if(all_orders_list.where((element1) => element1.statuse == statuse_list[0]).length != 0) {
                  setState(() {
                    uploading = true;
                  });
                  double price = 0;
                  all_orders_list.where((element) => element.cust_delivery_price.isNotEmpty && element.cust_delivery_price != null)
                      .forEach((element1) {
                    price += double.parse(element1.cust_delivery_price);
                  });

                  CollectionReference orders = FirebaseFirestore.instance.collection('companies').doc(comp_selected).collection('orders');
                  orders.where('last_date', isEqualTo: 'yes').get().then((value) {
                    value.docs.forEach((element) {
                      FirebaseDatabase.instance.reference().child('companies').child(comp_selected).child("delivery_money")
                          .child(element.id).child(delivery_id).set({
                        'delivered_count': all_orders_list.where((element1) => element1.statuse == statuse_list[0]).length,
                        'delivering_on_seller_count': all_orders_list.where((element1) => element1.statuse == statuse_list[1]).length,
                        'orders_price': price,
                        'name': delivery_name,
                        'phone': delivery_phone,
                      })
                          .whenComplete(() {
                        setState(() {
                          uploading = false;
                        });
                      });
                      // get all orders delivered (استلم)
                      all_orders_list.where((element1) => element1.statuse == statuse_list[0]).forEach((element2) {
                        // add all orders delivered (استلم) to orders to last date
                        orders.doc(element.id).collection('all').add(element2.to_map()).whenComplete(() {
                          // remove all orders delivered (استلم) from waiting orders
                          FirebaseFirestore.instance.collection('companies').doc(comp_selected).collection('waiting_orders')
                          .doc(element2.order_id).delete().whenComplete((){

                            setState(() {
                              all_orders_list.removeWhere((element1) => element1.statuse == statuse_list[0]);
                              search_orders_list.removeWhere((element1) => element1.statuse == statuse_list[0]);
                            });

                          });

                        });

                      });

                    });
                  });
                }else{
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("تاكد من استلام الشركه للتقفيل السابق",style: TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                    backgroundColor: Colors.red,
                  ));
                }
              }),
          SizedBox(height: 10,),
        ],
      ),
    );
  }

  get_orders(){
    all_orders_list.clear();
    search_orders_list.clear();
    FirebaseFirestore.instance.collection('companies').doc(comp_selected).collection('waiting_orders')
        .where('delivery_id',isEqualTo: delivery_id).get().then((snapshot){
          snapshot.docs.forEach((element) {
            order Order = order(element['cust_name'], element['cust_phone'], element['cust_city'], element['cust_address'],
                element['cust_price'], element['cust_note'], element['seller_id'], element['delivery_fee_plus'],
                element.id, element['statuse'], element['cust_delivery_price'], delivery_id);
            setState(() {
              all_orders_list.add(Order);
            });
          });
          search_orders_list.addAll(all_orders_list);
        });
  }

  Widget Row_style(index,cust_name,cust_phone,cust_address,cust_note,cust_price,String cust_city,statuse,delivery_price){


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
                    //['استلم','شحن على الراسل','مؤجل','مرتجع جزئى','مرتجع','قيد التنفيذ']
                    Text(statuse,style: TextStyle(fontSize: 20,color: statuse == statuse_list[0]? Colors.green:
                                      statuse == statuse_list[1]? Colors.red:
                                      statuse == statuse_list[2]? Colors.orange:
                                      statuse == statuse_list[3]? Colors.deepOrange:
                                      statuse == statuse_list[4]? Colors.redAccent:Colors.black),),

                    SizedBox(width: 10,),
                    Icon(Icons.assignment,size: 30,color: statuse == statuse_list[0]? Colors.green:
                                      statuse == statuse_list[1]? Colors.red:
                                      statuse == statuse_list[2]? Colors.orange:
                                      statuse == statuse_list[3]? Colors.deepOrange:
                                      statuse == statuse_list[4]? Colors.redAccent:Colors.black)
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
                    Text(cust_phone , style: TextStyle(fontSize: 20,color: Colors.black),),
                    Icon(Icons.phone,color: Colors.black,size: 30,)
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
            Container(height: 15,),
            Text(cust_address,style: TextStyle(fontSize: 20,color: Colors.black),),

            Container(height: 15,),
            Text(cust_note,style: TextStyle(fontSize: 20,color: Colors.black),),

            SizedBox(height: 15,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(delivery_price,style: TextStyle(fontSize: 20,color: Colors.green),),
                    SizedBox(width: 10,),
                    Icon(Icons.monetization_on,color: Colors.green,size: 30,)
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(cust_price,style: TextStyle(fontSize: 20,color: Colors.black),),
                    SizedBox(width: 10,),
                    Icon(Icons.attach_money,color: Colors.black,size: 30,)
                  ],
                ),
              ],
            ),

          ],
        ),
      ),
    );
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