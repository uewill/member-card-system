package com.membercard.controller;

import com.membercard.common.ApiResponse;
import com.membercard.entity.PerformanceRecord;
import com.membercard.service.PerformanceService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

/**
 * 业绩管理控制器
 */
@RestController
@RequestMapping("/api/v1/performance")
@Tag(name = "业绩管理", description = "员工业绩查询接口")
public class PerformanceController {

    private final PerformanceService performanceService;

    public PerformanceController(PerformanceService performanceService) {
        this.performanceService = performanceService;
    }

    @GetMapping("/employee/{employeeId}")
    @Operation(summary = "获取员工业绩记录")
    public ApiResponse<List<PerformanceRecord>> findByEmployeeId(@PathVariable Long employeeId) {
        return ApiResponse.success(performanceService.findByEmployeeId(employeeId));
    }

    @GetMapping("/store/{storeId}")
    @Operation(summary = "获取门店业绩记录")
    public ApiResponse<List<PerformanceRecord>> findByStoreId(@PathVariable Long storeId) {
        return ApiResponse.success(performanceService.findByStoreId(storeId));
    }

    @GetMapping("/date/{date}")
    @Operation(summary = "按日期查询业绩")
    public ApiResponse<List<PerformanceRecord>> findByDate(
            @PathVariable @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date) {
        return ApiResponse.success(performanceService.findByDate(date));
    }

    @GetMapping("/range")
    @Operation(summary = "按日期范围查询业绩")
    public ApiResponse<List<PerformanceRecord>> findByDateRange(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate) {
        return ApiResponse.success(performanceService.findByDateRange(startDate, endDate));
    }
}
