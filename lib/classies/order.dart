
class order {

  String cust_name=""; //اسم العميل
  String cust_phone=""; //تليفون العميل
  String cust_city=""; //محافظه العميل
  String cust_address=""; //عنوان تفصيلى للعميل
  String cust_price=""; // سعر الاجمالى من الاوردر
  String cust_note=""; //ملحوظه
  String comp_id="";
  String comp_name = '';
  String seller_id="";
  String delivery_fee_plus="";
  String order_id="";
  String statuse ='قيد التنفيذ';
  String cust_delivery_price ='';
  String delivery_id = '';

  order.info(this.comp_name,this.comp_id);

  order(this.cust_name, this.cust_phone, this.cust_city, this.cust_address,
      this.cust_price, this.cust_note, this.seller_id, this.delivery_fee_plus,
      this.order_id, this.statuse, this.cust_delivery_price,this.delivery_id);

  Map<String, String> to_map(){
    return {
      'cust_name':cust_name,
      'cust_phone':cust_phone,
      'cust_city':cust_city,
      'cust_address':cust_address,
      'cust_price':cust_price,
      'cust_note':cust_note,
      'seller_id':seller_id,
      'delivery_fee_plus':delivery_fee_plus,
      'delivery_id':delivery_id,
      'statuse':statuse,
      'cust_delivery_price':cust_delivery_price,
    };
  }
/*
  order(this.cust_name, this.cust_phone, this.cust_city, this.cust_address,
      this.cust_price, this.cust_note, this.delivery_id, this.seller_id,
      this.order_id,this.delivery_fee_plus );

  order.creat(this.seller_id,this.seller_name){
    set_initial_value();
  }


  order.request(this.seller_id,this.seller_name,this.count);

  order.new_order(this.cust_name, this.cust_phone, this.cust_city,
             this.cust_address, this.cust_price, this.cust_note, this.seller_id,this.delivery_fee_plus);


  order.update(this.cust_name, this.cust_phone, this.cust_city, this.cust_address, this.cust_price,
      this.cust_note, this.seller_id,this.delivery_fee_plus,this.order_id);

  order.recieve_from_delivery(this.cust_name, this.cust_phone, this.cust_city, this.cust_address,
      this.cust_price, this.cust_note, this.delivery_id, this.seller_id, this.delivery_fee_plus,
      this.order_id, this.statuse, this.cust_delivery_price){

      set_initial_value();
  }

  order.send_seller(this.cust_name, this.cust_phone, this.cust_city, this.cust_address,
      this.cust_price, this.cust_note, this.statuse);

  order.info(this.seller_name,this.seller_id);

  Map<String, String> to_map(){
    return {
      'cust_name':cust_name,
      'cust_phone':cust_phone,
      'cust_city':cust_city,
      'cust_address':cust_address,
      'cust_price':cust_price,
      'cust_note':cust_note,
      'seller_id':seller_id,
      'delivery_fee_plus':delivery_fee_plus,
      'delivery_id':delivery_id,
      'statuse':statuse,
      'cust_delivery_price':cust_delivery_price,
    };
  }

  set_initial_value(){
    if(this.cust_note==null)
      this.cust_note = "";
    if(this.cust_price==null)
      this.cust_price="";
    if(this.cust_address==null)
      this.cust_address="";
    if(this.cust_phone==null)
      this.cust_phone="";
    if(this.cust_name==null)
      this.cust_name="";
    if(this.statuse==null)
      this.statuse='قيد التنفيذ';
    if(this.cust_delivery_price==null)
      this.cust_delivery_price='';
  }

*/

}