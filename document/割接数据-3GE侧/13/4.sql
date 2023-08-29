insert into rc_factory
  select to_char(t.factory_code) factory_code,
          t.factory_name factory_name,
          '1' FACTORY_TYPE,
          '3GESS割接' ADDRESS,
          '3GESS割接' CONTACT_NAME,
          '0000000' CONTACT_TEL,
          t.validate_flag VALIDATE_FLAG,
          substr(t.update_depart,3,length(t.update_depart)) UPDATE_DEPART_ID,
          substr(t.update_staff,3,length(t.update_staff))  UPDATE_STAFF_ID,
          t.update_time UPDATE_TIME,
          '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') REMARK,
          '生产商' FACTORY_TYPE_DESC,
          '10'     PLATFORM,
          '联通自营' PLATFORM_NAME,
          '98' PROVINCE_CODE,
          '联通总部' PROVINCE_NAME
          from td_r_terminal_factory t
    where t.validate_flag = '0'
    and not exists (select 1 from rc_factory a where a.factory_code=t.factory_code)
   union all
   select t.intproxy_code factory_code,
          t.intproxy_name factory_name,
          '2' FACTORY_TYPE,
          '3GESS割接' ADDRESS,
          '3GESS割接' CONTACT_NAME,
          '0000000' CONTACT_TEL,
          t.validate_flag VALIDATE_FLAG,
          substr(t.update_depart,3,length(t.update_depart)) UPDATE_DEPART_ID,
          substr(t.update_staff,3,length(t.update_staff))  UPDATE_STAFF_ID,
          t.update_time UPDATE_TIME,
          '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') REMARK,
          '供应商' FACTORY_TYPE_DESC,
          '10'   PLATFORM,
          '联通自营' PLATFORM_NAME,
          t.province_id PROVINCE_CODE,
          a.province_name PROVINCE_NAME 
     from td_r_terminal_intproxy t,td_m_province a
    where t.province_id=a.province_code
    and t.validate_flag = '0'
    and not exists (select 1 from rc_factory b where b.factory_code=t.intproxy_code);
commit;