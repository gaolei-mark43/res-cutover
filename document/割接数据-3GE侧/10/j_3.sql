 insert /*+append*/ into RC_DEPOT_RES
  select /*+parallel(a,10)*/
   to_char(sysdate,'yyyymmdd')||to_char(seq_noiemi.nextval) TRDR_ID,
   rr.rsid RS_ID,
   a.stock_id DEPOT_ID,
   a.sum_num RS_NUM,
   a.lock_num LOCK_NUM,
   '' CONTRACT_NO,
   cc.province_id PROVINCE_CODE,
   cc.eparchy_code EPARCHY_CODE,
   a.latest_time RECORD_DATE,
   a.latest_time UPDATE_TIME,
   '3GESS???ио' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || cc.province_id REMARK,
   c.res_name rsname,
   cc.stock_name depotname,
   e.province_name province_name,
   d.eparchy_name eparchy_name
    from tf_r_stockres  a,
         TD_R_CODELIST c,
         tf_r_stock     cc,
         td_m_province        e,
         td_m_eparchy         d,
         te_rsid_rsidout      rr
   where a.res_code = c.res_code
     and a.stock_id = cc.stock_id
     and a.res_code = rr.rsidout
     and cc.eparchy_code = d.eparchy_code
     and cc.province_id=e.province_code
     and cc.valid_flag='1'
     and c.effect_tag='1'
     and cc.province_id in ('10')
     and not exists(select 1 from td_r_terminal_propty rc where rc.property_code=a.res_code);
commit;



