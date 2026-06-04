package com.membercard.controller;

import com.membercard.common.ApiResponse;
import com.membercard.dto.RechargeRequest;
import com.membercard.entity.PaymentRecord;
import com.membercard.service.PaymentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

/**
 * 支付管理控制器
 */
@RestController
@RequestMapping("/api/v1/payments")
@Tag(name = "支付管理", description = "支付记录及充值接口")
public class PaymentController {

    private final PaymentService paymentService;

    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    @GetMapping
    @Operation(summary = "获取所有支付记录")
    public ApiResponse<List<PaymentRecord>> findAll() {
        return ApiResponse.success(paymentService.findAll());
    }

    @GetMapping("/store/{storeId}")
    @Operation(summary = "获取门店支付记录")
    public ApiResponse<List<PaymentRecord>> findByStoreId(@PathVariable Long storeId) {
        return ApiResponse.success(paymentService.findByStoreId(storeId));
    }

    @GetMapping("/type/{type}")
    @Operation(summary = "按类型获取支付记录")
    public ApiResponse<List<PaymentRecord>> findByType(@PathVariable String type) {
        return ApiResponse.success(paymentService.findByType(type));
    }

    @PostMapping("/recharge")
    @Operation(summary = "充值")
    public ApiResponse<PaymentRecord> recharge(@Valid @RequestBody RechargeRequest request) {
        return ApiResponse.success(paymentService.recharge(request));
    }
}
