# -*- coding: UTF-8 -*-
import pandas as pd
import pymongo
import logging
import os
import pymysql
import json
import sys
import threading
import queue
from DBUtils.PooledDB import PooledDB
import phoenixdb
import phoenixdb.cursor


class MysqlConfig:
    """
    mysql参数处理
    """

    def __init__(self, config):
        self.host = config['host'] if 'host' in config else ''
        self.user = config['user'] if 'user' in config else ''
        self.password = config['password'] if 'password' in config else ''
        self.db = config['db'] if 'db' in config else ''
        self.port = config['port'] if 'port' in config else 3306
        self.charset = 'utf8'
        self.min_cached = 10
        self.max_cached = 10
        self.max_shared = 20
        self.max_connections = 100
        self.blocking = True
        self.max_usage = 0
        self.set_session = ['SET AUTOCOMMIT = 0']


class MysqlPool:
    """
    mysql连接池
    """

    def __init__(self, mysqlconfig):
        self.host = mysqlconfig.host
        self.user = mysqlconfig.user
        self.password = mysqlconfig.password
        self.db = mysqlconfig.db
        self.port = mysqlconfig.port
        self.charset = mysqlconfig.charset
        self.mincached = mysqlconfig.min_cached
        self.maxcached = mysqlconfig.max_cached
        self.maxshared = mysqlconfig.max_shared
        self.maxconnections = mysqlconfig.max_connections
        self.blocking = mysqlconfig.blocking
        self.maxusage = mysqlconfig.max_usage
        self.setsession = mysqlconfig.set_session
        self.pool = None

    def creatPool(self):
        self.pool = PooledDB(creator=pymysql, mincached=self.mincached, maxcached=self.maxcached,
                             maxshared=self.maxshared, maxconnections=self.maxconnections, blocking=self.blocking,
                             maxusage=self.maxusage, setsession=self.setsession, host=self.host,
                             user=self.user, password=self.password, db=self.db, port=self.port, charset=self.charset,
                             use_unicode=False)
        return self.pool


class Mysql:

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
            self.conn.rollback()
        self.cursor.close()
        self.conn.close()


class MysqlUtil:
    """
        mysql工具类
    """

    def __init__(self, mysql):
        self.mysql = mysql

    def selectAll(self, sql, param=None):
        with self.mysql as cursor:
            count = cursor.execute(sql, param)
            result_dict_list = []
            if count > 0:
                results = cursor.fetchall()
                col_name_list = [tuple[0] for tuple in cursor.description]
                for result in results:
                    result_dict = {}
                    for i in range(len(result)):
                        result_dict[col_name_list[i]] = result[i].decode(
                            'utf-8') if isinstance(result[i], bytes) else result[i]
                    result_dict_list.append(result_dict)
            return result_dict_list

    def delete(self, sql, param=None):
        with self.mysql as cursor:
            count = cursor.execute(sql, param)
            return count


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


class Logger():

    def __init__(self, logname,  logger, **arg):
        # 创建一个logger
        self.logger = logging.getLogger(logger)
        self.logger.setLevel(
            eval(arg['loggerLevel']) if 'loggerLevel' in arg else logging.DEBUG)

        # 创建一个handler，用于写入日志文件
        os.system("mkdir -p ./logs")
        fh = logging.FileHandler('./logs/{}'.format(logname))
        fh.setLevel(eval(arg['fileHandlerLevel'])
                    if 'fileHandlerLevel' in arg else logging.DEBUG)

        # 再创建一个handler，用于输出到控制台
        ch = logging.StreamHandler()
        ch.setLevel(eval(arg['streamHandlerLevel'])
                    if 'streamHandlerLevel' in arg else logging.DEBUG)

        # 定义handler的输出格式
        formatter = logging.Formatter(
            '[%(asctime)-18s][%(thread)-10d][%(filename)s] ## %(message)s')
        fh.setFormatter(formatter)
        ch.setFormatter(formatter)

        # 给logger添加handler
        self.logger.addHandler(fh)
        self.logger.addHandler(ch)

    def getlog(self):
        return self.logger


def write_csv(filename, datas):
    data = pd.DataFrame(datas)
    # 写入csv文件,'a+'是追加模式
    try:
        data.to_csv(filename, header=False, index=False,
                    mode='a+', encoding='utf-8')
    except UnicodeEncodeError:
        logger.info("编码错误, 该数据无法写到文件中, 直接忽略该数据")


def read_json(file):
    with open(file, 'r') as json_f:
        json_dict = json.load(json_f)
    return json_dict


def del_data(sql, pool):
    mysqlutil = MysqlUtil(Mysql(pool))
    count = mysqlutil.delete(sql)
    return count


def get_data(sql, pool):
    db = pool.connection()
    cursor_source = db.cursor()
    count = cursor_source.execute(sql)
    col_name_list = [tuple[0] for tuple in cursor_source.description]
    results = cursor_source.fetchall()
    result_dict_list = []
    for result in results:
        result_list = [0 for i in range(len(result))]
        for i in range(len(result)):
            result_list[i] = result[i].decode(
                'utf-8') if isinstance(result[i], bytes) else result[i]

        result_dict_list.append(tuple(result_list))
    db.close()
    cursor_source.close()
    return col_name_list, result_dict_list


