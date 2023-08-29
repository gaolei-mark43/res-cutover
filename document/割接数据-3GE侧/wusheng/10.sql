--arch����̻��ն�--
truncate table RC_STOCK;
--arch����̻��ն�--
insert /*+append*/into RC_STOCK
SELECT /*+parallel(t,10)*/
 trim(t.terminal_id) RS_IMEI,
 rr.rsid RS_ID,
 t.stock_id DEPOT_ID,
 decode(t.terminal_state,
        '1',
        '2',
        '2',
        '6',
        '3',
        '5',
        '4',
        '8',
        '5',
        '6',
        '8',
        '5',
        'B',
        '2',
        'C',
        '0') STATE,
 t.province_id PROVINCE_CODE,
 t.eparchy_code EPARCHY_CODE,
 '123' SHEL_NO,
 '456' SEAT_NO,
 t.batch_in_time RECORD_DATE,
 '' CONTRACT_NO,
 (select md.bss_depart_code
    from td_m_depart md
   where md.depart_id = rs.depart_id and md.province_code in ('10','13','70','84','97'))  DEPART_IN,
 substr(t.staff_id_in, 3, length(t.staff_id_in)) STAFF_IN,
 t.batch_in_time TIME_IN,
 t.update_time UPDATE_TIME,
 '3GESS���'|| '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id REMARK,
 a.property_name rsName,
 rs.stock_name depotName,
 decode(t.terminal_state,
        '1',
        '����',
        '2',
        '�������',
        '3',
        '���۳���',
        '4',
        '���ϻ�',
        '5',
        '�������',
        '8',
        '���۳���',
        'B',
        '����') stateDesc,
 c.province_name provinceName,
 (select me.eparchy_name
    from td_m_eparchy me
   where me.eparchy_code = t.eparchy_code and me.province_code in ('10','13','70','84','97')) eparchyName,
 (select md.depart_name
    from td_m_depart md
   where md.depart_id = rs.depart_id and md.province_code in ('10','13','70','84','97')) departInName,
 (select mf.staff_name from tf_m_staff mf where mf.staff_id=t.staff_id_in and mf.province_code in ('10','13','70','84','97')) staffInName,
 a.terminal_type_code resTypeCode,
 (SELECT p.param_name
    FROM TD_B_COMMPARA P
   WHERE P.PARAM_ATTR = '1520'
     and p.param_name not like '4G%'
     and p.param_code = a.terminal_type_code) resTypeDesc,
 a.terminal_brand_code resBrandCode,
 a.terminal_brand_desc resBrandDesc,
 a.terminal_model_code resModelCode,
 a.terminal_model_desc resModelDesc,
 '1',
 case
   when t.terminal_state = '8' then
    (select decode(trim(ts.out_type),
                   '1',
                   '�̿�',
                   '2',
                   '����',
                   '3',
                   '��ʾ��',
                   '4',
                   '���Գ���',
                   '5',
                   '����-�д���',
                   '6',
                   '����-�û�άϵ',
                   '7',
                   '����-�û���ȡ',
                   '8',
                   '���ֶһ�',
                   '9',
                   '����')
       from tf_r_tml_saletrade ts
      where ts.saletrade_id = t.sale_log_id
        and ts.sale_type = '3'
        and ts.province_code in ('10','13','70','84','97'))
   else
    ''
 end fy_State,
 case
   when t.terminal_state = '8' then
    (select trim(ts.out_type)
       from tf_r_tml_saletrade ts
      where ts.saletrade_id = t.sale_log_id
        and ts.sale_type = '3'
        and ts.province_code in ('10','13','70','84','97'))
   else
    ''
 end no_store_out_type,
 case
   when t.terminal_state = '8' then
    (select decode(trim(ts.out_type),
                   '1',
                   '�̿�',
                   '2',
                   '����',
                   '3',
                   '��ʾ��',
                   '4',
                   '���Գ���',
                   '5',
                   '����-�д���',
                   '6',
                   '����-�û�άϵ',
                   '7',
                   '����-�û���ȡ',
                   '8',
                   '���ֶһ�',
                   '9',
                   '����')
       from tf_r_tml_saletrade ts
      where ts.saletrade_id =t.sale_log_id 
        and ts.sale_type = '3'
        and ts.province_code in ('10','13','70','84','97'))
   else
    ''
 end no_store_out_type_desc
  FROM tf_r_tml_arch        t,
       td_r_terminal_propty a,
       td_m_matmac_ref      b,
       tf_r_stock           rs,
       td_m_province        c,
       te_rsid_rsidout      rr
 WHERE t.property_id = a.property_id
   AND a.property_code = b.machine_type_code
   AND t.stock_id = rs.stock_id
   AND t.province_id = c.province_code
   and b.material_code = rr.rsidout
   AND t.province_id in ('10','13','70','84','97')
   and t.package_code = b.package_code
   and rs.res_type_code = '1'
   and rs.province_id in ('10','13','70','84','97')
   AND t.terminal_state in ('1', '2', '3','4','5', '8', 'B')
   and not exists (select 1
          from tf_r_tml_arch_transition tat
         where tat.terminal_id = t.terminal_id);
