package com.membercard.dto;

import lombok.Data;

import java.math.BigDecimal;
import java.time.LocalDate;

/**
 * 卡匹配结果DTO - 用于返回最优卡匹配结果
 */
@Data
public class CardMatchResult {

    /**
     * 卡实例ID
     */
    private Long cardId;

    /**
     * 套餐模板ID
     */
    private Long templateId;

    /**
     * 套餐名称（从模板快照中获取）
     */
    private String templateName;

    /**
     * 卡类型: COUNT, VALUE, MIXED
     */
    private String cardType;

    /**
     * 该服务项目的剩余次数（仅COUNT/MIXED类型有意义）
     */
    private Integer remainingCount;

    /**
     * 剩余本金余额（仅VALUE/MIXED类型有意义）
     */
    private BigDecimal remainingPrincipal;

    /**
     * 剩余赠送余额（仅VALUE/MIXED类型有意义）
     */
    private BigDecimal remainingGift;

    /**
     * 剩余总余额
     */
    private BigDecimal remainingTotalBalance;

    /**
     * 到期日期
     */
    private LocalDate validTo;

    /**
     * 匹配优先级分数（越小越优先）
     */
    private Integer priorityScore;

    /**
     * 是否适用该服务项目
     */
    private Boolean applicable;

    /**
     * 扣减类型建议: COUNT 或 VALUE
     */
    private String suggestedDeductType;

    /**
     * 该服务项目对应的单次扣减金额（从模板快照中获取）
     */
    private BigDecimal deductAmountPerUse;
}
