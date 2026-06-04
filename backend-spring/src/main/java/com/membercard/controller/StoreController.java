package com.membercard.controller;

import com.membercard.common.ApiResponse;
import com.membercard.entity.Store;
import com.membercard.service.StoreService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 门店管理控制器
 */
@RestController
@RequestMapping("/api/v1/stores")
@Tag(name = "门店管理", description = "门店增删改查接口")
public class StoreController {

    private final StoreService storeService;

    public StoreController(StoreService storeService) {
        this.storeService = storeService;
    }

    @GetMapping
    @Operation(summary = "获取所有门店")
    public ApiResponse<List<Store>> findAll() {
        return ApiResponse.success(storeService.findAll());
    }

    @GetMapping("/enabled")
    @Operation(summary = "获取启用的门店")
    public ApiResponse<List<Store>> findEnabled() {
        return ApiResponse.success(storeService.findEnabled());
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取门店详情")
    public ApiResponse<Store> findById(@PathVariable Long id) {
        return ApiResponse.success(storeService.findById(id));
    }

    @PostMapping
    @Operation(summary = "创建门店")
    public ApiResponse<Store> create(@RequestBody Store store) {
        return ApiResponse.success(storeService.create(store));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新门店")
    public ApiResponse<Store> update(@PathVariable Long id, @RequestBody Store store) {
        store.setId(id);
        return ApiResponse.success(storeService.update(store));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除门店")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        storeService.delete(id);
        return ApiResponse.success();
    }
}
