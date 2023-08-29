insert /*+append*/ into rc_order
select /*+full(t) parallel(t,10)*/
 t.subscribe_province || SEQ_res_detail_ID.Nextval order_id,
 t.subscribe_id link_order_id,
 t.bss_subscribe_id order_id_out,
 '10' platform,
 '' depot_id_in,
 rr.depot_id depot_id_out,
 decode(t.trade_type,
        '10',
        '7',
        '20',
        '7',
        '201',
        '7',
        '1991',
        '8',
        '220',
        '8',
        '221',
        '8',
        '80',
        '9',
        '81',
        '9',
        '82',
        '9') order_type,
 '3' order_state,
 tc.factory_code FACTORY_CODE,
 substr(t.subscribe_depart, 3, length(t.subscribe_depart)) depart_id,
 substr(t.subscribe_staff, 3, length(t.subscribe_staff)) staff_id,
 t.accept_date order_time,
 t.subscribe_province province_code,
 t.subscribe_eparchy eparchy_code,
 mb.city_code city_code,
 substr(t.subscribe_staff, 3, length(t.subscribe_staff)) UPDATE_STAFF_ID,
 sysdate update_time,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.subscribe_province remark,
 '0' EXPORT_PURCHASE_FLAG,
 (select mp.province_name
    from td_m_province mp
   where mp.province_code = mb.province_code and mp.province_code in ('97')) as PROVINCE_NAME,
 (select me.eparchy_name
    from td_m_eparchy me
   where me.eparchy_code = t.subscribe_eparchy and me.province_code in ('97')) as EPARCHY_NAME,
 (select ma.area_name
    from td_m_area ma
   where ma.province_code = mb.province_code
     and ma.bss_area_code = mb.city_code
     and ma.province_code in ('97')
     and ma.validflag = '10') as CITY_NAME,
 decode(t.trade_type,
        '10',
        '销售单',
        '20',
        '销售单',
        '201',
        '销售单',
        '1991',
        '销售退货单',
        '220',
        '销售退货单',
        '221',
        '销售退货单',
        '80',
        '销售换货单',
        '81',
        '销售换货单',
        '82',
        '销售换货单') ORDER_TYPE_DESC,
 '处理完成' ORDER_STATE_DESC,
 mb.depart_name DEPART_NAME,
 ms.staff_name STAFF_NAME,
 '1' SALE_COUNT,
 t.activity_type ACTIVITY_TYPE,
 '联通自营' PLATFORM_DESC,
 ms.staff_name UPDATE_STAFF_NAME,
 tc.factory_name FACTORY_NAME,
 '' DEPOT_ID_IN_NAME,
 rr.depotname DEPOT_ID_OUT_NAME,
 '' AUDIT_DEPART,
 sysdate START_TIME,
 sysdate END_TIME,
 '' AUTHORIZE_DEPOT_ID,
 '' TRANS_FLAG,
 '' CREAT_DEPOT_ID,
 '' OMS_ID,
 '' CREATE_FILE_FLAG,
 '' OMS_ORDER_ID 
  from tl_r_trade         t,
       td_m_depart        mb,
       tf_f_terminal_self ts,
       rc_resource        tc,
       rc_stock           rr,
       tf_m_staff         ms
 where t.resource_id = ts.terminal_id
   and t.resource_id = rr.rs_imei
   and rr.rs_id = tc.rs_id
   and t.subscribe_province=mb.province_code
   and t.subscribe_province=ms.province_code
   and t.subscribe_province in ('97')
   and mb.province_code in ('97')
   and t.subscribe_depart = mb.depart_id
   and ms.staff_id = t.subscribe_staff
   and ms.province_code in ('97')
   and t.accept_date >= to_date('20150619 00:00:00', 'yyyymmdd hh24:mi:ss')
   and t.accept_date < sysdate;
   commit;
   
insert /*+append*/ into rc_order 
 select /*+parallel(t,10)*/
 t.province_code || SEQ_res_detail_ID.Nextval order_id,
