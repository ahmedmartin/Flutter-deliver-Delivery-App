import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'classies/order.dart';




class Profile_info extends StatefulWidget{

  List<order> comp_info = [];
  String delivery_name ;
  String delivery_phone ;
  String delivery_id ;
  Profile_info(this.delivery_name, this.delivery_phone, this.delivery_id,this.comp_info);

  @override
  State<StatefulWidget> createState() {
    return _Profile_info( this.delivery_name, this.delivery_phone, this.delivery_id,this.comp_info);
  }



}

class _Profile_info extends State<Profile_info>{

  List<order> comp_info = [];
  String delivery_name ;
  String delivery_phone ;
  String delivery_id ;
  _Profile_info( this.delivery_name, this.delivery_phone, this.delivery_id,this.comp_info);
  order comp ;

  DatabaseReference request ;
  get_requested_comp(){
    request = FirebaseDatabase.instance.reference().child('waiting_list').child('delivery').child(delivery_phone);
    request.once().then((snapshot){
       List val =snapshot.value.toString().split(',');
       print(val);
       setState(() {
         comp = order.info(val[1], val[0]);
       });
    });
  }
  
  @override
  void initState() {
    get_requested_comp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(delivery_name,style: TextStyle(fontSize: 25,color: Colors.black),textAlign: TextAlign.center,),
                Icon(Icons.person,color: Colors.black,)
              ],
            ),
            
            SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(delivery_phone,style: TextStyle(fontSize: 25,color: Colors.black),textAlign: TextAlign.center,),
                Icon(Icons.phone,color: Colors.black,)
              ],
            ),
            SizedBox(height: 40,),
            Text('طلبات اقتران',style: TextStyle(fontSize: 30,color: Colors.red,fontWeight: FontWeight.bold),textAlign: TextAlign.right,),
            SizedBox(height: 20,),
            comp==null? Container():Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                RaisedButton(
                    child:Text('قبول',style: TextStyle(fontSize: 20,color: Colors.white)),
                    color: Colors.black,
                    onPressed: (){
                      FirebaseFirestore.instance.collection('deliveries').doc(delivery_id).collection('companies')
                          .doc(comp.comp_id).set({'name':comp.comp_name});
                      FirebaseFirestore.instance.collection('companies').doc(comp.comp_id).collection('deliveries')
                      .doc(delivery_id).set({'name':delivery_name,'phone':delivery_phone});
                      remove();
                    }),
                RaisedButton(
                    child:Text('حذف',style: TextStyle(fontSize: 20,color: Colors.red)),
                    color: Colors.black,
                    onPressed: (){remove();}),
                Text(comp.comp_name,style: TextStyle(fontSize: 20,color: Colors.black)),
                SizedBox(),
              ],
            ),

            /*SizedBox(height: 40,),
            Text('الشركات',style: TextStyle(fontSize: 30,color: Colors.red,fontWeight: FontWeight.bold),textAlign: TextAlign.right,),
            ListView.builder(
                itemCount: comp_info.length,
                itemBuilder: (contex,index){
                   return Row(
                     mainAxisAlignment: MainAxisAlignment.spaceAround,
                     children: [
                       RaisedButton(
                           child:Text('حذف',style: TextStyle(fontSize: 20,color: Colors.red)),
                           color: Colors.black,
                           onPressed: (){
                             FirebaseFirestore.instance.collection('deliveries').doc(delivery_id).collection('companies')
                                 .doc(comp_info[index].comp_id).delete();
                             FirebaseFirestore.instance.collection('companies').doc(comp_info[index].comp_id).collection('deliveries')
                                 .doc(delivery_id).delete();
                           }),
                       Text(comp_info[index].comp_name,style: TextStyle(fontSize: 20,color: Colors.black)),
                     ],
                   );
                }),*/
          ],
        ),
      ),
    );

  }

  remove(){
    request.remove().whenComplete((){
      setState(() {
        comp = null;
      });
    });
  }

}