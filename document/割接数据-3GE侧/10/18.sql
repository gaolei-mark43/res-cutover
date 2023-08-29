truncate table rc_terminal_consig;
insert into rc_terminal_consig
select /*+parallel(t,10)(a,10)*/
 t.province_id,
 t.terminal_id,
 a.send_trade_id,
 a.refdlerp_no,
 a.update_time
  from tf_r_tml_arch t, tf_r_tml_consig a
 where t.send_log_id = a.send_trade_id
   and t.province_id in ('10');
commit;
insert /*+append*/ into rc_terminal_consig
select /*+parallel(t,10)*/ t.province_code,
       t.terminal_id,
       t.send_trade_id,
       t.send_trade_id,
       t.sale_time
  from tf_virtual_consig_detail t
 where t.province_code in ('10') and t.sale_time between
       to_date('20170601 00:00:00', 'yyyymmdd hh24:mi:ss') and sysdate;
commit;