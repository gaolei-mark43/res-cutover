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
    provinces = str(params1).strip()
    print(provinces)
    # user = "USER_97"
    oracle_config = {'host': '10.245.31.40', 
                     'password': '123123', 'sid': 'xlsdb01', 'port': '8000'}
    oracle_config['user'] = user
    print(oracle_config)
    oracle_pool = OraclePool(oracle_config).creatPool()
    oracleutil = OracleUtil(Oracle(oracle_pool))


    oracleutil.update("truncate table RC_RESOURCE_T",{})
    oracleutil.update("truncate table RC_RES_TAC_T",{})
    oracleutil.update("truncate table RC_FACTORY_T",{})
    oracleutil.update("truncate table RC_RES_EXT_T",{})

    # oracleutil.update("truncate table RC_RESOURCE_TEMP",{})
    # oracleutil.update("truncate table RC_RES_TAC_TEMP",{})
    # oracleutil.update("truncate table RC_FACTORY_TEMP",{})
    # oracleutil.update("truncate table RC_RES_EXT_TEMP",{})

    sql_1 = "insert  into RC_RES_TAC_T  select * from RC_RES_TAC a where not exists(select 1 from RC_RES_TAC_TEMP b where b.RS_ID= a.RS_ID and a.TAC_CODE=b.TAC_CODE) and a.RS_ID in (select RS_ID from RC_RESOURCE c where c.province_code in {})".format(provinces)

    sql_2 = "insert  into RC_RES_EXT_T  select * from RC_RES_EXT a where not exists(select 1 from RC_RES_EXT_TEMP b where b.RS_ID = a.RS_ID AND a.EXT_CODE=b.EXT_CODE) and a.RS_ID in (select RS_ID from RC_RESOURCE c where c.province_code in {})".format(provinces)

    sql_3 = "insert  into RC_FACTORY_T  select * from RC_FACTORY a where not exists(select 1 from RC_FACTORY_TEMP b where b.FACTORY_CODE = a.FACTORY_CODE) and a.province_code in {}".format(provinces)

    sql_4 = "insert  into RC_RESOURCE_T select * from RC_RESOURCE a where not exists(select 1 from RC_RESOURCE_TEMP b where b.rs_id_out = a.rs_id_out) and a.province_code in {}".format(provinces)
    
    print('执行:{}'.format(sql_1))
    oracleutil.update(sql_1,{})
    
    print('执行:{}'.format(sql_2))
    oracleutil.update(sql_2,{})
    
    print('执行:{}'.format(sql_3))
    oracleutil.update(sql_3,{})
    
    print('执行:{}'.format(sql_4))
    oracleutil.update(sql_4,{})
    
    count_1 = oracleutil.selectOne("select count(1) from RC_RESOURCE_T",{})
    print('导入RC_RESOURCE_T条数:{}'.format(count_1))
    count_2 = oracleutil.selectOne("select count(1) from RC_RES_TAC_T",{})
    print('导入RC_RES_TAC_T条数:{}'.format(count_2))
    count_3 = oracleutil.selectOne("select count(1) from RC_FACTORY_T",{})
    print('导入RC_FACTORY_T条数:{}'.format(count_3))
    count_4 = oracleutil.selectOne("select count(1) from RC_RES_EXT_T",{})
    print('导入RC_RES_EXT_T条数:{}'.format(count_4))


    