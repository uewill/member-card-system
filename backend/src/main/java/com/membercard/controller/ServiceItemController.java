package com.membercard.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.dto.ApiResponse;
import com.membercard.entity.ServiceItem;
import com.membercard.service.ServiceItemService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 服务项目管理控制器
 */
@RestController
@RequestMapping("/api/service-item")
@RequiredArgsConstructor
public class ServiceItemController {

    private final ServiceItemService serviceItemService;

    /**
     * 创建服务项目
     */
    @PostMapping
    public ApiResponse<ServiceItem> create(@RequestBody ServiceItem serviceItem) {
        ServiceItem created = serviceItemService.create(serviceItem);
        return ApiResponse.success(created);
    }

    /**
     * 更新服务项目
     */
    @PutMapping("/{id}")
    public ApiResponse<ServiceItem> update(@PathVariable Long id, @RequestBody ServiceItem serviceItem) {
        serviceItem.setId(id);
        ServiceItem updated = serviceItemService.update(serviceItem);
        return ApiResponse.success(updated);
    }

    /**
     * 获取服务项目详情
     */
    @GetMapping("/{id}")
    public ApiResponse<ServiceItem> getById(@PathVariable Long id) {
        ServiceItem item = serviceItemService.getById(id);
        return ApiResponse.success(item);
    }

    /**
     * 分页查询服务项目列表
     */
    @GetMapping("/page")
    public ApiResponse<Page<ServiceItem>> page(@RequestParam(defaultValue = "1") Integer current,
                                               @RequestParam(defaultValue = "10") Integer size,
                                               @RequestParam(required = false) String category,
                                               @RequestParam(required = false) String name,
                                               @RequestParam(required = false) Integer status) {
        Page<ServiceItem> page = serviceItemService.page(current, size, category, name, status);
        return ApiResponse.success(page);
    }

    /**
     * 获取所有启用的服务项目列表
     */
    @GetMapping("/list")
    public ApiResponse<List<ServiceItem>> listActive(@RequestParam(required = false) String category) {
        List<ServiceItem> list = serviceItemService.listActive(category);
        return ApiResponse.success(list);
    }

    /**
     * 启用/停用服务项目
     */
    @PutMapping("/{id}/status")
    public ApiResponse<Void> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        serviceItemService.updateStatus(id, status);
        return ApiResponse.success();
    }
}
