insert into rc_resource
  select rr.rsid rs_id,
         rr.rsidout rs_id_out,
         a.bar_code bar_code,
         a.property_name rs_name,
         '10' platform,
         a.terminal_type_code res_type_code,
         (SELECT p.param_name
            FROM TD_B_COMMPARA P
           WHERE P.PARAM_ATTR = '1520'
             and p.param_name not like '4G%'
             and p.param_code = a.terminal_type_code) res_type_desc,
         a.terminal_brand_code res_brand_code,
         a.terminal_model_code res_model_code,
         a.factory_code res_producer,
         a.property_name res_explain,
         a.terminal_vender factory_code,
         a.purchase_price price,
         a.validate_flag validate_flag,
         a.listing_time create_time, --注册时间(上市时间？）
         substr(a.update_depart, 3, length(a.update_depart)) update_depart,
         substr(a.update_staff, 3, length(a.update_staff)) update_staff,
         a.update_time update_time,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' ||  m.province_code remark,
         ti.intproxy_name FACTORY_NAME,
         a.terminal_brand_desc RES_BRAND_DESC,
         a.terminal_model_desc RES_MODEL_DESC,
         '销售部' UPDATE_DEPART_NAME,
         '叶楠' UPDATE_STAFF_NAME,
         '联通自营' PLATFORM_NAME,
         (select tf.factory_name
            from td_r_terminal_factory tf
           where tf.factory_code = a.factory_code) RES_PRODUCER_NAME,
         '1' MANAGE_TYPE,
         '串码管理' MANAGE_TYPE_DESC,
         a.terminal_subtype_code RES_SUBTYPE_CODE,
         (select ts.terminal_subtype_desc
            from td_r_terminal_subtype ts
           where ts.terminal_subtype_code = a.terminal_subtype_code) RES_SUBTYPE_DESC,
           m.province_code,
           m.province_name,
           '' RS_SPU
    from TD_R_TERMINAL_PROPTY   a,
         TD_M_MATMAC_REF        b,
         td_r_terminal_intproxy ti,
         te_rsid_rsidout        rr,
         td_m_province  m
   where a.property_code = b.machine_type_code
     and a.terminal_vender = ti.intproxy_code
     and b.material_code = rr.rsidout
     and a.province_id=m.province_code
     and not exists
   (select 1
            from tf_r_tml_transition rtt
           where rtt.property_code = a.property_code and rtt.remark is null)
    and not exists(
     select 1
            from rc_resource rc
           where rc.rs_id = rr.rsid)
  union all
  select rr.rsid rs_id,
         rr.rsidout rs_id_out,
         a.bar_code bar_code,
         a.property_name rs_name,
         '10' platform,
         a.terminal_type_code res_type_code,
         (SELECT p.param_name
            FROM TD_B_COMMPARA P
           WHERE P.PARAM_ATTR = '1520'
             and p.param_name not like '4G%'
             and p.param_code = a.terminal_type_code) res_type_desc,
         a.terminal_brand_code res_brand_code,
         a.terminal_model_code res_model_code,
         a.factory_code res_producer,
         a.property_name res_explain,
         a.terminal_vender factory_code,
         a.purchase_price price,
         a.validate_flag validate_flag,
         a.listing_time create_time, --注册时间(上市时间？）
         substr(a.update_depart, 3, length(a.update_depart)) update_depart,
         substr(a.update_staff, 3, length(a.update_staff)) update_staff,
         a.update_time update_time,
         '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' ||  m.province_code remark,
         ti.intproxy_name FACTORY_NAME,
         a.terminal_brand_desc RES_BRAND_DESC,
         a.terminal_model_desc RES_MODEL_DESC,
         '销售部' UPDATE_DEPART_NAME,
         '叶楠' UPDATE_STAFF_NAME,
         '联通自营' PLATFORM_NAME,
         (select tf.factory_name
            from td_r_terminal_factory tf
           where tf.factory_code = a.factory_code) RES_PRODUCER_NAME,
         '2' MANAGE_TYPE,
         '条码管理' MANAGE_TYPE_DESC,
         a.terminal_subtype_code RES_SUBTYPE_CODE,
         (select ts.terminal_subtype_desc
            from td_r_terminal_subtype ts
           where ts.terminal_subtype_code = a.terminal_subtype_code) RES_SUBTYPE_DESC,
         m.province_code,
         m.province_name,
        '' RS_SPU 
    from TD_R_TERMINAL_PROPTY   a,
         TD_M_MATMAC_REF        b,
         td_r_terminal_intproxy ti,
         te_rsid_rsidout        rr,
         td_m_province  m
   where a.property_code = b.machine_type_code
     and a.terminal_vender = ti.intproxy_code
     and b.material_code = rr.rsidout
     and a.province_id=m.province_code
     and exists (select 1
            from tf_r_tml_transition rtt
           where rtt.property_code = a.property_code and rtt.remark is null)
    and not exists(
     select 1
            from rc_resource rc
           where rc.rs_id = rr.rsid);
   commit;