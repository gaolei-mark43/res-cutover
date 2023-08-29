truncate table rc_depot;
insert /*+append*/ into rc_depot
---------实体仓库-----------
select a.stock_id as DEPOT_ID,
       a.stock_name as DEPOT_NAME,
       '1' as DEPOT_TYPE,
       a.stock_level as DEPOT_LEVEL,
       a.stock_address as DEPOT_ADDRE,
       a.parent_stock_id as SUP_DEPOT_ID,
       '1' as LON,
       '1' as LAT,
       a.contact_name as CONTACT_NAME,
       a.contact_tel as CONTACT_TEL,
       a.province_id as PROVINCE_CODE,
       a.eparchy_code as EPARCHY_CODE,
       b.city_code as CITY_CODE,
       (case when b.channel_id is null then
          b.bss_depart_code
         else
          b.parent_depart_code
       end) as DEPART_ID,
       '0' as STATE,
       a.update_time as UPDATE_TIME,
       (select cc.channel_code
          from tf_c_channel cc
         where cc.channel_id = b.channel_id and cc.province_id in ('36')) as CHNL_CODE,
       '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id as REMARK,
       mp.province_name as PROVINCENAME,
       (select me.eparchy_name
          from td_m_eparchy me
         where me.eparchy_code = a.eparchy_code and me.province_code in ('36')) as EPARCHYNAME,
       (select ma.area_name
          from td_m_area ma
         where ma.province_code = a.province_id
           and ma.bss_area_code = b.city_code
           and ma.province_code in ('36')
           and ma.validflag = '10') as CITYNAME,
       (case when b.channel_id is null then
          (select md.depart_name
             from td_m_depart md
            where md.depart_id = b.depart_id)
         else
          (select md.depart_name
             from td_m_depart md
            where md.depart_id = b.parent_depart_id)
       end) as DEPARTNAME,
       '实体仓库' as DEPOTTYPEDESC,
       (select cc.channel_name
          from tf_c_channel cc
         where cc.channel_id = b.channel_id) chnlName
  from tf_r_stock a, td_m_depart b, td_m_province mp
 where a.depart_id = b.depart_id
   and a.province_id = mp.province_code
   and a.province_id in ('36')
   and b.validflag = '0'
   and a.valid_flag = '1'
   and a.res_type_code = '1'
union all
------逻辑仓库------
select t.channel_code as DEPOT_ID,
       t.channel_name as DEPOT_NAME,
       '2' as DEPOT_TYPE,
       '1' as DEPOT_LEVEL,
       t.channel_detail_addr as DEPOT_ADDRE,
       '' as SUP_DEPOT_ID,
       '1' as LON,
       '1' as LAT,
       t.contact_name as CONTACT_NAME,
       t.contact_tel as CONTACT_TEL,
       t.province_id as PROVINCE_CODE,
       t.city_id as EPARCHY_CODE,
       t.district_id as CITY_CODE,
       a.parent_depart_code as DEPART_ID,
       '0' as STATE,
       a.update_time as UPDATE_TIME,
       t.channel_code as CHNL_CODE,
       '3GESS割接'||'-'||to_char(sysdate,'yyyymmdd')||'-'||t.province_id as REMARK,
       mp.province_name as PROVINCENAME,
       (select me.eparchy_name
          from td_m_eparchy me
         where me.eparchy_code = t.city_id and me.province_code in ('36')) as EPARCHYNAME,
       (select ma.area_name
          from td_m_area ma
         where ma.province_code = t.province_id
           and ma.bss_area_code = t.district_id
           and ma.province_code in ('36')
           and ma.validflag = '10') as CITYNAME,
       (select md.depart_name from td_m_depart md where md.depart_id=a.parent_depart_id) as DEPARTNAME,
       '逻辑仓库' as DEPOTTYPEDESC,
       t.channel_name chnlName
  from tf_c_channel t, td_m_depart a, td_m_province mp
 where t.province_id = mp.province_code
   and t.channel_id = a.channel_id
   and t.province_id in ('36')
   and t.channel_state = '10'
   and t.transition_tag = '1'
