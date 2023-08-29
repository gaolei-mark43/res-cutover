insert /*+append*/ into rc_order
select /*+parallel(t,10)*/
 t.order_log_id order_id,
 t.relate_order_id link_order_id,
 '' order_id_out,
 '10' platform,
 t.apply_stock_id depot_id_in,
 '' depot_id_out,
 'c' order_type,
 decode(t.order_bill_state,
        '0',
        '1',
        '1',
        '2',
        '2',
        '8',
        '3',
        '2',
        '4',
        '2',
        '5',
        '3') order_state,
 (select tp.terminal_vender
    from tf_r_tml_order_detail od, td_r_terminal_propty tp
   where od.order_log_id = t.order_log_id
     and od.property_id = tp.property_id
     and rownum = 1) FACTORY_CODE,
 substr(t.apply_depart_id, 3, length(t.apply_depart_id)) depart_id,
 substr(t.apply_staff_id, 3, length(t.apply_staff_id)) staff_id,
 t.update_time order_time,
 t.province_id province_code,
 t.apply_eparchy_code eparchy_code,
 mb.city_code city_code,
 substr(t.update_staff_id, 3, length(t.update_staff_id)) UPDATE_STAFF_ID,
 t.update_time update_time,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark,
 '1' EXPORT_PURCHASE_FLAG,
 (select mp.province_name
    from td_m_province mp
   where mp.province_code = mb.province_code and mp.province_code in ('97')) as PROVINCE_NAME,
 (select me.eparchy_name
    from td_m_eparchy me
   where me.eparchy_code = t.apply_eparchy_code and me.province_code in ('97')) as EPARCHY_NAME,
 (select ma.area_name
    from td_m_area ma
   where ma.province_code = mb.province_code
     and ma.bss_area_code = mb.city_code
     and ma.province_code in ('97')
     and ma.validflag = '10') as CITY_NAME,
 '采购单' ORDER_TYPE_DESC,
 decode(t.order_bill_state,
        '0',
        '待处理',
        '1',
        '处理中',
        '2',
        '审批不通过',
        '3',
        '处理中',
        '4',
        '处理中',
        '5',
        '处理完成') ORDER_STATE_DESC,
 mb.depart_name DEPART_NAME,
 (select ms.staff_name
    from tf_m_staff ms
   where ms.staff_id = t.apply_staff_id and ms.province_code in ('97')) STAFF_NAME,
 0 SALE_COUNT,
 '' ACTIVITY_TYPE,
 '联通自营' PLATFORM_DESC,
 (select ms.staff_name
    from tf_m_staff ms
   where ms.staff_id = t.apply_staff_id and ms.province_code in ('97')) UPDATE_STAFF_NAME,
 (select ti.intproxy_name
    from tf_r_tml_order_detail  od,
         td_r_terminal_propty   tp,
         td_r_terminal_intproxy ti
   where od.order_log_id = t.order_log_id
     and od.property_id = tp.property_id
     and tp.terminal_vender = ti.intproxy_code
     and od.province_id in ('97')
     and rownum = 1) FACTORY_NAME,
 (select t1.stock_name
    from tf_r_stock t1
   where t1.stock_id = t.apply_stock_id
      and t1.province_id in ('97')  
     and t1.res_type_code = '1') DEPOT_ID_IN_NAME,
 '' DEPOT_ID_OUT_NAME,
 '' AUDIT_DEPART,
 t.create_time start_time,
 t.update_time end_time,
 '' AUTHORIZE_DEPOT_ID,
 '' TRANS_FLAG,
 t.apply_stock_id CREAT_DEPOT_ID,
 '' OMS_ID,
 '1' CREATE_FILE_FLAG,
 '' OMS_ORDER_ID
  from tf_r_tml_order t, td_m_depart mb
where t.apply_depart_id = mb.depart_id(+)
and t.order_bill_state in ('0','1','2','3','4')
   and t.province_id in ('97')
 group by t.order_log_id,
          t.relate_order_id,
          t.apply_stock_id,
          t.order_bill_state,
          t.apply_depart_id,
          t.apply_staff_id,
          t.update_time,
          t.province_id,
          t.apply_eparchy_code,
          t.update_staff_id,
          mb.city_code,
          mb.province_code,
          mb.depart_name,
          t.create_time;
   commit;       

