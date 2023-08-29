truncate table rc_stock_in;
insert /*+ append*/ into rc_stock_in
select /*+ parallel(t,15) */t.rs_imei from rc_stock t;
commit;

drop index INDEX_IMEI;
commit;

insert /*+ append*/
into RC_STOCK
select /*+ leading(rt rsf) full(rt) parallel(rt,10)*/
   trim(rt.tandem_code) RS_IMEI,
   rr.rsid RS_ID,
   d2.depot_id depot_id, --��������ֿ����
   decode(rt.tandem_code_state,
          '0',
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
   rt.province_code PROVINCE_CODE,
   '000' EPARCHY_CODE,
   '123' SHEL_NO,
   '456' SEAT_NO,
   rt.record_time RECORD_DATE,
   '' CONTRACT_NO,
   '3GESS���' DEPART_IN,
   '3GESS���' STAFF_IN,
   rt.record_time TIME_IN,
   sysdate UPDATE_TIME,
   '3GESS���' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || rt.province_code REMARK,
   a.property_name rsName,
   d2.depot_name depotName,
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
          '���۳���') STATE,
   c.province_name provinceName,
   '��ͨ�ܲ�' eparchyName,
   '3GESS���' departInName,
   rt.record_staff staffInName,
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
    from tf_r_tandem_code     rt,
         td_m_matmac_ref      b,
         td_r_terminal_propty a,
         td_m_province        c,
         te_rsid_rsidout      rr,
         rc_depot_20 d2
   where rt.machine_type_code = b.machine_type_code
     and rt.province_code = c.province_code
     and rt.machine_type_code = a.property_code
     and b.material_code = rr.rsidout
     and rt.province_code=d2.province_code
     and rt.province_code in ('97')
     and rt.package_code = b.package_code
     and not EXISTS(select 1 from rc_stock_in rsf where rsf.rs_imei = rt.tandem_code);
COMMIT;

create index INDEX_IMEI on RC_STOCK (RS_IMEI)
  tablespace USERS
  pctfree 10
  initrans 2
  maxtrans 255
  storage
  (
    initial 64K
    minextents 1
    maxextents unlimited
  ) parallel 10;
 COMMIT;
 
 alter index INDEX_IMEI noparallel;
 COMMIT;