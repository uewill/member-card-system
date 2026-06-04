package com.membercard.config;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.context.annotation.Configuration;

/**
 * MyBatis 配置
 */
@Configuration
@MapperScan("com.membercard.mapper")
public class MyBatisConfig {
}
