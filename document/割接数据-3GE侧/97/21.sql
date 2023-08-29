-----发货单
insert /*+append*/into rc_depot_oper
select /*+parallel(t,10)*/
t.province_id || SEQ_res_detail_ID.Nextval OPER_ID,
 t.send_trade_id ORDER_ID,
 '' link_oper_id,
  t.province_id province_code,
 t.eparchy_code eparchy_code,
 mb.city_code city_code,
  (select mp.province_name
    from td_m_province mp
   where mp.province_code = mb.province_code) as PROVINCE_NAME,
 (select me.eparchy_name
    from td_m_eparchy me
   where me.eparchy_code = t.eparchy_code and me.province_code in ('97')) as EPARCHY_NAME,
 (select ma.area_name
    from td_m_area ma
   where ma.province_code = mb.province_code
     and ma.bss_area_code = mb.city_code
     and ma.province_code in ('97')
     and ma.validflag = '10') as CITY_NAME,
         '0' ORDER_TYPE,
         '供应商发货单' ORDER_TYPE_DESC,
         '1' OPER_TYPE,
         '入库' OPER_TYPE_DESC,
         '3' OPER_STATE,
         '处理完成' OPER_STATE_DESC,
         t.send_depart_id  DEPART_ID,
         mb.depart_name DEPART_NAME,
         '' STAFF_ID,
         '' STAFF_NAME,
         t.update_time UPDATE_TIME,
         '' OPER_ID_OUT,
         '10' PLATFORM,
          t.send_stock_id  DEPOT_ID,
         (select t1.stock_name from tf_r_stock t1 where t1.stock_id=t.send_stock_id and t1.res_type_code='1' and t1.province_id in ('97')) DEPOT_NAME,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark
  from tf_r_tml_consig t, td_m_depart mb
 where t.province_id = mb.province_code(+)
   and t.province_id in ('97')
   and t.send_depart_id = mb.depart_id(+)
   and t.bill_state in ('1');
 commit;  

insert /*+append*/ into RC_RES_DETAIL
select /*+parallel(a,10)*/
a.province_id || SEQ_res_detail_ID.Nextval TORD_ID,
ro.oper_id DEPOT_OPER_ID, --_class
         a.send_trade_id, --orderId
         d.rsid, --rsId
         a.res_num, --orderNum
         a.res_num,
         case when f.bill_state='2' then a.res_num else (select count(*) from tf_r_tml_consig_detail t where t.send_trade_id=a.send_trade_id and t.property_id=a.property_id and t.province_id in ('97')) end,
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
         Tf_r_Tml_Consig        f,
         rc_depot_oper ro
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and d.rsid=e.rs_id
     and a.send_trade_id=f.send_trade_id
     and a.send_trade_id=ro.order_id
     and a.province_id in ('97')
     and f.province_id in ('97')
     and ro.province_code in ('97')
     and ro.oper_type='1'
     and f.bill_state in ('1')
     and a.package_code=c.package_code;
  commit;

insert /*+append*/ into RC_STOCK_DETAIL
select /*+parallel(a,10)*/
a.province_id || SEQ_res_detail_ID.Nextval tosd_id,
        ro.oper_id depot_oper_id,
         a.send_trade_id, --orderId
         d.rsid, --rsId
         a.terminal_id rs_imei, --orderNum
         '' contract_no,
         substr(f.update_staff_id,3,length(f.update_staff_id)) update_staff_id,
         f.update_time, --updateTime
         e.rs_name,
         e.res_type_code,
         e.res_type_desc,
         e.res_brand_code,
         e.res_brand_desc,
         e.res_model_code,
         e.res_model_desc,
         (select tf.staff_name from tf_m_staff tf where tf.staff_id=f.update_staff_id and tf.province_code in ('97')) update_staff_name,
         '1',
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id remark
  from tf_r_tml_consig_detail a,
         TD_R_TERMINAL_PROPTY  b,
         TD_M_MATMAC_REF       c,
         TE_RSID_RSIDOUT       d,
         RC_RESOURCE       e,
         tf_r_tml_consig        f,
         rc_depot_oper ro
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and d.rsid=e.rs_id
     and a.send_trade_id=f.send_trade_id
     and a.send_trade_id=ro.order_id
     and ro.province_code in ('97')
     and ro.oper_type='1'
     and f.bill_state in ('1')
     and a.province_id in ('97')
     and f.province_id in ('97')
     and a.package_code=c.package_code;
