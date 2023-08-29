insert /*+append*/into RC_RES_DETAIL
select /*+parallel(a,10)*/a.province_id || SEQ_res_detail_ID.Nextval TORD_ID, --_id
         0 DEPOT_OPER_ID, --_class
         a.order_log_id, --orderId
         d.rsid, --rsId
         a.order_num, --orderNum
        a.order_num,
        a.order_num,
         f.apply_staff_id, --updateStaffId
         f.update_time, --updateTime
         e.rs_name,
         e.res_type_code,
         e.res_type_desc,
         e.res_brand_code,
         e.res_brand_desc,
         e.res_model_code,
         e.res_model_desc,
         '',
         e.factory_code,
         e.factory_name,
         e.price,
         d.rsidout,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id remark,
         '' CONTRACT_NO,
         '' ER_CODE,
         '' ORDER_ID_OUT,
         '' OMS_ID_OUT,
         '' OMS_ORDER_ITEM_ID
    from TF_R_TML_ORDER_DETAIL a,
         TD_R_TERMINAL_PROPTY  b,
         TD_M_MATMAC_REF       c,
         TE_RSID_RSIDOUT       d,
         RC_RESOURCE       e,
         TF_R_TML_ORDER        f
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and d.rsid=e.rs_id
     and a.order_log_id=f.order_log_id
     and a.province_id in ('84')
     and f.province_id in ('84')
     and a.package_code=c.package_code
     and f.order_bill_state in ('0','1','2','3','4');
 commit; 
----调拨单
insert /*+append*/ into RC_RES_DETAIL
select /*+parallel(a,10)*/
a.province_id || SEQ_res_detail_ID.Nextval TORD_ID,
 0 DEPOT_OPER_ID, --_class
         a.log_id, --orderId
         d.rsid, --rsId
         a.oper_num, --orderNum
         a.oper_num,
         a.oper_num,
         f.oper_staff_id, --updateStaffId
         a.oper_date, --updateTime
         e.rs_name,
         e.res_type_code,
         e.res_type_desc,
         e.res_brand_code,
         e.res_brand_desc,
         e.res_model_code,
         e.res_model_desc,
         '',
         e.factory_code,
         e.factory_name,
         e.price,
         d.rsidout,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id remark,
         '' CONTRACT_NO,
         '' ER_CODE,
         '' ORDER_ID_OUT,
         '' OMS_ID_OUT,
         '' OMS_ORDER_ITEM_ID
  from Tf_r_Tml_Transf_Class a,
         TD_R_TERMINAL_PROPTY  b,
         TD_M_MATMAC_REF       c,
         TE_RSID_RSIDOUT       d,
         RC_RESOURCE       e,
         Tf_r_Tml_Transf        f
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and d.rsid=e.rs_id
     and a.log_id=f.log_id
     and a.province_id in ('84')
     and f.province_id in ('84')
     and a.package_code=c.package_code
     and f.log_state in ('0','1','2');
    commit;       
-----退货单
insert /*+append*/ into RC_RES_DETAIL
select /*+parallel(a,10)*/
a.province_id || SEQ_res_detail_ID.Nextval TORD_ID,
 0 DEPOT_OPER_ID, --_class
         a.log_id, --orderId
         d.rsid, --rsId
         a.res_num, --orderNum
         a.res_num,
         a.res_num,
         f.out_staff_id, --updateStaffId
         a.return_date, --updateTime
         e.rs_name,
         e.res_type_code,
         e.res_type_desc,
         e.res_brand_code,
         e.res_brand_desc,
         e.res_model_code,
         e.res_model_desc,
         '',
         e.factory_code,
         e.factory_name,
         e.price,
         d.rsidout,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id remark,
         '' CONTRACT_NO,
         '' ER_CODE,
         '' ORDER_ID_OUT,
         '' OMS_ID_OUT,
         '' OMS_ORDER_ITEM_ID
  from Tf_r_Tml_Return_Class a,
         TD_R_TERMINAL_PROPTY  b,
         TD_M_MATMAC_REF       c,
         TE_RSID_RSIDOUT       d,
         RC_RESOURCE       e,
         Tf_r_Tml_Return        f
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and d.rsid=e.rs_id
     and a.log_id=f.log_id
     and a.province_id in ('84')
     and f.province_id in ('84')
     and a.package_code=c.package_code
     and f.return_state in ('1','2','6');
    commit;
