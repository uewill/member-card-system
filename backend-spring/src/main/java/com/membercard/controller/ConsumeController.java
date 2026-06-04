package com.membercard.controller;

import com.membercard.common.ApiResponse;
import com.membercard.dto.ConsumeRequest;
import com.membercard.entity.ConsumeDetail;
import com.membercard.entity.ConsumeOrder;
import com.membercard.service.ConsumeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.util.List;

/**
 * 消费管理控制器
 */
@RestController
@RequestMapping("/api/v1/consume-orders")
@Tag(name = "消费管理", description = "消费订单管理接口")
public class ConsumeController {

    private final ConsumeService consumeService;

    public ConsumeController(ConsumeService consumeService) {
        this.consumeService = consumeService;
    }

    @GetMapping
    @Operation(summary = "获取所有消费订单")
    public ApiResponse<List<ConsumeOrder>> findAll() {
        return ApiResponse.success(consumeService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取消费订单详情")
    public ApiResponse<ConsumeOrder> findById(@PathVariable Long id) {
        return ApiResponse.success(consumeService.findById(id));
    }

    @GetMapping("/{id}/details")
    @Operation(summary = "获取消费订单明细")
    public ApiResponse<List<ConsumeDetail>> findDetails(@PathVariable Long id) {
        return ApiResponse.success(consumeService.findDetailsByOrderId(id));
    }

    @GetMapping("/member/{memberId}")
    @Operation(summary = "获取会员的消费记录")
    public ApiResponse<List<ConsumeOrder>> findByMemberId(@PathVariable Long memberId) {
        return ApiResponse.success(consumeService.findByMemberId(memberId));
    }

    @PostMapping
    @Operation(summary = "创建消费订单")
    public ApiResponse<ConsumeOrder> create(@Valid @RequestBody ConsumeRequest request) {
        return ApiResponse.success(consumeService.createOrder(request));
    }

    @PostMapping("/{id}/cancel")
    @Operation(summary = "取消消费订单")
    public ApiResponse<Void> cancel(@PathVariable Long id) {
        consumeService.cancelOrder(id);
        return ApiResponse.success();
    }
}
