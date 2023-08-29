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

    sql_8 = "select count(1) from user_{}.RC_STOCK".format(province_code)
    print('执行:{}'.format(sql_8))
    print(oracleutil.selectAll(sql_8, {}))

    sql_9 = "DELETE FROM user_{}.RC_STOCK WHERE RS_IMEI IN (SELECT RS_IMEI FROM user_{}.gj_3GE_wtd)".format(
        province_code, province_code)
    print('执行:{}'.format(sql_9))
    oracleutil.update(sql_9, {})

    sql_13 = "select count(1) from user_{}.RC_STOCK".format(province_code)
    print('执行:{}'.format(sql_13))
    print(oracleutil.selectAll(sql_13, {}))

