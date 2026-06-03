package com.membercard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 全局字典服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class GlobalDictService {

    private final JdbcTemplate jdbcTemplate;

    /**
     * 新增字典项
     */
    public void create(Map<String, Object> dict) {
        String dictType = (String) dict.get("dictType");
        String dictKey = (String) dict.get("dictKey");
        String dictValue = (String) dict.get("dictValue");
        Integer sortOrder = dict.get("sortOrder") != null ? (Integer) dict.get("sortOrder") : 0;

        String sql = "INSERT INTO sys_global_dict (dict_type, dict_key, dict_value, sort_order, status) VALUES (?, ?, ?, ?, 1)";
        jdbcTemplate.update(sql, dictType, dictKey, dictValue, sortOrder);
    }

    /**
     * 更新字典项
     */
    public void update(Long id, Map<String, Object> dict) {
        StringBuilder sql = new StringBuilder("UPDATE sys_global_dict SET ");
        List<Object> params = new ArrayList<>();

        if (dict.containsKey("dictValue")) {
            sql.append("dict_value = ?, ");
            params.add(dict.get("dictValue"));
        }
        if (dict.containsKey("sortOrder")) {
            sql.append("sort_order = ?, ");
            params.add(dict.get("sortOrder"));
        }
        if (dict.containsKey("status")) {
            sql.append("status = ?, ");
            params.add(dict.get("status"));
        }

        if (params.isEmpty()) {
            return;
        }

        sql = new StringBuilder(sql.substring(0, sql.length() - 2));
        sql.append(" WHERE id = ?");
        params.add(id);

        jdbcTemplate.update(sql.toString(), params.toArray());
    }

    /**
     * 删除字典项
     */
    public void delete(Long id) {
        jdbcTemplate.update("DELETE FROM sys_global_dict WHERE id = ?", id);
    }

    /**
     * 根据字典类型查询字典列表
     */
    public List<Map<String, Object>> getByType(String dictType) {
        String sql = "SELECT id, dict_type, dict_key, dict_value, sort_order, status, created_at FROM sys_global_dict WHERE dict_type = ? AND status = 1 ORDER BY sort_order";
        return jdbcTemplate.queryForList(sql, dictType);
    }

    /**
     * 分页查询字典列表
     */
    public Page<Map<String, Object>> page(Integer current, Integer size, String dictType) {
        Page<Map<String, Object>> page = new Page<>(current, size);

        StringBuilder countSql = new StringBuilder("SELECT COUNT(*) FROM sys_global_dict WHERE status = 1");
        StringBuilder querySql = new StringBuilder("SELECT id, dict_type, dict_key, dict_value, sort_order, status, created_at FROM sys_global_dict WHERE status = 1");

        if (dictType != null && !dictType.isEmpty()) {
            countSql.append(" AND dict_type = '").append(dictType).append("'");
            querySql.append(" AND dict_type = '").append(dictType).append("'");
        }

        querySql.append(" ORDER BY sort_order LIMIT ").append(size).append(" OFFSET ").append((current - 1) * size);

        Long total = jdbcTemplate.queryForObject(countSql.toString(), Long.class);
        List<Map<String, Object>> records = jdbcTemplate.queryForList(querySql.toString());

        page.setTotal(total);
        page.setRecords(records);
        return page;
    }
}
