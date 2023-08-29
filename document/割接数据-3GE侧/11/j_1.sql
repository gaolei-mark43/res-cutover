  insert into te_rsid_rsidout
  select to_char(sysdate,'yyyymmdd')||seq_sku.nextval, a.res_code
    from TD_R_CODELIST a
   where not exists
   (select 1 from te_rsid_rsidout c where c.rsidout = a.res_code);
commit;

insert into rc_resource  
  select rr.rsid rs_id,
         rr.rsidout rs_id_out,
         '' bar_code,
         a.res_name rs_name,
         '10' platform,
          c.res_type_code res_type_code,
         (SELECT p.param_name
            FROM TD_B_COMMPARA P
           WHERE P.PARAM_ATTR = '1520'
             and p.param_code = c.res_type_code) res_type_desc,
         c.brand_code res_brand_code,
         c.model_code res_model_code,
         c.factory_code res_producer,
         a.res_name res_explain,
         c.res_vender factory_code,
         c.purchase_price price,
         '0' validate_flag,
         a.update_time create_time, --注册时间(上市时间？）
         substr(a.depart_id, 3, length(a.depart_id)) update_depart,
         substr(a.staff_id, 3, length(a.staff_id)) update_staff,
         a.update_time update_time,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id remark,
         ti.intproxy_name FACTORY_NAME,
         (select bd.terminal_brand_desc from td_r_terminal_brand bd where c.brand_code=bd.terminal_brand_code) RES_BRAND_DESC,
         (select tm.terminal_model_desc from td_r_terminal_model tm where c.model_code=tm.terminal_model_code) RES_MODEL_DESC,
         '' UPDATE_DEPART_NAME,
         '' UPDATE_STAFF_NAME,
         '' PLATFORM_NAME,
         (select tf.factory_name
            from td_r_terminal_factory tf
           where tf.factory_code = c.factory_code) RES_PRODUCER_NAME,
         '2' MANAGE_TYPE,
         '条码管理' MANAGE_TYPE_DESC,
         c.res_subtype_code RES_SUBTYPE_CODE,
         (select tc.param_name
            from TD_B_COMMPARA tc
           where  tc.para_code1 = c.res_type_code 
           and tc.param_code=c.res_subtype_code
           and tc.param_attr='1540') RES_SUBTYPE_DESC,
           m.province_code,
           m.province_name,
           '' RS_SPU
    from TD_R_CODELIST   a,
         TD_R_CODEOTHER        c,
         td_r_terminal_intproxy ti,
         te_rsid_rsidout        rr,
         td_m_province  m
   where a.res_code = c.res_code
     and c.res_vender = ti.intproxy_code
     and a.res_code = rr.rsidout
     and a.effect_tag = '1'
     and a.province_id=m.province_code
     and not exists(select 1 from td_r_terminal_propty rc where rc.property_code=a.res_code)
     and not exists(select 1 from rc_resource rc where rc.rs_id_out=a.res_code);
   commit;
