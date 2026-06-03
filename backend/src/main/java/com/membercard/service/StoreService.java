package com.membercard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.entity.Store;
import com.membercard.interceptor.TenantContextHolder;
import com.membercard.mapper.StoreMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 门店服务
 */
@Service
@RequiredArgsConstructor
public class StoreService {

    private final StoreMapper storeMapper;

    /**
     * 创建门店
     */
    public Store create(Store store) {
        Long tenantId = TenantContextHolder.getTenantId();
        store.setTenantId(tenantId);
        store.setStatus(1);
        store.setCreatedAt(LocalDateTime.now());
        store.setUpdatedAt(LocalDateTime.now());
        storeMapper.insert(store);
        return store;
    }

    /**
     * 更新门店
     */
    public Store update(Store store) {
        store.setUpdatedAt(LocalDateTime.now());
        storeMapper.updateById(store);
        return storeMapper.selectById(store.getId());
    }

    /**
     * 根据ID获取门店
     */
    public Store getById(Long id) {
        return storeMapper.selectById(id);
    }

    /**
     * 分页查询门店列表
     */
    public Page<Store> page(Integer current, Integer size, String storeName, Integer status) {
        Page<Store> page = new Page<>(current, size);
        LambdaQueryWrapper<Store> wrapper = new LambdaQueryWrapper<>();
        if (storeName != null && !storeName.isEmpty()) {
            wrapper.like(Store::getStoreName, storeName);
        }
        if (status != null) {
            wrapper.eq(Store::getStatus, status);
        }
        wrapper.orderByDesc(Store::getCreatedAt);
        return storeMapper.selectPage(page, wrapper);
    }

    /**
     * 获取所有启用的门店列表
     */
    public List<Store> listActive() {
        return storeMapper.selectList(
                new LambdaQueryWrapper<Store>()
                        .eq(Store::getStatus, 1)
                        .orderByAsc(Store::getStoreName));
    }

    /**
     * 启用/停用门店
     */
    public void updateStatus(Long id, Integer status) {
        Store store = storeMapper.selectById(id);
        if (store == null) {
            throw new RuntimeException("门店不存在");
        }
        store.setStatus(status);
        store.setUpdatedAt(LocalDateTime.now());
        storeMapper.updateById(store);
    }
}
