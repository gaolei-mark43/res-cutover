insert into rc_res_ext
select to_char(sysdate, 'yyyymmdd') || seq_sku.nextval TRRA_ID,
       a.rs_id RS_ID,
       '888' EXT_CODE,
       c.color_code EXT_VALUE,
       c.color_name EXT_DESC,
       '1' SEQ_NO,
       sysdate UPDATE_TIME,
       c.color_name EXT_VALUE_DESC
  from rc_resource          a,
       td_m_matmac_ref      b,
       td_r_terminal_propty p,
       td_r_terminal_color  c
 where a.rs_id_out = b.material_code
   and b.machine_type_code = p.property_code
   and p.color_desc = c.color_name
   and not exists (select 1 from rc_res_ext rti where rti.rs_id=a.rs_id);
commit;