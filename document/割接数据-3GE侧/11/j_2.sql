insert into rc_res_ext
select to_char(sysdate, 'yyyymmdd') || seq_sku.nextval TRRA_ID,
       a.rsid RS_ID,
       '888' EXT_CODE,
       c.color_code EXT_VALUE,
       c.color_name EXT_DESC,
       '1' SEQ_NO,
       sysdate UPDATE_TIME,
       c.color_name EXT_VALUE_DESC
  from te_rsid_rsidout a,
       TD_R_CODEOTHER p,
       td_r_terminal_color  c
 where a.rsidout = p.res_code
   and p.color_code = c.color_code
   and not exists (select 1 from rc_res_ext rti where rti.rs_id=a.rsid)
   and not exists(select 1 from td_r_terminal_propty rc where rc.property_code=a.rsidout)
   and not exists(select 1 from rc_resource rc where rc.rs_id_out=a.rsidout);
commit;