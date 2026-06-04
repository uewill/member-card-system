package com.membercard.service;

import com.membercard.common.BusinessException;
import com.membercard.common.TenantContext;
import com.membercard.entity.ServiceItem;
import com.membercard.mapper.ServiceItemMapper;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 服务项目服务
 */
@Service
public class ServiceItemService {

    private final ServiceItemMapper serviceItemMapper;

    public ServiceItemService(ServiceItemMapper serviceItemMapper) {
        this.serviceItemMapper = serviceItemMapper;
    }

    public ServiceItem findById(Long id) {
        Long tenantId = TenantContext.getTenantId();
        ServiceItem item = serviceItemMapper.findById(id, tenantId);
        if (item == null) {
            throw new BusinessException(404, "服务项目不存在");
        }
        return item;
    }

    public List<ServiceItem> findAll() {
        Long tenantId = TenantContext.getTenantId();
        return serviceItemMapper.findByTenantId(tenantId);
    }

    public List<ServiceItem> findEnabled() {
        Long tenantId = TenantContext.getTenantId();
        return serviceItemMapper.findByTenantIdAndStatus(tenantId, "enabled");
    }

    public List<ServiceItem> findByCategory(String category) {
        Long tenantId = TenantContext.getTenantId();
        return serviceItemMapper.findByTenantIdAndCategory(tenantId, category);
    }

    public ServiceItem create(ServiceItem serviceItem) {
        Long tenantId = TenantContext.getTenantId();
        serviceItem.setTenantId(tenantId);
        serviceItem.setStatus("enabled");
        serviceItemMapper.insert(serviceItem);
        return serviceItem;
    }

    public ServiceItem update(ServiceItem serviceItem) {
        Long tenantId = TenantContext.getTenantId();
        ServiceItem existing = findById(serviceItem.getId());
        existing.setName(serviceItem.getName());
        existing.setCategory(serviceItem.getCategory());
        existing.setPrice(serviceItem.getPrice());
        existing.setDuration(serviceItem.getDuration());
        existing.setPurchasableAlone(serviceItem.getPurchasableAlone());
        existing.setStatus(serviceItem.getStatus());
        serviceItemMapper.update(existing);
        return existing;
    }

    public void delete(Long id) {
        Long tenantId = TenantContext.getTenantId();
        serviceItemMapper.deleteById(id, tenantId);
    }
}
