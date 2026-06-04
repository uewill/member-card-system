package com.membercard.entity;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * 消费订单实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ConsumeOrder {
    private Long id;
    private Long tenantId;
    private Long storeId;
    private Long memberId;
    /** 总金额 */
    private BigDecimal totalAmount;
    /** 实付金额 */
    private BigDecimal actualPaid;
    /** 支付方式JSON */
    private String paymentMethodsJson;
    /** 操作员工ID */
    private Long employeeId;
    /** normal/cancelled */
    private String status;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
