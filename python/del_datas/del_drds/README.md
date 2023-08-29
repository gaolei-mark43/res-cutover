### [回到上级目录](../README.md)


## 删除drds，mysql，phoenix数据脚本

### 配置样例
```
{
    "mysql": {
        "host": "x.x.x.x",
        "user": "x",
        "password": "x",
        "db": "x",
        "deletetable": "x",
        "sql_get": "x;  ",
        "sql_del": "x",
        "deletekey":"x",
        "is_delete":1,
        "betch_size":20000
    },
    "mongo": {
        "ip": "x",
        "port": 27017,
        "db": "x",
        "username": "",
        "password": "",
        "deletetable": "x",
        "sql":"{'_id': {'$in': list(map(int, datas))}}",
        "is_delete":0
    },
    "phoenix": {
        "url": "x",
        "sql_del":"x",
        "is_delete":0,
        "betch_size":500
    }
}
```

### 参数说明
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
    - deletetable
        - DRDS中需要删除的表名
        - 必填
    - sql_get
        - 获取需要删除的数据，查询的结果会插入脚本运行目录的csv文件中
        - 必填
    - sql_del
        - 删除语句
        - 非必填
    - deletekey
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
        - 注意：删除的字段如果为int型使用{'_id': {'$in': list(map(int, datas))}}；如果为string型使用{'_id': {'$in': datas}}
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
