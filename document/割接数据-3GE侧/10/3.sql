insert into rc_res_tac
  select to_char(sysdate, 'yyyymmdd') || seq_sku.nextval as TAC_ID,
         rr.rsid as RS_ID,
         t.tac_code as TAC_CODE,
         '1' as VALID_FLAG,
         '3GESS¸î½Ó' as UPDATE_STAFF_ID,
         '3GESS¸î½Ó' as UPDATE_DEPART_ID,
         t.oper_time as CREATE_TIME,
         t.oper_time as UPDATE_TIME,
         '3GESS???¨®' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id as REMARK
    from td_r_terminal_tac t, td_m_matmac_ref a, te_rsid_rsidout rr
   where t.property_code = a.machine_type_code
     and a.material_code = rr.rsidout
     and not exists (select 1 from rc_res_tac rti where rti.tac_code=t.tac_code and rti.rs_id=rr.rsid);
commit;