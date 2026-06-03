package com.membercard.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.entity.PackageTemplate;
import com.membercard.interceptor.TenantContextHolder;
import com.membercard.mapper.PackageTemplateMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 套餐模板服务
 */
@Service
@RequiredArgsConstructor
public class PackageService {

    private final PackageTemplateMapper packageTemplateMapper;

    /**
     * 创建套餐模板
     */
    public PackageTemplate create(PackageTemplate packageTemplate) {
        Long tenantId = TenantContextHolder.getTenantId();
        packageTemplate.setTenantId(tenantId);
        packageTemplate.setStatus(1);
        packageTemplate.setCreatedAt(LocalDateTime.now());
        packageTemplate.setUpdatedAt(LocalDateTime.now());
        packageTemplateMapper.insert(packageTemplate);
        return packageTemplate;
    }

    /**
     * 更新套餐模板
     */
    public PackageTemplate update(PackageTemplate packageTemplate) {
        packageTemplate.setUpdatedAt(LocalDateTime.now());
        packageTemplateMapper.updateById(packageTemplate);
        return packageTemplateMapper.selectById(packageTemplate.getId());
    }

    /**
     * 根据ID获取套餐模板
     */
    public PackageTemplate getById(Long id) {
        return packageTemplateMapper.selectById(id);
    }

    /**
     * 分页查询套餐模板列表
     */
    public Page<PackageTemplate> page(Integer current, Integer size, String type, String name, Integer status) {
        Page<PackageTemplate> page = new Page<>(current, size);
        LambdaQueryWrapper<PackageTemplate> wrapper = new LambdaQueryWrapper<>();
        if (type != null && !type.isEmpty()) {
            wrapper.eq(PackageTemplate::getType, type);
        }
        if (name != null && !name.isEmpty()) {
            wrapper.like(PackageTemplate::getName, name);
        }
        if (status != null) {
            wrapper.eq(PackageTemplate::getStatus, status);
        }
        wrapper.orderByDesc(PackageTemplate::getCreatedAt);
        return packageTemplateMapper.selectPage(page, wrapper);
    }

    /**
     * 获取所有启用的套餐模板列表
     */
    public List<PackageTemplate> listActive(String type) {
        LambdaQueryWrapper<PackageTemplate> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(PackageTemplate::getStatus, 1);
        if (type != null && !type.isEmpty()) {
            wrapper.eq(PackageTemplate::getType, type);
        }
        wrapper.orderByDesc(PackageTemplate::getCreatedAt);
        return packageTemplateMapper.selectList(wrapper);
    }

    /**
     * 启用/停用套餐模板
     */
    public void updateStatus(Long id, Integer status) {
        PackageTemplate pkg = packageTemplateMapper.selectById(id);
        if (pkg == null) {
            throw new RuntimeException("套餐模板不存在");
        }
        pkg.setStatus(status);
        pkg.setUpdatedAt(LocalDateTime.now());
        packageTemplateMapper.updateById(pkg);
    }
}