commit;
--arch���̻��ն�--     
insert /*+append*/into RC_STOCK
 SELECT /*+parallel(t,10)*/
   trim(t.terminal_id) RS_IMEI,
   rr.rsid RS_ID,
   (case when exists (select 1 from tf_r_stock rs where rs.depart_id=rt.channel_id and rs.res_type_code='1' and rs.valid_flag='1' and rs.province_id in ('10','13','70','84','97'))
  then (select rs.stock_id from tf_r_stock rs where rs.depart_id=rt.channel_id and rs.res_type_code='1' and rs.valid_flag='1' and rs.province_id in ('10','13','70','84','97') and rownum=1)
    else case when exists (select 1 from tf_r_stock rs where rs.depart_id=rt.channel_id and rs.res_type_code='1' and rs.valid_flag='0' and rs.province_id in ('10','13','70','84','97'))
      and not exists (select 1 from tf_r_stock rs where rs.depart_id=rt.channel_id and rs.res_type_code='1' and rs.valid_flag='1' and rs.province_id in ('10','13','70','84','97')) 
  then (select rs.stock_id from tf_r_stock rs where rs.depart_id=rt.channel_id and rs.res_type_code='1' and rs.valid_flag='0' and rownum=1 and rs.province_id in ('10','13','70','84','97'))
   else 
   substr(rt.channel_id, 3, length(rt.channel_id)) end end )DEPOT_ID,
   decode(rt.tandem_code_state,'0',
          '2',
          '1',
          '2',
          'B',
          '2',
          'A',
          '2',
          '2',
          '5',
          '3',
          '8',
          'C',
          '5') STATE,
   t.province_id PROVINCE_CODE,
   t.eparchy_code EPARCHY_CODE,
   '123' SHEL_NO,
   '456' SEAT_NO,
   rt.record_time RECORD_DATE,
   '' CONTRACT_NO,
  substr(rt.channel_id, 3, length(rt.channel_id)) DEPART_IN,
   substr(rt.record_staff, 3, length(rt.record_staff)) STAFF_IN,
   rt.record_time TIME_IN,
   sysdate UPDATE_TIME,
   '3GESS���' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id REMARK,
   a.property_name rsName,
 (case
   when exists (select 1
           from tf_r_stock rs
          where rs.depart_id = rt.channel_id
            and rs.res_type_code = '1'
            and rs.valid_flag = '1'
            and rs.province_id in ('10','13','70','84','97')) then
    (select rs.stock_name
       from tf_r_stock rs
      where rs.depart_id = rt.channel_id
        and rs.res_type_code = '1'
        and rs.valid_flag = '1'
        and rs.province_id in ('10','13','70','84','97')
        and rownum = 1)
   else
    case
      when exists (select 1
              from tf_r_stock rs
             where rs.depart_id = rt.channel_id
               and rs.res_type_code = '1'
               and rs.province_id in ('10','13','70','84','97')
               and rs.valid_flag = '0') and not exists
       (select 1
              from tf_r_stock rs
             where rs.depart_id = rt.channel_id
               and rs.res_type_code = '1'
               and rs.valid_flag = '1'
               and rs.province_id in ('10','13','70','84','97')) then
       (select rs.stock_name
          from tf_r_stock rs
         where rs.depart_id = rt.channel_id
           and rs.res_type_code = '1'
           and rs.valid_flag = '0'
           and rs.province_id in ('10','13','70','84','97')
           and rownum = 1)
      else
       (select cc.channel_name
          from tf_c_channel cc
         where cc.channel_id = rt.channel_id
           and cc.province_id in ('10','13','70','84','97'))
    end
 end) depotName,
   decode(rt.tandem_code_state,
          '0',
          '����',
          '1',
          '����',
          'B',
          '����',
          'A',
          '����',
          '2',
          '���۳���',
          '3',
          '���ϻ�',
          'C',
          '���۳���') stateDesc,
   c.province_name provinceName,
   (select me.eparchy_name
      from td_m_eparchy me
     where me.eparchy_code = t.eparchy_code and me.province_code in ('10','13','70','84','97')) eparchyName,
    (select cc.channel_name
      from tf_c_channel cc
     where cc.channel_id = rt.channel_id) departInName,
  (select mf.staff_name from tf_m_staff mf where mf.staff_id=rt.record_staff and mf.province_code in ('10','13','70','84','97')) staffInName,
   a.terminal_type_code resTypeCode,
   (SELECT p.param_name
      FROM TD_B_COMMPARA P
     WHERE P.PARAM_ATTR = '1520'
       and p.param_name not like '4G%'
       and p.param_code = a.terminal_type_code) resTypeDesc,
   a.terminal_brand_code resBrandCode,
   a.terminal_brand_desc resBrandDesc,
   a.terminal_model_code resModelCode,
   a.terminal_model_desc resModelDesc,
   '1',
   '' fy_State,
   '',
   ''
    FROM tf_r_tml_arch        t,
         td_r_terminal_propty a,
         td_m_matmac_ref      b,
         tf_r_tandem_code     rt,
         td_m_Province        c,
         te_rsid_rsidout      rr
   WHERE t.property_id = a.property_id
     AND a.property_code = b.machine_type_code
     AND t.terminal_id = rt.tandem_code
     and t.package_code = b.package_code
     and b.material_code = rr.rsidout
     AND t.province_id = c.province_code
     AND t.terminal_state = '9'
     AND rt.distribution_tag = '1'
     AND t.province_id in ('10','13','70','84','97')
     and rt.province_code in ('10','13','70','84','97')
     and not exists (select 1
          from tf_r_tml_arch_transition tat
         where tat.terminal_id = t.terminal_id);
