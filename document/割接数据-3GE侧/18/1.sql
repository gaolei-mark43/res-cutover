truncate table te_rsid_rsidout;
insert into te_rsid_rsidout
  select RS_ID,RS_ID_OUT
    from RC_RESOURCE;
commit;

insert into td_m_matmac_ref
  select a.property_code,
         a.property_code,
         a.property_name,
         '',
         '',
         '',
         '',
         '10'
    from td_r_terminal_propty a
   where not exists (select 1
            from td_m_matmac_ref b
           where b.machine_type_code = a.property_code);
commit;
insert into te_rsid_rsidout
  select to_char(sysdate,'yyyymmdd')||seq_sku.nextval, b.material_code
    from td_r_terminal_propty a, td_m_matmac_ref b
   where a.property_code = b.machine_type_code
     and not exists
   (select 1 from te_rsid_rsidout c where c.rsidout = b.material_code);
commit;
