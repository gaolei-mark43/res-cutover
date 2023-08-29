import cx_Oracle
from DBUtils.PooledDB import PooledDB
import sys


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
        params = sys.argv[1]
        params1 = sys.argv[2]
    except Exception:
        print("./main.py  x")
        sys.exit(1)
    user = str(params).strip()
    flag = str(params1).strip()

    oracle_config = {'host': '10.245.31.40',
                     'password': '123123', 'sid': 'xlsdb01', 'port': '8000'}
    oracle_config['user'] = user
    print(oracle_config)
    oracle_pool = OraclePool(oracle_config).creatPool()
    oracleutil = OracleUtil(Oracle(oracle_pool))

    try:
        print('执行:{}'.format("truncate table RC_RESOURCE_T"))
        oracleutil.update("truncate table RC_RESOURCE_T", {})
        count_1 = oracleutil.selectOne(
            "select count(1) from RC_RESOURCE_T", {})
        print('RC_RESOURCE_T条数:{}\n'.format(count_1))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_RES_TAC_T"))
        oracleutil.update("truncate table RC_RES_TAC_T", {})
        count_2 = oracleutil.selectOne("select count(1) from RC_RES_TAC_T", {})
        print('RC_RES_TAC_T条数:{}\n'.format(count_2))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_FACTORY_T"))
        oracleutil.update("truncate table RC_FACTORY_T", {})
        count_3 = oracleutil.selectOne("select count(1) from RC_FACTORY_T", {})
        print('RC_FACTORY_T条数:{}\n'.format(count_3))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_RES_EXT_T"))
        oracleutil.update("truncate table RC_RES_EXT_T", {})
        count_4 = oracleutil.selectOne("select count(1) from RC_RES_EXT_T", {})
        print('RC_RES_EXT_T条数:{}\n'.format(count_4))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_RESOURCE_TEMP"))
        oracleutil.update("truncate table RC_RESOURCE_TEMP", {})
        count_5 = oracleutil.selectOne(
            "select count(1) from RC_RESOURCE_TEMP", {})
        print('RC_RESOURCE_TEMP条数:{}\n'.format(count_5))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_RES_TAC_TEMP"))
        oracleutil.update("truncate table RC_RES_TAC_TEMP", {})
        count_6 = oracleutil.selectOne(
            "select count(1) from RC_RES_TAC_TEMP", {})
        print('RC_RES_TAC_TEMP条数:{}\n'.format(count_6))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_FACTORY_TEMP"))
        oracleutil.update("truncate table RC_FACTORY_TEMP", {})
        count_7 = oracleutil.selectOne(
            "select count(1) from RC_FACTORY_TEMP", {})
        print('RC_FACTORY_TEMP条数:{}\n'.format(count_7))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_RES_EXT_TEMP"))
        oracleutil.update("truncate table RC_RES_EXT_TEMP", {})
        count_8 = oracleutil.selectOne(
            "select count(1) from RC_RES_EXT_TEMP", {})
        print('RC_RES_EXT_TEMP条数:{}\n'.format(count_8))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_RESOURCE"))
        oracleutil.update("truncate table RC_RESOURCE", {})
        count_9 = oracleutil.selectOne("select count(1) from RC_RESOURCE", {})
        print('RC_RESOURCE条数:{}\n'.format(count_9))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_RES_TAC"))
        oracleutil.update("truncate table RC_RES_TAC", {})
        count_10 = oracleutil.selectOne("select count(1) from RC_RES_TAC", {})
        print('RC_RES_TAC条数:{}\n'.format(count_10))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_FACTORY"))
        oracleutil.update("truncate table RC_FACTORY", {})
        count_11 = oracleutil.selectOne("select count(1) from RC_FACTORY", {})
        print('RC_FACTORY条数:{}\n'.format(count_11))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_RES_EXT"))
        oracleutil.update("truncate table RC_RES_EXT", {})
        count_12 = oracleutil.selectOne("select count(1) from RC_RES_EXT", {})
        print('RC_RES_EXT条数:{}\n'.format(count_12))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_DEPOT"))
        oracleutil.update("truncate table RC_DEPOT", {})
        count_13 = oracleutil.selectOne("select count(1) from RC_DEPOT", {})
        print('RC_DEPOT条数:{}\n'.format(count_13))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_DEPOT_AUTHORIZE"))
        oracleutil.update("truncate table RC_DEPOT_AUTHORIZE", {})
        count_14 = oracleutil.selectOne(
            "select count(1) from RC_DEPOT_AUTHORIZE", {})
        print('RC_DEPOT_AUTHORIZE条数:{}\n'.format(count_14))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_DEPOT_EFFECT"))
        oracleutil.update("truncate table RC_DEPOT_EFFECT", {})
        count_15 = oracleutil.selectOne(
            "select count(1) from RC_DEPOT_EFFECT", {})
        print('RC_DEPOT_EFFECT条数:{}\n'.format(count_15))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_DEPOT_OPER"))
        oracleutil.update("truncate table RC_DEPOT_OPER", {})
        count_16 = oracleutil.selectOne(
            "select count(1) from RC_DEPOT_OPER", {})
        print('RC_DEPOT_OPER条数:{}\n'.format(count_16))
    except Exception:
        print(Exception)

    try:
        print('执行:{}'.format("truncate table RC_DEPOT_OPER_CHG"))
        oracleutil.update("truncate table RC_DEPOT_OPER_CHG", {})
        count_17 = oracleutil.selectOne(
            "select count(1) from RC_DEPOT_OPER_CHG", {})
        print('RC_DEPOT_OPER_CHG条数:{}\n'.format(count_17))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_DEPOT_RES"))
        oracleutil.update("truncate table RC_DEPOT_RES", {})
        count_18 = oracleutil.selectOne(
            "select count(1) from RC_DEPOT_RES", {})
        print('RC_DEPOT_RES条数:{}\n'.format(count_18))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_DEPOT_RES_BAK"))
        oracleutil.update("truncate table RC_DEPOT_RES_BAK", {})
        count_19 = oracleutil.selectOne(
            "select count(1) from RC_DEPOT_RES_BAK", {})
        print('RC_DEPOT_RES_BAK条数:{}\n'.format(count_19))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_ORDER"))
        oracleutil.update("truncate table RC_ORDER", {})
        count_20 = oracleutil.selectOne("select count(1) from RC_ORDER", {})
        print('RC_ORDER条数:{}\n'.format(count_20))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_RES_DETAIL"))
        oracleutil.update("truncate table RC_RES_DETAIL", {})
        count_21 = oracleutil.selectOne(
            "select count(1) from RC_RES_DETAIL", {})
        print('RC_RES_DETAIL条数:{}\n'.format(count_21))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_RES_DETAIL_CHG"))
        oracleutil.update("truncate table RC_RES_DETAIL_CHG", {})
        count_22 = oracleutil.selectOne(
            "select count(1) from RC_RES_DETAIL_CHG", {})
        print('RC_RES_DETAIL_CHG条数:{}\n'.format(count_22))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_SALE"))
        oracleutil.update("truncate table RC_SALE", {})
        count_31 = oracleutil.selectOne("select count(1) from RC_SALE", {})
        print('RC_SALE条数:{}\n'.format(count_31))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_STOCK"))
        oracleutil.update("truncate table RC_STOCK", {})
        count_23 = oracleutil.selectOne("select count(1) from RC_STOCK", {})
        print('RC_STOCK条数:{}\n'.format(count_23))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_STOCK_DETAIL"))
        oracleutil.update("truncate table RC_STOCK_DETAIL", {})
        count_24 = oracleutil.selectOne(
            "select count(1) from RC_STOCK_DETAIL", {})
        print('RC_STOCK_DETAIL条数:{}\n'.format(count_24))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_STOCK_DETAIL_CHG"))
        oracleutil.update("truncate table RC_STOCK_DETAIL_CHG", {})
        count_25 = oracleutil.selectOne(
            "select count(1) from RC_STOCK_DETAIL_CHG", {})
        print('RC_STOCK_DETAIL_CHG条数:{}\n'.format(count_25))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_STOCK_EXT"))
        oracleutil.update("truncate table RC_STOCK_EXT", {})
        count_26 = oracleutil.selectOne(
            "select count(1) from RC_STOCK_EXT", {})
        print('RC_STOCK_EXT条数:{}\n'.format(count_26))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_STOCK_PAICHONG"))
        oracleutil.update("truncate table RC_STOCK_PAICHONG", {})
        count_27 = oracleutil.selectOne(
            "select count(1) from RC_STOCK_PAICHONG", {})
        print('RC_STOCK_PAICHONG条数:{}\n'.format(count_27))
    except Exception:
        pass

    try:
        print('执行:{}'.format("truncate table RC_TERMINAL_CONSIG"))
        oracleutil.update("truncate table RC_TERMINAL_CONSIG", {})
        count_28 = oracleutil.selectOne(
            "select count(1) from RC_TERMINAL_CONSIG", {})
        print('RC_TERMINAL_CONSIG条数:{}\n'.format(count_28))
    except Exception:
        pass

    if flag == '1':
        try:
            print('执行:{}'.format("truncate table GJ_3GE_WTD"))
            oracleutil.update("truncate table GJ_3GE_WTD", {})
            count_29 = oracleutil.selectOne(
                "select count(1) from GJ_3GE_WTD", {})
            print('GJ_3GE_WTD条数:{}\n'.format(count_29))
        except Exception:
            pass

        try:
            print('执行:{}'.format("truncate table GJ_ZYZX_WTD"))
            oracleutil.update("truncate table GJ_ZYZX_WTD", {})
            count_30 = oracleutil.selectOne(
                "select count(1) from GJ_ZYZX_WTD", {})
            print('GJ_ZYZX_WTD条数:{}\n'.format(count_30))
        except Exception:
            pass