union all
--------铺货社会渠道实体仓库-----------
select t.channel_code as DEPOT_ID,
       t.channel_name as DEPOT_NAME,
       '1' as DEPOT_TYPE,
       '1' as DEPOT_LEVEL,
       t.channel_detail_addr as DEPOT_ADDRE,
       '' as SUP_DEPOT_ID,
       '1' as LON,
       '1' as LAT,
       t.contact_name as CONTACT_NAME,
       t.contact_tel as CONTACT_TEL,
       t.province_id as PROVINCE_CODE,
       t.city_id as EPARCHY_CODE,
       t.district_id as CITY_CODE,
       a.parent_depart_code as DEPART_ID,
       '0' as STATE,
       a.update_time as UPDATE_TIME,
       t.channel_code as CHNL_CODE,
       '3GESS割接'||'-'||to_char(sysdate,'yyyymmdd')||'-'||t.province_id as REMARK,
       mp.province_name as PROVINCENAME,
       (select me.eparchy_name
          from td_m_eparchy me
         where me.eparchy_code = t.city_id and me.province_code in ('36')) as EPARCHYNAME,
       (select ma.area_name
          from td_m_area ma
         where ma.province_code = t.province_id
           and ma.bss_area_code = t.district_id
           and ma.province_code in ('36')
           and ma.validflag = '10') as CITYNAME,
       (select md.depart_name from td_m_depart md where md.depart_id=a.parent_depart_id) as DEPARTNAME,
       '实体仓库' as DEPOTTYPEDESC,
       t.channel_name chnlName
  from tf_c_channel t, td_m_depart a, td_m_province mp
 where t.province_id = mp.province_code
   and t.channel_id = a.channel_id
   and t.province_id in ('36')
   and t.channel_state = '10'
   and a.validflag = '0'
   and exists (select /*+parallel(rtc,10)*/
         1
          from tf_r_tandem_code rtc
         where rtc.channel_id = t.channel_id
           and rtc.distribution_tag = '1')
     and not exists (select 1 from tf_r_stock ts where ts.depart_id=t.channel_id and ts.res_type_code='1');
commit;

---失效的实体仓库-----
insert /*+append*/ into rc_depot
select a.stock_id as DEPOT_ID,
       a.stock_name as DEPOT_NAME,
       '1' as DEPOT_TYPE,
       a.stock_level as DEPOT_LEVEL,
       a.stock_address as DEPOT_ADDRE,
       a.parent_stock_id as SUP_DEPOT_ID,
       '1' as LON,
       '1' as LAT,
       a.contact_name as CONTACT_NAME,
       a.contact_tel as CONTACT_TEL,
       a.province_id as PROVINCE_CODE,
       a.eparchy_code as EPARCHY_CODE,
       b.city_code as CITY_CODE,
       (case when b.channel_id is null then
          b.bss_depart_code
         else
          b.parent_depart_code
       end) as DEPART_ID,
       '1' as STATE,
       a.update_time as UPDATE_TIME,
       (select cc.channel_code
          from tf_c_channel cc
         where cc.channel_id = b.channel_id) as CHNL_CODE,
       '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' ||
       a.province_id as REMARK,
       mp.province_name as PROVINCENAME,
       (select me.eparchy_name
          from td_m_eparchy me
         where me.eparchy_code = a.eparchy_code and me.province_code in ('36')) as EPARCHYNAME,
       (select ma.area_name
          from td_m_area ma
         where ma.province_code = a.province_id
           and ma.bss_area_code = b.city_code
           and ma.province_code in ('36')
           and ma.validflag = '10') as CITYNAME,
       (case when b.channel_id is null then
          (select md.depart_name
             from td_m_depart md
            where md.depart_id = b.depart_id)
         else
          (select md.depart_name
             from td_m_depart md
            where md.depart_id = b.parent_depart_id)
       end) as DEPARTNAME,
       '实体仓库' as DEPOTTYPEDESC,
       (select cc.channel_name
          from tf_c_channel cc
         where cc.channel_id = b.channel_id) chnlName
  from tf_r_stock a, td_m_depart b, td_m_province mp
 where a.depart_id = b.depart_id(+)
   and a.province_id = mp.province_code
   and a.province_id in ('36')
   and a.valid_flag = '0'
   and a.res_type_code = '1' 
