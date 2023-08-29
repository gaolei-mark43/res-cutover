truncate table rc_depot_authorize;
insert into rc_depot_authorize
  select seq_log_id.nextval AUTHORIZE_ID,
         t.stock_id DEPOT_ID,
         t.audit_stock AUTHORIZE_DEPOT_ID,
         decode(t.valid_flag, '0', '1', '1', '0') STATE,
         '3GESS¸î½Ó' STAFF_ID,
         sysdate CREATE_TIME,
         '3GESS¸î½Ó' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id REMARK,
         t.stock_name DEPOT_NAME,
         a.stock_name AUTHORIZE_DEPOT_NAME
    from tf_r_stock t, tf_r_stock a
   where t.audit_stock = a.stock_id
     and t.province_id in ('30')
     and t.res_type_code = '1'
     and a.res_type_code = '1'
     and t.audit_stock is not null;
commit;