commit;

----调拨单
insert /*+append*/
into rc_depot_oper
  select /*+parallel(t,10)*/
t.province_id  || SEQ_res_detail_ID.Nextval OPER_ID,
   t.log_id ORDER_ID,
   '' link_oper_id,
   t.province_id province_code,
   t.eparchy_code eparchy_code,
   mb.city_code city_code,
   (select mp.province_name
      from td_m_province mp
     where mp.province_code = mb.province_code) as PROVINCE_NAME,
   (select me.eparchy_name
      from td_m_eparchy me
     where me.eparchy_code = t.eparchy_code and me.province_code in ('97')) as EPARCHY_NAME,
   (select ma.area_name
      from td_m_area ma
     where ma.province_code = mb.province_code
       and ma.bss_area_code = mb.city_code
       and ma.province_code in ('97')
       and ma.validflag = '10') as CITY_NAME,
 decode(t.trade_type,
        '1',
        '1',
        '2',
        '2',
        '3',
        '3',
        '4',
        '4',
        '5',
        '1',
        '6',
        '3',
        '7',
        'i',
        '8',
        'h',
        '9',
        'i',
        '10',
        'h',
        '11',
        'h',
        '12',
        'h',
        '13',
        'a') ORDER_TYPE,
 decode(t.trade_type,
        '1',
        '调配下发单',
        '2',
        '调配回收单',
        '3',
        '调配调拨单',
        '4',
        '调配回退单',
        '5',
        '调配下发单',
        '6',
        '调配调拨单',
        '7',
        '调配铺货单',
        '8',
        '调配铺货回退单',
        '9',
        '调配铺货单',
        '10',
        '调配铺货回退单',
        '11',
        '调配铺货回退单',
        '12',
        '调配铺货回退单',
        '13',
        '故障机调拨') ORDER_TYPE_DESC,
   '2' OPER_TYPE,
   '出库' OPER_TYPE_DESC,
   '3' OPER_STATE,
   '处理完成' OPER_STATE_DESC,
   t.depart_id_out DEPART_ID,
   mb.depart_name DEPART_NAME,
   '' STAFF_ID,
   '' STAFF_NAME,
   t.create_date UPDATE_TIME,
   '' OPER_ID_OUT,
   '10' PLATFORM,
   t.stock_id_out DEPOT_ID,
   (select t1.stock_name
      from tf_r_stock t1
     where t1.stock_id = t.stock_id_out
       and t1.res_type_code = '1' and t1.province_id in ('97')) DEPOT_NAME,
   '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark
    from tf_r_tml_transf t, td_m_depart mb
   where t.province_id = mb.province_code(+)
     and t.province_id in ('97')
     and t.log_state in ('1','2')
     and t.depart_id_out = mb.depart_id(+);
commit;

insert /*+append*/
into rc_depot_oper
  select /*+parallel(t,10)*/
