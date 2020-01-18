<?php
class Stock_model extends CI_Model {

    public function __construct() {
		$this->load->database();
	}//check avilable medicine stock
	public function get_available_medicine($medicine_id) {
        $query = $this->db->get_where('view_available_stock', array('medicine_id' => $medicine_id));
        $row =  $query->row_array();
		//echo $this->db->last_query();
		return $row['available_quantity'];
    }
    //Items
	public function get_all_items() {
		$query = $this->db->get('item');
		return $query->result_array();
	}
	public function get_item_name(){
		$items = $this->get_items();
		$item_name = array();
		foreach($items as $item){
			$item_name[$item['item_id']] = $item['item_name'];
		}
		return $item_name;
	}
    public function get_items() {
		$query = $this->db->get('view_available_stock');
		//echo $this->db->last_query();
		return $query->result_array();
	}
	public function get_available_items() {
		$query = $this->db->get('view_available_stock');
		return $query->result_array();
	}
	public function get_item($item_id) {
        $query = $this->db->get_where('view_available_stock', array('item_id' => $item_id));
        return $query->row_array();
    }
	public function get_item_detail($item_name) {
    	$query = $this->db->get_where('item', array('item_name' => $item_name));
        return $query->row_array();
    }
    public function get_available_quantity($item_id){
		$query = $this->db->get_where('view_available_stock', array('item_id' => $item_id));
		$row = $query->row_array();
		$available_quantity = $row['available_quantity'];
		return $available_quantity;
	}
    public function insert_item() {
        $data['item_name'] = $this->input->post('item_name');
        $data['desired_stock'] = $this->input->post('desired_stock');
        $data['mrp'] = $this->input->post('mrp');
        $data['barcode'] = $this->input->post('barcode');
        $this->db->insert('item', $data);
		return $this->db->insert_id();
    }
    public function delete_item($item_id) {
		$this->db->delete('item', array('item_id' => $item_id));
    }
    public function update_item() {
		$item_id = $this->input->post('item_id');
		$data['item_id'] = $this->input->post('item_id');
		$data['item_name'] = $this->input->post('item_name');
		$data['desired_stock'] = $this->input->post('desired_stock');
		$data['mrp'] = $this->input->post('mrp');
      $data['barcode'] = $this->input->post('barcode');
		//$data['sync_status'] = 0;
		$this->db->update('item', $data, array('item_id' =>  $item_id));
		//echo $this->db->last_query();
	}
	 public function update_item_medicine_id($medicine_id,$item_id) {
		$data['medicine_id']=$medicine_id;
		$this->db->update('item', $data, array('item_id' =>  $item_id));
		//echo $this->db->last_query();
	}
	//change medicine_id in ck_item
	public function link_medicine_to_item($item_id,$medicine_id){
		$data['medicine_id'] = $medicine_id;
		$this->db->update('item', $data, array('item_id' =>  $item_id));
		//echo $this->db->last_query();
	}
	//get medicine_id
	public function get_medicine_id($item_id) {
        $query = $this->db->get_where('item', array('item_id' => $item_id));
        $row =  $query->row_array();
		return $row['medicine_id'];
    }
    //Suppliers
    public function get_suppliers() {
		$query = $this->db->get_where('view_supplier');
		//echo $this->db->last_query();
		return $query->result_array();
	}
    public function get_supplier($supplier_id) {
		$query = $this->db->get_where('view_supplier', array('supplier_id' => $supplier_id));
		//echo $this->db->last_query();
		return $query->row_array();
	}
    public function insert_supplier($contact_id) {
		$data['contact_id'] = $contact_id;
		$this->db->insert('supplier', $data);
		//echo $this->db->last_query();
	}
    public function delete_supplier($supplier_id) {
		$data['is_deleted'] = 1;
		$this->db->update('supplier', $data, array('supplier_id' =>  $supplier_id));
	}
	//Purchase
    public function get_purchases($selected_items = NULL,$from_date = NULL,$to_date = NULL,$bill_no=NULL) {
		if($selected_items != NULL && $selected_items != 0){
			$this->db->where('item_id IN ('.$selected_items.')');
		}
		if($from_date != NULL){
			$from_date = date('Y-m-d',strtotime($from_date));
			$this->db->where("purchase_date >= ",$from_date);
		}
		if($to_date != NULL){
			$to_date = date('Y-m-d',strtotime($to_date));
			$this->db->where("purchase_date <= ",$to_date);
		}
		if($bill_no != NULL){
			$this->db->where("bill_no = ",$bill_no);
		}

        $this->db->order_by("purchase_date","asc");
        $query = $this->db->get('view_purchase');
		//echo $this->db->last_query();
		return $query->result_array();
	}
    public function get_purchase($purchase_id) {
        $query = $this->db->get_where('view_purchase', array('purchase_id' => $purchase_id));
		return $query->row_array();
	}
	public function get_remain_quantity($item_id){
		$query = $this->db->get_where('view_purchase', array('item_id' => $item_id));
		$query = $this->db->query("SELECT * FROM ".$this->db->dbprefix('view_purchase') ." WHERE remain_quantity > 0 and item_id =".$item_id);
		$row = $query->row_array();
		return $query->result_array();
	}
	public function get_purchase_total($selected_items = NULL,$from_date = NULL,$to_date = NULL) {
		if($selected_items != NULL && $selected_items != 0){
			$this->db->where('item_id IN ('.$selected_items.')');
		}
		if($from_date != NULL){
			$from_date = date('Y-m-d',strtotime($from_date));
			$this->db->where("purchase_date >= ",$from_date);
		}
		if($to_date != NULL){
			$to_date = date('Y-m-d',strtotime($to_date));
			$this->db->where("purchase_date <= ",$to_date);
		}
		$this->db->select('purchase_date, bill_no, SUM(cost_price) as total');
		$this->db->group_by('purchase_date,bill_no');
        $query = $this->db->get('view_purchase');
		//echo $this->db->last_query();
        return $query->result_array();
    }
  /*  public function add_purchase() {
        //multiple item purchase
		$data['purchase_date'] = date("Y-m-d",strtotime($this->input->post('purchase_date')));
		$data['bill_no'] = $this->input->post('bill_no');
		$data['quantity'] =$this->input->post('quantity');
		$data['remain_quantity'] = $this->input->post('quantity');
		$data['supplier_id'] = $this->input->post('supplier_id');
		$data['cost_price'] = $this->input->post('cost_price');
		$data['available_purchase_quantity'] = $this->input->post('quantity');
		$data['item_id'] = $this->input->post('item_id');;
			$this->db->insert('purchase', $data);
			//echo $this->db->last_query();
			//echo "<br/>";

	}*/
	public function get_new_bill_no(){
		$this->db->select_max('bill_no');
		$query = $this->db->get('purchase');
		$row = $query->row();
		$last_bill_no= $row->bill_no;
		return $last_bill_no + 1;
	}
	public function add_purchase($data) {
		$this->db->insert('purchase', $data);
	}
   /* public function update_purchase() {
        $purchase_id = $this->input->post('purchase_id');
        $data['purchase_id'] = $this->input->post('purchase_id');
        $data['purchase_date'] = date("Y-m-d", strtotime($this->input->post('purchase_date')));
        $data['bill_no'] = $this->input->post('bill_no');
		$data['quantity'] = $this->input->post('quantity');
		$data['supplier_id'] = $this->input->post('supplier_id');
		$data['cost_price'] = $this->input->post('cost_price');
		$data['item_id'] = $this->input->post('item_id');;
			$this->db->update('purchase', $data, array('purchase_id' =>  $purchase_id));
			//echo $this->db->last_query();
			//echo "<br/>";
	}*/
	public function update_purchase($data) {
		$purchase_id = $data['purchase_id'];
		$this->db->update('purchase', $data, array('purchase_id' =>  $purchase_id));
			//echo $this->db->last_query();
	}
    public function delete_purchase($purchase_id) {
            $this->db->delete('purchase', array('purchase_id' => $purchase_id));
        }
    public function insert_sell($sell_no,$sell_date,$patient_id,$discount) {
		$data['sell_no'] = $sell_no;
		$data['sell_date'] = date("Y-m-d H:i:s",strtotime($sell_date));
		$data['patient_id'] = $patient_id;
		$data['discount'] = $discount;
		//$data['available_sold_quantity'] = $quantity;
		$this->db->insert('sell', $data);
		//echo $this->db->last_query();
		$sell_id = $this->db->insert_id();
		return $sell_id;
	}
	public function update_sell($sell_id,$sell_no,$sell_date,$patient_id,$discount) {
		$data['sell_no'] = $sell_no;
		$data['sell_date'] = date("Y-m-d H:i:s",strtotime($sell_date));
		$data['patient_id'] = $patient_id;
		$data['discount'] = $discount;
		$this->db->update('sell', $data,array('sell_id'=>$sell_id));
	}
    public function update_sell_amount($sell_id, $amount) {
        $query = $this->db->get_where('sell', array('sell_id' => $sell_id));
        $row = $query->row();
        if ($row)
            $sell_amount = $row->sell_amount;
        else
            $sell_amount = 0;

        $data['sell_amount'] = $amount + $sell_amount;
        $this->db->update('sell', $data, array('sell_id' =>  $sell_id));

    }
    public function insert_sell_detail($sell_id,$item_id,$quantity,$sell_price) {
		//Check if this item is already added in this Sell or not.
		$data['item_id'] = $item_id;
		$data['sell_id'] = $sell_id;
		$quantity = $quantity;
		$data['sell_price'] = $sell_price;

		$query = $this->db->get_where('sell_detail', array('sell_id' => $sell_id,'item_id'=>$data['item_id']));
		$row = $query->row();
		if ($row){
			//Update the existing row
			$data['quantity'] = $quantity + $row->quantity;
			$data['available_sold_quantity'] = $data['quantity'];
			$data['sell_amount'] = $data['sell_price'] * $data['quantity'];
			$amount = $data['sell_price'] * $quantity;
			$this->db->update('sell_detail', $data, array('sell_id' => $sell_id,'item_id'=>$data['item_id']));
			//echo $this->db->last_query();
		}else{
			$data['quantity'] = $quantity ;
			$data['available_sold_quantity']=$quantity ;
			$data['sell_amount'] = $data['sell_price'] * $data['quantity'];
			$amount = $data['sell_amount'];
			$this->db->insert('sell_detail', $data);
			//echo $this->db->last_query();
		}
        $this->update_sell_amount($sell_id,$amount);
    }
	public function get_item_from_medicine_id($medicine_id){
		$query = $this->db->get_where('item', array('medicine_id' => $medicine_id));
		return $query->row_array();
	}
	public function add_medicine($sell_id,$medicine_id,$quantity) {
		//Get Item from Medicine ID
		$item = $this->get_item_from_medicine_id($medicine_id);
		$item_id = $item['item_id'];
		$item_price = $item['mrp'];

		//Check if this item is already added in this Sell or not.
		$data['item_id'] = $item_id;
		$data['sell_id'] = $sell_id;
		$data['sell_price'] = $item_price;

		$query = $this->db->get_where('sell_detail', array('sell_id' => $sell_id,'item_id'=>$item_id));
		$row = $query->row();
		if ($row){
			//Update the existing row
			$data['quantity'] = $quantity + $row->quantity;
			$data['sell_amount'] = $data['sell_price'] * $data['quantity'];
			$amount = $data['sell_price'] * $quantity;
			$this->db->update('sell_detail', $data, array('sell_id' => $sell_id,'item_id'=>$item_id));
			//echo $this->db->last_query();
		}else{
			$data['quantity'] = $quantity ;
			$data['sell_amount'] = $data['sell_price'] * $data['quantity'];
			$amount = $data['sell_amount'];
			$this->db->insert('sell_detail', $data);
			//echo $this->db->last_query();
		}
        $this->update_sell_amount($sell_id,$amount);
    }
	public function is_item_inuse($item_id) {
		$message=array();
		$query = $this->db->get_where('sell_detail', array('item_id' => $item_id));
        $row = $query->row_array();
		if($row){
			$message[]="Sell";
		}
		$query = $this->db->get_where('sell_return', array('item_id' => $item_id));
        $row = $query->row_array();
		if($row){
			$message[]="sell return";
		}
		$query = $this->db->get_where('opening_stock', array('item_id' => $item_id));
        $row = $query->row_array();
		if($row){
			$message[]="opening stock";
		}
		$query = $this->db->get_where('purchase', array('item_id' => $item_id));
        $row = $query->row_array();
		if($row){
			$message[]="purchase";
		}
		$query = $this->db->get_where('purchase_return', array('item_id' => $item_id));
        $row = $query->row_array();
		if($row){
			$message[]="purchase return";
		}

		return $message;
	}
	public function get_sell_id($sell_no) {
		$query = $this->db->get_where('sell', array('sell_no' => $sell_no));
        $row = $query->row_array();
		return $row;
	}
	public function get_sell_detail_id_row($sell_id,$item_id) {
		$query = $this->db->get_where('sell_detail', array('sell_id' => $sell_id,'item_id'=>$item_id));
        $row = $query->row_array();
		return $row;
	}
	public function get_sold_quantity($sell_detail_id) {
        $sql = 'SELECT a.available_sold_quantity,b.item_name,a.quantity FROM '. $this->db->dbprefix('sell_detail') . ' as a,'. $this->db->dbprefix('item') . ' as b,'. $this->db->dbprefix('sell') .' as s WHERE a.item_id = b.item_id AND s.sell_id=a.sell_id AND a.sell_detail_id = ?';
        $query = $this->db->query($sql,$sell_detail_id);
		//echo $this->db->last_query();
		return $query->row_array();
    }
	//update avilable sold quantity to default
	public function update_sold_quantity_to_default($qty,$sell_detail_id) {
		$data['available_sold_quantity']=$qty;
		$this->db->update('sell_detail', $data,array('sell_detail_id'=>$sell_detail_id));
	}
	public function calculate_available_sold_quantity($sell_detail_id) {
		//geting last available_quantity
       $sell_detail=$this->get_sold_quantity($sell_detail_id);
	   $available_sold_quantity=$sell_detail['available_sold_quantity'];
	   $quantity=$this->input->post('quantity');

			//Update the available_sold_quantity
			$data['available_sold_quantity']=$available_sold_quantity-$quantity;
			$this->db->update('sell_detail', $data,array('sell_detail_id'=>$sell_detail_id));

    }

