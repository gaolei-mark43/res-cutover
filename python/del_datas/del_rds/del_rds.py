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

del_mysql_count = 0
del_mongo_count = 0
del_phoenix_count = 0 

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


def delete_mysql(datas, config):
    if config['is_delete'] == 1:
        sql = config['sql_del'].format('\',\''.join(datas))
        db = mysql_pool.connection()
        cursor_source = db.cursor()
        count = 0
        try:
            count = cursor_source.execute(sql)
            db.commit()
        except Exception:
            db.rollback()
            logger.error('数据删除失败，已回滚，脏数据:[{}]'.format(datas))
        db.close()
        cursor_source.close()
        return count
    else:
        return 0


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
    if config['is_delete'] == 1:
        client = pymongo.MongoClient(config['ip'], config['port'])  # 建立客户端对象
        db = client[config['db']]
        if config['username'] != '':
            db.authenticate(config['username'], config['password'])
        myquery = eval(config['sql'])
        collection = db[config['deletetable']]
        result = collection.delete_many(myquery)
        return result.deleted_count
    else:
        return 0


def delete_phoenix(datas, config):
    if config['is_delete'] == 1:
        conn = phoenixdb.connect(config['url'], autocommit=True)
        cursor = conn.cursor()
        count = 0
        betch_data = []
        betch_size = config['betch_size']
        task = len(datas)//betch_size
        if len(datas) % betch_size != 0:
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
    else :
        return 0
    


def del_datas(**args):
    global del_mysql_count
    global del_mongo_count
    global del_phoenix_count
    mysql_count = delete_mysql(args['batch_datas'],args['mysql_config'])
    mongo_count = delete_mongo(args['batch_datas'], args['mongo_config'])
    phoenix_count = delete_phoenix(args['batch_datas'], args['phoenix_config'])
    if mysql_count != 0 or mongo_count != 0 or phoenix_count != 0:
        lock.acquire()
        del_mysql_count = del_mysql_count + mysql_count
        del_mongo_count = del_mongo_count + mongo_count
        del_phoenix_count = del_phoenix_count + phoenix_count
        lock.release()


def process(common_config,mysql_config,mongo_config,phoenix_config,datas):
    global del_mysql_count
    global del_mongo_count
    global del_phoenix_count
    channel = common_config['channel'] if 'channel' in common_config else 5
    batch_size = common_config['batch_size'] if 'batch_size' in common_config else 1024
    channel_pool = MyThreadPool(queue.Queue(),channel)
    index = 0
    while True:
        batch_datas = []
        if index + batch_size <= len(datas) :
            batch_datas = datas[index:index + batch_size]
            index = index +batch_size
        elif index < len(datas):
            batch_datas = datas[index:len(datas)]
            index = len(datas)
        else:
            break    
        args= {'batch_datas':batch_datas,'mysql_config':mysql_config,'mongo_config':mongo_config,'phoenix_config':phoenix_config}
        task = {'func': del_datas, 'params': args}
        channel_pool.add(MyQueue(**task)) 
        
    channel_pool.join()
    logger.info("需要删除的数据条数:{},删除的mysql数据条数:{},删除的mongo数据条数:{},删除的phoenix数据条数:{}".format(len(datas), del_mysql_count, del_mongo_count, del_phoenix_count))


if __name__ == "__main__":
    logger = Logger(logname='del_rds.log', logger="del_rds", loggerLevel='logging.DEBUG',
                    fileHandlerLevel='logging.DEBUG', streamHandlerLevel='logging.DEBUG').getlog()
    lock = threading.Lock()

    try:
        params = sys.argv[1]
    except Exception:
        logger.error('./main.py  config.json')
        sys.exit(1)
    configfile = str(params).strip()
    logger.info('读取配置文件{}'.format(configfile))
    '''
    填写配置文件
    '''
    config_json = read_json(configfile)
    logger.info('配置信息:{}'.format(config_json))
    common_config = config_json['common']
    mysql_config = config_json['mysql']
    mongo_config = config_json['mongo']
    phoenix_config = config_json['phoenix']

    # 创建rds连接池
    db_config = {'host': config_json['mysql']['host'],
                 'user': config_json['mysql']['user'],
                 'password': config_json['mysql']['password'],
                 'db': config_json['mysql']['db']}
    mysql_pool = MysqlPool(MysqlConfig(db_config)).creatPool()

    # 读取rds要删除的数据
    sql_get = mysql_config['sql_get']
    col_name_list, result_dict_list = get_data(sql_get, mysql_pool)
    logger.info('rds读取到符合条件数据条数:{}'.format(len(result_dict_list)))
    if len(result_dict_list) != 0:
        bak_name = mysql_config['bak_name'] + '.csv'
        logger.info("备份要删除的数据至文件:{}".format(bak_name))
        write_csv(bak_name, result_dict_list)
        # 获取要删除的条件
        delete_key = col_name_list.index(mysql_config['delete_key'])
        result_delete_list = [str(result_dict[delete_key]) for result_dict in result_dict_list]
        if len(result_delete_list) != 0:
            process(common_config,mysql_config,mongo_config,phoenix_config,result_delete_list)