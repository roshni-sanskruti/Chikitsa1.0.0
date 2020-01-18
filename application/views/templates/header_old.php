<?php
/*
	This file is part of Chikitsa.

    Chikitsa is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Chikitsa is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Chikitsa.  If not, see <https://www.gnu.org/licenses/>.
*/
?>
<!DOCTYPE html>
<?php
	if(!isset($level)){
		$level = $this->session->userdata('category');
	}
	if(!isset($clinic_id)){
		$clinic_id = 1;
		if($this->session->userdata('clinic_id') != NULL ){
			$clinic_id = $this->session->userdata('clinic_id');
		}
		$this->db->where('clinic_id', $clinic_id);
		$query = $this->db->get('clinic');
		$clinic = $query->row_array();
	}
	if(!isset($active_modules)){
		//Active Modules
		$this->db->where('module_status', 1);
		$this->db->select('module_name');
		$query=$this->db->get('modules');
		$result =  $query->result_array();
		$active_modules = array();
		foreach($result as $row){
			$active_modules[]= $row['module_name'];
		}
	}

	if(!isset($user)){
		$user_id = $_SESSION['id'];
		$this->db->where('userid', $user_id);
		$query = $this->db->get('users');
		$user = $query->row_array();
	}

	if(!isset($login_page)){
		$this->db->where('ck_key', 'login_page');
		$query = $this->db->get('data');
		$data = $query->row_array();
		$login_page = $data['ck_value'];

		$parent_name="";
		$result_top_menu = $this->menu_model->find_menu($parent_name,$level);
		foreach ($result_top_menu as $top_menu){
			$id = $top_menu['id'];
			$parent_name = $top_menu['menu_name'];
			if($this->menu_model->has_access($top_menu['menu_name'],$level)){
				if($this->menu_model->is_module_active($top_menu['required_module'])){
					$result_sub_menu = $this->menu_model->find_menu($parent_name,$level);
					$rowcount= count($result_sub_menu);
					if($rowcount != 0){
						foreach ($result_sub_menu as $sub_menu){
							if($this->menu_model->has_access($sub_menu['menu_name'],$level)){
								if($this->menu_model->is_module_active($sub_menu['required_module'])){
									$login_page = $sub_menu['menu_url'];
									break;
								}
							}
						}
					}else{
						$login_page = $top_menu['menu_url'];
						break;
					}
				}
			}
		}
	}

