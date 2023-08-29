insert into rc_factory
  select to_char(t.factory_code) factory_code,
          t.factory_name factory_name,
          '1' FACTORY_TYPE,
          '3GESS���' ADDRESS,
          '3GESS���' CONTACT_NAME,
          '0000000' CONTACT_TEL,
          t.validate_flag VALIDATE_FLAG,
          substr(t.update_depart,3,length(t.update_depart)) UPDATE_DEPART_ID,
          substr(t.update_staff,3,length(t.update_staff))  UPDATE_STAFF_ID,
          t.update_time UPDATE_TIME,
          '3GESS���' || '-' || to_char(sysdate, 'yyyymmdd') REMARK,
          '������' FACTORY_TYPE_DESC,
          '10'     PLATFORM,
          '��ͨ��Ӫ' PLATFORM_NAME,
          '98' PROVINCE_CODE,
          '��ͨ�ܲ�' PROVINCE_NAME
          from td_r_terminal_factory t
    where t.validate_flag = '0'
    and not exists (select 1 from rc_factory a where a.factory_code=t.factory_code)
   union all
   select t.intproxy_code factory_code,
          t.intproxy_name factory_name,
          '2' FACTORY_TYPE,
          '3GESS���' ADDRESS,
          '3GESS���' CONTACT_NAME,
          '0000000' CONTACT_TEL,
          t.validate_flag VALIDATE_FLAG,
          substr(t.update_depart,3,length(t.update_depart)) UPDATE_DEPART_ID,
          substr(t.update_staff,3,length(t.update_staff))  UPDATE_STAFF_ID,
          t.update_time UPDATE_TIME,
          '3GESS���' || '-' || to_char(sysdate, 'yyyymmdd') REMARK,
          '��Ӧ��' FACTORY_TYPE_DESC,
          '10'   PLATFORM,
          '��ͨ��Ӫ' PLATFORM_NAME,
          t.province_id PROVINCE_CODE,
          a.province_name PROVINCE_NAME 
     from td_r_terminal_intproxy t,td_m_province a
    where t.province_id=a.province_code
    and t.validate_flag = '0'
    and not exists (select 1 from rc_factory b where b.factory_code=t.intproxy_code);
commit;