t.saletrade_id link_order_id,
 t.saletrade_id order_id_out,
 '10' platform,
 '' depot_id_in,
 t.sale_stock depot_id_out,
 decode(t.trade_type,
        '5',
        '7',
        '3',
        'j') order_type,
 '3' order_state,
 tc.factory_code FACTORY_CODE,
 substr(t.sale_depart, 3, length(t.sale_depart)) depart_id,
 substr(t.sale_staff, 3, length(t.sale_staff)) staff_id,
 t.sale_time order_time,
 t.province_code province_code,
 t.eparchy_code eparchy_code,
 mb.city_code city_code,
 substr(t.sale_staff, 3, length(t.sale_staff)) UPDATE_STAFF_ID,
 sysdate update_time,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_code remark,
 '0' EXPORT_PURCHASE_FLAG,
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
        '5',
        '销售单',
        '3',
        '非营业前台出库返销') ORDER_TYPE_DESC,
 '处理完成' ORDER_STATE_DESC,
 mb.depart_name DEPART_NAME,
 ms.staff_name STAFF_NAME,
 t.terminal_amount SALE_COUNT,
 t.activity_type ACTIVITY_TYPE,
 '联通自营' PLATFORM_DESC,
 ms.staff_name UPDATE_STAFF_NAME,
 tc.factory_name FACTORY_NAME,
 '' DEPOT_ID_IN_NAME,
 (select rs.stock_name from tf_r_stock rs where t.sale_stock=rs.stock_id and rs.res_type_code='1' and rs.province_id in ('97')) DEPOT_ID_OUT_NAME,
 '' AUDIT_DEPART,
 sysdate START_TIME,
 sysdate END_TIME,
 '' AUTHORIZE_DEPOT_ID,
 '' TRANS_FLAG,
 '' CREAT_DEPOT_ID,
 '' OMS_ID,
 '' CREATE_FILE_FLAG,
 '' OMS_ORDER_ID 
  from tf_r_tml_saletrade t,
       td_m_depart        mb,
       Tf_r_Tml_Saletrade_Detail ts,
       rc_resource        tc,
       rc_stock           rr,
       tf_m_staff         ms
 where t.saletrade_id = ts.saletrade_id
   and ts.terminal_id = rr.rs_imei
   and rr.rs_id = tc.rs_id
   and t.province_code=mb.province_code
   and t.province_code=ms.province_code
   and t.province_code in ('97')
   and ts.province_code in ('97')
   and mb.province_code in ('97')
   and t.sale_depart = mb.depart_id
   and ms.staff_id = t.sale_staff
   and ms.province_code in ('97')
   and t.sale_time >= to_date('20150619 00:00:00', 'yyyymmdd hh24:mi:ss')
   and t.sale_time < sysdate
   and t.sale_type='3';
   commit;
   
insert /*+append*/into rc_depot_oper
  select /*+parallel(t,10)*/t.order_id OPER_ID,
         t.order_id ORDER_ID,
         '' LINK_OPER_ID,
         t.province_code PROVINCE_CODE,
         t.eparchy_code EPARCHY_CODE,
         t.city_code CITY_CODE,
         t.province_name PROVINCE_NAME,
         t.eparchy_name EPARCHY_NAME,
         t.city_name CITY_NAME,
         t.order_type ORDER_TYPE,
         t.order_type_desc ORDER_TYPE_DESC,
         decode(t.order_type,'7','2','8','1','9','2','j','1') OPER_TYPE,
         decode(t.order_type,'7','出库','8','入库','9','出库','j','入库') OPER_TYPE_DESC,
         '3' OPER_STATE,
         '处理完成' OPER_STATE_DESC,
         t.depart_id DEPART_ID,
         t.depart_name DEPART_NAME,
         t.staff_id STAFF_ID,
         t.staff_name STAFF_NAME,
         t.update_time UPDATE_TIME,
         '' OPER_ID_OUT,
         t.platform PLATFORM,
         t.depot_id_out  DEPOT_ID,
         a.depot_name DEPOT_NAME,
         t.remark REMARK
          from rc_order t,rc_depot a
          where t.depot_id_out=a.depot_id(+);
commit;  