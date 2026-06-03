package com.membercard.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.dto.ApiResponse;
import com.membercard.entity.Store;
import com.membercard.service.StoreService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 门店管理控制器
 */
@RestController
@RequestMapping("/api/store")
@RequiredArgsConstructor
public class StoreController {

    private final StoreService storeService;

    /**
     * 创建门店
     */
    @PostMapping
    public ApiResponse<Store> create(@RequestBody Store store) {
        Store created = storeService.create(store);
        return ApiResponse.success(created);
    }

    /**
     * 更新门店
     */
    @PutMapping("/{id}")
    public ApiResponse<Store> update(@PathVariable Long id, @RequestBody Store store) {
        store.setId(id);
        Store updated = storeService.update(store);
        return ApiResponse.success(updated);
    }

    /**
     * 获取门店详情
     */
    @GetMapping("/{id}")
    public ApiResponse<Store> getById(@PathVariable Long id) {
        Store store = storeService.getById(id);
        return ApiResponse.success(store);
    }

    /**
     * 分页查询门店列表
     */
    @GetMapping("/page")
    public ApiResponse<Page<Store>> page(@RequestParam(defaultValue = "1") Integer current,
                                           @RequestParam(defaultValue = "10") Integer size,
                                           @RequestParam(required = false) String storeName,
                                           @RequestParam(required = false) Integer status) {
        Page<Store> page = storeService.page(current, size, storeName, status);
        return ApiResponse.success(page);
    }

    /**
     * 获取所有启用的门店列表
     */
    @GetMapping("/list")
    public ApiResponse<List<Store>> listActive() {
        List<Store> list = storeService.listActive();
        return ApiResponse.success(list);
    }

    /**
     * 启用/停用门店
     */
    @PutMapping("/{id}/status")
    public ApiResponse<Void> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        storeService.updateStatus(id, status);
        return ApiResponse.success();
    }
}
