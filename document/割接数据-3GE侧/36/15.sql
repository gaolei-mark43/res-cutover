insert /*+append*/ into rc_sale
select /*+full(t) parallel(t,10)*/
 ro.order_id order_id,
 t.bss_subscribe_id trade_id,
 t.cancel_id old_trade_id,
 decode(t.sale_system_tag,
        '0',
        'CB9900',
        '1',
        'N6ESS',
        t.subscribe_province || 'BSS') sys_code,
 ro.province_code,
 ro.province_name,
 ro.eparchy_code,
 ro.eparchy_name,
 ro.city_code,
 ro.city_name,
 decode(t.trade_type,
        '10',
        '00',
        '20',
        '00',
        '201',
        '00',
        '1991',
        '00',
        '220',
        '02',
        '221',
        '02',
        '80',
        '03',
        '81',
        '03',
        '82',
        '03') trade_type,
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
        '销售换货单') TRADE_TYPE_NAME,
 t.activity_type,
 '' activity_id,
 ts.serial_number telephone,
 t.accept_date sale_time,
 substr(t.subscribe_channel, 3, length(t.subscribe_channel)) channel_code,
 cc.channel_name CHANNEL_NAME,
 t.channel_type_id channel_type,
 decode(cc.transition_tag, '1', '1', '0') is_trans_channel,
 ro.depart_id depart_id,
 ro.depart_name,
 ro.staff_id staff_id,
 ro.staff_name,
 rr.rs_id rs_id,
 '10' platform,
 decode(t.res_num, null, '1', '0', '1', t.res_num) sale_num,
 ts.terminal_id rs_imei,
 t.old_resource_id rs_imei_org,
 '0' sale_price,
 case
   when t.trade_type = '1991' then
    '2'
   else
    decode(t.cancel_tag, '1', '1', '0')
 end cancel_tag,
 t.update_date update_time,
 decode(cc.transition_tag, '1', '1', '0') send_flag,
 '1' has_tml_flag,
 '0' self_tml_flag,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' ||
 t.subscribe_province remark,
 decode(cc.transition_tag, '1', '1', '0') CONSIG_CREATE_FLAG,
 rr.rsname,
 rr.restypecode RES_TYPE_CODE,
 rr.restypedesc RES_TYPE_DESC,
 rr.resbrandcode RES_BRAND_CODE,
 rr.resbranddesc RES_BRAND_DESC,
 rr.resmodelcode RES_MODEL_CODE,
 rr.resmodeldesc RES_MODEL_DESC,
 rc.factory_code FACTORY_CODE,
 rc.factory_name FACTORY_NAME,
 '' UPDATE_DEPART,
 '' UPDATE_DEPART_NAME,
 '' UPDATE_STAFF,
 '' UPDATE_STAFF_NAME,
 rc.platform_name PLATFORM_NAME,
 rc.manage_type MANAGE_TYPE,
 rc.manage_type_desc MANAGE_TYPE_DESC,
 rc.res_producer RES_PRODUCER,
 rc.res_producer_name RES_PRODUCER_NAME,
 rc.bar_code BARCODE,
 '' START_TIME,
 '' END_TIME,
 rr.depot_id DEPOT_ID,
 rr.depotname DEPOT_NAME,
 t.RECOMMENDID DRECOMMEND_ID,
 t.RECOMMENDNAME RECOMMEND_NAME,
 t.RECOMMENDNUMBER RECOMMEND_NUMBER,
 t.RECOMDEPARTID RECOM_DEPART_ID
  from tl_r_trade         t,
       rc_order           ro,
       tf_c_channel       cc,
       tf_f_terminal_self ts,
       rc_stock           rr,
       rc_resource        rc
 where t.subscribe_id = ro.link_order_id
   and t.subscribe_channel = cc.channel_id
   and t.resource_id = rr.rs_imei
   and rr.rs_id = rc.rs_id
   and t.resource_id = ts.terminal_id
   and t.subscribe_province in ('36')
   and cc.province_id in ('36')
   and t.accept_date >= to_date('20150619 00:00:00', 'yyyymmdd hh24:mi:ss')
   and t.accept_date < sysdate;
   commit;
 
insert /*+append*/ into rc_sale
select /*+parallel(t,10)*/
ro.order_id order_id,
 t.saletrade_id trade_id,
 t.cancel_id old_trade_id,
 t.province_code || 'BSS' sys_code,
  ro.province_code,
ro.province_name PROVINCE_NAME,
 ro.eparchy_code,
 ro.eparchy_name EPARCHY_NAME,
 ro.city_code,
ro.city_name CITY_NAME,
 '00' trade_type,
 decode(t.trade_type, '5', '销售', '3', '销售返销') TRADE_TYPE_NAME,
 '',
 '' activity_id,
 '' telephone,
 t.sale_time sale_time,
 substr(ts.channel_id, 3, length(ts.channel_id)) channel_code,
 cc.channel_name CHANNEL_NAME,