----调拨单
insert /*+append*/ into rc_order
select /*+parallel(t,10)*/
 t.log_id order_id,
 '' link_order_id,
 t.bill_no order_id_out,
 '10' platform,
 t.stock_id_in depot_id_in,
 t.stock_id_out depot_id_out,
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
        'a') order_type,
 decode(t.log_state, '0', '1', '1', '2', '2', '2','4','9','3','3') order_state,
 (select tp.terminal_vender
    from tf_r_tml_transf_class od, td_r_terminal_propty tp
   where od.log_id = t.log_id
     and od.property_id = tp.property_id
     and od.province_id in ('97')
     and rownum = 1) FACTORY_CODE,
 substr(t.oper_depart_id, 3, length(t.oper_depart_id)) depart_id,
 substr(t.oper_staff_id, 3, length(t.oper_staff_id)) staff_id,
 t.oper_date order_time,
 t.province_id province_code,
 t.eparchy_code eparchy_code,
 mb.city_code city_code,
 substr(t.oper_staff_id, 3, length(t.oper_staff_id)) UPDATE_STAFF_ID,
 t.oper_date update_time,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark,
 '1' EXPORT_PURCHASE_FLAG,
 (select mp.province_name
    from td_m_province mp
   where mp.province_code = mb.province_code and mp.province_code in ('97')) as PROVINCE_NAME,
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
 decode(t.log_state, '0', '待处理', '1', '处理中', '2', '处理中', '3','处理完成','4','撤销') ORDER_STATE_DESC,
 mb.depart_name DEPART_NAME,
 (select ms.staff_name
    from tf_m_staff ms
   where ms.staff_id = t.oper_staff_id and ms.province_code in ('97')) STAFF_NAME,
 0 SALE_COUNT,
 '' ACTIVITY_TYPE,
 '联通自营' PLATFORM_DESC,
 (select ms.staff_name
    from tf_m_staff ms
   where ms.staff_id = t.oper_staff_id and ms.province_code in ('97')) UPDATE_STAFF_NAME,
 (select ti.intproxy_name
    from tf_r_tml_transf_class  od,
         td_r_terminal_propty   tp,
         td_r_terminal_intproxy ti
   where od.log_id = t.log_id
     and od.property_id = tp.property_id
     and tp.terminal_vender = ti.intproxy_code
     and od.province_id in ('97')
     and rownum = 1) FACTORY_NAME,
 (select t1.stock_name
    from tf_r_stock t1
   where t1.stock_id = t.stock_id_in
     and t1.province_id in ('97')
     and t1.res_type_code = '1') DEPOT_ID_IN_NAME,
 (select t2.stock_name
    from tf_r_stock t2
   where t2.stock_id = t.stock_id_out
     and t2.province_id in ('97')   
     and t2.res_type_code = '1') DEPOT_ID_OUT_NAME,
 '' AUDIT_DEPART,
 t.create_date START_TIME,
 t.oper_date END_TIME,
 '' AUTHORIZE_DEPOT_ID,
 '' TRANS_FLAG,
 (select rd.stock_id
    from tf_r_stock rd
   where t.create_depart_id = rd.depart_id
     and rd.res_type_code = '1'
     and rd.province_id in ('97')
     and rd.valid_flag = '1' and rownum=1) CREAT_DEPOT_ID,
 '' OMS_ID,
 '1' CREATE_FILE_FLAG,
 '' OMS_ORDER_ID
  from tf_r_tml_transf t, td_m_depart mb
 where t.oper_depart_id = mb.depart_id(+)
 and t.log_state in ('0','1','2')
   and t.province_id in ('97');
