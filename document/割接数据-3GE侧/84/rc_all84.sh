sqlplus -s UQRY_CHANGQ_CT/Hgrl84pM5r@ESSDB3 <<EOF
prompt 第1步;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') start_time from dual;
@/3gess/expdp/84/1.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第2步资源详细信息;
@/3gess/expdp/84/2.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第3步TAC码表;
@/3gess/expdp/84/3.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第4步合作商表;
@/3gess/expdp/84/4.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第14步终端扩展属性（颜色）.sql;
@/3gess/expdp/84/14.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 礼品资源详细信息.sql;
@/3gess/expdp/84/j_1.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 礼品终端扩展属性（颜色）.sql;
@/3gess/expdp/84/j_2.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 积分礼品资源数量.sql;
@/3gess/expdp/84/j_3.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第8步仓库表.sql;
@/3gess/expdp/84/8.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第5步仓库审批节点表.sql;
@/3gess/expdp/84/5.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第6步无串码资源数量.sql;
@/3gess/expdp/84/6.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第10步串码表(arch表和transtion表).sql;
@/3gess/expdp/84/10.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第11步社会大池.sql;
@/3gess/expdp/84/11.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第16步铺货标记.sql;
@/3gess/expdp/84/16.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第17步仓库数量表.sql;
@/3gess/expdp/84/17.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第18步发货单数据.sql;
@/3gess/expdp/84/18.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 13.sql;
@/3gess/expdp/84/13.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 15.sql;
@/3gess/expdp/84/15.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第20在途order.sql;
@/3gess/expdp/84/20.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 第19步.sql;
@/3gess/expdp/84/19.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt 21.sql;
@/3gess/expdp/84/21.sql;
select to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') end_time from dual;
prompt end_sql;
quit;
exit;
EOF