    public function get_sell_details($sell_id) {
        $sql = 'SELECT a.sell_detail_id,b.item_name,b.barcode,a.quantity,a.sell_price,a.sell_amount FROM '. $this->db->dbprefix('sell_detail') . ' as a,'. $this->db->dbprefix('item') . ' as b WHERE a.item_id = b.item_id AND a.sell_id = ?';
        $query = $this->db->query($sql,$sell_id);
		//echo $this->db->last_query();
        return $query->result_array();
    }
    public function get_sells() {
        $sql = 'Select a.sell_no,a.sell_id,a.sell_date,s.item_id,i.item_name,s.quantity,a.patient_id,a.sell_amount,a.discount,c.first_name,c.middle_name,c.last_name
                  from ' . $this->db->dbprefix('sell') . ' as a
                       LEFT OUTER JOIN ' . $this->db->dbprefix('sell_detail') . ' as s ON a.sell_id = s.sell_id
                       LEFT OUTER JOIN ' . $this->db->dbprefix('item') . ' as i ON i.item_id = s.item_id
                       LEFT OUTER JOIN ' . $this->db->dbprefix('patient') . ' as b ON a.patient_id = b.patient_id
                       LEFT OUTER JOIN ' . $this->db->dbprefix('contacts') . ' as c ON c.contact_id = b.contact_id
					   ORDER BY a.sell_date DESC';
        $query = $this->db->query($sql);
		//echo $this->db->last_query();
        return $query->result_array();
    }
    public function get_sell($sell_id) {
        $sql = 'Select a.sell_no,a.sell_id,a.sell_date,a.discount,a.patient_id,a.sell_amount,c.first_name,c.middle_name,c.last_name
                  from ' . $this->db->dbprefix('sell') . ' as a
                       LEFT OUTER JOIN ' . $this->db->dbprefix('patient') . ' as b ON a.patient_id = b.patient_id
                       LEFT OUTER JOIN ' . $this->db->dbprefix('contacts') . ' as c ON c.contact_id = b.contact_id
                 where a.sell_id=' . $sell_id;
        $query = $this->db->query($sql);
		//echo $this->db->last_query();
        return $query->row_array();
    }
	public function get_new_sell_no(){
		$this->db->select_max('sell_no');
		$query = $this->db->get('sell');
		$row = $query->row();
		$last_sell_no= $row->sell_no;
		return $last_sell_no + 1;
	}
    public function delete_sell_detail($sell_detail_id) {
		$query = $this->db->get_where('sell_detail', array('sell_detail_id' => $sell_detail_id));
		$row = $query->row();
		$sell_id = $row->sell_id;
		$amount = (-1)* $row->sell_amount;
		$this->update_sell_amount($sell_id,$amount);

        $this->db->delete('sell_detail', array('sell_detail_id' => $sell_detail_id));
    }
    public function get_stock_report() {
        $query = $this->db->get('view_stock');
        return $query->result_array();
    }
	public function get_sell_receipt_template(){
		$query = $this->db->get_where('receipt_template', array('is_default' => 1,'type'=>'sell'));
        $row = $query->row_array();
		return $row;
	}
	public function get_sell_report($from_date,$to_date,$selected_items,$group_by){
		$this->db->where('DATE(sell_date) >=' , $from_date);
		$this->db->where('DATE(sell_date) <=' , $to_date);
		if(!empty($selected_items)){
			$this->db->where_in('item_id',$selected_items);
		}
		if($group_by != "none"){
			$this->db->order_by($group_by);
		}
		$query = $this->db->get('view_sell_report');
		//echo $this->db->last_query();
        return $query->result_array();
	}
	//update avilable purchased quantity to default
	public function update_purchase_quantity_to_default($qty,$purchase_id) {
		$data['available_purchase_quantity']=$qty;
		$this->db->update('purchase', $data,array('purchase_id'=>$purchase_id));
	}
	public function calculate_available_purchased_quantity($purchase_id) {
		//geting last available_quantity
       $purchase_deatil=$this->get_purchase($purchase_id);
	   $available_purchase_quantity=$purchase_deatil['available_purchase_quantity'];
	   $quantity=$this->input->post('quantity');

			//Update the available_sold_quantity
			$data['available_purchase_quantity']=$available_purchase_quantity-$quantity;
			$this->db->update('purchase', $data,array('purchase_id'=>$purchase_id));
			//echo $this->db->last_query();
    }

