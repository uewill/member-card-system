package com.membercard.service;

import com.membercard.common.BusinessException;
import com.membercard.common.TenantContext;
import com.membercard.entity.PackageTemplate;
import com.membercard.mapper.PackageTemplateMapper;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 套餐服务
 */
@Service
public class PackageService {

    private final PackageTemplateMapper packageTemplateMapper;

    public PackageService(PackageTemplateMapper packageTemplateMapper) {
        this.packageTemplateMapper = packageTemplateMapper;
    }

    public PackageTemplate findById(Long id) {
        Long tenantId = TenantContext.getTenantId();
        PackageTemplate pkg = packageTemplateMapper.findById(id, tenantId);
        if (pkg == null) {
            throw new BusinessException(404, "套餐不存在");
        }
        return pkg;
    }

    public List<PackageTemplate> findAll() {
        Long tenantId = TenantContext.getTenantId();
        return packageTemplateMapper.findByTenantId(tenantId);
    }

    public List<PackageTemplate> findEnabled() {
        Long tenantId = TenantContext.getTenantId();
        return packageTemplateMapper.findByTenantIdAndStatus(tenantId, "enabled");
    }

    public List<PackageTemplate> findByType(String type) {
        Long tenantId = TenantContext.getTenantId();
        return packageTemplateMapper.findByTenantIdAndType(tenantId, type);
    }

    public PackageTemplate create(PackageTemplate packageTemplate) {
        Long tenantId = TenantContext.getTenantId();
        packageTemplate.setTenantId(tenantId);
        packageTemplate.setStatus("enabled");
        packageTemplateMapper.insert(packageTemplate);
        return packageTemplate;
    }

    public PackageTemplate update(PackageTemplate packageTemplate) {
        Long tenantId = TenantContext.getTenantId();
        PackageTemplate existing = findById(packageTemplate.getId());
        existing.setName(packageTemplate.getName());
        existing.setType(packageTemplate.getType());
        existing.setServiceItemsJson(packageTemplate.getServiceItemsJson());
        existing.setServiceCountsJson(packageTemplate.getServiceCountsJson());
        existing.setPrincipalAmount(packageTemplate.getPrincipalAmount());
        existing.setBonusAmount(packageTemplate.getBonusAmount());
        existing.setSellingPrice(packageTemplate.getSellingPrice());
        existing.setValidityType(packageTemplate.getValidityType());
        existing.setValidityDays(packageTemplate.getValidityDays());
        existing.setExpiryDate(packageTemplate.getExpiryDate());
        existing.setAllowTransfer(packageTemplate.getAllowTransfer());
        existing.setAllowDiscountCombo(packageTemplate.getAllowDiscountCombo());
        existing.setStatus(packageTemplate.getStatus());
        packageTemplateMapper.update(existing);
        return existing;
    }

    public void delete(Long id) {
        Long tenantId = TenantContext.getTenantId();
        packageTemplateMapper.deleteById(id, tenantId);
    }
}
