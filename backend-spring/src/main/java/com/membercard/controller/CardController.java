package com.membercard.controller;

import com.membercard.common.ApiResponse;
import com.membercard.entity.MemberCard;
import com.membercard.service.CardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;

/**
 * 会员卡管理控制器
 */
@RestController
@RequestMapping("/api/v1/cards")
@Tag(name = "会员卡管理", description = "会员卡增删改查及操作接口")
public class CardController {

    private final CardService cardService;

    public CardController(CardService cardService) {
        this.cardService = cardService;
    }

    @GetMapping
    @Operation(summary = "获取所有会员卡")
    public ApiResponse<List<MemberCard>> findAll() {
        return ApiResponse.success(cardService.findAll());
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取会员卡详情")
    public ApiResponse<MemberCard> findById(@PathVariable Long id) {
        return ApiResponse.success(cardService.findById(id));
    }

    @GetMapping("/member/{memberId}")
    @Operation(summary = "获取会员的所有卡")
    public ApiResponse<List<MemberCard>> findByMemberId(@PathVariable Long memberId) {
        return ApiResponse.success(cardService.findByMemberId(memberId));
    }

    @GetMapping("/member/{memberId}/active")
    @Operation(summary = "获取会员的有效卡")
    public ApiResponse<List<MemberCard>> findActiveByMemberId(@PathVariable Long memberId) {
        return ApiResponse.success(cardService.findActiveByMemberId(memberId));
    }

    @PostMapping("/sell")
    @Operation(summary = "售卡")
    public ApiResponse<MemberCard> sellCard(@RequestParam Long memberId, @RequestParam Long packageId) {
        return ApiResponse.success(cardService.sellCard(memberId, packageId));
    }

    @PostMapping("/{id}/recharge")
    @Operation(summary = "储值卡充值")
    public ApiResponse<MemberCard> recharge(@PathVariable Long id, @RequestParam BigDecimal amount) {
        return ApiResponse.success(cardService.recharge(id, amount));
    }

    @PostMapping("/{id}/freeze")
    @Operation(summary = "冻结会员卡")
    public ApiResponse<Void> freeze(@PathVariable Long id) {
        cardService.freeze(id);
        return ApiResponse.success();
    }

    @PostMapping("/{id}/unfreeze")
    @Operation(summary = "解冻会员卡")
    public ApiResponse<Void> unfreeze(@PathVariable Long id) {
        cardService.unfreeze(id);
        return ApiResponse.success();
    }
}
