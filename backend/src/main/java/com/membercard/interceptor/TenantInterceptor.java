package com.membercard.interceptor;

import com.baomidou.mybatisplus.core.toolkit.PluginUtils;
import com.baomidou.mybatisplus.extension.plugins.inner.InnerInterceptor;
import lombok.extern.slf4j.Slf4j;
import net.sf.jsqlparser.expression.Expression;
import net.sf.jsqlparser.expression.LongValue;
import net.sf.jsqlparser.expression.operators.relational.EqualsTo;
import net.sf.jsqlparser.schema.Column;
import net.sf.jsqlparser.statement.select.PlainSelect;
import org.apache.ibatis.executor.Executor;
import org.apache.ibatis.mapping.BoundSql;
import org.apache.ibatis.mapping.MappedStatement;
import org.apache.ibatis.session.ResultHandler;
import org.apache.ibatis.session.RowBounds;
import org.springframework.stereotype.Component;

import java.lang.reflect.Field;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

/**
 * 多租户拦截器 - 自动注入 tenant_id 过滤条件
 */
@Slf4j
@Component
public class TenantInterceptor implements InnerInterceptor {

    /**
     * 忽略租户隔离的表（全局表）
     */
    private static final Set<String> IGNORE_TABLES = new HashSet<>(Arrays.asList(
            "sys_global_dict",
            "sys_tenant",
            "flyway_schema_history"
    ));

    /**
     * 从 ThreadLocal 获取当前租户 ID
     */
    private Long getCurrentTenantId() {
        return TenantContextHolder.getTenantId();
    }

    @Override
    public void beforeQuery(Executor executor, MappedStatement ms, Object parameter, 
                           RowBounds rowBounds, ResultHandler resultHandler, BoundSql boundSql) throws SQLException {
        
        Long tenantId = getCurrentTenantId();
        if (tenantId == null) {
            // 平台管理员或未登录场景，不注入租户条件
            return;
        }

        // 获取原始 SQL
        String sql = boundSql.getSql();
        
        // 解析 SQL 并注入 tenant_id 条件
        try {
            PluginUtils.MPBoundSql mpBs = PluginUtils.mpBoundSql(boundSql);
            String newSql = injectTenantCondition(sql, tenantId);
            mpBs.sql(newSql);
            log.debug("多租户SQL注入: {} -> {}", sql, newSql);
        } catch (Exception e) {
            log.warn("多租户SQL注入失败: {}", e.getMessage());
        }
    }

    /**
     * 注入 tenant_id 条件到 SQL 中
     */
    private String injectTenantCondition(String sql, Long tenantId) {
        // 简化实现：检查是否包含需要隔离的表
        for (String ignoreTable : IGNORE_TABLES) {
            if (sql.toLowerCase().contains(ignoreTable.toLowerCase())) {
                return sql; // 不注入
            }
        }

        // 构建 tenant_id 条件
        EqualsTo tenantCondition = new EqualsTo();
        tenantCondition.setLeftExpression(new Column("tenant_id"));
        tenantCondition.setRightExpression(new LongValue(tenantId));

        // 注入到 WHERE 条件中（简化版，实际应使用 JSqlParser 完整解析）
        if (sql.toLowerCase().contains("where")) {
            return sql + " AND tenant_id = " + tenantId;
        } else if (sql.toLowerCase().contains("group by") || sql.toLowerCase().contains("order by")) {
            // 在 GROUP BY 或 ORDER BY 前插入 WHERE
            int insertPos = sql.toLowerCase().indexOf("group by");
            if (insertPos == -1) {
                insertPos = sql.toLowerCase().indexOf("order by");
            }
            if (insertPos != -1) {
                return sql.substring(0, insertPos) + " WHERE tenant_id = " + tenantId + " " + sql.substring(insertPos);
            }
        }
        
        return sql + " WHERE tenant_id = " + tenantId;
    }
}