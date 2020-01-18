ALTER TABLE %dbprefix%bill CHANGE total_amount total_amount DECIMAL(10,0) NOT NULL DEFAULT '0';
ALTER TABLE %dbprefix%bill CHANGE due_amount due_amount DECIMAL(11,2) NOT NULL DEFAULT '0';
ALTER TABLE %dbprefix%bill_detail CHANGE particular particular VARCHAR(50) NULL;
ALTER TABLE %dbprefix%bill_detail CHANGE quantity quantity INT(11) NULL;
ALTER TABLE %dbprefix%bill_detail CHANGE mrp mrp DECIMAL(10,2) NULL;
ALTER TABLE %dbprefix%bill_detail CHANGE amount amount DECIMAL(10,2) NULL;
ALTER TABLE %dbprefix%clinic CHANGE next_followup_days next_followup_days INT(11) NULL DEFAULT '15';
ALTER TABLE %dbprefix%invoice CHANGE currency_postfix currency_postfix CHAR(10) NULL DEFAULT '/-';
ALTER TABLE %dbprefix%invoice CHANGE currency_symbol currency_symbol VARCHAR(10) NULL;
ALTER TABLE %dbprefix%invoice CHANGE static_prefix static_prefix VARCHAR(10) NOT NULL DEFAULT '';
ALTER TABLE %dbprefix%payment CHANGE cheque_no cheque_no VARCHAR(50) NULL;
ALTER TABLE %dbprefix%payment CHANGE pay_amount pay_amount DECIMAL(10,0) NOT NULL DEFAULT '0';
ALTER TABLE %dbprefix%visit CHANGE notes notes TEXT NULL;
UPDATE %dbprefix%version SET current_version='0.4.8';