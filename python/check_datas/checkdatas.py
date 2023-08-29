# -*- coding: UTF-8 -*-
import pandas as pd
import pymongo
import pymysql
import json
import sys
import threading
import queue
from DBUtils.PooledDB import PooledDB
import phoenixdb
import phoenixdb.cursor
import pandas as pd
import cx_Oracle

mysql_check_result = {}
mongo_check_result = {}
oracle_check_result = {}
phoenix_check_result = {}


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
        self.mincached = config['min_cached'] if 'min_cached' in config else 10
        self.maxcached = config['max_cached'] if 'max_cached' in config else 10
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


class MyThreadPool():
    def __init__(self, object, thread_num):
        self.queue = object
        self.thread_num = thread_num
        self.creat_pool()

    def creat_pool(self):
        '''自定义线程池'''
        for i in range(self.thread_num):
            thread = MyThread(self.queue)
            thread.setDaemon = True
            thread.start()

    def add(self, object):
        self.queue.put(object)

    def join(self):
        '''阻塞，直到队列中的任务被删除或者处理'''
        self.queue.join()


class MyQueue():
    """自定义先进先出"""

    def __init__(self, func, params):
        self.func = func
        self.params = params

    def getfunc(self):
        return self.func, self.params


class MyThread(threading.Thread):
    """自定义线程类"""

    def __init__(self, queue):
        super(MyThread, self).__init__()
        self.queue = queue

    def run(self):
        while True:
            try:
                func, params = self.queue.get(timeout=1).getfunc()
                func(**params)
                self.queue.task_done()
            except queue.Empty:
                break


def mysql_count(pool, sql, table_name):
    db = pool.connection()
    cursor_source = db.cursor()
    count = cursor_source.execute(sql)
    results = cursor_source.fetchall()
    db.close()
    cursor_source.close()
    lock.acquire()
    global mysql_check_result
    mysql_check_result[table_name] = results[0][0]
    lock.release()


def mongo_count(mongo_config, sql, table_name):
    client = pymongo.MongoClient(
        mongo_config['ip'], mongo_config['port'])  # 建立客户端对象
    db = client[mongo_config['db']]
    if mongo_config['username'] != '':
        db.authenticate(mongo_config['username'], mongo_config['password'])
    collection = db[table_name.lower()+mongo_config['suffix']]
    sql = eval(sql)
    result = collection.count(sql)
    lock.acquire()
    global mongo_check_result
    mongo_check_result[table_name] = result
    lock.release()


def oracle_count(pool, sql, table_name):
    db = pool.connection()
    cursor_source = db.cursor()
    count = cursor_source.execute(sql)
    results = cursor_source.fetchall()
    db.close()
    cursor_source.close()
    lock.acquire()
    global oracle_check_result
    oracle_check_result[table_name] = results[0][0]
    lock.release()

def phoenix_count(config, sql, table_name):
    conn = phoenixdb.connect(config['queryserver'], autocommit=True)
    cursor = conn.cursor()
    cursor.execute(sql)
    result = cursor.fetchall()
    lock.acquire()
    global phoenix_check_result
    phoenix_check_result[table_name] = result[0][0]
    lock.release()


def process_count(table_name, mysql_pool, mysql_config, mongo_config, oracle_pool, oracle_config,phoenix_config):
    # 查询mysql
    mysql_sql = mysql_config['tables'][table_name]
    mysql_count(mysql_pool, mysql_sql, table_name)
    # 查询mongo
    if table_name in mongo_config['tables']:
        mongo_sql = mongo_config['tables'][table_name]
        mongo_count(mongo_config, mongo_sql, table_name)
    else:
        lock.acquire()
        global mongo_check_result
        mongo_check_result[table_name] = '不存在'
        lock.release()
    # 查询oracle
    oracle_sql = oracle_config['tables'][table_name]
    oracle_count(oracle_pool, oracle_sql, table_name)
    # 查询phoenix
    if phoenix_config['ischeck'] == 1:
        if table_name in phoenix_config['tables']:
            phoenix_sql = phoenix_config['tables'][table_name]
            phoenix_count(phoenix_config, phoenix_sql, table_name)
        else:
            lock.acquire()
            global phoenix_check_result
            phoenix_check_result[table_name] = '不存在'
            lock.release()


