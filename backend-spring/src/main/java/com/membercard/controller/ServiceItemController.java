package com.membercard.controller;

import com.membercard.common.ApiResponse;
import com.membercard.entity.ServiceItem;
import com.membercard.service.ServiceItemService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 服务项目管理控制器
 */
@RestController
@RequestMapping("/api/v1/service-items")
@Tag(name = "服务项目管理", description = "服务项目增删改查接口")
public class ServiceItemController {

    private final ServiceItemService serviceItemService;

    public ServiceItemController(ServiceItemService serviceItemService) {
        this.serviceItemService = serviceItemService;
    }

    @GetMapping
    @Operation(summary = "获取所有服务项目")
    public ApiResponse<List<ServiceItem>> findAll() {
        return ApiResponse.success(serviceItemService.findAll());
    }

    @GetMapping("/enabled")
    @Operation(summary = "获取启用的服务项目")
    public ApiResponse<List<ServiceItem>> findEnabled() {
        return ApiResponse.success(serviceItemService.findEnabled());
    }

    @GetMapping("/category/{category}")
    @Operation(summary = "按分类获取服务项目")
    public ApiResponse<List<ServiceItem>> findByCategory(@PathVariable String category) {
        return ApiResponse.success(serviceItemService.findByCategory(category));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取服务项目详情")
    public ApiResponse<ServiceItem> findById(@PathVariable Long id) {
        return ApiResponse.success(serviceItemService.findById(id));
    }

    @PostMapping
    @Operation(summary = "创建服务项目")
    public ApiResponse<ServiceItem> create(@RequestBody ServiceItem serviceItem) {
        return ApiResponse.success(serviceItemService.create(serviceItem));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新服务项目")
    public ApiResponse<ServiceItem> update(@PathVariable Long id, @RequestBody ServiceItem serviceItem) {
        serviceItem.setId(id);
        return ApiResponse.success(serviceItemService.update(serviceItem));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除服务项目")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        serviceItemService.delete(id);
        return ApiResponse.success();
    }
}
