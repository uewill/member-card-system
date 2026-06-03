package com.membercard.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.dto.ApiResponse;
import com.membercard.entity.User;
import com.membercard.service.EmployeeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 员工管理控制器
 */
@RestController
@RequestMapping("/api/employee")
@RequiredArgsConstructor
public class EmployeeController {

    private final EmployeeService employeeService;

    /**
     * 创建员工
     */
    @PostMapping
    public ApiResponse<User> create(@RequestBody User user) {
        User created = employeeService.create(user);
        return ApiResponse.success(created);
    }

    /**
     * 更新员工信息
     */
    @PutMapping("/{id}")
    public ApiResponse<User> update(@PathVariable Long id, @RequestBody User user) {
        user.setId(id);
        User updated = employeeService.update(user);
        return ApiResponse.success(updated);
    }

    /**
     * 获取员工详情
     */
    @GetMapping("/{id}")
    public ApiResponse<User> getById(@PathVariable Long id) {
        User user = employeeService.getById(id);
        return ApiResponse.success(user);
    }

    /**
     * 分页查询员工列表
     */
    @GetMapping("/page")
    public ApiResponse<Page<User>> page(@RequestParam(defaultValue = "1") Integer current,
                                          @RequestParam(defaultValue = "10") Integer size,
                                          @RequestParam(required = false) Long storeId,
                                          @RequestParam(required = false) String role,
                                          @RequestParam(required = false) String name,
                                          @RequestParam(required = false) Integer status) {
        Page<User> page = employeeService.page(current, size, storeId, role, name, status);
        return ApiResponse.success(page);
    }

    /**
     * 获取所有启用的员工列表
     */
    @GetMapping("/list")
    public ApiResponse<List<User>> listActive(@RequestParam(required = false) Long storeId) {
        List<User> list = employeeService.listActive(storeId);
        return ApiResponse.success(list);
    }

    /**
     * 邀请员工（生成邀请码/链接）
     */
    @PostMapping("/invite")
    public ApiResponse<Map<String, Object>> invite(@RequestBody Map<String, Object> inviteRequest) {
        Map<String, Object> result = employeeService.invite(inviteRequest);
        return ApiResponse.success(result);
    }

    /**
     * 分配角色
     */
    @PutMapping("/{id}/role")
    public ApiResponse<Void> assignRole(@PathVariable Long id, @RequestParam String role) {
        employeeService.assignRole(id, role);
        return ApiResponse.success();
    }

    /**
     * 启用/停用员工
     */
    @PutMapping("/{id}/status")
    public ApiResponse<Void> updateStatus(@PathVariable Long id, @RequestParam Integer status) {
        employeeService.updateStatus(id, status);
        return ApiResponse.success();
    }
}
