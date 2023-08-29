insert into RC_DEPOT_RES
  select
   to_char(sysdate,'yyyymmdd')||to_char(seq_noiemi.nextval) TRDR_ID,
   rr.rsid RS_ID,
   a.channel_code DEPOT_ID,
   a.resnum RS_NUM,
   a.locknum LOCK_NUM,
   '' CONTRACT_NO,
   a.province_code PROVINCE_CODE,
   cc.city_id EPARCHY_CODE,
   '' RECORD_DATE,
   '' UPDATE_TIME,
   '3GESS¸î½Ó' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_code REMARK,
   c.property_name rsname,
   cc.channel_name depotname,
   e.province_name province_name,
   d.eparchy_name eparchy_name
    from (select t1.province_code province_code,
       t1.channel_code channel_code,
       t1.property_code property_code,
       t1.resnum resnum,
       sum(t1.locknum) locknum
  from (select t.province_code,
               t.channel_code,
               t.property_code,
               sum(t.res_num) over(partition by t.channel_code, t.property_code) resnum,
               case
                 when t.state_code = '1' then
                  sum(t.res_num)
                 else
                  0
               end locknum
          from tf_r_tml_transition t
         where t.res_num > 1 and t.province_code in ('10','13','70','84','97')
         group by t.province_code,
                  t.channel_code,
                  t.property_code,
                  t.res_num,
                  t.state_code) t1
 group by t1.province_code, t1.channel_code, t1.property_code, t1.resnum )a,
         td_m_matmac_ref      b,
         td_r_terminal_propty c,
         tf_c_channel         cc,
         td_m_province        e,
         td_m_eparchy         d,
         te_rsid_rsidout      rr
   where a.property_code = b.machine_type_code
     and a.property_code = c.property_code
     and b.machine_type_code=c.property_code
     and a.channel_code = cc.channel_code
     and b.material_code = rr.rsidout
     and cc.city_id = d.eparchy_code
     and a.province_code=e.province_code
     and cc.channel_state='10'
     and c.validate_flag='0';
commit;