package com.membercard.controller;

import com.membercard.common.ApiResponse;
import com.membercard.entity.Employee;
import com.membercard.entity.Store;
import com.membercard.service.EmployeeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 员工管理控制器
 */
@RestController
@RequestMapping("/api/v1/employees")
@Tag(name = "员工管理", description = "员工增删改查接口")
public class EmployeeController {

    private final EmployeeService employeeService;

    public EmployeeController(EmployeeService employeeService) {
        this.employeeService = employeeService;
    }

    @GetMapping
    @Operation(summary = "获取所有员工")
    public ApiResponse<List<Employee>> findAll() {
        return ApiResponse.success(employeeService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取员工详情")
    public ApiResponse<Employee> findById(@PathVariable Long id) {
        return ApiResponse.success(employeeService.findById(id));
    }

    @GetMapping("/role/{role}")
    @Operation(summary = "按角色获取员工")
    public ApiResponse<List<Employee>> findByRole(@PathVariable String role) {
        return ApiResponse.success(employeeService.findByRole(role));
    }

    @GetMapping("/{id}/stores")
    @Operation(summary = "获取员工关联的门店")
    public ApiResponse<List<Store>> findEmployeeStores(@PathVariable Long id) {
        return ApiResponse.success(employeeService.findStoresByEmployeeId(id));
    }

    @PostMapping
    @Operation(summary = "创建员工")
    public ApiResponse<Employee> create(@RequestBody Employee employee) {
        return ApiResponse.success(employeeService.create(employee));
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新员工")
    public ApiResponse<Employee> update(@PathVariable Long id, @RequestBody Employee employee) {
        employee.setId(id);
        return ApiResponse.success(employeeService.update(employee));
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除员工")
    public ApiResponse<Void> delete(@PathVariable Long id) {
        employeeService.delete(id);
        return ApiResponse.success();
    }

    @PostMapping("/{employeeId}/stores/{storeId}")
    @Operation(summary = "分配员工到门店")
    public ApiResponse<Void> assignStore(@PathVariable Long employeeId, @PathVariable Long storeId) {
        employeeService.assignStore(employeeId, storeId);
        return ApiResponse.success();
    }
}
