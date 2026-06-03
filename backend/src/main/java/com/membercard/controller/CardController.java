package com.membercard.controller;

import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.membercard.dto.ApiResponse;
import com.membercard.dto.CardMatchResult;
import com.membercard.dto.ConsumeRequest;
import com.membercard.dto.ConsumeResult;
import com.membercard.entity.MemberCard;
import com.membercard.service.CardService;
import com.membercard.service.ConsumeService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 卡实例管理控制器
 */
@RestController
@RequestMapping("/api/card")
@RequiredArgsConstructor
public class CardController {

    private final CardService cardService;

    /**
     * 获取卡实例详情
     */
    @GetMapping("/{id}")
    public ApiResponse<MemberCard> getById(@PathVariable Long id) {
        MemberCard card = cardService.getById(id);
        return ApiResponse.success(card);
    }

    /**
     * 分页查询会员的卡实例列表
     */
    @GetMapping("/page")
    public ApiResponse<Page<MemberCard>> page(@RequestParam Long memberId,
                                                @RequestParam(defaultValue = "1") Integer current,
                                                @RequestParam(defaultValue = "10") Integer size,
                                                @RequestParam(required = false) String status) {
        Page<MemberCard> page = cardService.page(memberId, current, size, status);
        return ApiResponse.success(page);
    }

    /**
     * 获取会员的所有有效卡列表
     */
    @GetMapping("/member/{memberId}/active")
    public ApiResponse<List<MemberCard>> listActiveCards(@PathVariable Long memberId) {
        List<MemberCard> list = cardService.listActiveCards(memberId);
        return ApiResponse.success(list);
    }

    /**
     * 冻结/解冻卡实例
     */
    @PutMapping("/{id}/freeze")
    public ApiResponse<Void> freeze(@PathVariable Long id, @RequestParam String action) {
        cardService.freeze(id, action);
        return ApiResponse.success();
    }

    /**
     * 最优卡匹配（为会员+服务项目匹配最优卡）
     */
    @GetMapping("/match")
    public ApiResponse<List<CardMatchResult>> matchCards(@RequestParam Long memberId,
                                                          @RequestParam Long serviceItemId) {
        List<CardMatchResult> results = cardService.matchCards(memberId, serviceItemId);
        return ApiResponse.success(results);
    }

    /**
     * 获取卡实例统计
     */
    @GetMapping("/stats")
    public ApiResponse<Map<String, Object>> stats() {
        Map<String, Object> stats = cardService.getCardStats();
        return ApiResponse.success(stats);
    }
}