commit;
----发货单
insert /*+append*/ into rc_order
 select /*+parallel(t,10)*/
 t.send_trade_id,
 '' link_order_id,
 t.send_bill_no order_id_out,
 '10' platform,
 t.send_stock_id depot_id_in,
 '' depot_id_out,
 '0' order_type,
 decode(t.bill_state, '0', '1', '1', '2','2','3','3','9') order_state,
  (select tp.terminal_vender
    from tf_r_tml_consig_class od, td_r_terminal_propty tp
   where od.send_trade_id = t.send_trade_id
     and od.property_id = tp.property_id
     and od.province_id in ('97')
     and rownum = 1) FACTORY_CODE,
 substr(t.send_depart_id, 3, length(t.send_depart_id)) depart_id,
 '' staff_id,
 t.send_date order_time,
 t.province_id province_code,
 t.eparchy_code eparchy_code,
 mb.city_code city_code,
 '' UPDATE_STAFF_ID,
 t.update_time update_time,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark,
 '1' EXPORT_PURCHASE_FLAG,
 (select mp.province_name
    from td_m_province mp
   where mp.province_code = mb.province_code and mp.province_code in ('97')) as PROVINCE_NAME,
 (select me.eparchy_name
    from td_m_eparchy me
   where me.eparchy_code = t.eparchy_code and me.province_code in ('97')) as EPARCHY_NAME,
 (select ma.area_name
    from td_m_area ma
   where ma.province_code = mb.province_code
     and ma.bss_area_code = mb.city_code
     and ma.province_code in ('97')
     and ma.validflag = '10') as CITY_NAME,
 '供应商发货单' ORDER_TYPE_DESC,
 decode(t.bill_state, '0', '待处理', '1', '处理中','2','处理完成','3','撤销') ORDER_STATE_DESC,
 mb.depart_name DEPART_NAME,
 '' STAFF_NAME,
 t.res_num SALE_COUNT,
 '' ACTIVITY_TYPE,
 '联通自营' PLATFORM_DESC,
 '' UPDATE_STAFF_NAME,
 (select ti.intproxy_name
    from tf_r_tml_consig_class  od,
         td_r_terminal_propty   tp,
         td_r_terminal_intproxy ti
   where od.send_trade_id = t.send_trade_id
     and od.property_id = tp.property_id
     and tp.terminal_vender = ti.intproxy_code
     and od.province_id in ('97')
     and rownum = 1) FACTORY_NAME,
(select t1.stock_name from tf_r_stock t1 where t1.stock_id=t.send_stock_id and t1.res_type_code='1' and t1.province_id in ('97')) DEPOT_ID_IN_NAME,
 '' DEPOT_ID_OUT_NAME,
'' AUDIT_DEPART,
 t.send_date START_TIME,
 t.update_time END_TIME,
 '' AUTHORIZE_DEPOT_ID,
 '' TRANS_FLAG,
t.export_flag CREAT_DEPOT_ID,
 '' OMS_ID,
 '1' CREATE_FILE_FLAG,
 '' OMS_ORDER_ID 
  from tf_r_tml_consig t, td_m_depart mb
 where t.send_depart_id = mb.depart_id(+)
 and t.bill_state in ('1', '0')
   and t.province_id in ('97');
 commit;  
-----补货单
insert /*+append*/ into rc_order
select /*+parallel(t,10)*/
 t.order_log_id order_id,
 '' link_order_id,
 '' order_id_out,
 '10' platform,
 t.apply_stock_id depot_id_in,
 '' depot_id_out,
 'b' order_type,
 decode(t.order_bill_state,
        '0',
        '1',
        '1',
        '2',
        '2',
        '2',
        '3',
        '2',
        '4',
        '3',
        '5',
        '8','9','9') order_state,
 (select tp.terminal_vender
    from tf_r_tml_expect_detail od, td_r_terminal_propty tp
   where od.order_log_id = t.order_log_id
     and od.property_id = tp.property_id
     and od.province_id in ('97')
     and rownum = 1) FACTORY_CODE,
 substr(t.apply_depart_id, 3, length(t.apply_depart_id)) depart_id,
 substr(t.apply_staff_id, 3, length(t.apply_staff_id)) staff_id,
 t.update_time order_time,
 t.province_id province_code,
 t.apply_eparchy_code eparchy_code,
 mb.city_code city_code,
 substr(t.update_staff_id, 3, length(t.update_staff_id)) UPDATE_STAFF_ID,
 t.update_time update_time,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark,
 '1' EXPORT_PURCHASE_FLAG,
 (select mp.province_name
    from td_m_province mp
   where mp.province_code = mb.province_code and mp.province_code in ('97')) as PROVINCE_NAME,
 (select me.eparchy_name
    from td_m_eparchy me
   where me.eparchy_code = t.apply_eparchy_code and me.province_code in ('97')) as EPARCHY_NAME,
 (select ma.area_name
    from td_m_area ma
   where ma.province_code = mb.province_code
     and ma.bss_area_code = mb.city_code
     and ma.province_code in ('97')
     and ma.validflag = '10') as CITY_NAME,
 '补货单' ORDER_TYPE_DESC,
 decode(t.order_bill_state,
       '0',
        '待处理',
        '1',
        '处理中',
        '2',
        '处理中',
        '3',
        '处理中',
        '4',
        '处理完成',
        '5',
        '审批不通过','9','撤销') ORDER_STATE_DESC,
 mb.depart_name DEPART_NAME,
 (select ms.staff_name
    from tf_m_staff ms
   where ms.staff_id = t.apply_staff_id and ms.province_code in ('97')) STAFF_NAME,
 0 SALE_COUNT,
 '' ACTIVITY_TYPE,
 '联通自营' PLATFORM_DESC,
 (select ms.staff_name
    from tf_m_staff ms
   where ms.staff_id = t.apply_staff_id and ms.province_code in ('97')) UPDATE_STAFF_NAME,
 (select ti.intproxy_name
    from tf_r_tml_expect_detail  od,
         td_r_terminal_propty   tp,
         td_r_terminal_intproxy ti
   where od.order_log_id = t.order_log_id
     and od.property_id = tp.property_id
     and tp.terminal_vender = ti.intproxy_code
     and od.province_id in ('97')
     and rownum = 1) FACTORY_NAME,
 (select t1.stock_name
    from tf_r_stock t1
   where t1.stock_id = t.apply_stock_id
     and t1.province_id in ('97')
     and t1.res_type_code = '1') DEPOT_ID_IN_NAME,
 '' DEPOT_ID_OUT_NAME,
 '' AUDIT_DEPART,
 t.order_date start_time,
 t.update_time end_time,
 '' AUTHORIZE_DEPOT_ID,
 '' TRANS_FLAG,
 t.apply_stock_id CREAT_DEPOT_ID,
 '' OMS_ID,
 '1' CREATE_FILE_FLAG,
 '' OMS_ORDER_ID
  from tf_r_tml_expect t, td_m_depart mb
 where t.apply_depart_id = mb.depart_id(+)
 and  t.order_bill_state in ('0','1','2','3')
   and t.province_id in ('97')
 group by t.order_log_id,
          t.apply_stock_id,
          t.order_bill_state,
          t.apply_depart_id,
          t.apply_staff_id,
          t.update_time,
          t.province_id,
          t.apply_eparchy_code,
          t.update_staff_id,
          mb.city_code,
          mb.province_code,
          mb.depart_name,
          t.order_date;
