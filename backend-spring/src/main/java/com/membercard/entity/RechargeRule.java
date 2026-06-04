package com.membercard.entity;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 充值赠送规则实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RechargeRule {
    private Long id;
    private Long tenantId;
    /** 最低充值金额 */
    private BigDecimal minAmount;
    /** 赠送金额 */
    private BigDecimal bonusAmount;
    /** fixed/ratio */
    private String bonusType;
    /** 赠送比例(%) */
    private BigDecimal bonusRatio;
    /** enabled/disabled */
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
