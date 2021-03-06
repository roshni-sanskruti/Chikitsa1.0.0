INSERT INTO %db_prefix%modules (module_name,module_display_name,module_description,module_status) VALUES ('stock', 'Medicine Store',"Manage Medicine Stock, Purchase and Sell", '1');
CREATE TABLE IF NOT EXISTS %db_prefix%item (item_id INT(11) NOT NULL AUTO_INCREMENT,item_name VARCHAR( 100 ) NOT NULL,desired_stock INT(11),PRIMARY KEY ( item_id ));
ALTER TABLE %db_prefix%item ADD mrp float(11,2) NOT NULL;
CREATE TABLE IF NOT EXISTS %db_prefix%supplier ( supplier_id INT(11) NOT NULL AUTO_INCREMENT , supplier_name VARCHAR( 100 ) NOT NULL , contact_number VARCHAR(100) , PRIMARY KEY ( supplier_id ) );
CREATE TABLE IF NOT EXISTS %db_prefix%purchase ( purchase_id INT(11) NOT NULL AUTO_INCREMENT , purchase_date DATE DEFAULT NULL , item_id INT(11) NOT NULL , quantity INT(11) NOT NULL , supplier_id INT(11) NOT NULL , cost_price DECIMAL(10,0) DEFAULT NULL , remain_quantity INT(11) NOT NULL , bill_no VARCHAR(255) NOT NULL , mrp FLOAT(11,2) NOT NULL , PRIMARY KEY (purchase_id) );
ALTER TABLE %db_prefix%purchase DROP mrp;
CREATE TABLE IF NOT EXISTS %db_prefix%sell ( sell_id INT(11) NOT NULL AUTO_INCREMENT , sell_date DATE NOT NULL , patient_id INT(11) NOT NULL , visit_id INT(11) NOT NULL , sell_amount DECIMAL(10,0) , PRIMARY KEY ( sell_id ) );
CREATE TABLE IF NOT EXISTS %db_prefix%sell_detail ( sell_detail_id INT(11) NOT NULL AUTO_INCREMENT , sell_id INT(11) NOT NULL , item_id INT(11) NOT NULL , quantity INT(11) NOT NULL , sell_price DECIMAL(10,0) , sell_amount DECIMAL(10,0) , PRIMARY KEY ( sell_detail_id ) );
CREATE OR REPLACE VIEW %db_prefix%view_purchase AS SELECT purchase_id,purchase_date,item_name,quantity,supplier_name,cost_price,a.item_id,a.supplier_id,a.remain_quantity,a.bill_no FROM %db_prefix%purchase AS a, %db_prefix%item AS b, %db_prefix%supplier AS c WHERE a.item_id = b.item_id AND a.supplier_id = c.supplier_id;
CREATE OR REPLACE VIEW %db_prefix%view_purchase_total AS SELECT purchase_date,bill_no,SUM(quantity*cost_price) AS total FROM %db_prefix%purchase GROUP BY bill_no;
CREATE OR REPLACE VIEW %db_prefix%view_stock AS SELECT a.item_id,a.item_name,a.desired_stock,(SELECT SUM(b.quantity) FROM %db_prefix%purchase b where a.item_id = b.item_id) purchase_quantity,(SELECT AVG(b.cost_price) FROM %db_prefix%purchase b where a.item_id = b.item_id) avg_purchase_price,(SELECT SUM(c.quantity) FROM %db_prefix%sell_detail c WHERE a.item_id = c.item_id) sell_quantity,(SELECT AVG(c.sell_price) FROM %db_prefix%sell_detail c WHERE a.item_id = c.item_id) avg_sell_price FROM %db_prefix%item a 
CREATE OR REPLACE VIEW %db_prefix%view_available_stock AS SELECT item.item_id,item.item_name,item.desired_stock,item.mrp,IFNULL((SELECT SUM(purchase.quantity) FROM %db_prefix%purchase AS purchase WHERE  item.item_id = purchase.item_id) ,0) - IFNULL((SELECT SUM(sell_detail.quantity) FROM %db_prefix%sell_detail AS sell_detail WHERE  item.item_id = sell_detail.item_id) ,0) available_quantity FROM %db_prefix%item AS item
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ('stock', '', 460,'stock', 'fa-medkit', 'Stock','stock');
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ('stock_item', 'stock', 100, 'stock/item', '', 'Items','stock');
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ('stock_supplier', 'stock', 200, 'stock/supplier', '', 'Suppliers','stock');
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ('stock_purchase', 'stock', 300, 'stock/purchase', '', 'Purchase','stock');
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ('stock_sell', 'stock', 50, 'stock/sell', '', 'Sell','stock');
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ('stock_all_sell', 'stock', 450, 'stock/all_sell', '', 'All Sell','stock');
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ('stock_stock_report', 'stock', 500, 'stock/stock_report', '', 'Stock Report','stock');
/*INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ('stock_purchase_report', 'stock', 600, 'stock/purchase_report', '', 'Purchase Report','stock');*/
INSERT INTO %db_prefix%receipt_template (template,is_default,template_name,type) VALUES ('Test', '1', 'Main', 'sell');
UPDATE %db_prefix%modules SET module_version = '0.0.3' WHERE module_name = 'stock';
UPDATE %db_prefix%receipt_template SET is_default = 0 WHERE type = 'sell';
INSERT INTO %db_prefix%receipt_template (template, is_default, template_name, type) VALUES ('<h1 style="text-align:center;">[clinic_name]</h1><h2 style="text-align:center;">[tag_line]</h2><p style="text-align:center;">[clinic_address]</p><span class="contact"><p style="text-align: center;"><b style="line-height: 1.42857143;">Landline : </b><span style="line-height: 1.42857143;">[landline]</span>  <b style="line-height: 1.42857143;">Mobile : </b><span style="line-height: 1.42857143;">[mobile]</span>  <b style="line-height: 1.42857143;">Email : </b><span style="text-align: center;"> [email]</span></p></span><hr id="null"><h3 style="text-align: center;"><u style="text-align: center;">RECEIPT</u></h3><span style="text-align: left;"><b>Date : </b>[bill_date]</span><span style="float: right;"><b>Receipt Number :</b> [bill_id]</span><p style="text-align: left;"><b style="text-align: left;">Patient Name: </b><span style="text-align: left;">[patient_name]<br></span></p><hr id="null" style="text-align: left;">Received fees for Professional services and other charges of our:<p><br></p><table style="width: 100%;margin-top: 25px;margin-bottom: 25px;border-collapse: collapse;border:1px solid black;"><thead><tr><td style="width: 400px;text-align: left;padding:5px;border:1px solid black;"><b style="width: 400px;text-align: left;">Item</b></td><td style="padding:5px;border:1px solid black;"><b>Quantity</b></td><td style="width: 100px;text-align:right;padding:5px;border:1px solid black;"><b>M.R.P.</b></td><td style="width: 100px;text-align:right;padding:5px;border:1px solid black;"><b>Amount</b></td></tr></thead><tbody>[col:item_name|quantity|sell_price|sell_amount]<tr><td colspan="3" style="padding:5px;border:1px solid black;">Total</td><td style="text-align:right;padding:5px;border:1px solid black;"><b>[total]</b></td></tr></tbody></table>Received with Thanks,<p>For [clinic_name]</p><p><br></p><p><br></p><p>Signature</p><hr id="null">', 1, 'Main', 'sell');
UPDATE %db_prefix%modules SET module_version = '0.0.4' WHERE module_name = 'stock';
UPDATE %db_prefix%modules SET module_version = '0.0.5' WHERE module_name = 'stock';
CREATE OR REPLACE VIEW %db_prefix%view_available_stock AS SELECT item.item_id,item.item_name,item.desired_stock,item.mrp,IFNULL((SELECT SUM(purchase.quantity) FROM %db_prefix%purchase AS purchase WHERE  item.item_id = purchase.item_id) ,0) - IFNULL((SELECT SUM(sell_detail.quantity) FROM %db_prefix%sell_detail AS sell_detail WHERE  item.item_id = sell_detail.item_id) ,0) - IFNULL((SELECT SUM(bill_detail.quantity) FROM %db_prefix%bill_detail AS bill_detail WHERE  item.item_id = bill_detail.item_id) ,0) available_quantity FROM %db_prefix%item AS item
UPDATE %db_prefix%modules SET module_version = '0.0.6' WHERE module_name = 'stock';
ALTER TABLE %db_prefix%sell ADD sell_no INT( 5 ) NOT NULL AFTER sell_id;
ALTER TABLE %db_prefix%sell ADD UNIQUE (sell_no);
UPDATE %db_prefix%sell SET sell_no = sell_id;
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ( 'stock_report', 'stock', 500, '#', NULL, 'Reports', 'stock');
UPDATE %db_prefix%navigation_menu SET parent_name = 'stock_report' WHERE menu_name = 'stock_stock_report';
UPDATE %db_prefix%navigation_menu SET parent_name = 'stock_report' WHERE menu_name = 'stock_purchase_report';
CREATE OR REPLACE VIEW %db_prefix%view_sell_report AS SELECT sell.sell_no,sell.sell_id,sell.sell_date,item.item_id,item.item_name,sell_detail.quantity,sell_detail.sell_price,sell_detail.sell_amount FROM %db_prefix%sell AS sell INNER JOIN %db_prefix%sell_detail AS sell_detail ON sell_detail.sell_id = sell.sell_id INNER JOIN %db_prefix%item AS item ON sell_detail.item_id = item.item_id;  
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ('stock_sell_report', 'stock_report', 700, 'stock/sell_report', '', 'All Sell Report','stock');
UPDATE %db_prefix%modules SET module_version = '0.0.7' WHERE module_name = 'stock';
ALTER TABLE %db_prefix%supplier ADD is_deleted INT NULL;
ALTER TABLE %db_prefix%item ADD is_deleted INT NULL;
UPDATE %db_prefix%modules SET module_version = '0.0.8' WHERE module_name = 'stock';
ALTER TABLE %db_prefix%sell CHANGE sell_date sell_date DATETIME NOT NULL ;
UPDATE %db_prefix%modules SET module_version = '0.0.9' WHERE module_name = 'stock';
CREATE TABLE IF NOT EXISTS %db_prefix%purchase_return ( return_id INT(11) NOT NULL AUTO_INCREMENT , return_date DATE DEFAULT NULL , item_id INT(11) NOT NULL , quantity INT(11) NOT NULL , supplier_id INT(11) NOT NULL , price DECIMAL(10,0) DEFAULT NULL ,  bill_no VARCHAR(255) NOT NULL , PRIMARY KEY (return_id) );
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ('purchase_return', 'stock', 350, 'stock/purchase_return', '', 'Purchase Return','stock');
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ('sell_return', 'stock', 450, 'stock/sell_return', '', 'Sell Return','stock');
CREATE OR REPLACE VIEW %db_prefix%view_purchase_return AS SELECT  a.return_id,a.return_date,b.item_name,a.quantity,c.supplier_name,		a.price,		a.item_id,		a.supplier_id,		a.bill_no    FROM %db_prefix%purchase_return AS a,         %db_prefix%item AS b, 		%db_prefix%supplier AS c WHERE a.item_id = b.item_id AND a.supplier_id = c.supplier_id;
CREATE OR REPLACE VIEW %db_prefix%view_available_stock AS SELECT item.item_id,		item.item_name,		item.desired_stock,item.mrp, 		IFNULL((SELECT SUM(purchase.quantity) FROM %db_prefix%purchase AS purchase WHERE  item.item_id = purchase.item_id) ,0)		- IFNULL((SELECT SUM(sell_detail.quantity) FROM %db_prefix%sell_detail AS sell_detail WHERE  item.item_id = sell_detail.item_id) ,0)		- IFNULL((SELECT SUM(purchase_return.quantity) FROM %db_prefix%purchase_return AS purchase_return WHERE item.item_id = purchase_return.item_id) ,0) 		+ IFNULL((SELECT SUM(sell_return.quantity) FROM %db_prefix%sell_return AS sell_return WHERE item.item_id = sell_return.item_id) ,0) 		available_quantity FROM %db_prefix%item AS item;
CREATE TABLE IF NOT EXISTS %db_prefix%sell_return ( return_id INT(11) NOT NULL AUTO_INCREMENT , return_date DATE DEFAULT NULL , item_id INT(11) NOT NULL , quantity INT(11) NOT NULL , patient_id INT(11) NOT NULL , price DECIMAL(10,0) DEFAULT NULL ,  bill_no VARCHAR(255) NULL , PRIMARY KEY (return_id) );
CREATE OR REPLACE VIEW %db_prefix%view_sell_return AS SELECT  a.return_id,        a.return_date,		b.item_name,		a.quantity,        CONCAT(IFNULL(c.first_name,''),' ',IFNULL(c.middle_name,''),' ',IFNULL(c.last_name,'')) patient_name,		a.price,		a.item_id,		a.patient_id,		a.bill_no       FROM %db_prefix%sell_return AS a,        %db_prefix%item AS b, 		%db_prefix%view_patient AS c   WHERE a.item_id = b.item_id     AND a.patient_id = c.patient_id;
UPDATE %db_prefix%modules SET module_version = '0.1.0' WHERE module_name = 'stock';
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text,required_module) VALUES ('opening_stock', 'stock', 750, 'stock/opening_stock', '', 'Opening Stock','stock');
CREATE TABLE IF NOT EXISTS %db_prefix%opening_stock ( stock_id INT(11) NOT NULL AUTO_INCREMENT , added_date DATE DEFAULT NULL , item_id INT(11) NOT NULL , quantity INT(11) NOT NULL , price DECIMAL(10,0) DEFAULT NULL ,  PRIMARY KEY (stock_id) );
CREATE OR REPLACE VIEW %db_prefix%view_opening_stock AS SELECT opening_stock.stock_id, opening_stock.added_date,       item.item_name,	 item.item_id,  opening_stock.quantity,	   opening_stock.price  FROM %db_prefix%opening_stock AS opening_stock,       %db_prefix%item AS item WHERE item.item_id = opening_stock.item_id;
UPDATE %db_prefix%modules SET module_version = '0.1.0' WHERE module_name = 'stock';
ALTER TABLE %db_prefix%supplier ADD contact_id INT( 11 ) NULL AFTER supplier_id;
ALTER TABLE %db_prefix%supplier CHANGE contact_id contact_id INT(11) NULL;.
INSERT INTO %db_prefix%contacts	(first_name,phone_number,second_number) SELECT supplier_name,contact_number,supplier_id FROM %db_prefix%supplier;
UPDATE %db_prefix%supplier a JOIN %db_prefix%contacts b ON a.supplier_id = b.second_number SET a.contact_id = b.contact_id WHERE a.contact_id IS NULL;
UPDATE %db_prefix%contacts a JOIN %db_prefix%supplier b ON a.contact_id = b.contact_id SET a.second_number = NULL;
INSERT INTO %dbprefix%contact_details (contact_id,type,detail) SELECT contact_id,'mobile',phone_number FROM %dbprefix%contacts WHERE (phone_number IS NOT NULL AND phone_number != '') AND contact_id IN (SELECT contact_id FROM %dbprefix%supplier);
CREATE OR REPLACE VIEW %db_prefix%view_supplier AS SELECT supplier.supplier_id, contacts.contact_id,contacts.title, contacts.first_name, contacts.middle_name, contacts.last_name, contacts.phone_number, contacts.second_number FROM %db_prefix%supplier AS supplier INNER JOIN %db_prefix%contacts AS contacts ON supplier.contact_id = contacts.contact_id WHERE IFNULL(supplier.is_deleted,0) != 1;
CREATE OR REPLACE VIEW %db_prefix%view_available_stock AS SELECT item.item_id, item.medicine_id,		item.item_name,		item.desired_stock,item.mrp, 		IFNULL((SELECT SUM(purchase.quantity) FROM %db_prefix%purchase AS purchase WHERE  item.item_id = purchase.item_id) ,0)		- IFNULL((SELECT SUM(sell_detail.quantity) FROM %db_prefix%sell_detail AS sell_detail WHERE  item.item_id = sell_detail.item_id) ,0)		- IFNULL((SELECT SUM(purchase_return.quantity) FROM %db_prefix%purchase_return AS purchase_return WHERE item.item_id = purchase_return.item_id) ,0) 		+ IFNULL((SELECT SUM(sell_return.quantity) FROM %db_prefix%sell_return AS sell_return WHERE item.item_id = sell_return.item_id) ,0)		+ IFNULL((SELECT SUM(opening_stock.quantity) FROM %db_prefix%opening_stock AS opening_stock WHERE item.item_id = opening_stock.item_id) ,0) 		available_quantity FROM %db_prefix%item AS item;
UPDATE %db_prefix%modules SET module_version = '0.1.1' WHERE module_name = 'stock';
ALTER TABLE %db_prefix%sell ADD discount DECIMAL NULL AFTER sell_amount;
UPDATE %db_prefix%receipt_template SET is_default = 0 WHERE type = 'sell';
INSERT INTO %db_prefix%receipt_template (template, is_default, template_name, type) VALUES ('<h1 style="text-align:center;">[clinic_name]</h1><h2 style="text-align:center;">[tag_line]</h2><p style="text-align:center;">[clinic_address]</p><span class="contact">	<p style="text-align: center;"><b style="line-height: 1.42857143;">Landline : </b><span style="line-height: 1.42857143;">[landline]</span>  <b style="line-height: 1.42857143;">Mobile : </b><span style="line-height: 1.42857143;">[mobile]</span>  <b style="line-height: 1.42857143;">Email : </b><span style="text-align: center;"> [email]</span></p></span><hr id="null"><h3 style="text-align: center;"><u style="text-align: center;">RECEIPT</u></h3><span style="text-align: left;"><b>Date : </b>[bill_date]</span><span style="float: right;"><b>Receipt Number :</b> [bill_id]</span><p style="text-align: left;"><b style="text-align: left;">Patient Name: </b><span style="text-align: left;">[patient_name]<br></span></p><hr id="null" style="text-align: left;">Received fees for Professional services and other charges of our:<p><br></p><table style="width: 100%;margin-top: 25px;margin-bottom: 25px;border-collapse: collapse;border:1px solid black;"><thead><tr><td style="width: 400px;text-align: left;padding:5px;border:1px solid black;"><b style="width: 400px;text-align: left;">Item</b></td><td style="padding:5px;border:1px solid black;"><b>Quantity</b></td><td style="width: 100px;text-align:right;padding:5px;border:1px solid black;"><b>M.R.P.</b></td><td style="width: 100px;text-align:right;padding:5px;border:1px solid black;"><b>Amount</b></td></tr></thead><tbody>[col:item_name|quantity|sell_price|sell_amount]	<tr><td colspan="3" style="padding:5px;border:1px solid black;">Discount</td><td style="text-align:right;padding:5px;border:1px solid black;"><b>[discount]</b></td></tr>	<tr><td colspan="3" style="padding:5px;border:1px solid black;">Total</td><td style="text-align:right;padding:5px;border:1px solid black;"><b>[total]</b></td></tr>	</tbody></table>	Received with Thanks,<p>For [clinic_name]</p><p><br></p><p><br></p><p>Signature</p>	<hr id="null">', 1, 'Main', 'sell');
ALTER TABLE %dbprefix%item ADD is_deleted INT NULL;
ALTER TABLE %dbprefix%opening_stock ADD is_deleted INT NULL;
ALTER TABLE %dbprefix%purchase ADD is_deleted INT NULL;
ALTER TABLE %dbprefix%purchase_return ADD is_deleted INT NULL;
ALTER TABLE %dbprefix%sell ADD is_deleted INT NULL;
ALTER TABLE %dbprefix%sell_detail ADD is_deleted INT NULL;
ALTER TABLE %dbprefix%sell_return ADD is_deleted INT NULL;
ALTER TABLE %dbprefix%supplier ADD is_deleted INT NULL;
ALTER TABLE %dbprefix%item ADD sync_status INT NULL;
ALTER TABLE %dbprefix%opening_stock ADD sync_status INT NULL;
ALTER TABLE %dbprefix%purchase ADD sync_status INT NULL;
ALTER TABLE %dbprefix%purchase_return ADD sync_status INT NULL;
ALTER TABLE %dbprefix%sell ADD sync_status INT NULL;
ALTER TABLE %dbprefix%sell_detail ADD sync_status INT NULL;
ALTER TABLE %dbprefix%sell_return ADD sync_status INT NULL;
ALTER TABLE %dbprefix%supplier ADD sync_status INT NULL;
CREATE OR REPLACE VIEW %db_prefix%view_stock AS SELECT a.item_id,       a.item_name,	   a.desired_stock,	   (SELECT SUM(b.quantity) FROM %db_prefix%purchase b where a.item_id = b.item_id) purchase_quantity,	   (SELECT SUM(d.quantity) FROM %db_prefix%purchase_return d where a.item_id = d.item_id) purchase_return_quantity,	   (SELECT SUM(c.quantity) FROM %db_prefix%sell_detail c WHERE a.item_id = c.item_id) sell_quantity,	   (SELECT SUM(e.quantity) FROM %db_prefix%sell_return e where a.item_id = e.item_id) sell_return_quantity,	   (SELECT SUM(f.quantity) FROM %db_prefix%opening_stock f where a.item_id = f.item_id) opening_sto%db_prefix%quantity  FROM %db_prefix%item a;
CREATE OR REPLACE VIEW %db_prefix%view_purchase AS SELECT purchase_id,       purchase_date,	   item_name,	   quantity,	   CONCAT(IFNULL(d.first_name,''),' ',IFNULL(d.middle_name,''),' ', IFNULL(d.last_name,'')) AS supplier_name,	   cost_price,	   a.item_id,	   a.supplier_id,	   a.remain_quantity,	   a.bill_no   FROM %db_prefix%purchase AS a,       %db_prefix%item AS b,	   %db_prefix%supplier AS c,	   %db_prefix%contacts AS d WHERE a.item_id = b.item_id    AND a.supplier_id = c.supplier_id   AND c.contact_id = d.contact_id;
CREATE OR REPLACE VIEW %db_prefix%view_purchase_return AS SELECT  a.return_id,a.return_date,b.item_name,a.quantity,CONCAT(IFNULL(d.first_name,''),' ',IFNULL(d.middle_name,''),' ', IFNULL(d.last_name,'')) AS supplier_name,		a.price,		a.item_id,		a.supplier_id,		a.bill_no    FROM %db_prefix%purchase_return AS a,         %db_prefix%item AS b, 		%db_prefix%supplier AS c,	   %db_prefix%contacts AS d WHERE a.item_id = b.item_id AND a.supplier_id = c.supplier_id   AND c.contact_id = d.contact_id;
UPDATE %db_prefix%modules SET module_version = '0.1.2' WHERE module_name = 'stock';
UPDATE %db_prefix%navigation_menu SET menu_text = 'stock' WHERE menu_name = 'stock';
UPDATE %db_prefix%navigation_menu SET menu_text = 'items' WHERE menu_name = 'stock_item';
UPDATE %db_prefix%navigation_menu SET menu_text = 'supplier' WHERE menu_name = 'stock_supplier';
UPDATE %db_prefix%navigation_menu SET menu_text = 'purchase' WHERE menu_name = 'stock_purchase';
UPDATE %db_prefix%navigation_menu SET menu_text = 'sell' WHERE menu_name = 'stock_sell';
UPDATE %db_prefix%navigation_menu SET menu_text = 'all_sell' WHERE menu_name = 'stock_all_sell';
UPDATE %db_prefix%navigation_menu SET menu_text = 'stock_report' WHERE menu_name = 'stock_stock_report';
UPDATE %db_prefix%navigation_menu SET menu_text = 'stock_purchase_report' WHERE menu_name = 'stock_purchase_report';
UPDATE %db_prefix%navigation_menu SET menu_text = 'reports' WHERE menu_name = 'stock_report';
UPDATE %db_prefix%navigation_menu SET menu_text = 'stock_sell_report' WHERE menu_name = 'stock_sell_report';
UPDATE %db_prefix%navigation_menu SET menu_text = 'purchase_return' WHERE menu_name = 'purchase_return';
UPDATE %db_prefix%navigation_menu SET menu_text = 'sell_return' WHERE menu_name = 'sell_return';
UPDATE %db_prefix%navigation_menu SET menu_text = 'opening_stock' WHERE menu_name = 'opening_stock';
UPDATE %db_prefix%modules SET module_version = '0.1.4' WHERE module_name = 'stock';
ALTER TABLE %db_prefix%item ADD medicine_id INT(11) NULL;
CREATE OR REPLACE VIEW %db_prefix%view_supplier AS select supplier.supplier_id AS supplier_id,contacts.contact_id AS contact_id,contacts.title AS title,contacts.first_name AS first_name,contacts.middle_name AS middle_name,contacts.last_name AS last_name,contacts.phone_number AS phone_number,contacts.second_number AS second_number,contacts.email AS email,contacts.type AS type,contacts.address_line_1 AS address_line_1,contacts.address_line_2 AS address_line_2,contacts.city AS city,contacts.state as state,contacts.postal_code AS postal_code,contacts.country AS country from (%db_prefix%supplier supplier join %db_prefix%contacts contacts on((supplier.contact_id = contacts.contact_id))) where (ifnull(supplier.is_deleted,0) <> 1);
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ('stock_report', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ('purchase_return', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ('sell_return', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ('opening_stock', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ('stock_item', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ('stock_supplier', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ('stock_purchase', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ('stock_sell', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ('stock_all_sell', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ('stock_stock_report', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ('stock_purchase_report', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (m nu_name, category_name, allow) VALUES ('stock', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_report', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'purchase_return', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'sell_return', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'opening_stock', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_item', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_supplier', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_purchase', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_sell', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_all_sell', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_stock_report', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_purchase_report', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_sell_report', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_stock_report', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_purchase_report', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_sell_report', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (id, menu_name, category_name, allow) VALUES (NULL, 'stock_sell', 'System Administrator', '1');
INSERT INTO %db_prefix%navigation_menu (menu_name, parent_name, menu_order, menu_url, menu_icon, menu_text, required_module, is_deleted, sync_status) VALUES ('view_prescription', 'stock', '50', 'prescription/view_prescription', NULL, 'view_prescription', NULL, NULL, NULL);
ALTER TABLE %db_prefix%supplier ADD email VARCHAR(150) NULL;
ALTER TABLE %db_prefix%supplier ADD type VARCHAR(50) NULL;
ALTER TABLE %db_prefix%supplier ADD address_line_1 VARCHAR(150) NULL;
ALTER TABLE %db_prefix%supplier ADD address_line_2 VARCHAR(150) NULL;
ALTER TABLE %db_prefix%supplier ADD area VARCHAR(25) NULL;
ALTER TABLE %db_prefix%supplier ADD city VARCHAR(50) NULL;
ALTER TABLE %db_prefix%supplier ADD state VARCHAR(50) NULL;
ALTER TABLE %db_prefix%supplier ADD postal_code VARCHAR(50) NULL;
ALTER TABLE %db_prefix%supplier ADD country VARCHAR(50) NULL;
CREATE OR REPLACE VIEW %db_prefix%view_available_stock AS SELECT item.item_id, item.medicine_id,		item.item_name,		item.desired_stock,item.mrp, 		IFNULL((SELECT SUM(purchase.quantity) FROM %db_prefix%purchase AS purchase WHERE  item.item_id = purchase.item_id) ,0)		- IFNULL((SELECT SUM(sell_detail.quantity) FROM %db_prefix%sell_detail AS sell_detail WHERE  item.item_id = sell_detail.item_id) ,0)		- IFNULL((SELECT SUM(purchase_return.quantity) FROM %db_prefix%purchase_return AS purchase_return WHERE item.item_id = purchase_return.item_id) ,0) 		+ IFNULL((SELECT SUM(sell_return.quantity) FROM %db_prefix%sell_return AS sell_return WHERE item.item_id = sell_return.item_id) ,0)		+ IFNULL((SELECT SUM(opening_stock.quantity) FROM %db_prefix%opening_stock AS opening_stock WHERE item.item_id = opening_stock.item_id) ,0) 		available_quantity FROM %db_prefix%item AS item;
DELETE FROM %db_prefix%navigation_menu  WHERE menu_name = 'view_prescription';
UPDATE %db_prefix%modules SET module_version = '0.1.6' WHERE module_name = 'stock';
ALTER TABLE %db_prefix%item ADD barcode VARCHAR(100) NULL ; 
CREATE OR REPLACE VIEW %db_prefix%view_available_stock AS SELECT item.item_id, item.medicine_id,		item.item_name,item.barcode,		item.desired_stock,item.mrp, 		IFNULL((SELECT SUM(purchase.quantity) FROM %db_prefix%purchase AS purchase WHERE  item.item_id = purchase.item_id) ,0)		- IFNULL((SELECT SUM(sell_detail.quantity) FROM %db_prefix%sell_detail AS sell_detail WHERE  item.item_id = sell_detail.item_id) ,0)		- IFNULL((SELECT SUM(purchase_return.quantity) FROM %db_prefix%purchase_return AS purchase_return WHERE item.item_id = purchase_return.item_id) ,0) 		+ IFNULL((SELECT SUM(sell_return.quantity) FROM %db_prefix%sell_return AS sell_return WHERE item.item_id = sell_return.item_id) ,0)		+ IFNULL((SELECT SUM(opening_stock.quantity) FROM %db_prefix%opening_stock AS opening_stock WHERE item.item_id = opening_stock.item_id) ,0) 		available_quantity FROM %db_prefix%item AS item;
ALTER TABLE %db_prefix%purchase ADD `available_purchase_quantity` INT(11) NOT NULL; 
CREATE OR REPLACE VIEW %db_prefix%view_purchase AS SELECT purchase_id,purchase_date,item_name,quantity,supplier_name,cost_price,a.item_id,a.supplier_id,a.remain_quantity,a.bill_no,a.available_purchase_quantity FROM %db_prefix%purchase AS a, %db_prefix%item AS b, %db_prefix%supplier AS c WHERE a.item_id = b.item_id AND a.supplier_id = c.supplier_id;
ALTER TABLE %db_prefix%sell_detail ADD `available_sold_quantity` INT(11) NOT NULL ;