UPDATE %db_prefix%navigation_menu SET menu_name = 'appointment_report' WHERE menu_text = "Appointment Report"; 
UPDATE %db_prefix%navigation_menu SET menu_name = 'bill_report' WHERE menu_text = "Bill Detail Report"; 
UPDATE %db_prefix%navigation_menu SET menu_name = 'clinic_detail' WHERE menu_text = "Clinic Detail"; 
UPDATE %db_prefix%navigation_menu SET menu_name = 'invoice_setting' WHERE menu_text = "Invoice";
INSERT INTO %db_prefix%modules (module_name, module_display_name,module_description, module_status,module_version) VALUES ('menu_access','Menu Access', 'User access system module', '1','0.0.1');
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text) VALUES ('menu_access', 'administration', '700', 'menu_access/index', '', 'menu_access');
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text) VALUES ('categories', 'administration', '350', 'menu_access/category', '', 'category');
UPDATE %db_prefix%menu_access SET menu_name = 'appointment_report' WHERE menu_name = "appointment report";
UPDATE %db_prefix%modules SET module_version = '0.0.2' WHERE module_name = 'menu_access';
UPDATE %db_prefix%navigation_menu SET parent_name = 'users' WHERE menu_name = 'menu_access';
UPDATE %db_prefix%navigation_menu SET parent_name = 'users' WHERE menu_name = 'categories';
INSERT INTO %db_prefix%navigation_menu (menu_name,parent_name,menu_order,menu_url,menu_icon,menu_text) VALUES ('special_access', 'users', '500', 'menu_access/special_access', '', 'special_access');
CREATE TABLE IF NOT EXISTS %db_prefix%special_access ( id int(11) NOT NULL AUTO_INCREMENT, category_name varchar(25) NOT NULL, access_name varchar(25) NOT NULL, allow int(1) NOT NULL, PRIMARY KEY (id));
ALTER TABLE %db_prefix%menu_access ADD is_deleted INT NULL;
ALTER TABLE %db_prefix%special_access ADD is_deleted INT NULL;
ALTER TABLE %db_prefix%menu_access ADD sync_status INT NULL;
ALTER TABLE %db_prefix%special_access ADD sync_status INT NULL;
UPDATE %db_prefix%modules SET module_version = '0.0.3' WHERE module_name = 'menu_access';
UPDATE %db_prefix%modules SET module_version = '0.0.4' WHERE module_name = 'menu_access';
UPDATE %db_prefix%navigation_menu SET menu_name = 'clinic_detail' WHERE menu_name = "clinic detail";
ALTER TABLE  %db_prefix%menu_access ADD UNIQUE( menu_name, category_name);
UPDATE %db_prefix%modules SET module_version = '0.0.5' WHERE module_name = 'menu_access';
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ( 'menu_access', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ( 'special_access', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ( 'categories', 'System Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ( 'menu_access', 'Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ( 'special_access', 'Administrator', '1');
INSERT INTO %db_prefix%menu_access (menu_name, category_name, allow) VALUES ( 'categories', 'Administrator', '1');
UPDATE %db_prefix%modules SET module_version = '0.0.6',activation_hook = NULL WHERE module_name = 'menu_access';
UPDATE %db_prefix%modules SET module_version = '0.0.7',activation_hook = NULL WHERE module_name = 'menu_access';
