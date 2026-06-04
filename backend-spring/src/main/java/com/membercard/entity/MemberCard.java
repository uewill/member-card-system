package com.membercard.entity;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 会员卡实例实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class MemberCard {
    private Long id;
    private Long tenantId;
    private Long memberId;
    /** 套餐快照JSON */
    private String packageSnapshotJson;
    /** times_card/value_card/hybrid_card */
    private String type;
    /** 剩余次数JSON */
    private String remainingCountsJson;
    /** 本金余额 */
    private BigDecimal principalBalance;
    /** 赠送余额 */
    private BigDecimal bonusBalance;
    /** 到期日 */
    private LocalDate expiryDate;
    /** active/expired/depleted/frozen/transferred */
    private String status;
    /** 卡号 */
    private String cardNo;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
