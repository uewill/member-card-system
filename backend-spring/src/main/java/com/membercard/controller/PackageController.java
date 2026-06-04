package com.membercard.controller;

import com.membercard.common.ApiResponse;
import com.membercard.entity.PackageTemplate;
import com.membercard.service.PackageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 套餐管理控制器
 */
@RestController
@RequestMapping("/api/v1/packages")
@Tag(name = "套餐管理", description = "套餐模板增删改查接口")
public class PackageController {

    private final PackageService packageService;

    public PackageController(PackageService packageService) {
        this.packageService = packageService;
    }

    @GetMapping
    @Operation(summary = "获取所有套餐")
    public ApiResponse<List<PackageTemplate>> findAll() {
        return ApiResponse.success(packageService.findAll());
    }

    @GetMapping("/enabled")
    @Operation(summary = "获取启用的套餐")
    public ApiResponse<List<PackageTemplate>> findEnabled() {
        return ApiResponse.success(packageService.findEnabled());
    }

    @GetMapping("/type/{type}")
    @Operation(summary = "按类型获取套餐")
    public ApiResponse<List<PackageTemplate>> findByType(@PathVariable String type) {
        return ApiResponse.success(packageService.findByType(type));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取套餐详情")
    public ApiResponse<PackageTemplate> findById(@PathVariable Long id) {
        return ApiResponse.success(packageService.findById(id));
    }

    @PostMapping
    @Operation(summary = "创建套餐")
    public ApiResponse<PackageTemplate> create(@RequestBody PackageTemplate packageTemplate) {
        return ApiResponse.success(packageService.create(packageTemplate));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新套餐")
    public ApiResponse<PackageTemplate> update(@PathVariable Long id, @RequestBody PackageTemplate packageTemplate) {
        packageTemplate.setId(id);
        return ApiResponse.success(packageService.update(packageTemplate));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除套餐")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        packageService.delete(id);
        return ApiResponse.success();
    }
}