cc.channel_type_id channel_type,
 '' is_trans_channel,
 substr(t.sale_depart, 3, length(t.sale_depart)) depart_id,
 ro.depart_name,
 substr(t.sale_staff, 3, length(t.sale_staff)) staff_id,
 ms.staff_name,
 rr.rs_id rs_id,
 '10' platform,
 t.terminal_amount sale_num,
 ts.terminal_id rs_imei,
 '' rs_imei_org,
 '0' sale_price,
  case
   when t.trade_type = '3' then
    '2'
   else
    decode(t.cancel_flag, '1', '1', '0')
 end cancel_tag,
 t.update_time update_time,
 '' send_flag,
 '1' has_tml_flag,
 '0' self_tml_flag,
 '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.saletrade_id remark,
 '' CONSIG_CREATE_FLAG,
 rr.rsname,
 rr.restypecode RES_TYPE_CODE,
 rr.restypedesc RES_TYPE_DESC,
 rr.resbrandcode RES_BRAND_CODE,
 rr.resbranddesc RES_BRAND_DESC,
 rr.resmodelcode RES_MODEL_CODE,
 rr.resmodeldesc RES_MODEL_DESC,
 tc.factory_code FACTORY_CODE,
 tc.factory_name FACTORY_NAME,
 '' UPDATE_DEPART,
 '' UPDATE_DEPART_NAME,
 '' UPDATE_STAFF,
 '' UPDATE_STAFF_NAME,
 tc.platform_name PLATFORM_NAME,
 tc.manage_type MANAGE_TYPE,
 tc.manage_type_desc MANAGE_TYPE_DESC,
 tc.res_producer RES_PRODUCER,
 tc.res_producer_name RES_PRODUCER_NAME,
 tc.bar_code BARCODE,
 '' START_TIME,
 '' END_TIME,
 rr.depot_id DEPOT_ID,
 rr.depotname DEPOT_NAME,
 '' DRECOMMEND_ID,
 '' RECOMMEND_NAME,
 '' RECOMMEND_NUMBER,
 '' RECOM_DEPART_ID
  from tf_r_tml_saletrade        t,
       Tf_r_Tml_Saletrade_Detail ts,
       rc_resource               tc,
       rc_stock                  rr,
       tf_m_staff                ms,
       tf_c_channel              cc,
       rc_order ro
 where t.saletrade_id = ts.saletrade_id
   and ts.terminal_id = rr.rs_imei
   and rr.rs_id = tc.rs_id
   and ts.channel_id=cc.channel_id(+)
   and t.province_code = ms.province_code
   and t.province_code in ('36')
   and ts.province_code in ('36')
   and ms.staff_id = t.sale_staff
   and ms.province_code in ('36')
   and ro.link_order_id=t.saletrade_id
   and t.sale_time < sysdate
   and t.sale_type = '3';
   commit;

update rc_order t
set t.link_order_id='';
commit;


insert /*+append*/into RC_RES_DETAIL
select /*+parallel(t,10)*/t.province_code || SEQ_res_detail_ID.Nextval TORD_ID, --_id
        0 DEPOT_OPER_ID, --_class
         t.order_id, --orderId
         t.rs_id, --rsId
         t.sale_num, --orderNum
         1,
         1,
         t.update_staff, --updateStaffId
         t.update_time, --updateTime
         t.rs_name,
         t.res_type_code,
         t.res_type_desc,
         t.res_brand_code,
         t.res_brand_desc,
         t.res_model_code,
         t.res_model_desc,
         t.update_staff_name,
         t.factory_code,
         t.factory_name,
         t.sale_price,
         a.rs_id_out,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_code remark,
         '' CONTRACT_NO,
         '' ER_CODE,
         '' ORDER_ID_OUT,
         '' OMS_ID_OUT,
         '' OMS_ORDER_ITEM_ID
    from rc_sale t, rc_resource a where t.rs_id=a.rs_id;
   commit;

insert /*+append*/into RC_RES_DETAIL
select /*+parallel(t,10)*/t.province_code || SEQ_res_detail_ID.Nextval TORD_ID, --_id
        t.order_id DEPOT_OPER_ID, --_class
         t.order_id, --orderId
         t.rs_id, --rsId
         t.sale_num, --orderNum
         1,
         1,
         t.update_staff, --updateStaffId
         t.update_time, --updateTime
         t.rs_name,
         t.res_type_code,
         t.res_type_desc,
         t.res_brand_code,
         t.res_brand_desc,
         t.res_model_code,
         t.res_model_desc,
         t.update_staff_name,
         t.factory_code,
         t.factory_name,
         t.sale_price,
         a.rs_id_out,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_code remark,
         '' CONTRACT_NO,
         '' ER_CODE,
         '' ORDER_ID_OUT,
         '' OMS_ID_OUT,
         '' OMS_ORDER_ITEM_ID
    from rc_sale t, rc_resource a where t.rs_id=a.rs_id;
   commit;
   
insert /*+append*/into RC_STOCK_DETAIL
select /*+parallel(t,10)*/t.province_code || SEQ_res_detail_ID.Nextval tosd_id,
        t.order_id depot_oper_id,
         t.order_id, --orderId
         t.rs_id, --rsId
         t.rs_imei rs_imei, --orderNum
         '' contract_no,
         t.update_staff update_staff_id,
         t.update_time, --updateTime
         t.rs_name,
         t.res_type_code,
         t.res_type_desc,
         t.res_brand_code,
         t.res_brand_desc,
         t.res_model_code,
         t.res_model_desc,
         t.update_staff_name update_staff_name,
         1,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_code remark
    from rc_sale t ;
    commit;

   
 