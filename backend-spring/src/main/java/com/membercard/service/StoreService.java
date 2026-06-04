package com.membercard.service;

import com.membercard.common.BusinessException;
import com.membercard.common.TenantContext;
import com.membercard.entity.Store;
import com.membercard.mapper.StoreMapper;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * 门店服务
 */
@Service
public class StoreService {

    private final StoreMapper storeMapper;

    public StoreService(StoreMapper storeMapper) {
        this.storeMapper = storeMapper;
    }

    public Store findById(Long id) {
        Long tenantId = TenantContext.getTenantId();
        Store store = storeMapper.findById(id, tenantId);
        if (store == null) {
            throw new BusinessException(404, "门店不存在");
        }
        return store;
    }

    public List<Store> findAll() {
        Long tenantId = TenantContext.getTenantId();
        return storeMapper.findByTenantId(tenantId);
    }

    public List<Store> findEnabled() {
        Long tenantId = TenantContext.getTenantId();
        return storeMapper.findByTenantIdAndStatus(tenantId, "enabled");
    }

    public Store create(Store store) {
        Long tenantId = TenantContext.getTenantId();
        store.setTenantId(tenantId);
        store.setStatus("enabled");
        storeMapper.insert(store);
        return store;
    }

    public Store update(Store store) {
        Long tenantId = TenantContext.getTenantId();
        Store existing = findById(store.getId());
        existing.setName(store.getName());
        existing.setAddress(store.getAddress());
        existing.setPhone(store.getPhone());
        existing.setBusinessHours(store.getBusinessHours());
        existing.setStatus(store.getStatus());
        existing.setAllowedCardUsage(store.getAllowedCardUsage());
        storeMapper.update(existing);
        return existing;
    }

    public void delete(Long id) {
        Long tenantId = TenantContext.getTenantId();
        storeMapper.deleteById(id, tenantId);
    }
}
