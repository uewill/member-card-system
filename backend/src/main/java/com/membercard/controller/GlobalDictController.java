package com.membercard.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.dto.ApiResponse;
import com.membercard.entity.Tenant;
import com.membercard.service.GlobalDictService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 全局字典管理控制器
 */
@RestController
@RequestMapping("/api/dict")
@RequiredArgsConstructor
public class GlobalDictController {

    private final GlobalDictService globalDictService;

    /**
     * 新增字典项
     */
    @PostMapping
    public ApiResponse<Void> create(@RequestBody Map<String, Object> dict) {
        globalDictService.create(dict);
        return ApiResponse.success();
    }

    /**
     * 更新字典项
     */
    @PutMapping("/{id}")
    public ApiResponse<Void> update(@PathVariable Long id, @RequestBody Map<String, Object> dict) {
        globalDictService.update(id, dict);
        return ApiResponse.success();
    }

    /**
     * 删除字典项
     */
    @DeleteMapping("/{id}")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        globalDictService.delete(id);
        return ApiResponse.success();
    }

    /**
     * 根据字典类型查询字典列表
     */
    @GetMapping("/type/{dictType}")
    public ApiResponse<List<Map<String, Object>>> getByType(@PathVariable String dictType) {
        List<Map<String, Object>> list = globalDictService.getByType(dictType);
        return ApiResponse.success(list);
    }

    /**
     * 分页查询字典列表
     */
    @GetMapping("/page")
    public ApiResponse<Page<Map<String, Object>>> page(@RequestParam(defaultValue = "1") Integer current,
                                                       @RequestParam(defaultValue = "10") Integer size,
                                                       @RequestParam(required = false) String dictType) {
        Page<Map<String, Object>> page = globalDictService.page(current, size, dictType);
        return ApiResponse.success(page);
    }
}
