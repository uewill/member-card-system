package com.membercard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.entity.Tenant;
import com.membercard.entity.User;
import com.membercard.interceptor.TenantContextHolder;
import com.membercard.mapper.TenantMapper;
import com.membercard.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.*;

/**
 * 租户服务
 */
@Service
@RequiredArgsConstructor
public class TenantService {

    private final TenantMapper tenantMapper;
    private final UserMapper userMapper;

    /**
     * 创建租户（同时创建租户管理员账号）
     */
    @Transactional
    public Tenant create(Tenant tenant) {
        tenant.setStatus(1);
        tenant.setCreatedAt(LocalDateTime.now());
        tenant.setUpdatedAt(LocalDateTime.now());
        tenantMapper.insert(tenant);

        // 创建租户管理员账号
        User admin = new User();
        admin.setTenantId(tenant.getId());
        admin.setPhone(tenant.getAdminPhone());
        admin.setName(tenant.getAdminName());
        admin.setPassword(new BCryptPasswordEncoder().encode("123456"));
        admin.setRole("TENANT_ADMIN");
        admin.setStatus(1);
        admin.setCreatedAt(LocalDateTime.now());
        admin.setUpdatedAt(LocalDateTime.now());
        userMapper.insert(admin);

        return tenant;
    }

    /**
     * 更新租户信息
     */
    public Tenant update(Tenant tenant) {
        tenant.setUpdatedAt(LocalDateTime.now());
        tenantMapper.updateById(tenant);
        return tenantMapper.selectById(tenant.getId());
    }

    /**
     * 根据ID获取租户
     */
    public Tenant getById(Long id) {
        return tenantMapper.selectById(id);
    }

    /**
     * 分页查询租户列表
     */
    public Page<Tenant> page(Integer current, Integer size, String companyName, Integer status) {
        Page<Tenant> page = new Page<>(current, size);
        LambdaQueryWrapper<Tenant> wrapper = new LambdaQueryWrapper<>();
        if (companyName != null && !companyName.isEmpty()) {
            wrapper.like(Tenant::getCompanyName, companyName);
        }
        if (status != null) {
            wrapper.eq(Tenant::getStatus, status);
        }
        wrapper.orderByDesc(Tenant::getCreatedAt);
        return tenantMapper.selectPage(page, wrapper);
    }

    /**
     * 审批租户
     */
    public void approve(Long id, Integer status) {
        Tenant tenant = tenantMapper.selectById(id);
        if (tenant == null) {
            throw new RuntimeException("租户不存在");
        }
        tenant.setStatus(status);
        tenant.setUpdatedAt(LocalDateTime.now());
        tenantMapper.updateById(tenant);
    }

    /**
     * 更新租户配置
     */
    public Tenant updateConfig(Long id, Map<String, Object> config) {
        Tenant tenant = tenantMapper.selectById(id);
        if (tenant == null) {
            throw new RuntimeException("租户不存在");
        }
        // 配置字段可扩展，当前简化处理
        if (config.containsKey("industry")) {
            tenant.setIndustry((String) config.get("industry"));
        }
        if (config.containsKey("adminName")) {
            tenant.setAdminName((String) config.get("adminName"));
        }
        tenant.setUpdatedAt(LocalDateTime.now());
        tenantMapper.updateById(tenant);
        return tenantMapper.selectById(id);
    }

    /**
     * 更新租户状态（启用/停用）
     */
    public void updateStatus(Long id, Integer status) {
        Tenant tenant = tenantMapper.selectById(id);
        if (tenant == null) {
            throw new RuntimeException("租户不存在");
        }
        tenant.setStatus(status);
        tenant.setUpdatedAt(LocalDateTime.now());
        tenantMapper.updateById(tenant);
    }

    /**
     * 获取平台总览数据
     */
    public Map<String, Object> getPlatformOverview() {
        Map<String, Object> overview = new HashMap<>();
        long totalTenants = tenantMapper.selectCount(null);
        long activeTenants = tenantMapper.selectCount(
                new LambdaQueryWrapper<Tenant>().eq(Tenant::getStatus, 1));
        overview.put("totalTenants", totalTenants);
        overview.put("activeTenants", activeTenants);
        overview.put("inactiveTenants", totalTenants - activeTenants);
        return overview;
    }

    /**
     * 获取租户统计排行
     */
    public List<Map<String, Object>> getTenantRanking(Integer top) {
        // 简化实现：返回所有活跃租户
        List<Tenant> tenants = tenantMapper.selectList(
                new LambdaQueryWrapper<Tenant>()
                        .eq(Tenant::getStatus, 1)
                        .orderByDesc(Tenant::getCreatedAt)
                        .last("LIMIT " + top));
        List<Map<String, Object>> ranking = new ArrayList<>();
        for (Tenant t : tenants) {
            Map<String, Object> item = new HashMap<>();
            item.put("id", t.getId());
            item.put("companyName", t.getCompanyName());
            item.put("industry", t.getIndustry());
            item.put("createdAt", t.getCreatedAt());
            ranking.add(item);
        }
        return ranking;
    }

    /**
     * 获取行业分布统计
     */
    public List<Map<String, Object>> getIndustryDistribution() {
        List<Tenant> tenants = tenantMapper.selectList(null);
        Map<String, Long> distribution = new HashMap<>();
        for (Tenant t : tenants) {
            String industry = t.getIndustry() != null ? t.getIndustry() : "未分类";
            distribution.put(industry, distribution.getOrDefault(industry, 0L) + 1);
        }
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map.Entry<String, Long> entry : distribution.entrySet()) {
            Map<String, Object> item = new HashMap<>();
            item.put("industry", entry.getKey());
            item.put("count", entry.getValue());
            result.add(item);
        }
        return result;
    }
}