commit;
-----采购关联补货单
insert /*+append*/ into rc_order
select /*+parallel(t,10)*/
 t.order_log_id order_id,
 '' link_order_id,
 '' order_id_out,
 '10' platform,
 t.apply_stock_id depot_id_in,
 '' depot_id_out,
 'b' order_type,
 decode(t.order_bill_state,
        '0',
        '1',
        '1',
        '2',
        '2',
        '2',
        '3',
        '2',
        '4',
        '3',
        '5',
        '8','9','9') order_state,
 (select tp.terminal_vender
    from tf_r_tml_expect_detail od, td_r_terminal_propty tp
   where od.order_log_id = t.order_log_id
     and od.property_id = tp.property_id
     and od.province_id in ('97')
     and rownum = 1) FACTORY_CODE,
 substr(t.apply_depart_id, 3, length(t.apply_depart_id)) depart_id,
 substr(t.apply_staff_id, 3, length(t.apply_staff_id)) staff_id,
 t.update_time order_time,
 t.province_id province_code,
 t.apply_eparchy_code eparchy_code,
 mb.city_code city_code,
 substr(t.update_staff_id, 3, length(t.update_staff_id)) UPDATE_STAFF_ID,
 t.update_time update_time,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark,
 '1' EXPORT_PURCHASE_FLAG,
 (select mp.province_name
    from td_m_province mp
   where mp.province_code = mb.province_code and mp.province_code in ('97')) as PROVINCE_NAME,
 (select me.eparchy_name
    from td_m_eparchy me
   where me.eparchy_code = t.apply_eparchy_code and me.province_code in ('97')) as EPARCHY_NAME,
 (select ma.area_name
    from td_m_area ma
   where ma.province_code = mb.province_code
     and ma.bss_area_code = mb.city_code
     and ma.province_code in ('97')
     and ma.validflag = '10') as CITY_NAME,
 '补货单' ORDER_TYPE_DESC,
 decode(t.order_bill_state,
       '0',
        '待处理',
        '1',
        '处理中',
        '2',
        '处理中',
        '3',
        '处理中',
        '4',
        '处理完成',
        '5',
        '审批不通过','9','撤销') ORDER_STATE_DESC,
 mb.depart_name DEPART_NAME,
 (select ms.staff_name
    from tf_m_staff ms
   where ms.staff_id = t.apply_staff_id and ms.province_code in ('97')) STAFF_NAME,
 0 SALE_COUNT,
 '' ACTIVITY_TYPE,
 '联通自营' PLATFORM_DESC,
 (select ms.staff_name
    from tf_m_staff ms
   where ms.staff_id = t.apply_staff_id and ms.province_code in ('97')) UPDATE_STAFF_NAME,
 (select ti.intproxy_name
    from tf_r_tml_expect_detail  od,
         td_r_terminal_propty   tp,
         td_r_terminal_intproxy ti
   where od.order_log_id = t.order_log_id
     and od.property_id = tp.property_id
     and tp.terminal_vender = ti.intproxy_code
     and od.province_id in ('97')
     and rownum = 1) FACTORY_NAME,
 (select t1.stock_name
    from tf_r_stock t1
   where t1.stock_id = t.apply_stock_id
     and t1.province_id in ('97')
     and t1.res_type_code = '1') DEPOT_ID_IN_NAME,
 '' DEPOT_ID_OUT_NAME,
 '' AUDIT_DEPART,
 t.order_date start_time,
 t.update_time end_time,
 '' AUTHORIZE_DEPOT_ID,
 '' TRANS_FLAG,
 t.apply_stock_id CREAT_DEPOT_ID,
 '' OMS_ID,
 '1' CREATE_FILE_FLAG,
 '' OMS_ORDER_ID
  from tf_r_tml_expect t, td_m_depart mb
 where t.apply_depart_id = mb.depart_id(+)
 and  t.order_bill_state='4'
   and t.province_id in ('97')
   and exists(select 1 from tf_r_tml_order tc where tc.relate_order_id=t.order_log_id and tc.order_bill_state in ('0','1','2','3','4') and tc.province_id in ('97'))
 group by t.order_log_id,
          t.apply_stock_id,
          t.order_bill_state,
          t.apply_depart_id,
          t.apply_staff_id,
          t.update_time,
          t.province_id,
          t.apply_eparchy_code,
          t.update_staff_id,
          mb.city_code,
          mb.province_code,
          mb.depart_name,
          t.order_date;
