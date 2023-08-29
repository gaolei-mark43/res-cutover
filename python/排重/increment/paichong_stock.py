# -*- coding: UTF-8 -*-
import pymysql
from DBUtils.PooledDB import PooledDB
import sys


class MysqlPool:
    """
    mysql连接池
    """

    def __init__(self, config):
        self.host = config['host'] if 'host' in config else ''
        self.user = config['user'] if 'user' in config else ''
        self.password = config['password'] if 'password' in config else ''
        self.db = config['db'] if 'db' in config else ''
        self.port = config['port'] if 'port' in config else 3306
        self.charset = config['charset'] if 'charset' in config else 'utf8'
        self.mincached = config['min_cached'] if 'min_cached' in config else 1
        self.maxcached = config['max_cached'] if 'max_cached' in config else 2
        self.maxshared = config['max_shared'] if 'max_shared' in config else 20
        self.maxconnections = config['max_connections'] if 'max_connections' in config else 100
        self.blocking = config['blocking'] if 'blocking' in config else True
        self.maxusage = config['max_usage'] if 'max_usage' in config else 0
        self.setsession = ['SET AUTOCOMMIT = 1']
        self.pool = None

    def creatPool(self):
        self.pool = PooledDB(creator=pymysql, mincached=self.mincached, maxcached=self.maxcached,
                             maxshared=self.maxshared, maxconnections=self.maxconnections, blocking=self.blocking,
                             maxusage=self.maxusage, setsession=self.setsession, host=self.host,
                             user=self.user, password=self.password, db=self.db, port=self.port, charset=self.charset,
                             use_unicode=False)
        return self.pool


if __name__ == "__main__":
    
    try:
        params1= sys.argv[1]
        params2= sys.argv[2]
    except Exception:
        print("输入参数 python paichong_stock_1.py pre 18")
        sys.exit(1)
    env = str(params1).strip()
    province_code = str(params2).strip()
    if env != 'prod' and env != 'pre':
        print('请输入正确的参数:生产:prod,联调:pre')
        sys.exit(1)

    prod_config = {"host": "10.245.32.95",
            "user": "prod_zyzx_drsstock",
            "password": "prod_drsstock_0258",
            "db": "prod_zyzx_drsstock"}
    pre_config = {"host": "10.124.144.98",
            "user": "test_zyzx_dres",
            "password": "test_dres_8635",
            "db": "test_zyzx_dres"}
    
    pool = None
    if env == 'prod':
        pool = MysqlPool(prod_config).creatPool()
    elif env == 'pre':
        pool = MysqlPool(pre_config).creatPool()
    print('操作数据库:{}'.format(env))
    connection = pool.connection()
    cursor_source = connection.cursor()
    sql_1 = "truncate RC_STOCK_REPICK_{}".format(province_code)
    print('执行sql:{}'.format(sql_1))
    try:
        count = cursor_source.execute(sql_1)
        connection.commit()
    except Exception:
        connection.rollback()
        print('执行错误')
        sys.exit(1)
    cursor_source.close()
    connection.close()

    sql_2 = "select count(1) from RC_STOCK_REPICK_{}".format(province_code)
    print('执行sql:{}'.format(sql_2))
    connection_2 = pool.connection()
    cursor_source_2 = connection_2.cursor()
    cursor_source_2.execute(sql_2)
    results = cursor_source_2.fetchall()
    cursor_source_2.close()
    connection_2.close()
    print('查询结果:{}'.format(results[0][0]))

    sql_3 = "INSERT INTO RC_STOCK_REPICK_{} (SELECT a.*  FROM RC_STOCK a INNER JOIN RC_STOCK_{} b ON a.RS_IMEI = b.RS_IMEI)".format(province_code,province_code)
    print('执行sql:{}'.format(sql_3))
    connection_3 = pool.connection()
    cursor_source_3 = connection_3.cursor()
    try:
        count = cursor_source_3.execute(sql_3)
        connection_3.commit()
    except Exception:
        connection_3.rollback()
        print('执行错误')
        sys.exit(1)
    cursor_source_3.close()
    connection_3.close()

    print('执行sql:{}'.format(sql_2))
    connection_2 = pool.connection()
    cursor_source_2 = connection_2.cursor()
    cursor_source_2.execute(sql_2)
    results = cursor_source_2.fetchall()
    cursor_source_2.close()
    connection_2.close()
    print('查询结果:{}'.format(results[0][0]))