commit;

--ת�������ն˴���--
insert /*+append*/into RC_STOCK
  SELECT /*+parallel(ah,10)*/
   trim(ah.terminal_id) RS_IMEI,
   rr.rsid RS_ID,
   ah.channel_code DEPOT_ID,
   decode(ah.terminal_state, '1', '2', '3', '5', '4', '8', 'B', '2') STATE,
   ah.province_code PROVINCE_CODE,
   (select cc.city_id
      from tf_c_channel cc
     where cc.channel_code = ah.channel_code and cc.province_id in ('10','13','70','84','97')) EPARCHY_CODE,
   '123' SHEL_NO,
   '456' SEAT_NO,
   ah.update_time RECORD_DATE,
   '' CONTRACT_NO,
   ah.channel_code DEPART_IN,
   '3GESS���' STAFF_IN,
   ah.batchin_time TIME_IN,
   ah.update_time UPDATE_TIME,
   '3GESS���' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || ah.province_code REMARK,
   a.property_name rsName,
   (select cc.channel_name
      from tf_c_channel cc
     where cc.channel_code = ah.channel_code and cc.province_id in ('10','13','70','84','97')) depotName,
   decode(ah.terminal_state,
          '1',
          '����',
          '3',
          '���۳���',
          '4',
          '���ϻ�',
          'B',
          '����') stateDesc,
   c.province_name provinceName,
   (select me.eparchy_name
      from tf_c_channel cc, td_m_eparchy me
     where cc.channel_code = ah.channel_code
       and cc.city_id = me.eparchy_code and me.province_code in ('10','13','70','84','97')) eparchyName,
   (select cc.channel_name
      from tf_c_channel cc
     where cc.channel_code = ah.channel_code and cc.province_id in ('10','13','70','84','97')) departInName,
   '3GESS���' staffInName,
   a.terminal_type_code resTypeCode,
   (SELECT p.param_name
      FROM TD_B_COMMPARA P
     WHERE P.PARAM_ATTR = '1520'
       and p.param_name not like '4G%'
       and p.param_code = a.terminal_type_code) resTypeDesc,
   a.terminal_brand_code resBrandCode,
   a.terminal_brand_desc resBrandDesc,
   a.terminal_model_code resModelCode,
   a.terminal_model_desc resModelDesc,
   '1',
   '' fy_State,
   '',
   ''
    FROM tf_r_tml_arch_transition ah,
         td_r_terminal_propty     a,
         td_m_matmac_ref          b,
         td_m_province            c,
         te_rsid_rsidout          rr
   WHERE ah.property_id = a.property_id
     AND a.property_code = b.machine_type_code
     and ah.province_code = c.province_code
     and b.material_code = rr.rsidout
     AND ah.province_code in ('10','13','70','84','97')
     and b.package_code = '10';