def delete_mongo(datas, config):
    client = pymongo.MongoClient(config['ip'], config['port'])  # 建立客户端对象
    db = client[config['db']]
    if config['username'] != '':
        db.authenticate(config['username'], config['password'])
    myquery = eval(config['sql'])
    collection = db[config['deletetable']]
    result = collection.delete_many(myquery)

    return result.deleted_count


def delete_phoenix(datas, config):
    database_url = config['url']
    conn = phoenixdb.connect(database_url, autocommit=True)
    cursor = conn.cursor()
    count = 0
    betch_data = []
    betch_size = config['betch_size']
    task = len(datas)//betch_size
    if len(result_prikey_list) % betch_size != 0:
        task = task + 1
    for i in range(task):
        del_datas = []
        if betch_size*(i+1) < len(datas):
            del_datas = datas[betch_size*i:betch_size*(i+1)]
        else:
            del_datas = datas[betch_size*i:len(datas)]
        result = cursor.execute(
            config['sql_del'].format('\',\''.join(betch_data)))
        count = count + result.deleted_count
    return count


def process(s_node, config, pool):
    sql_get = config['mysql']['sql_get']
    col_name_list, result_dict_list = get_data(s_node + sql_get, pool)
    deletekeyindex = col_name_list.index(config['mysql']['deletekey'])
    logger.info("操作节点:{}-读取到符合条件数据条数:{}".format(s_node, len(result_dict_list)))
    if len(result_dict_list) != 0:
        logger.info("操作节点:{}-备份要删除的数据".format(s_node))
        write_csv('{}.csv'.format(
            config['mysql']['deletetable']), result_dict_list)

    # 获取删除要用的条件
    result_prikey_list = [str(result_dict[deletekeyindex])
                          for result_dict in result_dict_list]
    if len(result_prikey_list) != 0:
        logger.info("操作节点:{}-需要删除的数据条数:{}".format(s_node,
                                                  len(result_prikey_list)))
        betch_size = config['mysql']['betch_size']
        task = len(result_prikey_list)//betch_size
        if len(result_prikey_list) % betch_size != 0:
            task = task + 1
        del_mysql_count = 0
        del_mongo_count = 0
        del_phoenix_count = 0
        for i in range(task):
            del_datas = []
            if betch_size*(i+1) < len(result_prikey_list):
                del_datas = result_prikey_list[betch_size*i:betch_size*(i+1)]
            else:
                del_datas = result_prikey_list[betch_size *
                                               i:len(result_prikey_list)]
            if config['mysql']['is_delete'] == 1:
                del_mysql_count = del_mysql_count + \
                    del_data(
                        s_node+config['mysql']['sql_del'].format(','.join(del_datas)), pool)
            if config['mongo']['is_delete'] == 1:
                del_mongo_count = del_mongo_count + \
                    delete_mongo(del_datas, config['mongo'])
            if config['phoenix']['is_delete'] == 1:
                del_phoenix_count = del_phoenix_count + \
                    delete_phoenix(del_datas, config['phoenix'])
        logger.info("操作节点:{}-需要删除的数据条数:{},删除的mysql数据条数:{},删除的mongo数据条数:{},删除的phoenix数据条数:{}".format(
            s_node, len(result_prikey_list), del_mysql_count, del_mongo_count, del_phoenix_count))


if __name__ == "__main__":
    logger = Logger(logname='main.log', logger="mylog", loggerLevel='logging.DEBUG',
                    fileHandlerLevel='logging.DEBUG', streamHandlerLevel='logging.DEBUG').getlog()

    try:
        params = sys.argv[1]
    except Exception:
        logger.error("./main.py  config.json")
        sys.exit(1)
    configfile = str(params).strip()
    logger.info("读取配置文件{}".format(configfile))
    '''
    填写配置文件
    '''
    config_json = read_json(configfile)
    logger.info("配置信息:{}".format(config_json))
    db_config = {'host': config_json['mysql']['host'],
                 'user': config_json['mysql']['user'],
                 'password': config_json['mysql']['password'],
                 'db': config_json['mysql']['db']}
    logger.info("读取node{}".format(db_config))
    pool = MysqlPool(MysqlConfig(db_config)).creatPool()
    mysqlutil = MysqlUtil(Mysql(pool))
    result = mysqlutil.selectAll(sql="show node;")
    node_list = [map['NAME'] for map in result]

    node_num = len(node_list)
    thread_pool = MyThreadPool(queue.Queue(), 12)
    for i in range(len(node_list)):
        s_node = "/!TDDL:NODE IN('{}')*/".format(node_list[i])
        param = {'s_node': s_node, 'config': config_json, 'pool': pool}
        dict = {'func': process, 'params': param}
        thread_pool.add(MyQueue(**dict))
    thread_pool.join()
