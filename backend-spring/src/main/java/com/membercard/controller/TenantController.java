package com.membercard.controller;

import com.membercard.common.ApiResponse;
import com.membercard.entity.Tenant;
import com.membercard.service.TenantService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 租户管理控制器（平台管理接口）
 */
@RestController
@RequestMapping("/api/v1/platform/tenants")
@Tag(name = "平台-租户管理", description = "平台管理员管理租户接口")
public class TenantController {

    private final TenantService tenantService;

    public TenantController(TenantService tenantService) {
        this.tenantService = tenantService;
    }

    @GetMapping
    @Operation(summary = "获取所有租户列表")
    public ApiResponse<List<Tenant>> findAll() {
        return ApiResponse.success(tenantService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取租户详情")
    public ApiResponse<Tenant> findById(@PathVariable Long id) {
        return ApiResponse.success(tenantService.findById(id));
    }

    @PostMapping
    @Operation(summary = "创建租户")
    public ApiResponse<Tenant> create(@RequestBody Tenant tenant) {
        return ApiResponse.success(tenantService.create(tenant));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新租户信息")
    public ApiResponse<Tenant> update(@PathVariable Long id, @RequestBody Tenant tenant) {
        tenant.setId(id);
        return ApiResponse.success(tenantService.update(tenant));
    }

    @PostMapping("/{id}/approve")
    @Operation(summary = "审批通过租户")
    public ApiResponse<Void> approve(@PathVariable Long id) {
        tenantService.approve(id);
        return ApiResponse.success();
    }

    @PostMapping("/{id}/reject")
    @Operation(summary = "拒绝租户申请")
    public ApiResponse<Void> reject(@PathVariable Long id) {
        tenantService.reject(id);
        return ApiResponse.success();
    }

    @PostMapping("/{id}/disable")
    @Operation(summary = "禁用租户")
    public ApiResponse<Void> disable(@PathVariable Long id) {
        tenantService.disable(id);
        return ApiResponse.success();
    }
}
