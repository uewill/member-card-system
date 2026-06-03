package com.membercard.controller;

import com.membercard.dto.ApiResponse;
import com.membercard.service.ReportService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 报表中心控制器
 */
@RestController
@RequestMapping("/api/report")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    /**
     * 营业报表（日/周/月）
     */
    @GetMapping("/business")
    public ApiResponse<Map<String, Object>> businessReport(
            @RequestParam String startDate,
            @RequestParam String endDate,
            @RequestParam(required = false) Long storeId,
            @RequestParam(required = false) String groupBy) {
        Map<String, Object> report = reportService.getBusinessReport(startDate, endDate, storeId, groupBy);
        return ApiResponse.success(report);
    }

    /**
     * 套餐分析报表
     */
    @GetMapping("/package")
    public ApiResponse<List<Map<String, Object>>> packageReport(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        List<Map<String, Object>> report = reportService.getPackageReport(startDate, endDate);
        return ApiResponse.success(report);
    }

    /**
     * 会员分析报表
     */
    @GetMapping("/member")
    public ApiResponse<Map<String, Object>> memberReport(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        Map<String, Object> report = reportService.getMemberReport(startDate, endDate);
        return ApiResponse.success(report);
    }

    /**
     * 收入趋势
     */
    @GetMapping("/revenue-trend")
    public ApiResponse<List<Map<String, Object>>> revenueTrend(
            @RequestParam String startDate,
            @RequestParam String endDate,
            @RequestParam(defaultValue = "day") String granularity) {
        List<Map<String, Object>> trend = reportService.getRevenueTrend(startDate, endDate, granularity);
        return ApiResponse.success(trend);
    }

    /**
     * 服务项目排行
     */
    @GetMapping("/service-ranking")
    public ApiResponse<List<Map<String, Object>>> serviceRanking(
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate,
            @RequestParam(defaultValue = "10") Integer top) {
        List<Map<String, Object>> ranking = reportService.getServiceRanking(startDate, endDate, top);
        return ApiResponse.success(ranking);
    }
}
