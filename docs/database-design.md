# docs/database-design.md 完整文档（新增district三级联动地区表，包含全部11张表）
```markdown
# 驿站快递管理系统 - 数据库设计文档
## 1. 文档概述
### 1.1 项目说明
本项目是快递驿站综合管理平台，包含用户端、驿站员工端、管理员后台，实现包裹入库出库、取件、客服聊天、操作日志、权限管理、短信验证码、快递商管理、省市区三级地址联动等全流程功能。
### 1.2 数据库基础信息
- 数据库名：`station`
- 数据库版本：MySQL 8.0+
- 字符集：utf8mb4（支持emoji、生僻中文）
- 存储引擎：InnoDB
- 排序规则：utf8mb4_0900_ai_ci
### 1.3 设计规范
1. 主键统一使用 `bigint` 自增id；
2. 状态、层级、角色等枚举字段统一用 `tinyint` 数字；
3. 时间字段统一 `datetime`，默认 `CURRENT_TIMESTAMP`；
4. 手机号、编码、取件码、token类字段建立唯一索引；
5. 高频查询、关联查询字段建立普通/复合索引提升性能；
6. 基础字典表优先创建（district地区表、carrier快递公司表）；
7. 不使用物理外键，业务关联逻辑由后端代码校验，避免并发锁表。

## 2. 整体业务ER关系说明
1. `district` 地区字典表：全国省市区三级联动基础数据，供驿站、用户地址选择；
2. `user` 用户表：区分普通用户、员工、站长、超级管理员四种角色；
3. `station` 驿站表：一个站长管理一个驿站，存储驿站地址关联district地区ID；
4. `station_staff` 员工关联表：多对多关联用户与驿站，一个员工可绑定多个驿站；
5. `shelf` 货架表：每个驿站拥有多个货架，货架分层存放包裹；
6. `parcel` 包裹表（核心业务表）：绑定驿站、货架、快递公司、收件用户手机号；
7. `carrier` 快递公司表：预存顺丰、中通、圆通等主流快递编码与名称；
8. `chat_message` 客服消息表：用户与驿站员工在线聊天记录；
9. `operation_log` 操作日志表：记录后台所有人员增删改查操作、操作IP；
10. `sms_code` 短信验证码表：注册、找回密码短信缓存，带过期时间；
11. `refresh_token` 登录令牌表：存储用户长效刷新Token，实现登录无感续期。

## 3. 数据表详细设计
### 3.1 district 省市区三级联动字典表
#### 表用途
提供全国标准省、市、区县数据，前端地址下拉三级联动专用；驿站、用户不再存储纯文本省市区，仅存储地区did，统一地址数据规范。
| 字段名 | 类型 | 约束 | 注释 |
| ---- | ---- | ---- | ---- |
| did | bigint unsigned | PK、自增 | 地区唯一主键ID |
| pid | bigint unsigned | NOT NULL 默认0 | 父级ID；省份pid=0，城市pid=省份did，区县pid=城市did |
| district | varchar(120) | NOT NULL | 省/市/区名称 |
| level | tinyint | NOT NULL | 层级：1=省份，2=城市，3=区县 |
#### 索引说明
1. `idx_pid(pid)`：核心索引，根据父ID快速查询下级地区，支撑三级联动下拉；
2. `idx_level(level)`：快速单独查询全部省份/城市/区县。

### 3.2 carrier 快递公司表
| 字段名 | 类型 | 约束 | 注释 |
| ---- | ---- | ---- | ---- |
| id | bigint | PK、自增 | 主键ID |
| name | varchar(50) | NOT NULL | 快递公司名称 |
| code | varchar(20) | NOT NULL、唯一索引 | 快递编码 SF/ZTO/YTO/EMS等 |
| sort | int | 默认0 | 前台展示排序号 |
| created_at | datetime | 默认当前时间 | 创建时间 |
初始化基础数据：顺丰速运、中通快递、圆通速递、申通快递、韵达速递、极兔速递、京东物流、邮政EMS。

### 3.3 user 用户表（权限核心表）
| 字段名 | 类型 | 约束 | 注释 |
| ---- | ---- | ---- | ---- |
| id | bigint | PK自增 | 用户唯一ID |
| phone | varchar(11) | NOT NULL、唯一 | 登录手机号 |
| password | varchar(255) | NOT NULL | BCrypt加密密码 |
| nickname | varchar(50) | 可空 | 用户昵称 |
| avatar | varchar(255) | 可空 | 头像图片URL |
| role | tinyint | 默认0 | 0普通用户 1员工 2站长 3超级管理员 |
| audit_status | tinyint | 默认1 | 0待审核 1已通过 2审核拒绝 |
| reject_reason | varchar(255) | 可空 | 员工账号审核拒绝理由 |
| province_did | bigint unsigned | 可空 | 用户收货省份did，关联district.did |
| city_did | bigint unsigned | 可空 | 用户收货城市did |
| district_did | bigint unsigned | 可空 | 用户收货区县did |
| address | varchar(255) | 可空 | 详细街道地址 |
| login_fail_count | tinyint | 默认0 | 密码错误累计次数，用于账号锁定 |
| lock_until | datetime | 可空 | 账号锁定截止时间 |
| deletion_status | tinyint | 默认0 | 0正常 1注销冷静期 2已删除 |
| deletion_time | datetime | 可空 | 提交注销申请时间 |
| created_at | datetime | 默认当前时间 | 创建时间 |
| updated_at | datetime | 自动更新 | 信息修改更新时间 |
#### 索引说明
1. 唯一索引：phone，手机号全局唯一；
2. 复合索引：idx_role_audit(role,audit_status)，快速筛选不同角色审核状态用户。

### 3.4 station 驿站表
| 字段名 | 类型 | 约束 | 注释 |
| ---- | ---- | ---- | ---- |
| id | bigint | PK自增 | 驿站ID |
| name | varchar(100) | NOT NULL | 驿站门店名称 |
| province_did | bigint unsigned | NOT NULL | 驿站省份did |
| city_did | bigint unsigned | NOT NULL | 驿站城市did |
| district_did | bigint unsigned | NOT NULL | 驿站区县did |
| address | varchar(255) | NOT NULL | 驿站详细街道地址 |
| manager_id | bigint | NOT NULL、索引 | 站长用户ID，关联user.id |
| status | tinyint | 默认1 | 0停用关闭 1正常营业 |
| created_at | datetime | 默认当前时间 | 创建时间 |

### 3.5 station_staff 驿站员工关联表（多对多）
#### 业务说明
一个驿站可绑定多名员工，一名员工可同时任职多个驿站；联合唯一索引防止重复绑定。
| 字段名 | 类型 | 约束 | 注释 |
| ---- | ---- | ---- | ---- |
| id | bigint | PK自增 | 主键ID |
| station_id | bigint | NOT NULL | 驿站ID |
| user_id | bigint | NOT NULL | 员工用户ID |
| created_at | datetime | 默认当前时间 | 绑定入职时间 |
#### 索引：uk_station_user(station_id,user_id) 联合唯一索引

### 3.6 shelf 货架表
| 字段名 | 类型 | 约束 | 注释 |
| ---- | ---- | ---- | ---- |
| id | bigint | PK自增 | 货架ID |
| station_id | bigint | NOT NULL | 所属驿站ID |
| code | varchar(10) | NOT NULL | 货架编码 A/B/C |
| floor_count | tinyint | 默认5 | 货架总层数 |
| status | tinyint | 默认1 | 0停用 1正常存放包裹 |
| created_at | datetime | 默认当前时间 | 创建时间 |
#### 索引：uk_station_code(station_id,code)，同一驿站货架编码不重复

### 3.7 parcel 包裹业务核心表
| 字段名 | 类型 | 约束 | 注释 |
| ---- | ---- | ---- | ---- |
| id | bigint | PK自增 | 包裹主键ID |
| tracking_no | varchar(50) | NOT NULL | 快递原始运单号 |
| pickup_code | varchar(20) | NOT NULL、唯一 | 驿站取件码 格式A-03-005 |
| station_id | bigint | NOT NULL | 归属驿站ID |
| shelf_id | bigint | NOT NULL | 存放货架ID |
| shelf_floor | tinyint | NOT NULL | 货架层数 |
| carrier_id | bigint | NOT NULL | 快递公司ID，关联carrier.id |
| recipient_phone | varchar(11) | NOT NULL | 收件人手机号 |
| status | tinyint | 默认0 | 0待取件 1已出库取走 2滞留超期 |
| inbound_time | datetime | NOT NULL | 包裹入库扫描时间 |
| outbound_time | datetime | 可空 | 取件出库时间 |
| outbound_by | bigint | 可空 | 出库操作员工user.id |
| operator_id | bigint | NOT NULL | 入库扫描操作人user.id |
| created_at | datetime | 默认当前时间 | 记录创建时间 |
#### 索引说明
1. 唯一索引：pickup_code，取件码全局唯一；
2. idx_recipient_phone：手机号快速查本人所有包裹；
3. idx_station_status(station_id,status)：驿站分页查询本站待取/已取包裹；
4. idx_inbound_time：按入库时间筛选历史包裹。

### 3.8 chat_message 客服聊天消息表
#### 业务说明
存储用户与驿站员工在线对话记录，支持文字、图片消息，区分已读未读状态。
| 字段名 | 类型 | 约束 | 注释 |
| ---- | ---- | ---- | ---- |
| id | bigint | PK自增 | 消息ID |
| sender_id | bigint | NOT NULL | 发送者user.id |
| receiver_id | bigint | NOT NULL | 接收者user.id |
| content | text | NOT NULL | 消息文本/图片链接 |
| type | tinyint | 默认0 | 0文字消息 1图片消息 |
| is_read | tinyint | 默认0 | 0未读 1已读 |
| created_at | datetime | 默认当前时间 | 消息发送时间 |
#### 索引
1. idx_sender_receiver(sender_id,receiver_id)：快速查询两人完整聊天记录；
2. idx_receiver_read(receiver_id,is_read)：查询用户未读消息。

### 3.9 operation_log 后台操作日志表
记录所有后台账号增删改查、导入导出操作，用于溯源审计。
| 字段名 | 类型 | 约束 | 注释 |
| ---- | ---- | ---- | ---- |
| id | bigint | PK自增 | 日志ID |
| user_id | bigint | NOT NULL | 操作人user.id |
| module | varchar(50) | NOT NULL | 操作模块：包裹管理/驿站管理/用户管理等 |
| action | varchar(50) | NOT NULL | 操作类型：新增/编辑/删除/导出/入库 |
| description | varchar(255) | 可空 | 操作详情描述 |
| ip | varchar(50) | 可空 | 操作客户端IP地址 |
| created_at | datetime | 默认当前时间 | 操作时间 |
#### 索引：idx_user_id、idx_module，按操作人/模块筛选日志

### 3.10 sms_code 短信验证码表
用于账号注册、找回密码短信验证码存储，过期自动失效。
| 字段名 | 类型 | 约束 | 注释 |
| ---- | ---- | ---- | ---- |
| id | bigint | PK自增 | 主键ID |
| phone | varchar(11) | NOT NULL | 接收验证码手机号 |
| code | varchar(6) | NOT NULL | 6位数字验证码 |
| type | tinyint | NOT NULL | 1注册账号 2找回密码 |
| expire_time | datetime | NOT NULL | 验证码过期时间 |
| created_at | datetime | 默认当前时间 | 发送时间 |
#### 索引：idx_phone_type(phone,type)，快速校验对应业务验证码

### 3.11 refresh_token 登录刷新令牌表
实现JWT长效登录，token过期前自动刷新，登出/注销直接删除记录。
| 字段名 | 类型 | 约束 | 注释 |
| ---- | ---- | ---- | ---- |
| id | bigint | PK自增 | 主键ID |
| user_id | bigint | NOT NULL | 所属登录用户ID |
| token | varchar(500) | NOT NULL、唯一 | 长效刷新Token字符串 |
| expire_time | datetime | NOT NULL | Token过期时间 |
| created_at | datetime | 默认当前时间 | 签发时间 |
#### 索引：唯一索引token；普通索引idx_user_id

## 4. 索引整体设计规范
1. 唯一索引场景：手机号、快递编码、取件码、刷新Token、驿站+货架联合、驿站+员工联合；
2. 普通索引场景：所有外键关联ID（station_id、user_id、manager_id、pid、did）；
3. 复合索引场景：高频联合筛选条件（驿站+包裹状态、发送人+接收人、手机号+验证码类型）；
4. 时间索引：入库时间、操作时间，用于分页筛选历史数据。

## 5. 性能与拓展设计说明
1. 统一字符集utf8mb4，兼容生僻字、emoji表情；
2. 使用tinyint存储状态、角色、层级，节省磁盘空间，查询效率高于字符串；
3. 无物理外键，业务关联校验由后端代码实现，避免高并发入库锁表；
4. 地址统一使用district地区表ID关联，解决多表省市区文本不一致问题，支持地址筛选统计；
5. 短信验证码、refresh_token设置过期时间，定时任务清理失效数据，减少表体积；
6. 包裹表针对驿站高频查询做复合索引，适配驿站只查看本站包裹的核心业务场景。

## 6. 配套SQL脚本文件说明
项目sql目录三份脚本分工：
1. `sql/init-database.sql`：完整建表语句，表创建顺序优先district、carrier基础字典，再业务表；
2. `sql/init-data.sql`：系统初始化基础数据，包含全国省市区district完整数据、8条快递公司基础数据、超级管理员初始账号；
3. `sql/demo-data.sql`：测试演示数据，包含测试驿站、员工账号、20条模拟包裹、客服聊天测试消息。
```