package com.membercard.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

/**
 * 行业模板 Mapper
 */
@Mapper
public interface IndustryTemplateMapper {

    /**
     * 查询所有行业列表（仅返回 id 和 industry）
     */
    @Select("SELECT id, industry, created_at FROM sys_industry_template ORDER BY id")
    List<Map<String, Object>> selectIndustryList();

    /**
     * 根据行业标识查询模板详情
     */
    @Select("SELECT id, industry, service_items, package_templates, created_at FROM sys_industry_template WHERE industry = #{industry}")
    Map<String, Object> selectByIndustry(String industry);
}