t.province_id  || SEQ_res_detail_ID.Nextval OPER_ID,
   t.log_id ORDER_ID,
   '' link_oper_id,
   t.province_id province_code,
   t.eparchy_code eparchy_code,
   mb.city_code city_code,
   (select mp.province_name
      from td_m_province mp
     where mp.province_code = mb.province_code
     and mp.province_code in ('97')) as PROVINCE_NAME,
   (select me.eparchy_name
      from td_m_eparchy me
     where me.eparchy_code = t.eparchy_code and me.province_code in ('97')) as EPARCHY_NAME,
   (select ma.area_name
      from td_m_area ma
     where ma.province_code = mb.province_code
       and ma.bss_area_code = mb.city_code
       and ma.province_code in ('97')
       and ma.validflag = '10') as CITY_NAME,
 decode(t.trade_type,
        '1',
        '1',
        '2',
        '2',
        '3',
        '3',
        '4',
        '4',
        '5',
        '1',
        '6',
        '3',
        '7',
        'i',
        '8',
        'h',
        '9',
        'i',
        '10',
        'h',
        '11',
        'h',
        '12',
        'h',
        '13',
        'a') ORDER_TYPE,
 decode(t.trade_type,
        '1',
        '调配下发单',
        '2',
        '调配回收单',
        '3',
        '调配调拨单',
        '4',
        '调配回退单',
        '5',
        '调配下发单',
        '6',
        '调配调拨单',
        '7',
        '调配铺货单',
        '8',
        '调配铺货回退单',
        '9',
        '调配铺货单',
        '10',
        '调配铺货回退单',
        '11',
        '调配铺货回退单',
        '12',
        '调配铺货回退单',
        '13',
        '故障机调拨') ORDER_TYPE_DESC,
   '1' OPER_TYPE,
   '入库' OPER_TYPE_DESC,
   '3' OPER_STATE,
   '处理完成' OPER_STATE_DESC,
   t.depart_id_in DEPART_ID,
   mb.depart_name DEPART_NAME,
   '' STAFF_ID,
   '' STAFF_NAME,
   t.create_date UPDATE_TIME,
   '' OPER_ID_OUT,
   '10' PLATFORM,
   t.stock_id_in DEPOT_ID,
   (select t1.stock_name
      from tf_r_stock t1
     where t1.stock_id = t.stock_id_in
       and t1.res_type_code = '1' and t1.province_id in ('97')) DEPOT_NAME,
   '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark
    from tf_r_tml_transf t, td_m_depart mb
   where t.province_id = mb.province_code(+)
     and t.province_id in ('97')
     and t.log_state in ('2')
     and t.depart_id_out = mb.depart_id(+);
commit;

insert /*+append*/ into RC_RES_DETAIL
select /*+parallel(a,10)*/
a.province_id || SEQ_res_detail_ID.Nextval TORD_ID,
ro.oper_id DEPOT_OPER_ID, --_class
         a.log_id, --orderId
         d.rsid, --rsId
         a.oper_num, --orderNum
         a.oper_num,
         a.oper_num,
         '', --updateStaffId
         f1.create_date, --updateTime
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
         Tf_r_Tml_Transf        f1,
         rc_depot_oper ro
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and f1.log_id=ro.order_id
     and ro.oper_type='2'
     and d.rsid=e.rs_id
     and a.log_id=f1.log_id
     and f1.log_state in ('1','2')
     and a.province_id in ('97')
     and f1.province_id in ('97')
     and ro.province_code in ('97')
     and a.package_code=c.package_code;
  commit;
  
  
insert /*+append*/ into RC_RES_DETAIL
select /*+parallel(a,10)*/
a.province_id || SEQ_res_detail_ID.Nextval TORD_ID,
ro.oper_id DEPOT_OPER_ID, --_class
         a.log_id, --orderId
         d.rsid, --rsId
         a.oper_num, --orderNum
         a.oper_num,
         case when f1.log_state='3' then a.oper_num else (select count(*) from tf_r_tml_transf_detail td where td.log_id=a.log_id and td.property_id=a.property_id and td.province_id in ('97') and td.entry_id is not null) end,
         '', --updateStaffId
         f1.create_date, --updateTime
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
         Tf_r_Tml_Transf        f1,
         rc_depot_oper ro
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and f1.log_id=ro.order_id
     and ro.oper_type='1'
     and d.rsid=e.rs_id
     and a.log_id=f1.log_id
     and f1.log_state in ('2')
     and a.province_id in ('97')
     and f1.province_id in ('97')
     and ro.province_code in ('97')
     and a.package_code=c.package_code;
  commit;