	public function get_purchase_returns($selected_items = NULL,$from_date = NULL,$to_date = NULL){
		if($selected_items != NULL && $selected_items != 0){
			$this->db->where('item_id IN ('.$selected_items.')');
		}
		if($from_date != NULL){
			$from_date = date('Y-m-d',strtotime($from_date));
			$this->db->where("return_date >= ",$from_date);
		}
		if($to_date != NULL){
			$to_date = date('Y-m-d',strtotime($to_date));
			$this->db->where("return_date <= ",$to_date);
		}
        $this->db->order_by("return_date","asc");
        $query = $this->db->get('view_purchase_return');
		//echo $this->db->last_query();
		return $query->result_array();
	}
	public function get_purchase_returns_total($selected_items = NULL,$from_date = NULL,$to_date = NULL) {
		if($selected_items != NULL && $selected_items != 0){
			$this->db->where('item_id IN ('.$selected_items.')');
		}

		if($from_date != NULL){
			$from_date = date('Y-m-d',strtotime($from_date));
			$this->db->where("return_date >= ",$from_date);
		}
		if($to_date != NULL){
			$to_date = date('Y-m-d',strtotime($to_date));
			$this->db->where("return_date <= ",$to_date);
		}
		$this->db->select('return_date, bill_no, SUM(price) as total');
		$this->db->group_by('return_date,bill_no');
        $query = $this->db->get('view_purchase_return');
		//echo $this->db->last_query();
        return $query->result_array();
    }
	public function get_purchase_id($bill_no,$item_id){
		$query = $this->db->get_where('purchase', array('bill_no' => $bill_no,'item_id'=>$item_id));
		//echo $this->db->last_query();
		return $query->row_array();
	}
	public function get_purchase_return($return_id){
		$query = $this->db->get_where('view_purchase_return', array('return_id' => $return_id));
		return $query->row_array();
	}
	public function save_purchase_return() {
        $data['return_date'] = date("Y-m-d",strtotime($this->input->post('return_date')));
        $data['bill_no'] = $this->input->post('bill_no');
		$data['item_id'] = $this->input->post('item_id');
		$data['quantity'] = $this->input->post('quantity');
		$data['supplier_id'] = $this->input->post('supplier_id');
		$data['price'] = $this->input->post('price');
		$this->db->insert('purchase_return', $data);
		//echo $this->db->last_query();
	}
	public function update_purchase_return() {
        $return_id = $this->input->post('return_id');

        $data['return_id'] = $this->input->post('return_id');
        $data['return_date'] = date("Y-m-d", strtotime($this->input->post('return_date')));
        $data['bill_no'] = $this->input->post('bill_no');
		$data['item_id'] = $this->input->post('item_id');
		$data['quantity'] = $this->input->post('quantity');
		$data['supplier_id'] = $this->input->post('supplier_id');
		$data['price'] = $this->input->post('price');
		$this->db->update('purchase_return', $data, array('return_id' =>  $return_id));
    }
	public function delete_return_purchase($return_id){
		$this->db->delete('purchase_return', array('return_id' => $return_id));
	}
	public function get_sell_returns($selected_items = NULL,$from_date = NULL,$to_date = NULL){
		if($selected_items != NULL && $selected_items != 0){
			$this->db->where('item_id IN ('.$selected_items.')');
		}
		if($from_date != NULL){
			$from_date = date('Y-m-d',strtotime($from_date));
			$this->db->where("return_date >= ",$from_date);
		}
		if($to_date != NULL){
			$to_date = date('Y-m-d',strtotime($to_date));
			$this->db->where("return_date <= ",$to_date);
		}

		$this->db->order_by("return_date","asc");
        $query = $this->db->get('view_sell_return');
		//echo $this->db->last_query();
		return $query->result_array();
	}
	public function get_sell_returns_total($selected_items = NULL,$from_date = NULL,$to_date = NULL) {
		if($selected_items != NULL && $selected_items != 0){
			$this->db->where('item_id IN ('.$selected_items.')');
		}
		if($from_date != NULL){
			$from_date = date('Y-m-d',strtotime($from_date));
			$this->db->where("return_date >= ",$from_date);
		}
		if($to_date != NULL){
			$to_date = date('Y-m-d',strtotime($to_date));
			$this->db->where("return_date <= ",$to_date);
		}
		$this->db->select('return_date, bill_no, SUM(price) as total');
		$this->db->group_by('return_date,bill_no');
        $query = $this->db->get('view_sell_return');
		//echo $this->db->last_query();
        return $query->result_array();
    }
	public function get_sell_return($return_id){
		$query = $this->db->get_where('view_sell_return', array('return_id' => $return_id));
		return $query->row_array();
	}
	public function save_sell_return() {
        $data['return_date'] = date("Y-m-d",strtotime($this->input->post('return_date')));
        $data['bill_no'] = $this->input->post('bill_no');
		$data['item_id'] = $this->input->post('item_id');
		$data['quantity'] = $this->input->post('quantity');
		$data['patient_id'] = $this->input->post('patient_id');
		$data['price'] = $this->input->post('price');
		$this->db->insert('sell_return', $data);
		//echo $this->db->last_query();
	}
	public function update_sell_return() {
        $return_id = $this->input->post('return_id');

        $data['return_date'] = date("Y-m-d", strtotime($this->input->post('return_date')));
        $data['bill_no'] = $this->input->post('bill_no');
		$data['item_id'] = $this->input->post('item_id');
		$data['quantity'] = $this->input->post('quantity');
		$data['patient_id'] = $this->input->post('patient_id');
		$data['price'] = $this->input->post('price');
		$this->db->update('sell_return', $data, array('return_id' =>  $return_id));
		//echo $this->db->last_query();
    }
	public function delete_sell_return($return_id){
		$this->db->delete('sell_return', array('return_id' => $return_id));
	}
	public function get_opening_stocks($selected_items){
		if($selected_items != NULL){
			$this->db->where('item_id IN ('.$selected_items.')');
		}
		$this->db->order_by("added_date","desc");
        $query = $this->db->get('view_opening_stock');
		//echo $this->db->last_query();
		return $query->result_array();
	}
	public function get_opening_stock($stock_id){
		$query = $this->db->get_where('view_opening_stock', array('stock_id' => $stock_id));
		return $query->row_array();
	}
	public function add_opening_stock(){
		$data['added_date'] = date("Y-m-d",strtotime($this->input->post('added_date')));
		$data['item_id'] = $this->input->post('item_id');
		$data['quantity'] = $this->input->post('quantity');
		$data['price'] = $this->input->post('price');
		$this->db->insert('opening_stock', $data);
	}
	public function update_opening_stock($stock_id){
		$stock_id = $this->input->post('stock_id');

        $data['added_date'] = date("Y-m-d",strtotime($this->input->post('added_date')));
		$data['item_id'] = $this->input->post('item_id');
		$data['quantity'] = $this->input->post('quantity');
		$data['price'] = $this->input->post('price');
		$this->db->update('opening_stock', $data, array('stock_id' =>  $stock_id));
		//echo $this->db->last_query();
	}
	public function delete_opening_stock($stock_id){
		$this->db->delete('opening_stock', array('stock_id' => $stock_id));
	}
	public function delete_sell_discount($sell_id){
		$data['discount'] = 0;
        $this->db->update('sell', $data, array('sell_id' =>  $sell_id));
	}
	public function get_medicines_not_link(){
		$query = $this->db->query("SELECT medicine_id,medicine_name
									  FROM ".$this->db->dbprefix('medicines')."
									  WHERE medicine_id  NOT IN (SELECT IFNULL(medicine_id,0) AS medicine_id from ".$this->db->dbprefix('item').")");

		//echo $this->db->last_query()."<br/>";
		$result = $query->result_array();
		return $result;
	}
}
?>
