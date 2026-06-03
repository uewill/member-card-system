package com.membercard.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.dto.ApiResponse;
import com.membercard.dto.RechargeRequest;
import com.membercard.entity.RechargeOrder;
import com.membercard.service.RechargeService;
import javax.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 充值/购卡控制器
 */
@RestController
@RequestMapping("/api/recharge")
@RequiredArgsConstructor
public class RechargeController {

    private final RechargeService rechargeService;

    /**
     * 售卖开卡 / 充值
     */
    @PostMapping
    public ApiResponse<Map<String, Object>> recharge(@Valid @RequestBody RechargeRequest request) {
        Map<String, Object> result = rechargeService.recharge(request);
        return ApiResponse.success(result);
    }

    /**
     * 获取充值订单详情
     */
    @GetMapping("/{id}")
    public ApiResponse<RechargeOrder> getById(@PathVariable Long id) {
        RechargeOrder order = rechargeService.getById(id);
        return ApiResponse.success(order);
    }

    /**
     * 分页查询充值订单列表
     */
    @GetMapping("/page")
    public ApiResponse<Page<RechargeOrder>> page(@RequestParam(defaultValue = "1") Integer current,
                                                  @RequestParam(defaultValue = "10") Integer size,
                                                  @RequestParam(required = false) Long memberId,
                                                  @RequestParam(required = false) String orderType,
                                                  @RequestParam(required = false) String paymentStatus) {
        Page<RechargeOrder> page = rechargeService.page(current, size, memberId, orderType, paymentStatus);
        return ApiResponse.success(page);
    }

    /**
     * 查询赠送规则
     */
    @GetMapping("/gift-rules")
    public ApiResponse<java.util.List<Map<String, Object>>> getGiftRules() {
        java.util.List<Map<String, Object>> rules = rechargeService.getGiftRules();
        return ApiResponse.success(rules);
    }

    /**
     * 计算赠送金额
     */
    @GetMapping("/calculate-gift")
    public ApiResponse<Map<String, Object>> calculateGift(@RequestParam java.math.BigDecimal amount) {
        Map<String, Object> result = rechargeService.calculateGift(amount);
        return ApiResponse.success(result);
    }
}
