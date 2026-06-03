package com.membercard.service;

import com.membercard.interceptor.TenantContextHolder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;

/**
 * 报表服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ReportService {

    private final JdbcTemplate jdbcTemplate;

    /**
     * 营业报表（日/周/月）
     */
    public Map<String, Object> getBusinessReport(String startDate, String endDate, Long storeId, String groupBy) {
        Long tenantId = TenantContextHolder.getTenantId();

        // 汇总数据
        StringBuilder summarySql = new StringBuilder(
                "SELECT COUNT(*) AS total_orders, " +
                "SUM(total_amount) AS total_amount, " +
                "SUM(paid_amount) AS paid_amount, " +
                "COUNT(DISTINCT member_id) AS total_members " +
                "FROM t_consume_order " +
                "WHERE tenant_id = ? AND status = 'COMPLETED' " +
                "AND created_at >= ? AND created_at <= ? ");

        List<Object> params = new ArrayList<>();
        params.add(tenantId);
        params.add(startDate);
        params.add(endDate);

        if (storeId != null) {
            summarySql.append("AND store_id = ? ");
            params.add(storeId);
        }

        Map<String, Object> summary = jdbcTemplate.queryForMap(summarySql.toString(), params.toArray());

        // 分组数据
        String groupField = "groupBy" != null && "month".equals(groupBy) ?
                "DATE_FORMAT(created_at, '%Y-%m')" : "DATE(created_at)";

        StringBuilder detailSql = new StringBuilder(
                "SELECT " + groupField + " AS period, " +
                "COUNT(*) AS order_count, " +
                "SUM(total_amount) AS total_amount, " +
                "SUM(paid_amount) AS paid_amount, " +
                "COUNT(DISTINCT member_id) AS member_count " +
                "FROM t_consume_order " +
                "WHERE tenant_id = ? AND status = 'COMPLETED' " +
                "AND created_at >= ? AND created_at <= ? ");

        List<Object> detailParams = new ArrayList<>();
        detailParams.add(tenantId);
        detailParams.add(startDate);
        detailParams.add(endDate);

        if (storeId != null) {
            detailSql.append("AND store_id = ? ");
            detailParams.add(storeId);
        }

        detailSql.append("GROUP BY period ORDER BY period");

        List<Map<String, Object>> details = jdbcTemplate.queryForList(detailSql.toString(), detailParams.toArray());

        Map<String, Object> report = new HashMap<>();
        report.put("summary", summary);
        report.put("details", details);
        report.put("startDate", startDate);
        report.put("endDate", endDate);
        return report;
    }

    /**
     * 套餐分析报表
     */
    public List<Map<String, Object>> getPackageReport(String startDate, String endDate) {
        Long tenantId = TenantContextHolder.getTenantId();

        StringBuilder sql = new StringBuilder(
                "SELECT pt.id, pt.name, pt.type, pt.sale_price, " +
                "COUNT(mc.id) AS sold_count, " +
                "SUM(pt.sale_price) AS total_revenue, " +
                "SUM(CASE WHEN mc.status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_count, " +
                "SUM(CASE WHEN mc.status = 'USED_UP' THEN 1 ELSE 0 END) AS used_up_count, " +
                "SUM(CASE WHEN mc.status = 'EXPIRED' THEN 1 ELSE 0 END) AS expired_count " +
                "FROM t_package_template pt " +
                "LEFT JOIN t_member_card mc ON pt.id = mc.template_id AND mc.tenant_id = pt.tenant_id ");

        List<Object> params = new ArrayList<>();
        params.add(tenantId);

        sql.append("WHERE pt.tenant_id = ? ");

        if (startDate != null && !startDate.isEmpty()) {
            sql.append("AND mc.created_at >= ? ");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append("AND mc.created_at <= ? ");
            params.add(endDate);
        }

        sql.append("GROUP BY pt.id, pt.name, pt.type, pt.sale_price ORDER BY total_revenue DESC");

        return jdbcTemplate.queryForList(sql.toString(), params.toArray());
    }

    /**
     * 会员分析报表
     */
    public Map<String, Object> getMemberReport(String startDate, String endDate) {
        Long tenantId = TenantContextHolder.getTenantId();

        // 会员总数
        Long totalMembers = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM t_member WHERE tenant_id = ?", Long.class, tenantId);

        // 新增会员数
        StringBuilder newMemberSql = new StringBuilder(
                "SELECT COUNT(*) FROM t_member WHERE tenant_id = ? ");
        List<Object> params = new ArrayList<>();
        params.add(tenantId);

        if (startDate != null && !startDate.isEmpty()) {
            newMemberSql.append("AND created_at >= ? ");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            newMemberSql.append("AND created_at <= ? ");
            params.add(endDate);
        }

        Long newMembers = jdbcTemplate.queryForObject(newMemberSql.toString(), Long.class, params.toArray());

        // 活跃会员数（有消费记录的会员）
        StringBuilder activeMemberSql = new StringBuilder(
                "SELECT COUNT(DISTINCT member_id) FROM t_consume_order WHERE tenant_id = ? AND status = 'COMPLETED' ");
        List<Object> activeParams = new ArrayList<>();
        activeParams.add(tenantId);

        if (startDate != null && !startDate.isEmpty()) {
            activeMemberSql.append("AND created_at >= ? ");
            activeParams.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            activeMemberSql.append("AND created_at <= ? ");
            activeParams.add(endDate);
        }

        Long activeMembers = jdbcTemplate.queryForObject(activeMemberSql.toString(), Long.class, activeParams.toArray());

        // 会员来源分布
        List<Map<String, Object>> sourceDistribution = jdbcTemplate.queryForList(
                "SELECT source_channel, COUNT(*) AS count FROM t_member WHERE tenant_id = ? AND source_channel IS NOT NULL GROUP BY source_channel ORDER BY count DESC",
                tenantId);

        Map<String, Object> report = new HashMap<>();
        report.put("totalMembers", totalMembers);
        report.put("newMembers", newMembers);
        report.put("activeMembers", activeMembers);
        report.put("activeRate", totalMembers > 0 ?
                String.format("%.2f", (double) activeMembers / totalMembers * 100) + "%" : "0%");
        report.put("sourceDistribution", sourceDistribution);
        return report;
    }

    /**
     * 收入趋势
     */
    public List<Map<String, Object>> getRevenueTrend(String startDate, String endDate, String granularity) {
        Long tenantId = TenantContextHolder.getTenantId();

        String dateFormat;
        switch (granularity) {
            case "month":
                dateFormat = "%Y-%m";
                break;
            case "week":
                dateFormat = "%Y-W%u";
                break;
            default:
                dateFormat = "%Y-%m-%d";
        }

        String sql = String.format(
                "SELECT DATE_FORMAT(created_at, '%s') AS period, " +
                "SUM(total_amount) AS revenue, " +
                "COUNT(*) AS order_count " +
                "FROM t_consume_order " +
                "WHERE tenant_id = ? AND status = 'COMPLETED' " +
                "AND created_at >= ? AND created_at <= ? " +
                "GROUP BY period ORDER BY period", dateFormat);

        return jdbcTemplate.queryForList(sql, tenantId, startDate, endDate);
    }

    /**
     * 服务项目排行
     */
    public List<Map<String, Object>> getServiceRanking(String startDate, String endDate, Integer top) {
        Long tenantId = TenantContextHolder.getTenantId();

        StringBuilder sql = new StringBuilder(
                "SELECT cd.service_item_id, cd.service_item_name, " +
                "COUNT(*) AS service_count, " +
                "SUM(CASE WHEN cd.deduct_type = 'VALUE' THEN cd.deduct_amount ELSE 0 END) AS total_amount, " +
                "COUNT(DISTINCT cd.order_id) AS order_count " +
                "FROM t_consume_detail cd " +
                "WHERE cd.tenant_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(tenantId);

        if (startDate != null && !startDate.isEmpty()) {
            sql.append("AND cd.created_at >= ? ");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append("AND cd.created_at <= ? ");
            params.add(endDate);
        }

        sql.append("GROUP BY cd.service_item_id, cd.service_item_name ");
        sql.append("ORDER BY service_count DESC LIMIT ?");

        params.add(top);

        return jdbcTemplate.queryForList(sql.toString(), params.toArray());
    }
}
