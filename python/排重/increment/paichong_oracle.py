# -*- coding: UTF-8 -*-
import sys
from DBUtils.PooledDB import PooledDB
import cx_Oracle


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
        self.mincached = config['min_cached'] if 'min_cached' in config else 1
        self.maxcached = config['max_cached'] if 'max_cached' in config else 2
        self.maxshared = config['max_shared'] if 'max_shared' in config else 2
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
    except Exception:
        print("缺少参数")
        sys.exit(1)

    province_code = str(params1).strip()

    oracle_config = {'host': '10.245.31.40', 'user': 'usr_cut',
                     'password': 'usrcut', 'sid': 'xlsdb01', 'port': '8000'}
    oracle_pool = OraclePool(oracle_config).creatPool()
    oracleutil = OracleUtil(Oracle(oracle_pool))

    sql_1 = "truncate table user_{}.gj_zyzx_wtd".format(province_code)
    print('执行:{}'.format(sql_1))
    oracleutil.update(sql_1, {})

    sql_2 = "truncate table user_{}.gj_3GE_wtd".format(province_code)
    print('执行:{}'.format(sql_2))
    oracleutil.update(sql_2, {})

    sql_3 = "insert into user_{}.gj_zyzx_wtd select a.rs_imei ,'1' from user_{}.rc_stock_paichong a ,user_{}.rc_stock b where a.rs_imei=b.rs_imei and a.depot_id in (select b.depot_id from USR_CUT.rc_depot_shdc b) and b.depot_id not in (select b.depot_id from USR_CUT.rc_depot_shdc b)".format(
        province_code, province_code, province_code)
    print('执行:{}'.format(sql_3))
    oracleutil.update(sql_3, {})

    sql_4 = "insert into user_{}.gj_3GE_wtd select a.rs_imei ,'1' from user_{}.rc_stock_paichong a ,user_{}.rc_stock b where a.rs_imei=b.rs_imei and a.depot_id not in (select b.depot_id from USR_CUT.rc_depot_shdc b) and b.depot_id  in (select b.depot_id from USR_CUT.rc_depot_shdc b)".format(
        province_code, province_code, province_code)
    print('执行:{}'.format(sql_4))
    oracleutil.update(sql_4, {})

    sql_5 = "insert into user_{}.gj_zyzx_wtd select a.rs_imei,'3' from user_{}.rc_stock_paichong a ,user_{}.rc_stock b where a.rs_imei=b.rs_imei and a.time_in<b.time_in and a.depot_id in (select b.depot_id from USR_CUT.rc_depot_shdc b) and b.depot_id in (select b.depot_id from USR_CUT.rc_depot_shdc b)".format(
        province_code, province_code, province_code)
    print('执行:{}'.format(sql_5))
    oracleutil.update(sql_5, {})

    sql_6 = "insert into user_{}.gj_3GE_wtd select a.rs_imei,'2' from user_{}.rc_stock_paichong a ,user_{}.rc_stock b where a.rs_imei=b.rs_imei and a.time_in>b.time_in and a.depot_id in (select b.depot_id from USR_CUT.rc_depot_shdc b) and b.depot_id in (select b.depot_id from USR_CUT.rc_depot_shdc b)".format(
        province_code, province_code, province_code)
    print('执行:{}'.format(sql_6))
    oracleutil.update(sql_6, {})

    sql_7 = "insert into user_{}.gj_3GE_wtd select a.rs_imei,'3' from user_{}.rc_stock_paichong a ,user_{}.rc_stock b where a.rs_imei=b.rs_imei and a.time_in>b.time_in and a.depot_id not in (select b.depot_id from USR_CUT.rc_depot_shdc b) and b.depot_id not in (select b.depot_id from USR_CUT.rc_depot_shdc b)".format(
        province_code, province_code, province_code)
    print('执行:{}'.format(sql_7))
    oracleutil.update(sql_7, {})

    sql_8 = "insert into user_{}.gj_zyzx_wtd select a.rs_imei ,'4' from user_{}.rc_stock_paichong a ,user_{}.rc_stock b where a.rs_imei=b.rs_imei and a.time_in<b.time_in and a.depot_id not in (select b.depot_id from USR_CUT.rc_depot_shdc b) and b.depot_id not in (select b.depot_id from USR_CUT.rc_depot_shdc b)".format(
        province_code, province_code, province_code)
    print('执行:{}'.format(sql_8))
    oracleutil.update(sql_8, {})

    sql_10 = "select count(1) from user_{}.gj_zyzx_wtd".format(province_code)
    print('执行:{}'.format(sql_10))
    print(oracleutil.selectAll(sql_10, {}))

    sql_11 = "select count(1) from user_{}.gj_3GE_wtd".format(province_code)
    print('执行:{}'.format(sql_11))
    print(oracleutil.selectAll(sql_11, {}))

    # sql_9 = "DELETE FROM user_{}.RC_STOCK WHERE RS_IMEI IN (SELECT RS_IMEI FROM user_{}.gj_3GE_wtd)".format(
    #     province_code, province_code)
    # print('执行:{}'.format(sql_9))
    # oracleutil.update(sql_9, {})

    sql_12 = "DELETE FROM user_{}.GJ_ZYZX_WTD A WHERE ROWID!=(SELECT MAX(ROWID) FROM user_{}.GJ_ZYZX_WTD D WHERE A.RS_IMEI=D.RS_IMEI )".format(
        province_code, province_code)
    print('执行:{}'.format(sql_12))
    oracleutil.update(sql_12, {})

    sql_13 = "select count(1) from user_{}.gj_zyzx_wtd".format(province_code)
    print('执行:{}'.format(sql_13))
    print(oracleutil.selectAll(sql_13, {}))