---------发货单
insert /*+append*/ into RC_RES_DETAIL
select /*+parallel(a,10)*/
a.province_id || SEQ_res_detail_ID.Nextval TORD_ID,
 0 DEPOT_OPER_ID, --_class
         a.send_trade_id, --orderId
         d.rsid, --rsId 
         a.res_num, --orderNum
         a.res_num,
         a.res_num,
         '', --updateStaffId
         f.update_time, --updateTime
         e.rs_name,
         e.res_type_code,
         e.res_type_desc,
         e.res_brand_code,
         e.res_brand_desc,
         e.res_model_code,
         e.res_model_desc,
         '',
         e.factory_code,
         e.factory_name,
         e.price,
         d.rsidout,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id remark,
         '' CONTRACT_NO,
         '' ER_CODE,
         '' ORDER_ID_OUT,
         '' OMS_ID_OUT,
         '' OMS_ORDER_ITEM_ID
  from Tf_r_Tml_Consig_Class a,
         TD_R_TERMINAL_PROPTY  b,
         TD_M_MATMAC_REF       c,
         TE_RSID_RSIDOUT       d,
         RC_RESOURCE       e,
         Tf_r_Tml_Consig        f
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and d.rsid=e.rs_id
     and a.send_trade_id=f.send_trade_id
     and a.province_id in ('84')
     and f.province_id in ('84')
     and a.package_code=c.package_code
     and f.bill_state in ('1', '0');
  commit;
 -----补货
 insert /*+append*/ into RC_RES_DETAIL
 select /*+parallel(a,10)*/a.province_id || SEQ_res_detail_ID.Nextval TORD_ID, --_id
         0 DEPOT_OPER_ID, --_class
         a.order_log_id, --orderId
         d.rsid, --rsId
         a.apply_num, --orderNum
         a.undealt_num,
         a.undealt_num,
         f.apply_staff_id, --updateStaffId
         f.update_time, --updateTime
         e.rs_name,
         e.res_type_code,
         e.res_type_desc,
         e.res_brand_code,
         e.res_brand_desc,
         e.res_model_code,
         e.res_model_desc,
         '',
         e.factory_code,
         e.factory_name,
         e.price,
         d.rsidout,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id remark,
         '' CONTRACT_NO,
         '' ER_CODE,
         '' ORDER_ID_OUT,
         '' OMS_ID_OUT,
         '' OMS_ORDER_ITEM_ID
    from Tf_r_Tml_Expect_Detail a,
         TD_R_TERMINAL_PROPTY  b,
         TD_M_MATMAC_REF       c,
         TE_RSID_RSIDOUT       d,
         RC_RESOURCE       e,
         Tf_r_Tml_Expect       f
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and d.rsid=e.rs_id
     and a.order_log_id=f.order_log_id
     and a.province_id in ('84')
     and f.province_id in ('84')
     and a.package_code=c.package_code
     and f.order_bill_state in ('0','1','2','3');
  commit;
   insert /*+append*/ into RC_RES_DETAIL
 select /*+parallel(a,10)*/a.province_id || SEQ_res_detail_ID.Nextval TORD_ID, --_id
         0 DEPOT_OPER_ID, --_class
         a.order_log_id, --orderId
         d.rsid, --rsId
         a.apply_num, --orderNum
         a.undealt_num,
         a.undealt_num,
         f.apply_staff_id, --updateStaffId
         f.update_time, --updateTime
         e.rs_name,
         e.res_type_code,
         e.res_type_desc,
         e.res_brand_code,
         e.res_brand_desc,
         e.res_model_code,
         e.res_model_desc,
         '',
         e.factory_code,
         e.factory_name,
         e.price,
         d.rsidout,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id remark,
         '' CONTRACT_NO,
         '' ER_CODE,
         '' ORDER_ID_OUT,
         '' OMS_ID_OUT,
         '' OMS_ORDER_ITEM_ID
    from Tf_r_Tml_Expect_Detail a,
         TD_R_TERMINAL_PROPTY  b,
         TD_M_MATMAC_REF       c,
         TE_RSID_RSIDOUT       d,
         RC_RESOURCE       e,
         Tf_r_Tml_Expect       f
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and d.rsid=e.rs_id
     and a.order_log_id=f.order_log_id
     and a.province_id in ('84')
     and f.province_id in ('84')
     and a.package_code=c.package_code
     and f.order_bill_state='4'
     and exists(select 1 from tf_r_tml_order tc where tc.relate_order_id=f.order_log_id and tc.order_bill_state in ('0','1','2','3','4') and tc.province_id in ('84'));
     commit;