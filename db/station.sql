/*
 Navicat Premium Data Transfer

 Source Server         : 本地MySQL8
 Source Server Type    : MySQL
 Source Server Version : 80046
 Source Host           : localhost:3307
 Source Schema         : station

 Target Server Type    : MySQL
 Target Server Version : 80046
 File Encoding         : 65001

 Date: 09/07/2026 19:52:40
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for carrier
-- ----------------------------
DROP TABLE IF EXISTS `carrier`;
CREATE TABLE `carrier`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '快递公司名称',
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '公司编码',
  `sort` int(0) NULL DEFAULT 0 COMMENT '排序',
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `code`(`code`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 9 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '快递公司表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of carrier
-- ----------------------------
INSERT INTO `carrier` VALUES (1, '顺丰速运', 'SF', 1, '2026-07-09 19:50:19');
INSERT INTO `carrier` VALUES (2, '中通快递', 'ZTO', 2, '2026-07-09 19:50:19');
INSERT INTO `carrier` VALUES (3, '圆通速递', 'YTO', 3, '2026-07-09 19:50:19');
INSERT INTO `carrier` VALUES (4, '申通快递', 'STO', 4, '2026-07-09 19:50:19');
INSERT INTO `carrier` VALUES (5, '韵达速递', 'YD', 5, '2026-07-09 19:50:19');
INSERT INTO `carrier` VALUES (6, '极兔速递', 'JT', 6, '2026-07-09 19:50:19');
INSERT INTO `carrier` VALUES (7, '京东物流', 'JD', 7, '2026-07-09 19:50:19');
INSERT INTO `carrier` VALUES (8, '邮政EMS', 'EMS', 8, '2026-07-09 19:50:19');

-- ----------------------------
-- Table structure for chat_message
-- ----------------------------
DROP TABLE IF EXISTS `chat_message`;
CREATE TABLE `chat_message`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `sender_id` bigint(0) NOT NULL COMMENT '发送者ID',
  `receiver_id` bigint(0) NOT NULL COMMENT '接收者ID',
  `content` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '消息内容',
  `type` tinyint(0) NULL DEFAULT 0 COMMENT '0-文字 1-图片',
  `is_read` tinyint(0) NULL DEFAULT 0 COMMENT '0-未读 1-已读',
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_sender_receiver`(`sender_id`, `receiver_id`) USING BTREE,
  INDEX `idx_receiver_read`(`receiver_id`, `is_read`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '客服消息表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of chat_message
-- ----------------------------

-- ----------------------------
-- Table structure for operation_log
-- ----------------------------
DROP TABLE IF EXISTS `operation_log`;
CREATE TABLE `operation_log`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(0) NOT NULL COMMENT '操作人ID',
  `module` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '功能模块',
  `action` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '操作类型',
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '操作描述',
  `ip` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT 'IP地址',
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE,
  INDEX `idx_module`(`module`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '操作日志表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of operation_log
-- ----------------------------

-- ----------------------------
-- Table structure for parcel
-- ----------------------------
DROP TABLE IF EXISTS `parcel`;
CREATE TABLE `parcel`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `tracking_no` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '运单号',
  `pickup_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '取件码 A-03-005',
  `station_id` bigint(0) NOT NULL COMMENT '驿站ID',
  `shelf_id` bigint(0) NOT NULL COMMENT '货架ID',
  `shelf_floor` tinyint(0) NOT NULL COMMENT '货架层号',
  `carrier_id` bigint(0) NOT NULL COMMENT '快递公司ID',
  `recipient_phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '收件人手机号',
  `status` tinyint(0) NULL DEFAULT 0 COMMENT '0-待取 1-已取 2-滞留',
  `inbound_time` datetime(0) NOT NULL COMMENT '入库时间',
  `outbound_time` datetime(0) NULL DEFAULT NULL COMMENT '出库时间',
  `outbound_by` bigint(0) NULL DEFAULT NULL COMMENT '出库操作人ID',
  `operator_id` bigint(0) NOT NULL COMMENT '入库操作人ID',
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `pickup_code`(`pickup_code`) USING BTREE,
  INDEX `idx_pickup_code`(`pickup_code`) USING BTREE,
  INDEX `idx_recipient_phone`(`recipient_phone`) USING BTREE,
  INDEX `idx_station_status`(`station_id`, `status`) USING BTREE,
  INDEX `idx_inbound_time`(`inbound_time`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '包裹表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of parcel
-- ----------------------------

-- ----------------------------
-- Table structure for refresh_token
-- ----------------------------
DROP TABLE IF EXISTS `refresh_token`;
CREATE TABLE `refresh_token`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `user_id` bigint(0) NOT NULL COMMENT '用户ID',
  `token` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'Refresh Token',
  `expire_time` datetime(0) NOT NULL COMMENT '过期时间',
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `token`(`token`) USING BTREE,
  INDEX `idx_user_id`(`user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = 'Token白名单表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of refresh_token
-- ----------------------------

-- ----------------------------
-- Table structure for shelf
-- ----------------------------
DROP TABLE IF EXISTS `shelf`;
CREATE TABLE `shelf`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `station_id` bigint(0) NOT NULL COMMENT '驿站ID',
  `code` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '货架编码 A/B/C',
  `floor_count` tinyint(0) NULL DEFAULT 5 COMMENT '层数',
  `status` tinyint(0) NULL DEFAULT 1 COMMENT '0-停用 1-正常',
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_station_code`(`station_id`, `code`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '货架表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of shelf
-- ----------------------------

-- ----------------------------
-- Table structure for sms_code
-- ----------------------------
DROP TABLE IF EXISTS `sms_code`;
CREATE TABLE `sms_code`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号',
  `code` varchar(6) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '验证码',
  `type` tinyint(0) NOT NULL COMMENT '1-注册 2-找回密码',
  `expire_time` datetime(0) NOT NULL COMMENT '过期时间',
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_phone_type`(`phone`, `type`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '短信验证码表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of sms_code
-- ----------------------------

-- ----------------------------
-- Table structure for station
-- ----------------------------
DROP TABLE IF EXISTS `station`;
CREATE TABLE `station`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '驿站名称',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `district` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '详细地址',
  `manager_id` bigint(0) NOT NULL COMMENT '站长ID',
  `status` tinyint(0) NULL DEFAULT 1 COMMENT '0-停用 1-正常',
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_manager`(`manager_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '驿站表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of station
-- ----------------------------

-- ----------------------------
-- Table structure for station_staff
-- ----------------------------
DROP TABLE IF EXISTS `station_staff`;
CREATE TABLE `station_staff`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `station_id` bigint(0) NOT NULL COMMENT '驿站ID',
  `user_id` bigint(0) NOT NULL COMMENT '员工用户ID',
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_station_user`(`station_id`, `user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '员工关联表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of station_staff
-- ----------------------------

-- ----------------------------
-- Table structure for user
-- ----------------------------
DROP TABLE IF EXISTS `user`;
CREATE TABLE `user`  (
  `id` bigint(0) NOT NULL AUTO_INCREMENT,
  `phone` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT '手机号',
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'BCrypt加密密码',
  `nickname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '昵称',
  `avatar` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '头像URL',
  `role` tinyint(0) NOT NULL DEFAULT 0 COMMENT '0-普通用户 1-员工 2-站长 3-管理员',
  `audit_status` tinyint(0) NULL DEFAULT 1 COMMENT '0-待审核 1-已通过 2-已拒绝',
  `reject_reason` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL COMMENT '拒绝理由',
  `province` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `city` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `district` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `login_fail_count` tinyint(0) NULL DEFAULT 0 COMMENT '密码错误次数',
  `lock_until` datetime(0) NULL DEFAULT NULL COMMENT '锁定截止时间',
  `deletion_status` tinyint(0) NULL DEFAULT 0 COMMENT '0-正常 1-冷静期 2-已删除',
  `deletion_time` datetime(0) NULL DEFAULT NULL COMMENT '申请注销时间',
  `created_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0),
  `updated_at` datetime(0) NULL DEFAULT CURRENT_TIMESTAMP(0) ON UPDATE CURRENT_TIMESTAMP(0),
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `phone`(`phone`) USING BTREE,
  INDEX `idx_phone`(`phone`) USING BTREE,
  INDEX `idx_role_audit`(`role`, `audit_status`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci COMMENT = '用户表' ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of user
-- ----------------------------

SET FOREIGN_KEY_CHECKS = 1;
