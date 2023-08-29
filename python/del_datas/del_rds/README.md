### [回到上级目录](../README.md)


## 删除rds，mysql，phoenix数据脚本

### 配置样例
```
{
    "common":{
        "channel":10,
        "batch_size":1024
    },
    "mysql": {
        "host": "10.124.158.186",
        "user": "pre_manager",
        "password": "aa11bb22",
        "db": "pre_param",
        "bak_name": "rc_depot_copy1",
        "sql_get": "SELECT DEPOT_ID from rc_depot_copy1 limit 10000;  ",
        "sql_del": "delete from rc_depot_copy1  where DEPOT_ID in ('{}')",
        "delete_key":"DEPOT_ID",
        "is_delete":1
    },
    "mongo": {
        "ip": "10.124.202.96",
        "port": 27017,
        "db": "res-int",
        "username": "",
        "password": "",
        "deletetable": "rc_depot_oper_copy2",
        "sql":"{'_id': {'$in': list(map(int, datas))}}",
        "is_delete":0
    },
    "phoenix": {
        "url": "http://10.124.193.210:8765/",
        "sql_del":"delete from rc_depot_oper_copy1 where ROW_KEY in ('{}')",
        "is_delete":0,
        "betch_size":500
    }
}
```

### 参数说明
- common
    通用配置
    - channel 
        - 线程池大小
        - 默认5
    - batch_size
        - 当个任务操作数据量
        - 默认1024
- mysql
    
    以下配置是DRDS的删除数据的配置信息
    - host
        - DRDS数据库的ip地址
        - 必填
    - user
        - DRDS数据库的用户名
        - 必填
    - password
        - DRDS数据库的密码
        - 必填
    - db
        - DRDS数据库的库名
        - 必填
    - bak_name
        - 备份数据的文件名
        - 必填
    - sql_get
        - 获取需要删除的数据，查询的结果会插入脚本运行目录的csv文件中
        - 必填
    - sql_del
        - 删除语句
        - 非必填
    - delete_key
        - 查询结果中的某列，用于删除使用
        - 必填
    - is_delete
        - 是否删除DRDS中数据，1删除 0不删除
        - 必填

- mongo
    
    以下配置是mongo的删除数据的配置信息
    - ip
        - mongo数据库的ip地址
        - 必填
    - port
        - mongo数据库的端口
        - 必填
    - db
        - mongo数据库的库名
        - 必填
    - username
        - mongo数据库的用户名
        - 非必填
    - password
        - DRDS数据库的密码
        - 必填  
    - deletetable
        - mongo中需要删除的表名
        - 必填
    - sql
        - 删除的条件 {'_id': {'$in': list(map(int, datas))}},可根据实际情况修改_id和类型
        - 非必填
    - is_delete
        - 是否删除mongo中数据，1删除 0不删除
        - 必填

- phoenix
    
    以下配置是phoenix的删除数据的配置信息
    - url
        - phoenix数据库的ip地址
        - 必填
    - sql_del
        - phoenix数据库的删除语句
        - 必填
    - betch_size
        - phoenix数据库的每次删除条数
        - 必填
    - is_delete
        - 是否删除mongo中数据，1删除 0不删除
        - 必填
