package com.membercard.service;

import com.membercard.interceptor.TenantContextHolder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.*;

/**
 * 业绩统计服务 - 业绩统计、提成计算
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PerformanceService {

    private final JdbcTemplate jdbcTemplate;

    /**
     * 员工业绩查询
     */
    public List<Map<String, Object>> getStaffPerformance(Long staffId, String startDate, String endDate) {
        Long tenantId = TenantContextHolder.getTenantId();
        StringBuilder sql = new StringBuilder(
                "SELECT cd.service_staff_id, cd.service_staff_name, " +
                "COUNT(*) AS total_services, " +
                "SUM(CASE WHEN cd.deduct_type = 'VALUE' THEN cd.deduct_amount ELSE 0 END) AS total_amount, " +
                "SUM(si.price * cd.performance_ratio) AS total_performance " +
                "FROM t_consume_detail cd " +
                "LEFT JOIN t_service_item si ON cd.service_item_id = si.id " +
                "WHERE cd.tenant_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(tenantId);

        if (staffId != null) {
            sql.append("AND cd.service_staff_id = ? ");
            params.add(staffId);
        }
        if (startDate != null && !startDate.isEmpty()) {
            sql.append("AND cd.created_at >= ? ");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append("AND cd.created_at <= ? ");
            params.add(endDate);
        }

        sql.append("GROUP BY cd.service_staff_id, cd.service_staff_name ORDER BY total_performance DESC");

        return jdbcTemplate.queryForList(sql.toString(), params.toArray());
    }

    /**
     * 门店业绩查询
     */
    public List<Map<String, Object>> getStorePerformance(Long storeId, String startDate, String endDate) {
        Long tenantId = TenantContextHolder.getTenantId();
        StringBuilder sql = new StringBuilder(
                "SELECT co.store_id, " +
                "COUNT(DISTINCT co.id) AS total_orders, " +
                "SUM(co.total_amount) AS total_amount, " +
                "SUM(co.paid_amount) AS paid_amount, " +
                "COUNT(DISTINCT co.member_id) AS total_members " +
                "FROM t_consume_order co " +
                "WHERE co.tenant_id = ? AND co.status = 'COMPLETED' ");

        List<Object> params = new ArrayList<>();
        params.add(tenantId);

        if (storeId != null) {
            sql.append("AND co.store_id = ? ");
            params.add(storeId);
        }
        if (startDate != null && !startDate.isEmpty()) {
            sql.append("AND co.created_at >= ? ");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append("AND co.created_at <= ? ");
            params.add(endDate);
        }

        sql.append("GROUP BY co.store_id ORDER BY total_amount DESC");

        return jdbcTemplate.queryForList(sql.toString(), params.toArray());
    }

    /**
     * 员工提成计算
     */
    public List<Map<String, Object>> calculateCommission(Long staffId, String startDate, String endDate) {
        Long tenantId = TenantContextHolder.getTenantId();

        // 查询该员工的所有消费明细
        StringBuilder sql = new StringBuilder(
                "SELECT cd.id, cd.order_id, cd.service_item_name, " +
                "cd.deduct_type, cd.deduct_amount, cd.performance_ratio, " +
                "si.price AS service_price, " +
                "cd.deduct_amount * cd.performance_ratio AS commission_amount, " +
                "cd.created_at " +
                "FROM t_consume_detail cd " +
                "LEFT JOIN t_service_item si ON cd.service_item_id = si.id " +
                "WHERE cd.tenant_id = ? AND cd.service_staff_id = ? ");

        List<Object> params = new ArrayList<>();
        params.add(tenantId);
        params.add(staffId);

        if (startDate != null && !startDate.isEmpty()) {
            sql.append("AND cd.created_at >= ? ");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append("AND cd.created_at <= ? ");
            params.add(endDate);
        }

        sql.append("ORDER BY cd.created_at DESC");

        List<Map<String, Object>> details = jdbcTemplate.queryForList(sql.toString(), params.toArray());

        // 计算总提成
        BigDecimal totalCommission = BigDecimal.ZERO;
        for (Map<String, Object> detail : details) {
            Object commissionObj = detail.get("commission_amount");
            if (commissionObj != null) {
                totalCommission = totalCommission.add(new BigDecimal(commissionObj.toString()));
            }
        }

        // 添加汇总信息
        Map<String, Object> summary = new HashMap<>();
        summary.put("staffId", staffId);
        summary.put("totalCommission", totalCommission);
        summary.put("detailCount", details.size());
        details.add(0, summary);

        return details;
    }

    /**
     * 业绩排行榜
     */
    public List<Map<String, Object>> getPerformanceRanking(Long storeId, String startDate, String endDate, Integer top) {
        Long tenantId = TenantContextHolder.getTenantId();
        StringBuilder sql = new StringBuilder(
                "SELECT cd.service_staff_id, cd.service_staff_name, " +
                "COUNT(*) AS service_count, " +
                "SUM(CASE WHEN cd.deduct_type = 'VALUE' THEN cd.deduct_amount ELSE 0 END) AS total_deduct_amount, " +
                "SUM(si.price * cd.performance_ratio) AS total_performance " +
                "FROM t_consume_detail cd " +
                "LEFT JOIN t_service_item si ON cd.service_item_id = si.id " +
                "LEFT JOIN t_consume_order co ON cd.order_id = co.id " +
                "WHERE cd.tenant_id = ? AND cd.service_staff_id IS NOT NULL ");

        List<Object> params = new ArrayList<>();
        params.add(tenantId);

        if (storeId != null) {
            sql.append("AND co.store_id = ? ");
            params.add(storeId);
        }
        if (startDate != null && !startDate.isEmpty()) {
            sql.append("AND cd.created_at >= ? ");
            params.add(startDate);
        }
        if (endDate != null && !endDate.isEmpty()) {
            sql.append("AND cd.created_at <= ? ");
            params.add(endDate);
        }

        sql.append("GROUP BY cd.service_staff_id, cd.service_staff_name ");
        sql.append("ORDER BY total_performance DESC LIMIT ?");

        params.add(top);

        return jdbcTemplate.queryForList(sql.toString(), params.toArray());
    }
}
