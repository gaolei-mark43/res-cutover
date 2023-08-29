# -*- coding: UTF-8 -*-
import cx_Oracle 
import sys
from DBUtils.PooledDB import PooledDB
import os 
os.environ["NLS_LANG"] = ".AL32UTF8" 

class OraclePool:
    """
    Oracle连接池
    """

    def __init__(self, config):
        self.host = config['host'] if 'host' in config else ''
        self.user = config['user'] if 'user' in config else ''
        self.password = config['password'] if 'password' in config else ''
        self.sid = config['sid'] if 'sid' in config else ''
        self.port = config['port'] if 'port' in config else 3306
        self.mincached = config['min_cached'] if 'min_cached' in config else 10
        self.maxcached = config['max_cached'] if 'max_cached' in config else 10
        self.maxshared = config['max_shared'] if 'max_shared' in config else 20
        self.maxconnections = config['max_connections'] if 'max_connections' in config else 100
        self.blocking = config['blocking'] if 'blocking' in config else True
        self.maxusage = config['max_usage'] if 'max_usage' in config else 0
        self.pool = None

    def creatPool(self):
        config = {
            "user": self.user,
            "password": self.password,
            "dsn": self.host + ":" + self.port + "/" + self.sid
        }
        self.pool = PooledDB(creator=cx_Oracle, mincached=self.mincached, maxcached=self.maxcached,
                             maxshared=self.maxshared, maxconnections=self.maxconnections, blocking=self.blocking,
                             maxusage=self.maxusage, **config)
        return self.pool


class Oracle:

    def __init__(self, pool):
        self.pool = pool
        self.cursor = None
        self.conn = None

    def __enter__(self):
        self.conn = self.pool.connection()
        self.cursor = self.conn.cursor()
        return self.cursor

    def __exit__(self, type, value, tb):
        if tb is None:
            self.conn.commit()
        else:
            print("回滚当前事务")
            self.conn.rollback()
        self.cursor.close()
        self.conn.close()


class OracleUtil:
    """
        Oracle工具类
    """

    def __init__(self, oracle):
        self.oracle = oracle

    def insertOne(self, sql, param=None):
        with self.oracle as cursor:
            return cursor.execute(sql, param)

    def insertMany(self, sql, param=None):
        with self.oracle as cursor:
            return cursor.executemany(sql, param)

    def selectOne(self, sql, param=None):
        with self.oracle as cursor:
            cursor.execute(sql, param)
            result = cursor.fetchone()
        return result

    def selectAll(self, sql, param=None):
        with self.oracle as cursor:
            cursor.execute(sql, param)
            result = cursor.fetchall()
        return result

    def update(self, sql, param=None):
        with self.oracle as cursor:
            count = cursor.execute(sql, param)
            return count

    def delete(self, sql, param=None):
        with self.oracle as cursor:
            count = cursor.execute(sql, param)
            return count

if __name__ == "__main__":
    try:
        params1 = sys.argv[1]
        params2 = sys.argv[2]
        params3 = sys.argv[3]
    except Exception:
        print("缺少参数")
        sys.exit(1)
    oracle_config = {'host': '10.245.31.40', 'user':'usr_cut',
                     'password': 'usrcut', 'sid': 'xlsdb01', 'port': '8000'}
    oracle_pool = OraclePool(oracle_config).creatPool()
    oracleutil = OracleUtil(Oracle(oracle_pool))

    sql_1 = "delete from user_{}.rc_res_detail a where a.orderid in (select m.order_id from user_{}.RC_ORDER m group by m.order_id having count(m.order_id) > 1)".format(str(params3).strip(),str(params3).strip())
    sql_2 = "delete from user_{}.RC_ORDER n where n.order_id in (select m.order_id from user_{}.RC_ORDER m group by m.order_id having count(m.order_id) > 1)".format(str(params3).strip(),str(params3).strip())
    sql_3="update user_{}.rc_factory a set a.contact_tel='无' where a.contact_tel is null".format(str(params3).strip())
    sql_4="update user_{}.rc_factory a set a.contact_name='无' where a.contact_name is null".format(str(params3).strip())
    sql_5="update user_{}.rc_factory a set a.address='无'  where a.address is null".format(str(params3).strip())
    sql_6="delete user_{}.rc_stock a where a.rs_imei in (select rs_imei from user_{}.gj_3GE_wtd)".format(str(params3).strip(),str(params3).strip())
    print('执行:{}'.format(sql_1))
    print(oracleutil.update(sql_1,{}))
    print('执行:{}'.format(sql_2))
    print(oracleutil.update(sql_2,{}))
    print('执行:{}'.format(sql_3))
    print(oracleutil.update(sql_3,{}))
    print('执行:{}'.format(sql_4))
    print(oracleutil.update(sql_4,{}))
    print('执行:{}'.format(sql_5))
    print(oracleutil.update(sql_5,{}))
    print('执行:{}'.format(sql_6))
    print(oracleutil.update(sql_6,{}))

    # 连接数据库
    conn = oracle_pool.connection()
    # 创建游标
    cursor = conn.cursor()
    # 调用存储过程
    try:
        cursor.callproc('prc_zd_check', [str(params1).strip(),str(params2).strip(),str(params3).strip()])
        message = '执行成功'
    except Exception as e:
        error, = e.args
        message = "执行失败 " + error.message
    cursor.close()
    conn.close()
    print(message)