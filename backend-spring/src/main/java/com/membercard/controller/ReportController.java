package com.membercard.controller;

import com.membercard.common.ApiResponse;
import com.membercard.common.TenantContext;
import com.membercard.entity.*;
import com.membercard.mapper.*;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.*;

/**
 * 报表控制器
 */
@RestController
@RequestMapping("/api/v1/reports")
@Tag(name = "报表统计", description = "经营数据统计报表接口")
public class ReportController {

    private final MemberMapper memberMapper;
    private final MemberCardMapper memberCardMapper;
    private final ConsumeOrderMapper consumeOrderMapper;
    private final PaymentRecordMapper paymentRecordMapper;
    private final PerformanceRecordMapper performanceRecordMapper;

    public ReportController(MemberMapper memberMapper, MemberCardMapper memberCardMapper,
                           ConsumeOrderMapper consumeOrderMapper, PaymentRecordMapper paymentRecordMapper,
                           PerformanceRecordMapper performanceRecordMapper) {
        this.memberMapper = memberMapper;
        this.memberCardMapper = memberCardMapper;
        this.consumeOrderMapper = consumeOrderMapper;
        this.paymentRecordMapper = paymentRecordMapper;
        this.performanceRecordMapper = performanceRecordMapper;
    }

    @GetMapping("/dashboard")
    @Operation(summary = "获取仪表盘概览数据")
    public ApiResponse<Map<String, Object>> dashboard() {
        Long tenantId = TenantContext.getTenantId();
        Map<String, Object> data = new HashMap<>();

        // 会员总数
        List<Member> members = memberMapper.findByTenantId(tenantId);
        data.put("totalMembers", members.size());

        // 会员卡总数
        List<MemberCard> cards = memberCardMapper.findByTenantId(tenantId);
        data.put("totalCards", cards.size());
        data.put("activeCards", cards.stream().filter(c -> "active".equals(c.getStatus())).count());

        // 今日消费订单数
        List<ConsumeOrder> orders = consumeOrderMapper.findByTenantId(tenantId);
        data.put("totalOrders", orders.size());

        return ApiResponse.success(data);
    }

    @GetMapping("/sales")
    @Operation(summary = "获取销售统计")
    public ApiResponse<Map<String, Object>> salesReport(
            @RequestParam @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam @org.springframework.format.annotation.DateTimeFormat(iso = org.springframework.format.annotation.DateTimeFormat.ISO.DATE) LocalDate endDate) {
        Long tenantId = TenantContext.getTenantId();
        Map<String, Object> data = new HashMap<>();

        // 售卡收入
        BigDecimal sellCardIncome = paymentRecordMapper.sumByTypeAndDateRange(tenantId, "sell_card", startDate, endDate);
        data.put("sellCardIncome", sellCardIncome);

        // 充值收入
        BigDecimal rechargeIncome = paymentRecordMapper.sumByTypeAndDateRange(tenantId, "recharge", startDate, endDate);
        data.put("rechargeIncome", rechargeIncome);

        // 消费差额收入
        BigDecimal consumeDiffIncome = paymentRecordMapper.sumByTypeAndDateRange(tenantId, "consume_diff", startDate, endDate);
        data.put("consumeDiffIncome", consumeDiffIncome);

        // 总收入
        data.put("totalIncome", sellCardIncome.add(rechargeIncome).add(consumeDiffIncome));

        return ApiResponse.success(data);
    }

    @GetMapping("/members/stats")
    @Operation(summary = "获取会员统计")
    public ApiResponse<Map<String, Object>> memberStats() {
        Long tenantId = TenantContext.getTenantId();
        Map<String, Object> data = new HashMap<>();

        List<Member> members = memberMapper.findByTenantId(tenantId);
        data.put("totalMembers", members.size());

        List<MemberCard> cards = memberCardMapper.findByTenantId(tenantId);
        long activeCards = cards.stream().filter(c -> "active".equals(c.getStatus())).count();
        data.put("activeCards", activeCards);
        data.put("totalCardBalance", cards.stream()
                .filter(c -> "active".equals(c.getStatus()))
                .mapToDouble(c -> c.getPrincipalBalance().add(c.getBonusBalance()).doubleValue())
                .sum());

        return ApiResponse.success(data);
    }
}
