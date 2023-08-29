import pymysql
from DBUtils.PooledDB import PooledDB
import sys
import logging
import os
import json
import threading
import queue
move_datas_count = 0
move_batch_datas_count = 0


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

    def get_qsize(self):
        '''获取队列深度'''
        return self.queue.qsize()

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
    """
        指定保存日志的文件路径，日志级别，以及调用文件
        将日志存入到指定的文件中
    """

    def __init__(self, logname,  logger, **arg):
        '''
           logname: 日志文件名
           logger: logger名
           **arg: loggerLevel = logging.DEBUG, fileHandlerLevel = logging.DEBUG, streamHandlerLevel = logging.DEBUG
        '''
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
            '%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')
        fh.setFormatter(formatter)
        ch.setFormatter(formatter)

        # 给logger添加handler
        self.logger.addHandler(fh)
        self.logger.addHandler(ch)

    def getlog(self):
        return self.logger


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
        self.setsession = ['SET AUTOCOMMIT = 0']
        self.pool = None

    def creatPool(self):
        self.pool = PooledDB(creator=pymysql, mincached=self.mincached, maxcached=self.maxcached,
                             maxshared=self.maxshared, maxconnections=self.maxconnections, blocking=self.blocking,
                             maxusage=self.maxusage, setsession=self.setsession, host=self.host,
                             user=self.user, password=self.password, db=self.db, port=self.port, charset=self.charset,
                             use_unicode=False)
        return self.pool


def read_json(file):
    '''
        读取json文件
    '''
    try:
        with open(file, 'r') as json_f:
            json_dict = json.load(json_f)
    except:
        raise Exception
    return json_dict


def get_columns(pool, table):
    show_cloumns_sql = "SHOW COLUMNS FROM {};".format(table)
    try:
        conn = pool.connection()
        cursor = conn.cursor()
        count = cursor.execute(show_cloumns_sql)
        if count > 0:
            results = cursor.fetchall()
            col_name_list = [tuple[0] for tuple in cursor.description]
            col_value_list = []
            for result in results:
                result_list = [0 for i in range(len(result))]
                for i in range(len(result)):
                    result_list[i] = result[i].decode(
                        'utf-8') if isinstance(result[i], bytes) else result[i]
                col_value_list.append(tuple(result_list))
    except:
        raise Exception
        logger.error('获取表{}表结构失败'.format(table))
    finally:
        cursor.close()
        conn.close()
    return col_name_list, col_value_list


def get_datas_count(pool, table):
    sql = 'select count(1) from {};'.format(table)
    try:
        conn = pool.connection()
        cursor = conn.cursor()
        count = cursor.execute(sql)
        result = cursor.fetchone()
    except:
        raise Exception
        logger.error('获取表{}总数据量失败'.format(table))
    finally:
        cursor.close()
        conn.close()
    return result[0]


def get_page_datas(pool, table, index_start, batch_size):
    sql = 'select * from {} limit {},{};'.format(
        table, index_start, batch_size)
    try:
        conn = pool.connection()
        cursor = conn.cursor()
        count = cursor.execute(sql)
        if count > 0:
            results = cursor.fetchall()
            page_name_list = [tuple[0] for tuple in cursor.description]
            page_value_list = []
            for result in results:
                result_list = [0 for i in range(len(result))]
                for i in range(len(result)):
                    result_list[i] = result[i].decode(
                        'utf-8') if isinstance(result[i], bytes) else result[i]
                page_value_list.append(tuple(result_list))
    except:
        logger.error('获取表{}表数据失败'.format(table))
    finally:
        cursor.close()
        conn.close()
    return page_name_list, page_value_list


def set_page_datas(pool, table, columns, datas, write_mode):
    s = '%s'
    for i in range(len(columns)-1):
        s = s + ',%s'
    sql = ''
    if write_mode == 'replace':
        sql = 'replace into {} ({}) values ({})'.format(
            table, ','.join(columns), s)
    elif write_mode == 'insert':
        sql = 'insert into {} ({}) values ({})'.format(
            table, ','.join(columns), s)

    conn = pool.connection()
    cursor = conn.cursor()
    # logger.info('执行[{}], 插入数据量[{}]'.format(sql, len(datas)))
    try:
        cursor.executemany(sql, datas)
        conn.commit()
    except Exception:
        conn.rollback()
        logger.error('数据批量插入失败，已回滚，改为一个一个插入')
        for data in datas:
            try:
                cursor.execute(sql, datain)
                conn.commit()
            except Exception:
                conn.rollback()
                logger.error('数据插入失败，已回滚，脏数据:[{}]'.format(data))


