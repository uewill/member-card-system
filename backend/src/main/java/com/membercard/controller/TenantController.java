package com.membercard.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.dto.ApiResponse;
import com.membercard.entity.Tenant;
import com.membercard.service.TenantService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 租户管理控制器
 */
@RestController
@RequestMapping("/api/tenant")
@RequiredArgsConstructor
public class TenantController {

    private final TenantService tenantService;

    /**
     * 创建租户（平台管理员操作）
     */
    @PostMapping
    public ApiResponse<Tenant> create(@RequestBody Tenant tenant) {
        Tenant created = tenantService.create(tenant);
        return ApiResponse.success(created);
    }

    /**
     * 更新租户信息
     */
    @PutMapping("/{id}")
    public ApiResponse<Tenant> update(@PathVariable Long id, @RequestBody Tenant tenant) {
        tenant.setId(id);
        Tenant updated = tenantService.update(tenant);
        return ApiResponse.success(updated);
    }

    /**
     * 获取租户详情
     */
    @GetMapping("/{id}")
    public ApiResponse<Tenant> getById(@PathVariable Long id) {
        Tenant tenant = tenantService.getById(id);
        return ApiResponse.success(tenant);
    }

    /**
     * 分页查询租户列表（平台管理员）
     */
    @GetMapping("/page")
    public ApiResponse<Page<Tenant>> page(@RequestParam(defaultValue = "1") Integer current,
                                            @RequestParam(defaultValue = "10") Integer size,
                                            @RequestParam(required = false) String companyName,
                                            @RequestParam(required = false) Integer status) {
        Page<Tenant> page = tenantService.page(current, size, companyName, status);
        return ApiResponse.success(page);
    }

    /**
     * 审批租户（通过/拒绝）
     */
    @PutMapping("/{id}/approve")
    public ApiResponse<Void> approve(@PathVariable Long id, @RequestParam Integer status) {
        tenantService.approve(id, status);
        return ApiResponse.success();
    }

    /**
     * 更新租户配置
     */
    @PutMapping("/{id}/config")
    public ApiResponse<Tenant> updateConfig(@PathVariable Long id, @RequestBody Map<String, Object> config) {
        Tenant updated = tenantService.updateConfig(id, config);
        return ApiResponse.success(updated);
    }

    /**
     * 启用/停用租户
     */
    @PutMapping("/{id}/status")
    public ApiResponse<Void> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        tenantService.updateStatus(id, status);
        return ApiResponse.success();
    }
}