commit;
--tf_r_tml_arch_migration--
insert /*+append*/into RC_STOCK
SELECT /*+parallel(t,10)*/
 trim(t.terminal_id) RS_IMEI,
 rr.rsid RS_ID,
 t.stock_id DEPOT_ID,
'5' STATE,
 t.province_id PROVINCE_CODE,
 t.eparchy_code EPARCHY_CODE,
 '123' SHEL_NO,
 '456' SEAT_NO,
 t.batch_in_time RECORD_DATE,
 '' CONTRACT_NO,
  substr(rs.depart_id, 3, length(rs.depart_id)) DEPART_IN,
 substr(t.staff_id_in, 3, length(t.staff_id_in)) STAFF_IN,
 t.batch_in_time TIME_IN,
 t.update_time UPDATE_TIME,
 '3GESS���' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || t.province_id REMARK,
 a.property_name rsName,
 rs.stock_name depotName,
 '���۳���' stateDesc,
 c.province_name provinceName,
 (select me.eparchy_name
    from td_m_eparchy me
   where me.eparchy_code = t.eparchy_code and me.province_code in ('10','13','70','84','97')) eparchyName,
 (select md.depart_name
    from td_m_depart md
   where md.depart_id = rs.depart_id and md.province_code in ('10','13','70','84','97')) departInName,
 (select mf.staff_name from tf_m_staff mf where mf.staff_id=t.staff_id_in and mf.province_code in ('10','13','70','84','97')) staffInName,
 a.terminal_type_code resTypeCode,
 (SELECT p.param_name
    FROM TD_B_COMMPARA P
   WHERE P.PARAM_ATTR = '1520'
     and p.param_name not like '4G%'
     and p.param_code = a.terminal_type_code) resTypeDesc,
 a.terminal_brand_code resBrandCode,
 a.terminal_brand_desc resBrandDesc,
 a.terminal_model_code resModelCode,
 a.terminal_model_desc resModelDesc,
 '1',
    '' fy_State,
    '' no_store_out_type,
    '' no_store_out_type_desc
  FROM tf_r_tml_arch_migration t,
       td_r_terminal_propty a,
       td_m_matmac_ref      b,
       tf_r_stock           rs,
       td_m_province        c,
       te_rsid_rsidout      rr
 WHERE t.property_id = a.property_id
   AND a.property_code = b.machine_type_code
   AND t.stock_id = rs.stock_id
   AND t.province_id = c.province_code
   and b.material_code = rr.rsidout
   AND t.province_id in ('10','13','70','84','97')
   and rs.province_id in ('10','13','70','84','97')
   and t.package_code = b.package_code
   and rs.res_type_code = '1'
   and not exists(select 1
          from rc_stock ar
         where ar.RS_IMEI = t.terminal_id);
commit;