def task_job(source_pool, source_table, index_start, batch_size, target_pool, target_table, write_mode):
    page_name_list, page_value_list = get_page_datas(
        source_pool, source_table, index_start, batch_size)
    set_page_datas(target_pool, target_table, page_name_list, tuple(
        page_value_list), write_mode)
    lock.acquire()
    global move_batch_datas_count
    global move_datas_count
    move_batch_datas_count = move_batch_datas_count + batch_size
    move_datas_count = move_datas_count + batch_size
    lock.release()


def print_task_info():

    lock.acquire()
    global move_batch_datas_count
    global move_datas_count
    logger.info('导入数据总量:{}--导入速度:{}record/s'.format(move_datas_count,
                                                    move_batch_datas_count//10))
    move_batch_datas_count = 0
    lock.release()
    global timer
    timer = threading.Timer(10, print_task_info)
    timer.setDaemon(True)
    timer.start()


if __name__ == "__main__":

    logger = Logger(logname='log.log', logger="mylog", loggerLevel='logging.DEBUG',
                    fileHandlerLevel='logging.DEBUG', streamHandlerLevel='logging.DEBUG').getlog()
    try:
        params = sys.argv[1]
    except Exception:
        logger.error("请填写配置文件: python main.py  config.json")
        sys.exit(1)
    config_dict = read_json(params)

    logger.info('配置文件信息:\n{}'.format(json.dumps(config_dict,indent=4)))

    common_config = config_dict['common']
    source_config = config_dict['source']
    target_config = config_dict['target']
    channel = common_config['channel'] if 'channel' in common_config else 1
    batch_size = common_config['batch_size'] if 'batch_size' in common_config else 1024
    write_mode = common_config['write_mode']
    if write_mode != 'replace' and write_mode != 'insert':
        logger.error('write_modez只能为replace或者insert')
        os._exit()

    # 创建源数据源和目标数据源连接池
    source_pool = MysqlPool(source_config).creatPool()
    target_pool = MysqlPool(target_config).creatPool()

    # 读取源表表结构
    source_col_name_list, source_col_value_list = get_columns(
        source_pool, source_config['table'])
    source_columns = [source_col_value[0]
                      for source_col_value in source_col_value_list]

    # 读取目标表表结构
    target_col_name_list, target_col_value_list = get_columns(
        target_pool, target_config['table'])
    target_columns = [target_col_value[0]
                      for target_col_value in target_col_value_list]

    # 对比表结构
    for source_column in source_columns:
        if source_column in target_columns:
            target_columns.remove(source_column)
        else:
            logger.error('源表和目标表表结构不相同')
            sys.exit(1)
    if len(target_columns) != 0:
        logger.error('源表和目标表表结构不相同')
        sys.exit(1)

    # 读取源表数据总数
    source_datas_count = get_datas_count(source_pool, source_config['table'])

    # 创建连接池
    task_pool = MyThreadPool(queue.Queue(), channel)
    lock = threading.Lock()

    timer = threading.Timer(0, print_task_info)
    timer.setDaemon(True)
    timer.start()
    # 切分数据
    # splitPk应该为整形式
    # splitPk没有填写
    index_start = 0

    while True:
        if index_start > source_datas_count:
            break
        args = {'source_pool': source_pool, 'source_table': source_config['table'], 'index_start': index_start,
                'batch_size': batch_size, 'target_pool': target_pool, 'target_table': target_config['table'], 'write_mode': write_mode}
        task = {'func': task_job, 'params': args}
        task_pool.add(MyQueue(**task))
        index_start = index_start + batch_size
    task_pool.join()
    logger.info('任务结束:\n导入数据总量            :{}\n'.format(move_datas_count))
    sys.exit(0)
