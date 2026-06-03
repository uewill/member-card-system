package com.membercard;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 通用多租户次卡会员管理系统 - 后端启动类
 */
@SpringBootApplication
@MapperScan("com.membercard.mapper")
public class MemberCardApplication {

    public static void main(String[] args) {
        SpringApplication.run(MemberCardApplication.class, args);
    }
}