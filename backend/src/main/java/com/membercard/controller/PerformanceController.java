package com.membercard.controller;

import com.membercard.dto.ApiResponse;
import com.membercard.service.PerformanceService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 业绩统计控制器
 */
@RestController
@RequestMapping("/api/performance")
@RequiredArgsConstructor
public class PerformanceController {

    private final PerformanceService performanceService;

    /**
     * 员工业绩查询
     */
    @GetMapping("/staff")
    public ApiResponse<List<Map<String, Object>>> staffPerformance(
            @RequestParam(required = false) Long staffId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        List<Map<String, Object>> data = performanceService.getStaffPerformance(staffId, startDate, endDate);
        return ApiResponse.success(data);
    }

    /**
     * 门店业绩查询
     */
    @GetMapping("/store")
    public ApiResponse<List<Map<String, Object>>> storePerformance(
            @RequestParam(required = false) Long storeId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        List<Map<String, Object>> data = performanceService.getStorePerformance(storeId, startDate, endDate);
        return ApiResponse.success(data);
    }

    /**
     * 员工提成计算
     */
    @GetMapping("/commission")
    public ApiResponse<List<Map<String, Object>>> calculateCommission(
            @RequestParam Long staffId,
            @RequestParam String startDate,
            @RequestParam String endDate) {
        List<Map<String, Object>> data = performanceService.calculateCommission(staffId, startDate, endDate);
        return ApiResponse.success(data);
    }

    /**
     * 业绩排行榜
     */
    @GetMapping("/ranking")
    public ApiResponse<List<Map<String, Object>>> ranking(
            @RequestParam(required = false) Long storeId,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(defaultValue = "10") Integer top) {
        List<Map<String, Object>> data = performanceService.getPerformanceRanking(storeId, startDate, endDate, top);
        return ApiResponse.success(data);
    }
}