def read_json(file):
    with open(file, 'r') as json_f:
        json_dict = json.load(json_f)
    return json_dict


if __name__ == "__main__":
    lock = threading.RLock()

    try:
        params1 = sys.argv[1]
        params2 = sys.argv[2]
    except Exception:
        print("./main.py  config.json")
        sys.exit(1)
    configfile = str(params1).strip()
    xlsxfile = str(params2).strip()
    print("读取配置文件{}".format(configfile))
    '''
    填写配置文件
    '''
    config_json = read_json(configfile)
    print("配置信息:{}".format(config_json))

    stock_config = config_json['mysql']['stock']
    order_config = config_json['mysql']['order']
    param_config = config_json['mysql']['param']
    mongo_config = config_json['mongo']
    oracle_config = config_json['oracle']
    phoenix_config = config_json['phoenix']

    oracle_pool = OraclePool(oracle_config).creatPool()
    order_pool = MysqlPool(order_config).creatPool()
    stock_pool = MysqlPool(stock_config).creatPool()
    param_pool = MysqlPool(param_config).creatPool()

    thread_pool = MyThreadPool(queue.Queue(), 10)
    stock_tables = stock_config['tables']
    for table in stock_tables:
        param = {'table_name': table,  'mysql_pool': stock_pool, 'mysql_config': stock_config,
                 'mongo_config': mongo_config, 'oracle_pool': oracle_pool, 'oracle_config': oracle_config,'phoenix_config':phoenix_config}
        dict = {'func': process_count, 'params': param}
        thread_pool.add(MyQueue(**dict))
    order_tables = order_config['tables']
    for table in order_tables:
        param = {'table_name': table, 'mysql_pool': order_pool, 'mysql_config': order_config,
                 'mongo_config': mongo_config, 'oracle_pool': oracle_pool, 'oracle_config': oracle_config,'phoenix_config':phoenix_config}
        dict = {'func': process_count, 'params': param}
        thread_pool.add(MyQueue(**dict))

    param_tables = param_config['tables']
    for table in param_tables:
        param = {'table_name': table, 'mysql_pool': param_pool, 'mysql_config': param_config,
                 'mongo_config': mongo_config, 'oracle_pool': oracle_pool, 'oracle_config': oracle_config,'phoenix_config':phoenix_config}
        dict = {'func': process_count, 'params': param}
        thread_pool.add(MyQueue(**dict))
    thread_pool.join()

    result_dict = {}
    for table in oracle_check_result:
        result_list = []
        mysql_num = mysql_check_result[table]
        mongo_num = mongo_check_result[table]
        oracle_num = oracle_check_result[table]
        result_list.append(mysql_num)
        result_list.append(mongo_num)
        result_list.append(oracle_num)
        if phoenix_config['ischeck'] == 1:
            phoenix_num=phoenix_check_result[table]
            result_list.append(phoenix_num)
        if oracle_num != mysql_num:
            result_list.append("是")
        elif mongo_num != '不存在':
            if oracle_num != mongo_num:
                result_list.append("是")
            else:
                result_list.append("否")
        elif phoenix_config['ischeck'] == 1  and oracle_num != phoenix_num:
            result_list.append("是")
        else:
            result_list.append("否")
        result_dict[table] = result_list

    df = pd.DataFrame(result_dict).T
    print(df)
    writer = pd.ExcelWriter('{}.xlsx'.format(xlsxfile))
    if phoenix_config['ischeck'] == 1 :
        df.to_excel(writer, sheet_name='稽核结果', startrow=5, startcol=5, index=True,
                header=['mysql数据量', 'mongo数据量', 'oracle数据量','phoenix数据量', '是否存在差异'])
    else:
        df.to_excel(writer, sheet_name='稽核结果', startrow=5, startcol=5, index=True,
                header=['mysql数据量', 'mongo数据量', 'oracle数据量', '是否存在差异'])
    writer.save()