insert /*+append*/ into RC_STOCK_DETAIL
select /*+parallel(a,15)*/
a.province_id || SEQ_res_detail_ID.Nextval tosd_id,
        ro.oper_id depot_oper_id,
         a.log_id, --orderId
         d.rsid, --rsId
         a.terminal_id rs_imei, --orderNum
         '' contract_no,
         substr(a.out_staff_id,3,length(a.in_staff_id)) update_staff_id,
         a.out_date, --updateTime
         e.rs_name,
         e.res_type_code,
         e.res_type_desc,
         e.res_brand_code,
         e.res_brand_desc,
         e.res_model_code,
         e.res_model_desc,
         (select tf.staff_name from tf_m_staff tf where tf.staff_id=a.out_staff_id and tf.province_code in ('97')) update_staff_name,
         '1',
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id remark
  from Tf_r_Tml_Transf_Detail a,
         TD_R_TERMINAL_PROPTY  b,
         TD_M_MATMAC_REF       c,
         TE_RSID_RSIDOUT       d,
         RC_RESOURCE       e,
         Tf_r_Tml_Transf        f,
         rc_depot_oper ro
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and d.rsid=e.rs_id
     and a.log_id=f.log_id
     and f.log_id=ro.order_id
     and a.province_id in ('97')
     and f.province_id in ('97')
     and ro.province_code in ('97')
     and ro.oper_type='2'
     and f.log_state in ('1','2')
     and a.package_code=c.package_code;
    commit; 

insert /*+append*/ into RC_STOCK_DETAIL
select /*+parallel(a,15)*/
a.province_id || SEQ_res_detail_ID.Nextval tosd_id,
        ro.oper_id depot_oper_id,
         a.log_id, --orderId
         d.rsid, --rsId
         a.terminal_id rs_imei, --orderNum
         '' contract_no,
         substr(a.in_staff_id,3,length(a.in_staff_id)) update_staff_id,
         a.in_date, --updateTime
         e.rs_name,
         e.res_type_code,
         e.res_type_desc,
         e.res_brand_code,
         e.res_brand_desc,
         e.res_model_code,
         e.res_model_desc,
         (select tf.staff_name from tf_m_staff tf where tf.staff_id=a.in_staff_id and tf.province_code in ('97')) update_staff_name,
         '1',
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id remark
  from Tf_r_Tml_Transf_Detail a,
         TD_R_TERMINAL_PROPTY  b,
         TD_M_MATMAC_REF       c,
         TE_RSID_RSIDOUT       d,
         RC_RESOURCE       e,
         Tf_r_Tml_Transf        f,
         rc_depot_oper ro
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and d.rsid=e.rs_id
     and a.log_id=f.log_id
     and f.log_id=ro.order_id
     and a.province_id in ('97')
     and f.province_id in ('97')
     and ro.province_code in ('97')
     and ro.oper_type='1'
     and f.log_state in ('2')
     and a.package_code=c.package_code
     and a.entry_id is not null;
    commit; 

    
