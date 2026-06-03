package com.membercard.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.dto.ApiResponse;
import com.membercard.service.PointsService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 积分管理控制器
 */
@RestController
@RequestMapping("/api/points")
@RequiredArgsConstructor
public class PointsController {

    private final PointsService pointsService;

    /**
     * 获取会员积分余额
     */
    @GetMapping("/balance/{memberId}")
    public ApiResponse<Map<String, Object>> getBalance(@PathVariable Long memberId) {
        Map<String, Object> balance = pointsService.getBalance(memberId);
        return ApiResponse.success(balance);
    }

    /**
     * 积分变动记录
     */
    @GetMapping("/records")
    public ApiResponse<Page<Map<String, Object>>> records(
            @RequestParam Long memberId,
            @RequestParam(defaultValue = "1") Integer current,
            @RequestParam(defaultValue = "10") Integer size,
            @RequestParam(required = false) String source) {
        Page<Map<String, Object>> page = pointsService.getRecords(memberId, current, size, source);
        return ApiResponse.success(page);
    }

    /**
     * 增加积分（手动/赠送）
     */
    @PostMapping("/add")
    public ApiResponse<Void> addPoints(@RequestBody Map<String, Object> request) {
        Long memberId = Long.valueOf(request.get("memberId").toString());
        Integer points = Integer.valueOf(request.get("points").toString());
        String source = (String) request.getOrDefault("source", "GIFT");
        String remark = (String) request.getOrDefault("remark", "");
        pointsService.addPoints(memberId, points, source, remark);
        return ApiResponse.success();
    }

    /**
     * 扣减积分（兑换）
     */
    @PostMapping("/deduct")
    public ApiResponse<Void> deductPoints(@RequestBody Map<String, Object> request) {
        Long memberId = Long.valueOf(request.get("memberId").toString());
        Integer points = Integer.valueOf(request.get("points").toString());
        String remark = (String) request.getOrDefault("remark", "");
        pointsService.deductPoints(memberId, points, remark);
        return ApiResponse.success();
    }

    /**
     * 积分排行榜
     */
    @GetMapping("/ranking")
    public ApiResponse<List<Map<String, Object>>> ranking(@RequestParam(defaultValue = "10") Integer top) {
        List<Map<String, Object>> ranking = pointsService.getRanking(top);
        return ApiResponse.success(ranking);
    }
}
