package com.membercard.controller;

import com.membercard.dto.ApiResponse;
import com.membercard.dto.ConsumeRequest;
import com.membercard.dto.ConsumeResult;
import com.membercard.service.ConsumeService;
import javax.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * 消费核销控制器
 */
@RestController
@RequestMapping("/api/consume")
@RequiredArgsConstructor
public class ConsumeController {

    private final ConsumeService consumeService;

    /**
     * 快速核销（自动匹配最优卡）
     */
    @PostMapping("/quick")
    public ApiResponse<ConsumeResult> quickConsume(@Valid @RequestBody ConsumeRequest request) {
        ConsumeResult result = consumeService.quickConsume(request);
        return ApiResponse.success(result);
    }

    /**
     * 指定卡核销
     */
    @PostMapping("/deduct")
    public ApiResponse<ConsumeResult> deduct(@Valid @RequestBody ConsumeRequest request) {
        ConsumeResult result = consumeService.consumeWithCard(request);
        return ApiResponse.success(result);
    }

    /**
     * 多卡组合支付核销
     */
    @PostMapping("/combine")
    public ApiResponse<ConsumeResult> combineConsume(@Valid @RequestBody ConsumeRequest request) {
        ConsumeResult result = consumeService.combineConsume(request);
        return ApiResponse.success(result);
    }

    /**
     * 撤销核销
     */
    @PostMapping("/cancel/{orderNo}")
    public ApiResponse<Void> cancel(@PathVariable String orderNo) {
        consumeService.cancelConsume(orderNo);
        return ApiResponse.success();
    }

    /**
     * 获取核销记录详情
     */
    @GetMapping("/order/{orderNo}")
    public ApiResponse<Map<String, Object>> getOrderDetail(@PathVariable String orderNo) {
        Map<String, Object> detail = consumeService.getOrderDetail(orderNo);
        return ApiResponse.success(detail);
    }
}
