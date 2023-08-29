----计算资源数量
declare
begin
  for i in (select /*+ parallel(t1,10) */
 t1.rs_id,
 t1.depot_id,
 t1.province_code,
 t1.eparchy_code,
 t1.rsname,
 t1.depotname,
 t1.provincename,
 t1.EPARCHYNAME,
 t1.rs_num rs_num,
 sum(t1.v_sum) lock_num
  from (select /*+ parallel(t,10) */
         t.rs_id,
         t.depot_id,
         t.province_code,
         t.eparchy_code,
         t.rsname,
         t.depotname,
         t.provincename,
         t.EPARCHYNAME,
         sum(count(1)) over(partition by t.depot_id,t.rs_id ) rs_num,
          case when t.state='8' then count(1) else 0 end v_sum
          from rc_stock t
         where exists (select 1
                  from rc_depot a
                 where t.depot_id = a.depot_id
                   and t.province_code = a.province_code)
           and t.state in ('2', '8')
         group by t.rs_id,
                  t.depot_id,
                  t.province_code,
                  t.eparchy_code,
                  t.rsname,
                  t.depotname,
                  t.provincename,
                  t.EPARCHYNAME,
                  t.state) t1
 group by t1.rs_id,
          t1.depot_id,
          t1.province_code,
          t1.eparchy_code,
          t1.rsname,
          t1.depotname,
          t1.provincename,
          t1.EPARCHYNAME,
          t1.rs_num ) loop
    insert into rc_depot_res
      (trdr_id,
       rs_id,
       depot_id,
       rs_num,
       lock_num,
       contract_no,
       province_code,
       eparchy_code,
       record_date,
       update_time,
       remark,
       rsname,
       depotname,
       provincename,
       EPARCHYNAME)
    values
      (seq_sku.nextval,
       i.rs_id,
       i.depot_id,
       i.rs_num,
       i.lock_num,
       null,
       i.province_code,
       i.eparchy_code,
       sysdate,
       sysdate,
       '3GESS割接' || '-' || to_char(sysdate, 'yyyymmdd') || '-' || i.province_code,
       i.rsname,
       i.depotname,
       i.provincename,
       i.EPARCHYNAME);
    commit;
  end loop;
    commit;
end;
/
