package com.membercard.service;

import com.membercard.common.BusinessException;
import com.membercard.entity.Tenant;
import com.membercard.mapper.TenantMapper;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 租户服务
 */
@Service
public class TenantService {

    private final TenantMapper tenantMapper;

    public TenantService(TenantMapper tenantMapper) {
        this.tenantMapper = tenantMapper;
    }

    public Tenant findById(Long id) {
        Tenant tenant = tenantMapper.findById(id);
        if (tenant == null) {
            throw new BusinessException(404, "租户不存在");
        }
        return tenant;
    }

    public List<Tenant> findAll() {
        return tenantMapper.findAll();
    }

    public List<Tenant> findByStatus(String status) {
        return tenantMapper.findByStatus(status);
    }

    public Tenant create(Tenant tenant) {
        tenant.setStatus("pending");
        tenantMapper.insert(tenant);
        return tenant;
    }

    public Tenant update(Tenant tenant) {
        Tenant existing = findById(tenant.getId());
        existing.setCompanyName(tenant.getCompanyName());
        existing.setIndustryTag(tenant.getIndustryTag());
        existing.setAdminContact(tenant.getAdminContact());
        existing.setAdminPhone(tenant.getAdminPhone());
        existing.setStatus(tenant.getStatus());
        existing.setPaymentMethods(tenant.getPaymentMethods());
        existing.setPointsEnabled(tenant.getPointsEnabled());
        existing.setVersionLimit(tenant.getVersionLimit());
        tenantMapper.update(existing);
        return existing;
    }

    public void approve(Long id) {
        Tenant tenant = findById(id);
        tenant.setStatus("approved");
        tenantMapper.update(tenant);
    }

    public void reject(Long id) {
        Tenant tenant = findById(id);
        tenant.setStatus("rejected");
        tenantMapper.update(tenant);
    }

    public void disable(Long id) {
        Tenant tenant = findById(id);
        tenant.setStatus("disabled");
        tenantMapper.update(tenant);
    }
}
