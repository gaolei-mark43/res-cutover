insert into rc_stock_ext
  select to_char(sysdate, 'yyyymmdd') || seq_sku.nextval trse_id,
         t.terminal_id rs_imei,
         'distributeTag' ext_code,
         '1' ext_value,
         '铺货标记' ext_desc,
         sysdate update_time,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark
    from tf_r_tml_arch t
   where t.province_id in ('10','13','70','84','97')
     and t.distribution_tag = '1';
commit;


insert into rc_stock_ext
  select to_char(sysdate, 'yyyymmdd') || seq_sku.nextval trse_id,
         t.terminal_id rs_imei,
         'distributeDepot' ext_code,
         t.stock_id_pre ext_value,
         '出库仓库' ext_desc,
         sysdate update_time,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id remark
    from tf_r_tml_arch t
   where t.province_id in ('10','13','70','84','97')
     and t.distribution_tag = '1';
commit;


insert /*+append*/
into rc_stock_ext
  select /*+parallel(t,10)*/
   to_char(sysdate, 'yyyymmdd') || seq_sku.nextval trse_id,
   t.tandem_code rs_imei,
   'distributeTag' ext_code,
   '1' ext_value,
   '铺货标记' ext_desc,
   sysdate update_time,
   '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_code remark
    from tf_r_tandem_code t
   where t.province_code in ('10','13','70','84','97')
     and t.distribution_tag = '1';
commit;



insert /*+append*/
into rc_stock_ext
  select /*+parallel(t,10)*/
   to_char(sysdate, 'yyyymmdd') || seq_sku.nextval trse_id,
   t.tandem_code rs_imei,
   'distributeDepot' ext_code,
   t.stock_id_p ext_value,
   '出库仓库' ext_desc,
   sysdate update_time,
   '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_code remark
    from tf_r_tandem_code t
   where t.province_code in ('10','13','70','84','97')
     and t.distribution_tag = '1';
commit;