package com.membercard.entity;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 消费明细实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConsumeDetail {
    private Long id;
    private Long tenantId;
    private Long orderId;
    private Long serviceItemId;
    private Long cardId;
    /** count/balance */
    private String deductionType;
    /** 扣减次数 */
    private Integer deductionCount;
    /** 扣减金额 */
    private BigDecimal deductionAmount;
    /** 扣减前快照JSON */
    private String beforeSnapshotJson;
    /** 扣减后快照JSON */
    private String afterSnapshotJson;
    /** 员工业绩分配比例JSON */
    private String employeeRatioJson;
    private LocalDateTime createdAt;
}
