package com.membercard.entity;

import lombok.Data;
import lombok.Builder;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

/**
 * 业绩记录实体
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PerformanceRecord {
    private Long id;
    private Long tenantId;
    private Long employeeId;
    private Long storeId;
    /** 日期 */
    private LocalDate date;
    /** 服务次数 */
    private Integer serviceCount;
    /** 服务金额 */
    private BigDecimal serviceAmount;
    /** 提成 */
    private BigDecimal commission;
    private LocalDateTime createdAt;
}