union all
select a.stock_id as DEPOT_ID,
       a.stock_name as DEPOT_NAME,
       '1' as DEPOT_TYPE,
       a.stock_level as DEPOT_LEVEL,
       a.stock_address as DEPOT_ADDRE,
       a.parent_stock_id as SUP_DEPOT_ID,
       '1' as LON,
       '1' as LAT,
       a.contact_name as CONTACT_NAME,
       a.contact_tel as CONTACT_TEL,
       a.province_id as PROVINCE_CODE,
       a.eparchy_code as EPARCHY_CODE,
       b.city_code as CITY_CODE,
       (case when b.channel_id is null then
          b.bss_depart_code
         else
          b.parent_depart_code
       end) as DEPART_ID,
       '1' as STATE,
       a.update_time as UPDATE_TIME,
       (select cc.channel_code
          from tf_c_channel cc
         where cc.channel_id = b.channel_id) as CHNL_CODE,
       '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id as REMARK,
       mp.province_name as PROVINCENAME,
       (select me.eparchy_name
          from td_m_eparchy me
         where me.eparchy_code = a.eparchy_code and me.province_code in ('36')) as EPARCHYNAME,
       (select ma.area_name
          from td_m_area ma
         where ma.province_code = a.province_id
           and ma.bss_area_code = b.city_code
           and ma.province_code in ('36')
           and ma.validflag = '10') as CITYNAME,
       (case when b.channel_id is null then
          (select md.depart_name
             from td_m_depart md
            where md.depart_id = b.depart_id)
         else
          (select md.depart_name
             from td_m_depart md
            where md.depart_id = b.parent_depart_id)
       end) as DEPARTNAME,
       '实体仓库' as DEPOTTYPEDESC,
       (select cc.channel_name
          from tf_c_channel cc
         where cc.channel_id = b.channel_id) chnlName
  from tf_r_stock a, td_m_depart b, td_m_province mp
 where a.depart_id = b.depart_id
   and a.province_id = mp.province_code
   and a.province_id in ('36')
   and b.validflag <> '0'
   and a.valid_flag = '1'
   and a.res_type_code = '1'
union all
select a.stock_id as DEPOT_ID,
       a.stock_name as DEPOT_NAME,
       '1' as DEPOT_TYPE,
       a.stock_level as DEPOT_LEVEL,
       a.stock_address as DEPOT_ADDRE,
       a.parent_stock_id as SUP_DEPOT_ID,
       '1' as LON,
       '1' as LAT,
       a.contact_name as CONTACT_NAME,
       a.contact_tel as CONTACT_TEL,
       a.province_id as PROVINCE_CODE,
       a.eparchy_code as EPARCHY_CODE,
       '' CITY_CODE,
       '' DEPART_ID,
       '1' as STATE,
       a.update_time as UPDATE_TIME,
       '' as CHNL_CODE,
       '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || a.province_id as REMARK,
       mp.province_name as PROVINCENAME,
       (select me.eparchy_name
          from td_m_eparchy me
         where me.eparchy_code = a.eparchy_code and me.province_code in ('36')) as EPARCHYNAME,
       '' CITYNAME,
     '' DEPARTNAME,
       '实体仓库' as DEPOTTYPEDESC,
       '' chnlName
  from tf_r_stock a, td_m_province mp
 where a.depart_id not in (
 select c.depart_id from td_m_depart c where c.province_code in ('36'))
   and a.province_id = mp.province_code
   and a.province_id in ('36')
   and a.valid_flag = '1'
   and a.res_type_code = '1';
commit;
------失效逻辑仓库------
insert /*+append*/ into rc_depot
select t.channel_code as DEPOT_ID,
       t.channel_name as DEPOT_NAME,
       '2' as DEPOT_TYPE,
       '1' as DEPOT_LEVEL,
       t.channel_detail_addr as DEPOT_ADDRE,
       '' as SUP_DEPOT_ID,
       '1' as LON,
       '1' as LAT,
       t.contact_name as CONTACT_NAME,
       t.contact_tel as CONTACT_TEL,
       t.province_id as PROVINCE_CODE,
       t.city_id as EPARCHY_CODE,
       t.district_id as CITY_CODE,
       a.parent_depart_code as DEPART_ID,
       '1' as STATE,
       a.update_time as UPDATE_TIME,
       t.channel_code as CHNL_CODE,
       '3GESS割接'||'-'||to_char(sysdate,'yyyymmdd')||'-'||t.province_id as REMARK,
       mp.province_name as PROVINCENAME,
       (select me.eparchy_name
          from td_m_eparchy me
         where me.eparchy_code = t.city_id and me.province_code in ('36')) as EPARCHYNAME,
       (select ma.area_name
          from td_m_area ma
         where ma.province_code = t.province_id
           and ma.bss_area_code = t.district_id
           and ma.province_code in ('36')
           and ma.validflag = '10') as CITYNAME,
       (select md.depart_name from td_m_depart md where md.depart_id=a.parent_depart_id) as DEPARTNAME,
       '逻辑仓库' as DEPOTTYPEDESC,
       t.channel_name chnlName
  from tf_c_channel t, td_m_depart a, td_m_province mp
 where t.province_id = mp.province_code
   and t.channel_id = a.channel_id
   and t.province_id in ('36')
   and t.channel_state <> '10'
   and t.transition_tag = '1';
