package com.membercard.service;

import com.membercard.interceptor.TenantContextHolder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * 积分服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PointsService {

    private final JdbcTemplate jdbcTemplate;

    /**
     * 获取会员积分余额
     */
    public Map<String, Object> getBalance(Long memberId) {
        Long tenantId = TenantContextHolder.getTenantId();

        // 获取最新积分余额
        Integer balance = jdbcTemplate.queryForObject(
                "SELECT balance_after FROM t_points_record WHERE tenant_id = ? AND member_id = ? ORDER BY created_at DESC LIMIT 1",
                Integer.class, tenantId, memberId);

        if (balance == null) {
            balance = 0;
        }

        // 获取累计积分
        Integer totalEarned = jdbcTemplate.queryForObject(
                "SELECT COALESCE(SUM(points), 0) FROM t_points_record WHERE tenant_id = ? AND member_id = ? AND points > 0",
                Integer.class, tenantId, memberId);

        Integer totalSpent = jdbcTemplate.queryForObject(
                "SELECT COALESCE(SUM(ABS(points)), 0) FROM t_points_record WHERE tenant_id = ? AND member_id = ? AND points < 0",
                Integer.class, tenantId, memberId);

        Map<String, Object> result = new HashMap<>();
        result.put("memberId", memberId);
        result.put("balance", balance);
        result.put("totalEarned", totalEarned);
        result.put("totalSpent", totalSpent);
        return result;
    }

    /**
     * 获取积分变动记录
     */
    public Page<Map<String, Object>> getRecords(Long memberId, Integer current, Integer size, String source) {
        Long tenantId = TenantContextHolder.getTenantId();

        int offset = (current - 1) * size;

        StringBuilder countSql = new StringBuilder(
                "SELECT COUNT(*) FROM t_points_record WHERE tenant_id = ? AND member_id = ? ");
        StringBuilder querySql = new StringBuilder(
                "SELECT id, member_id, points, balance_after, source, related_order_id, created_at " +
                "FROM t_points_record WHERE tenant_id = ? AND member_id = ? ");

        List<Object> params = new ArrayList<>();
        List<Object> queryParams = new ArrayList<>();

        params.add(tenantId);
        params.add(memberId);
        queryParams.add(tenantId);
        queryParams.add(memberId);

        if (source != null && !source.isEmpty()) {
            countSql.append("AND source = ? ");
            querySql.append("AND source = ? ");
            params.add(source);
            queryParams.add(source);
        }

        Long total = jdbcTemplate.queryForObject(countSql.toString(), Long.class, params.toArray());

        querySql.append("ORDER BY created_at DESC LIMIT ? OFFSET ?");
        queryParams.add(size);
        queryParams.add(offset);

        List<Map<String, Object>> records = jdbcTemplate.queryForList(querySql.toString(), queryParams.toArray());

        Page<Map<String, Object>> page = new Page<>(current, size);
        page.setTotal(total);
        page.setRecords(records);
        return page;
    }

    /**
     * 增加积分
     */
    @Transactional
    public void addPoints(Long memberId, Integer points, String source, String remark) {
        Long tenantId = TenantContextHolder.getTenantId();

        // 获取当前余额
        Integer currentBalance = getBalance(memberId);
        int newBalance = currentBalance + points;

        jdbcTemplate.update(
                "INSERT INTO t_points_record (tenant_id, member_id, points, balance_after, source, created_at) VALUES (?, ?, ?, ?, ?, NOW())",
                tenantId, memberId, points, newBalance, source);

        log.info("增加积分: memberId={}, points={}, newBalance={}, source={}", memberId, points, newBalance, source);
    }

    /**
     * 扣减积分
     */
    @Transactional
    public void deductPoints(Long memberId, Integer points, String remark) {
        Long tenantId = TenantContextHolder.getTenantId();

        // 获取当前余额
        Integer currentBalance = getBalance(memberId);
        if (currentBalance < points) {
            throw new RuntimeException("积分余额不足，当前余额: " + currentBalance);
        }

        int newBalance = currentBalance - points;

        jdbcTemplate.update(
                "INSERT INTO t_points_record (tenant_id, member_id, points, balance_after, source, created_at) VALUES (?, ?, ?, ?, ?, NOW())",
                tenantId, memberId, -points, newBalance, "EXCHANGE");

        log.info("扣减积分: memberId={}, points={}, newBalance={}", memberId, points, newBalance);
    }

    /**
     * 积分排行榜
     */
    public List<Map<String, Object>> getRanking(Integer top) {
        Long tenantId = TenantContextHolder.getTenantId();

        return jdbcTemplate.queryForList(
                "SELECT pr.member_id, m.name, m.phone, pr.balance_after AS points " +
                "FROM t_points_record pr " +
                "INNER JOIN t_member m ON pr.member_id = m.id AND pr.tenant_id = m.tenant_id " +
                "WHERE pr.tenant_id = ? " +
                "AND pr.created_at = (" +
                "  SELECT MAX(created_at) FROM t_points_record pr2 " +
                "  WHERE pr2.tenant_id = pr.tenant_id AND pr2.member_id = pr.member_id" +
                ") " +
                "ORDER BY pr.balance_after DESC LIMIT ?",
                tenantId, top);
    }
}