?>
<html>
    <head>
        <title><?= $clinic['clinic_name'] .' - ' .$clinic['tag_line'];?></title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
		<link rel="shortcut icon"  href="<?= base_url() ?>/favicon.ico"/>

        <!-- BOOTSTRAP STYLES-->
		<link href="<?= base_url() ?>assets/css/bootstrap.min.css" rel="stylesheet" />
		<!-- JQUERY UI STYLES-->
		<link href="<?= base_url() ?>assets/css/jquery-ui-1.9.1.custom.min.css" rel="stylesheet" />
		<!-- FONTAWESOME STYLES-->
		<link href="<?= base_url() ?>assets/css/font-awesome.min.css" rel="stylesheet" />
        
		<!-- CHIKITSA STYLES-->
		<link href="<?= base_url() ?>assets/css/chikitsa.min.css" rel="stylesheet" />
		<!-- TABLE STYLES-->
		<link href="<?= base_url() ?>assets/js/dataTables/dataTables.bootstrap.min.css" rel="stylesheet" />
		<link href="<?= base_url() ?>assets/js/dataTables/responsive.dataTables.min.css" rel="stylesheet" />

		
		<!-- JQUERY SCRIPTS -->
		<script src="<?= base_url() ?>assets/js/jquery-1.11.3.min.js"></script>
		<!-- JQUERY UI SCRIPTS -->
		<script src="<?= base_url() ?>assets/js/jquery-ui.min.js"></script>
		<!-- BOOTSTRAP SCRIPTS -->
		<script src="<?= base_url() ?>assets/js/bootstrap.min.js"></script>
		<!-- METISMENU SCRIPTS -->
		<script src="<?= base_url() ?>assets/js/jquery.metisMenu.min.js"></script>
		<!-- DATA TABLE SCRIPTS -->
		<script src="<?= base_url() ?>assets/js/dataTables/jquery.dataTables.min.js"></script>
		<script src="<?= base_url() ?>assets/js/dataTables/dataTables.bootstrap.min.js"></script>
		<script src="<?= base_url() ?>assets/js/dataTables/moment.min.js"></script>
		<script src="<?= base_url() ?>assets/js/dataTables/datetime-moment.min.js"></script>
		<script src="<?= base_url() ?>assets/js/dataTables/dataTables.responsive.min.js"></script>
		<!-- TimePicker SCRIPTS-->
		<script src="<?= base_url() ?>assets/js/jquery.datetimepicker.min.js"></script>
		<link href="<?= base_url() ?>assets/js/jquery.datetimepicker.min.css" rel="stylesheet" />
		<!-- CHOSEN SCRIPTS-->
		<script src="<?= base_url() ?>assets/js/chosen.jquery.min.js"></script>
		<link href="<?= base_url() ?>assets/css/chosen.min.css" rel="stylesheet" />
		<!-- Lightbox SCRIPTS-->
		<script src="<?= base_url() ?>assets/js/lightbox.min.js"></script>
		<link href="<?= base_url() ?>assets/css/lightbox.min.css" rel="stylesheet" />
		 <!-- MORRIS CHART STYLES-->
		<link href="<?= base_url() ?>assets/js/morris/morris-0.4.3.min.css" rel="stylesheet" />
		<!-- MORRIS CHART SCRIPTS -->
		<script src="<?= base_url() ?>assets/js/morris/raphael-2.1.0.min.js"></script>
		<script src="<?= base_url() ?>assets/js/morris/morris.min.js"></script>
		<!-- Sketch SCRIPTS-->
		<script src="<?= base_url() ?>assets/js/sketch.min.js"></script>
		<!-- CUSTOM SCRIPTS -->
		<script src="<?= base_url() ?>assets/js/custom.min.js"></script>
		<!-- CUSTOM STYLES-->
		<link href="<?= base_url() ?>assets/css/custom.css" rel="stylesheet" />

		<link rel="stylesheet" href="<?= base_url() ?>assets/js/jsTree/themes/default/style.min.css" />
		<script src="<?= base_url() ?>assets/js/jsTree/jstree.min.js"></script>
    </head>
    <body>
        <div id="wrapper">
		<nav class="navbar navbar-default navbar-cls-top " role="navigation" style="margin-bottom: 0">
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".sidebar-collapse">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
				<?php if($clinic['clinic_logo'] != NULL){  ?>
					<a class="navbar-brand" style="padding:0px;background:#FFF;" href="<?= site_url($login_page); ?>">
						<img src="<?php echo base_url().$clinic['clinic_logo']; ?>" alt="Logo"  height="60"  />
					</a>
				<?php  }elseif($clinic['clinic_name'] != NULL){  ?>
					<a class="navbar-brand" href="<?= site_url($login_page); ?>">
						<?= $clinic['clinic_name'];?>
					</a>
				<?php  } else { ?>
					<a class="navbar-brand" href="<?= site_url($login_page); ?>">
						<?= $software_name;?>
					</a>
				<?php }  ?>
            </div>
			<div style="color: white;float:left;font-size: 16px;margin-left:25px;">
                    <h4><?php if($clinic['tag_line'] == NULL){
								echo $this->lang->line('tag_line');
							  }else {
								echo $clinic['tag_line'];
							  } ?>
					</h4>
            </div>
			<div style="color: white;padding: 15px 50px 5px 50px;float: right;font-size: 16px;">
				Welcome, <?=$user['name']; ?>
				<?php
					$new_messages = $this->menu_model->new_messages_count();
					if($new_messages > 0){
				?>
				<a data-notifications="<?=$new_messages;?>" href="<?=site_url("chat/index"); ?>" class="btn btn-primary square-btn-adjust"><i class="fa fa-bell" aria-hidden="true"></i></a>
				<?php } elseif($new_messages == 0) { ?>
				<a href="<?=site_url("chat/index");?>" class="btn btn-primary square-btn-adjust"><i class="fa fa-bell" aria-hidden="true"></i></a>
				<?php } ?>
				<?php if (in_array("centers", $active_modules)) { ?>
				<a href="<?=site_url("centers/change_center"); ?>" class="btn btn-primary square-btn-adjust">Change Center</a>
				<?php } ?>
				<a href="<?=site_url("admin/change_profile"); ?>" class="btn btn-primary square-btn-adjust">Change Profile</a>
				<a href="<?= site_url("login/logout"); ?>" class="btn btn-danger square-btn-adjust"><?php echo $this->lang->line('log_out');?></a>
			</div>
        </nav>