-----退货单
insert /*+append*/into rc_depot_oper
select /*+parallel(t,10)*/
 t.province_id  || SEQ_res_detail_ID.Nextval OPER_ID,
 t.log_id ORDER_ID,
 '' link_oper_id,
  t.province_id province_code,
 t.eparchy_code eparchy_code,
 mb.city_code city_code,
  (select mp.province_name
    from td_m_province mp
   where mp.province_code = mb.province_code) as PROVINCE_NAME,
 (select me.eparchy_name
    from td_m_eparchy me
   where me.eparchy_code = t.eparchy_code and me.province_code in ('97')) as EPARCHY_NAME,
 (select ma.area_name
    from td_m_area ma
   where ma.province_code = mb.province_code
     and ma.bss_area_code = mb.city_code
     and ma.province_code in ('97')
     and ma.validflag = '10') as CITY_NAME,
         '5' ORDER_TYPE,
         '供应商退货单' ORDER_TYPE_DESC,
         '2' OPER_TYPE,
         '出库' OPER_TYPE_DESC,
         '3' OPER_STATE,
         '处理完成' OPER_STATE_DESC,
         t.out_depart_id  DEPART_ID,
         mb.depart_name DEPART_NAME,
         '' STAFF_ID,
         '' STAFF_NAME,
         t.update_date UPDATE_TIME,
         '' OPER_ID_OUT,
         '10' PLATFORM,
          t.stock  DEPOT_ID,
         (select t1.stock_name from tf_r_stock t1 where t1.stock_id=t.stock and t1.res_type_code='1' and t1.province_id in ('97')) DEPOT_NAME,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark
  from tf_r_tml_return t, td_m_depart mb
 where t.province_id = mb.province_code(+)
   and t.province_id in ('97')
   and t.out_depart_id = mb.depart_id(+)
   and t.return_state in ('2','6');
 commit;
 
 insert /*+append*/into rc_depot_oper
select /*+parallel(t,10)*/
 t.province_id  || SEQ_res_detail_ID.Nextval OPER_ID,
 t.log_id ORDER_ID,
 '' link_oper_id,
  t.province_id province_code,
 t.eparchy_code eparchy_code,
 mb.city_code city_code,
  (select mp.province_name
    from td_m_province mp
   where mp.province_code = mb.province_code) as PROVINCE_NAME,
 (select me.eparchy_name
    from td_m_eparchy me
   where me.eparchy_code = t.eparchy_code
   and me.province_code in ('97')) as EPARCHY_NAME,
 (select ma.area_name
    from td_m_area ma
   where ma.province_code = mb.province_code
     and ma.bss_area_code = mb.city_code
     and ma.province_code in ('97')
     and ma.validflag = '10') as CITY_NAME,
         '5' ORDER_TYPE,
         '退货' ORDER_TYPE_DESC,
         '1' OPER_TYPE,
         '入库' OPER_TYPE_DESC,
         '3' OPER_STATE,
         '处理完成' OPER_STATE_DESC,
         t.confirm_depart  DEPART_ID,
         mb.depart_name DEPART_NAME,
         '' STAFF_ID,
         '' STAFF_NAME,
         t.update_date UPDATE_TIME,
         '' OPER_ID_OUT,
         '10' PLATFORM,
          t.stock  DEPOT_ID,
         (select t1.stock_name from tf_r_stock t1 where t1.stock_id=t.stock and t1.res_type_code='1' and t1.province_id in ('97')) DEPOT_NAME,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark
  from tf_r_tml_return t, td_m_depart mb
 where t.province_id = mb.province_code(+)
   and t.province_id in ('97')
   and t.confirm_depart = mb.depart_id(+)
   and t.return_state in ('6')
   and exists(select 1 from tf_r_tml_return_detail rd where rd.log_id=t.log_id and rd.terminal_state='1');
commit;

insert /*+append*/ into RC_RES_DETAIL
select /*+parallel(a,10)*/
a.province_id || SEQ_res_detail_ID.Nextval TORD_ID,
ro.oper_id DEPOT_OPER_ID, --_class
         a.log_id, --orderId
         d.rsid, --rsId
         a.res_num, --orderNum
         a.res_num,
         a.res_num,
         '', --updateStaffId
         f1.update_date, --updateTime
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
         Tf_r_Tml_Return        f1,
         rc_depot_oper ro
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and f1.log_id=ro.order_id
     and ro.oper_type='2'
     and f1.return_state in ('2','6')
     and d.rsid=e.rs_id
     and a.log_id=f1.log_id
     and a.province_id in ('97')
     and f1.province_id in ('97')
     and ro.province_code in ('97')
     and a.package_code=c.package_code;
  commit;

