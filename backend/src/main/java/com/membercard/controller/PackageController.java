package com.membercard.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.dto.ApiResponse;
import com.membercard.entity.PackageTemplate;
import com.membercard.service.PackageService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 套餐管理控制器
 */
@RestController
@RequestMapping("/api/package")
@RequiredArgsConstructor
public class PackageController {

    private final PackageService packageService;

    /**
     * 创建套餐模板
     */
    @PostMapping
    public ApiResponse<PackageTemplate> create(@RequestBody PackageTemplate packageTemplate) {
        PackageTemplate created = packageService.create(packageTemplate);
        return ApiResponse.success(created);
    }

    /**
     * 更新套餐模板
     */
    @PutMapping("/{id}")
    public ApiResponse<PackageTemplate> update(@PathVariable Long id, @RequestBody PackageTemplate packageTemplate) {
        packageTemplate.setId(id);
        PackageTemplate updated = packageService.update(packageTemplate);
        return ApiResponse.success(updated);
    }

    /**
     * 获取套餐模板详情
     */
    @GetMapping("/{id}")
    public ApiResponse<PackageTemplate> getById(@PathVariable Long id) {
        PackageTemplate pkg = packageService.getById(id);
        return ApiResponse.success(pkg);
    }

    /**
     * 分页查询套餐模板列表
     */
    @GetMapping("/page")
    public ApiResponse<Page<PackageTemplate>> page(@RequestParam(defaultValue = "1") Integer current,
                                                    @RequestParam(defaultValue = "10") Integer size,
                                                    @RequestParam(required = false) String type,
                                                    @RequestParam(required = false) String name,
                                                    @RequestParam(required = false) Integer status) {
        Page<PackageTemplate> page = packageService.page(current, size, type, name, status);
        return ApiResponse.success(page);
    }

    /**
     * 获取所有启用的套餐模板列表
     */
    @GetMapping("/list")
    public ApiResponse<List<PackageTemplate>> listActive(@RequestParam(required = false) String type) {
        List<PackageTemplate> list = packageService.listActive(type);
        return ApiResponse.success(list);
    }

    /**
     * 启用/停用套餐模板
     */
    @PutMapping("/{id}/status")
    public ApiResponse<Void> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        packageService.updateStatus(id, status);
        return ApiResponse.success();
    }
}