commit;
-----在途退货单
insert /*+append*/ into rc_order
select /*+parallel(t,10)*/
 t.log_id order_id,
 '' link_order_id,
 t.bill_no order_id_out,
 '10' platform,
'' depot_id_in,
t.stock depot_id_out,
'5' order_type,
t.return_state order_state,
'' FACTORY_CODE,
 substr(t.depart_id, 3, length(t.depart_id)) depart_id,
 substr(t.update_staff_id, 3, length(t.update_staff_id)) staff_id,
 t.out_date order_time,
 t.province_id province_code,
 t.eparchy_code eparchy_code,
 mb.city_code city_code,
 substr(t.update_staff_id, 3, length(t.update_staff_id)) UPDATE_STAFF_ID,
 sysdate update_time,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark,
 '1' EXPORT_PURCHASE_FLAG,
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
        '供应商退货单' ORDER_TYPE_DESC,
        decode(t.return_state,'1','待处理','2','处理中') ORDER_STATE_DESC,
 mb.depart_name DEPART_NAME,
(select ms.staff_name from tf_m_staff ms where ms.staff_id=t.return_staff_id and ms.province_code in ('97')) STAFF_NAME,
 t.res_num SALE_COUNT,
 '' ACTIVITY_TYPE,
 '联通自营' PLATFORM_DESC,
(select ms.staff_name from tf_m_staff ms where ms.staff_id=t.return_staff_id and ms.province_code in ('97')) UPDATE_STAFF_NAME,
'' FACTORY_NAME,
'' DEPOT_ID_IN_NAME,
(select t2.stock_name from tf_r_stock t2 where t2.stock_id=t.stock and t2.res_type_code='1' and t2.province_id in ('97')) DEPOT_ID_OUT_NAME,
 t.stock AUDIT_DEPART,
 sysdate START_TIME,
 sysdate END_TIME,
 '' AUTHORIZE_DEPOT_ID,
 '' TRANS_FLAG,
t.export_flag CREAT_DEPOT_ID,
 '' OMS_ID,
 '' CREATE_FILE_FLAG,
 '' OMS_ORDER_ID 
  from tf_r_tml_return       t,
       td_m_depart           mb
 where t.depart_id = mb.depart_id(+)
 and t.return_state in ('1','2','6')
 and t.province_id in ('97');
    commit;