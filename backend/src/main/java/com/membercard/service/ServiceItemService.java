package com.membercard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.entity.ServiceItem;
import com.membercard.interceptor.TenantContextHolder;
import com.membercard.mapper.ServiceItemMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 服务项目服务
 */
@Service
@RequiredArgsConstructor
public class ServiceItemService {

    private final ServiceItemMapper serviceItemMapper;

    /**
     * 创建服务项目
     */
    public ServiceItem create(ServiceItem serviceItem) {
        Long tenantId = TenantContextHolder.getTenantId();
        serviceItem.setTenantId(tenantId);
        serviceItem.setStatus(1);
        serviceItem.setCreatedAt(LocalDateTime.now());
        serviceItem.setUpdatedAt(LocalDateTime.now());
        serviceItemMapper.insert(serviceItem);
        return serviceItem;
    }

    /**
     * 更新服务项目
     */
    public ServiceItem update(ServiceItem serviceItem) {
        serviceItem.setUpdatedAt(LocalDateTime.now());
        serviceItemMapper.updateById(serviceItem);
        return serviceItemMapper.selectById(serviceItem.getId());
    }

    /**
     * 根据ID获取服务项目
     */
    public ServiceItem getById(Long id) {
        return serviceItemMapper.selectById(id);
    }

    /**
     * 分页查询服务项目列表
     */
    public Page<ServiceItem> page(Integer current, Integer size, String category, String name, Integer status) {
        Page<ServiceItem> page = new Page<>(current, size);
        LambdaQueryWrapper<ServiceItem> wrapper = new LambdaQueryWrapper<>();
        if (category != null && !category.isEmpty()) {
            wrapper.eq(ServiceItem::getCategory, category);
        }
        if (name != null && !name.isEmpty()) {
            wrapper.like(ServiceItem::getName, name);
        }
        if (status != null) {
            wrapper.eq(ServiceItem::getStatus, status);
        }
        wrapper.orderByDesc(ServiceItem::getCreatedAt);
        return serviceItemMapper.selectPage(page, wrapper);
    }

    /**
     * 获取所有启用的服务项目列表
     */
    public List<ServiceItem> listActive(String category) {
        LambdaQueryWrapper<ServiceItem> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ServiceItem::getStatus, 1);
        if (category != null && !category.isEmpty()) {
            wrapper.eq(ServiceItem::getCategory, category);
        }
        wrapper.orderByAsc(ServiceItem::getCategory).orderByAsc(ServiceItem::getName);
        return serviceItemMapper.selectList(wrapper);
    }

    /**
     * 启用/停用服务项目
     */
    public void updateStatus(Long id, Integer status) {
        ServiceItem item = serviceItemMapper.selectById(id);
        if (item == null) {
            throw new RuntimeException("服务项目不存在");
        }
        item.setStatus(status);
        item.setUpdatedAt(LocalDateTime.now());
        serviceItemMapper.updateById(item);
    }
}
