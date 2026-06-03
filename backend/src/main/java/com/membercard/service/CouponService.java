package com.membercard.service;

import com.membercard.interceptor.TenantContextHolder;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * 优惠券服务
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class CouponService {

    private final JdbcTemplate jdbcTemplate;

    /**
     * 创建优惠券
     */
    public void create(Map<String, Object> coupon) {
        Long tenantId = TenantContextHolder.getTenantId();
        String name = (String) coupon.get("name");
        String type = (String) coupon.get("type");
        String config = coupon.get("config").toString();
        String applicableItems = coupon.get("applicableItems") != null ?
                coupon.get("applicableItems").toString() : null;
        String validFrom = (String) coupon.get("validFrom");
        String validTo = (String) coupon.get("validTo");
        Integer totalCount = coupon.get("totalCount") != null ?
                Integer.valueOf(coupon.get("totalCount").toString()) : null;

        jdbcTemplate.update(
                "INSERT INTO t_coupon (tenant_id, name, type, config, applicable_items, valid_from, valid_to, total_count, status) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1)",
                tenantId, name, type, config, applicableItems, validFrom, validTo, totalCount);
    }

    /**
     * 更新优惠券
     */
    public void update(Long id, Map<String, Object> coupon) {
        StringBuilder sql = new StringBuilder("UPDATE t_coupon SET ");
        List<Object> params = new ArrayList<>();

        if (coupon.containsKey("name")) {
            sql.append("name = ?, ");
            params.add(coupon.get("name"));
        }
        if (coupon.containsKey("config")) {
            sql.append("config = ?, ");
            params.add(coupon.get("config").toString());
        }
        if (coupon.containsKey("applicableItems")) {
            sql.append("applicable_items = ?, ");
            params.add(coupon.get("applicableItems").toString());
        }
        if (coupon.containsKey("validFrom")) {
            sql.append("valid_from = ?, ");
            params.add(coupon.get("validFrom"));
        }
        if (coupon.containsKey("validTo")) {
            sql.append("valid_to = ?, ");
            params.add(coupon.get("validTo"));
        }
        if (coupon.containsKey("totalCount")) {
            sql.append("total_count = ?, ");
            params.add(Integer.valueOf(coupon.get("totalCount").toString()));
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
     * 获取优惠券详情
     */
    public Map<String, Object> getById(Long id) {
        return jdbcTemplate.queryForMap(
                "SELECT id, tenant_id, name, type, config, applicable_items, valid_from, valid_to, total_count, used_count, status, created_at FROM t_coupon WHERE id = ?",
                id);
    }

    /**
     * 分页查询优惠券列表
     */
    public Page<Map<String, Object>> page(Integer current, Integer size, String type, Integer status) {
        Long tenantId = TenantContextHolder.getTenantId();
        int offset = (current - 1) * size;

        StringBuilder countSql = new StringBuilder(
                "SELECT COUNT(*) FROM t_coupon WHERE tenant_id = ? ");
        StringBuilder querySql = new StringBuilder(
                "SELECT id, name, type, config, applicable_items, valid_from, valid_to, total_count, used_count, status, created_at " +
                "FROM t_coupon WHERE tenant_id = ? ");

        List<Object> params = new ArrayList<>();
        List<Object> queryParams = new ArrayList<>();

        params.add(tenantId);
        queryParams.add(tenantId);

        if (type != null && !type.isEmpty()) {
            countSql.append("AND type = ? ");
            querySql.append("AND type = ? ");
            params.add(type);
            queryParams.add(type);
        }
        if (status != null) {
            countSql.append("AND status = ? ");
            querySql.append("AND status = ? ");
            params.add(status);
            queryParams.add(status);
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
     * 发放优惠券给会员
     */
    @Transactional
    public void distribute(Long couponId, List<Long> memberIds) {
        Long tenantId = TenantContextHolder.getTenantId();

        // 验证优惠券
        Map<String, Object> coupon = getById(couponId);
        if (coupon == null) {
            throw new RuntimeException("优惠券不存在");
        }

        // 检查库存
        Integer totalCount = coupon.get("total_count") != null ?
                Integer.valueOf(coupon.get("total_count").toString()) : null;
        Integer usedCount = Integer.valueOf(coupon.get("used_count").toString());

        if (totalCount != null && usedCount + memberIds.size() > totalCount) {
            throw new RuntimeException("优惠券库存不足");
        }

        // 批量发放
        for (Long memberId : memberIds) {
            jdbcTemplate.update(
                    "INSERT INTO t_member_coupon (tenant_id, member_id, coupon_id, status, created_at) VALUES (?, ?, ?, 'UNUSED', NOW())",
                    tenantId, memberId, couponId);
        }

        // 更新已使用数量
        jdbcTemplate.update(
                "UPDATE t_coupon SET used_count = used_count + ? WHERE id = ?",
                memberIds.size(), couponId);

        log.info("发放优惠券: couponId={}, memberCount={}", couponId, memberIds.size());
    }

    /**
     * 查询会员的优惠券列表
     */
    public List<Map<String, Object>> getMemberCoupons(Long memberId) {
        Long tenantId = TenantContextHolder.getTenantId();

        return jdbcTemplate.queryForList(
                "SELECT mc.id, mc.coupon_id, c.name, c.type, c.config, " +
                "c.valid_from, c.valid_to, mc.status, mc.created_at " +
                "FROM t_member_coupon mc " +
                "INNER JOIN t_coupon c ON mc.coupon_id = c.id AND mc.tenant_id = c.tenant_id " +
                "WHERE mc.tenant_id = ? AND mc.member_id = ? " +
                "ORDER BY mc.created_at DESC",
                tenantId, memberId);
    }

    /**
     * 启用/停用优惠券
     */
    public void updateStatus(Long id, Integer status) {
        jdbcTemplate.update("UPDATE t_coupon SET status = ? WHERE id = ?", status, id);
    }
}