insert /*+append*/ into RC_RES_DETAIL
select /*+parallel(a,10)*/
a.province_id || SEQ_res_detail_ID.Nextval TORD_ID,
ro.oper_id DEPOT_OPER_ID, --_class
         a.log_id, --orderId
         d.rsid, --rsId
         a.res_num, --orderNum
         a.res_num,
         (select count(*) from tf_r_tml_return_detail rd where rd.log_id=a.log_id and rd.property_id=a.property_id and rd.terminal_state='1' and rd.province_id in ('97')),
         '', --updateStaffId
         f1.update_date, --updateTime
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
         Tf_r_Tml_Return        f1,
         rc_depot_oper ro
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and f1.log_id=ro.order_id
     and ro.oper_type='1'
     and f1.return_state in ('6')
     and d.rsid=e.rs_id
     and a.log_id=f1.log_id
     and a.province_id in ('97')
     and f1.province_id in ('97')
     and ro.province_code in ('97')
     and a.package_code=c.package_code;
  commit;


insert /*+append*/ into RC_STOCK_DETAIL
select /*+parallel(a,10)*/
a.province_id || SEQ_res_detail_ID.Nextval tosd_id,
        ro.oper_id depot_oper_id,
         a.log_id, --orderId
         d.rsid, --rsId
         a.terminal_id rs_imei, --orderNum
         '' contract_no,
         substr(f.out_staff_id,3,length(f.out_staff_id)) update_staff_id,
         f.out_date, --updateTime
         e.rs_name,
         e.res_type_code,
         e.res_type_desc,
         e.res_brand_code,
         e.res_brand_desc,
         e.res_model_code,
         e.res_model_desc,
         (select tf.staff_name from tf_m_staff tf where tf.staff_id=f.out_staff_id and tf.province_code in ('97')) update_staff_name,
         '1',
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id remark
  from Tf_r_Tml_Return_Detail a,
         TD_R_TERMINAL_PROPTY  b,
         TD_M_MATMAC_REF       c,
         TE_RSID_RSIDOUT       d,
         RC_RESOURCE       e,
         Tf_r_Tml_Return        f,
         rc_depot_oper ro
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and d.rsid=e.rs_id
     and a.log_id=f.log_id
     and f.log_id=ro.order_id
     and a.province_id in ('97')
     and f.province_id in ('97')
     and ro.province_code in ('97')
     and ro.oper_type='2'
     and f.return_state in ('2','6')
     and a.package_code=c.package_code;
    commit;

insert /*+append*/ into RC_STOCK_DETAIL
select /*+parallel(a,10)*/
a.province_id || SEQ_res_detail_ID.Nextval tosd_id,
        ro.oper_id depot_oper_id,
         a.log_id, --orderId
         d.rsid, --rsId
         a.terminal_id rs_imei, --orderNum
         '' contract_no,
         substr(f.confirm_staff,3,length(f.confirm_staff)) update_staff_id,
         f.update_date, --updateTime
         e.rs_name,
         e.res_type_code,
         e.res_type_desc,
         e.res_brand_code,
         e.res_brand_desc,
         e.res_model_code,
         e.res_model_desc,
         (select tf.staff_name from tf_m_staff tf where tf.staff_id=f.confirm_staff and tf.province_code in ('97')) update_staff_name,
         '1',
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id remark
  from Tf_r_Tml_Return_Detail a,
         TD_R_TERMINAL_PROPTY  b,
         TD_M_MATMAC_REF       c,
         TE_RSID_RSIDOUT       d,
         RC_RESOURCE       e,
         Tf_r_Tml_Return        f,
         rc_depot_oper ro
   where a.property_id = b.property_id
     and b.property_code = c.machine_type_code
     and c.material_code = d.rsidout
     and d.rsid=e.rs_id
     and a.log_id=f.log_id
     and f.log_id=ro.order_id
     and a.province_id in ('97')
     and f.province_id in ('97')
     and ro.province_code in ('97')
     and ro.oper_type='1'
     and f.return_state in ('6')
     and a.package_code=c.package_code
     and a.terminal_state='1';
    commit;