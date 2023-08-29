# 存放资源中心割接用的相关文档和脚本

## 说明

## 目录
### [文档](document)
- [环境配置](document/环境配置.txt)
- [省份](document/省份.txt)

### [datax脚本](dataxjob)
- [中间库到测试环境](dataxjob/oracle2test/README.md)

- [中间库到联调环境](dataxjob/oracle2pre/README.md)

- [中间库到生产环境](dataxjob/oracle2prod/README.md)

- [生产环境到联调环境](dataxjob/prod2pre)

### [python脚本](python)
- [删除RDS、mongo、phoenix数据脚本](python/del_datas/del_rds/README.md)

- [删除DRDS、mongo、phoenix数据脚本](python/del_datas/del_drds/README.md)

## 注意
***1.不要擅自修改脚本，如果需要可联系平台单独拉出一个分支进行修改***

***2.脚本修改一律本地修改提交后，再登陆datax主机更新，确保git上的脚本是最新的在用的脚本***