commit;

insert /*+append*/ into rc_depot
select t.channel_code as DEPOT_ID,
       t.channel_name as DEPOT_NAME,
       '2' as DEPOT_TYPE,
       '1' as DEPOT_LEVEL,
       t.channel_detail_addr as DEPOT_ADDRE,
       '' as SUP_DEPOT_ID,
       '1' as LON,
       '1' as LAT,
       t.contact_name as CONTACT_NAME,
       t.contact_tel as CONTACT_TEL,
       t.province_id as PROVINCE_CODE,
       t.city_id as EPARCHY_CODE,
       t.district_id as CITY_CODE,
       a.parent_depart_code as DEPART_ID,
       '1' as STATE,
       a.update_time as UPDATE_TIME,
       t.channel_code as CHNL_CODE,
       '3GESS割接'||'-'||to_char(sysdate,'yyyymmdd')||'-'||t.province_id as REMARK,
       mp.province_name as PROVINCENAME,
       (select me.eparchy_name
          from td_m_eparchy me
         where me.eparchy_code = t.city_id and me.province_code in ('36')) as EPARCHYNAME,
       (select ma.area_name
          from td_m_area ma
         where ma.province_code = t.province_id
           and ma.bss_area_code = t.district_id
           and ma.province_code in ('36')
           and ma.validflag = '10') as CITYNAME,
       (select md.depart_name from td_m_depart md where md.depart_id=a.parent_depart_id) as DEPARTNAME,
       '逻辑仓库' as DEPOTTYPEDESC,
       t.channel_name chnlName
  from tf_c_channel t, td_m_depart a, td_m_province mp
 where t.province_id = mp.province_code
   and t.channel_id = a.channel_id
   and t.province_id in ('36')
   and t.transition_tag <>'1'
   and exists(
   select /*+parallel(ta,10)*/1 from tf_r_tml_arch_transition ta where t.channel_code=ta.channel_code) ;
commit;

--------失效铺货社会渠道实体仓库-----------
insert /*+append*/ into rc_depot
select t.channel_code as DEPOT_ID,
       t.channel_name as DEPOT_NAME,
       '1' as DEPOT_TYPE,
       '1' as DEPOT_LEVEL,
       t.channel_detail_addr as DEPOT_ADDRE,
       '' as SUP_DEPOT_ID,
       '1' as LON,
       '1' as LAT,
       t.contact_name as CONTACT_NAME,
       t.contact_tel as CONTACT_TEL,
       t.province_id as PROVINCE_CODE,
       t.city_id as EPARCHY_CODE,
       t.district_id as CITY_CODE,
       a.parent_depart_code as DEPART_ID,
       '1' as STATE,
       a.update_time as UPDATE_TIME,
       t.channel_code as CHNL_CODE,
       '3GESS割接'||'-'||to_char(sysdate,'yyyymmdd')||'-'||t.province_id as REMARK,
       mp.province_name as PROVINCENAME,
       (select me.eparchy_name
          from td_m_eparchy me
         where me.eparchy_code = t.city_id and me.province_code in ('36')) as EPARCHYNAME,
       (select ma.area_name
          from td_m_area ma
         where ma.province_code = t.province_id
           and ma.bss_area_code = t.district_id
           and ma.province_code in ('36')
           and ma.validflag = '10') as CITYNAME,
       (select md.depart_name from td_m_depart md where md.depart_id=a.parent_depart_id) as DEPARTNAME,
       '实体仓库' as DEPOTTYPEDESC,
       t.channel_name chnlName
  from tf_c_channel t, td_m_depart a, td_m_province mp
 where t.province_id = mp.province_code
   and t.channel_id = a.channel_id
   and t.province_id in ('36')
   and t.channel_state <> '10'  
   and exists (select /*+parallel(rtc,10)*/
         1
          from tf_r_tandem_code rtc
         where rtc.channel_id = t.channel_id
           and rtc.distribution_tag = '1')
   and not exists (select 1 from tf_r_stock ts where ts.depart_id=t.channel_id and ts.res_type_code='1');
commit; 
