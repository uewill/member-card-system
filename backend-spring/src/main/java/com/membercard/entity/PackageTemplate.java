package com.membercard.entity;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 套餐模板实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PackageTemplate {
    private Long id;
    private Long tenantId;
    private String name;
    /** times_card/value_card/hybrid_card */
    private String type;
    /** 包含的服务项目JSON */
    private String serviceItemsJson;
    /** 服务次数JSON */
    private String serviceCountsJson;
    /** 本金金额 */
    private BigDecimal principalAmount;
    /** 赠送金额 */
    private BigDecimal bonusAmount;
    /** 售价 */
    private BigDecimal sellingPrice;
    /** days/fixed_date */
    private String validityType;
    /** 有效天数 */
    private Integer validityDays;
    /** 固定到期日 */
    private LocalDate expiryDate;
    /** 是否允许转卡 */
    private Integer allowTransfer;
    /** 是否允许折扣组合 */
    private Integer allowDiscountCombo;
    /** enabled/disabled */
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
