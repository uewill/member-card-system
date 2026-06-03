package com.membercard.controller;

import com.membercard.dto.ApiResponse;
import com.membercard.service.TenantService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 平台运营监控控制器
 */
@RestController
@RequestMapping("/api/platform/stats")
@RequiredArgsConstructor
public class PlatformStatsController {

    private final TenantService tenantService;

    /**
     * 平台总览数据
     */
    @GetMapping("/overview")
    public ApiResponse<Map<String, Object>> overview() {
        Map<String, Object> data = tenantService.getPlatformOverview();
        return ApiResponse.success(data);
    }

    /**
     * 租户统计排行
     */
    @GetMapping("/tenant-ranking")
    public ApiResponse<List<Map<String, Object>>> tenantRanking(@RequestParam(defaultValue = "10") Integer top) {
        List<Map<String, Object>> data = tenantService.getTenantRanking(top);
        return ApiResponse.success(data);
    }

    /**
     * 行业分布统计
     */
    @GetMapping("/industry-distribution")
    public ApiResponse<List<Map<String, Object>>> industryDistribution() {
        List<Map<String, Object>> data = tenantService.getIndustryDistribution();
        return ApiResponse.success(data);
    }
}
